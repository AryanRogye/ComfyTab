//  Created by temoki just copy pasted over from the repo
//  https://github.com/temoki/lq
//  A bit of my own twist, I let it go through the pipeline

#include <metal_stdlib>
#include <SwiftUI/SwiftUI.h>
using namespace metal;

inline half4 applyKawaseBlurTex(texture2d<half> bgTex, sampler s,
                                float2 p, float2 uSize, float blurRadius) {
    if (blurRadius < 0.001) return bgTex.sample(s, p / uSize);
    
    half4 color = half4(0.0);
    float totalWeight = 0.0;
    float2 texelSize = 1.0 / uSize;
    float2 uv = p / uSize;
    
    float offset = blurRadius;
    
    float2 offsets1[4] = { float2(-offset,-offset), float2(offset,-offset),
        float2(-offset, offset), float2(offset, offset) };
    for (int i=0;i<4;i++){ color += bgTex.sample(s, uv + offsets1[i]*texelSize); totalWeight += 1.0; }
    
    float offset2 = offset * 1.5;
    float2 offsets2[4] = { float2(0,-offset2), float2(0,offset2),
        float2(-offset2,0), float2(offset2,0) };
    for (int i=0;i<4;i++){ color += bgTex.sample(s, uv + offsets2[i]*texelSize)*0.8; totalWeight += 0.8; }
    
    float offset3 = offset * 0.7;
    float2 offsets3[4] = { float2(-offset3,0), float2(offset3,0),
        float2(0,-offset3), float2(0,offset3) };
    for (int i=0;i<4;i++){ color += bgTex.sample(s, uv + offsets3[i]*texelSize)*0.6; totalWeight += 0.6; }
    
    color += bgTex.sample(s, uv) * 2.0; totalWeight += 2.0;
    
    return (totalWeight > 0.0) ? color / totalWeight : bgTex.sample(s, uv);
}

// Calculate height/depth of the liquid surface
float getHeight(float sd, float thickness) {
    if (sd >= 0.0 || thickness <= 0.0) {
        return 0.0;
    }
    if (sd < -thickness) {
        return thickness;
    }
    
    float x = thickness + sd;
    return sqrt(max(0.0, thickness * thickness - x * x));
}

// Calculate lighting effects based on displacement data
float3 calculateLighting(float3 normal, float height, float2 refractionDisplacement, float thickness, float lightAngle, float lightIntensity, float ambientStrength) {
    // Basic shape mask
    float normalizedHeight = thickness > 0.0 ? height / thickness : 0.0;
    float shape = smoothstep(0.0, 0.9, 1.0 - normalizedHeight);
    
    // If we're outside the shape, no lighting.
    if (shape < 0.01) {
        return float3(0.0);
    }
    
    float3 viewDir = float3(0.0, 0.0, 1.0);
    
    // --- Rim lighting (Fresnel) ---
    // This creates a constant, soft outline.
    float fresnel = pow(1.0 - max(0.0, dot(normal, viewDir)), 3.0);
    float3 rimLight = float3(fresnel * ambientStrength * 0.5);
    
    // --- Light-dependent effects ---
    float3 lightDir = normalize(float3(cos(lightAngle), sin(lightAngle), -0.7));
    float3 oppositeLightDir = normalize(float3(-lightDir.xy, lightDir.z));
    
    // Common vectors needed for both light sources
    float3 halfwayDir1 = normalize(lightDir + viewDir);
    float specDot1 = max(0.0, dot(normal, halfwayDir1));
    float3 halfwayDir2 = normalize(oppositeLightDir + viewDir);
    float specDot2 = max(0.0, dot(normal, halfwayDir2));
    
    // 1. Sharp surface glint (pure white)
    float glintExponent = mix(120.0, 200.0, smoothstep(5.0, 25.0, thickness));
    float sharpFactor = pow(specDot1, glintExponent) + 0.4 * pow(specDot2, glintExponent);
    
    // Pure white glint without environment tinting
    float3 sharpGlint = float3(sharpFactor) * lightIntensity * 2.5;
    
    // 2. Soft internal bleed, for a subtle "glow"
    float softFactor = pow(specDot1, 20.0) + 0.5 * pow(specDot2, 20.0);
    float3 softBleed = float3(softFactor) * lightIntensity * 0.4;
    
    // Combine lighting components
    float3 lighting = rimLight + sharpGlint + softBleed;
    
    // Final combination
    return lighting * shape;
}

// Apply glass color tinting to the liquid color
half4 applyGlassColor(half4 liquidColor, half4 glassColor) {
    half4 finalColor = liquidColor;
    
    if (glassColor.a > 0.0) {
        float glassLuminance = dot(glassColor.rgb, half3(0.299, 0.587, 0.114));
        
        if (glassLuminance < 0.5) {
            half3 darkened = liquidColor.rgb * (glassColor.rgb * 2.0);
            finalColor.rgb = mix(liquidColor.rgb, darkened, glassColor.a);
        } else {
            half3 invLiquid = half3(1.0) - liquidColor.rgb;
            half3 invGlass = half3(1.0) - glassColor.rgb;
            half3 screened = half3(1.0) - (invLiquid * invGlass);
            finalColor.rgb = mix(liquidColor.rgb, screened, glassColor.a);
        }
        
        finalColor.a = liquidColor.a;
    }
    
    return finalColor;
}

inline half4 calculateRefractionTex(
                                    float2 p, float3 normal, float height, float thickness,
                                    float refractiveIndex, float chromaticAberration, float2 uSize,
                                    texture2d<half> bgTex, sampler s, float blurRadius,
                                    thread float2 &refractionDisplacement
                                    ){
    float baseHeight = thickness * 8.0;
    float3 incident = float3(0.0, 0.0, -1.0);
    
    if (chromaticAberration > 0.001) {
        float iorR = refractiveIndex - chromaticAberration * 0.04;
        float iorG = refractiveIndex;
        float iorB = refractiveIndex + chromaticAberration * 0.08;
        
        float3 refrR = refract(incident, normal, 1.0 / iorR);
        float lenR = (height + baseHeight) / max(0.001, fabs(refrR.z));
        float2 uvR = (p + refrR.xy * lenR);
        
        float3 refrG = refract(incident, normal, 1.0 / iorG);
        float lenG = (height + baseHeight) / max(0.001, fabs(refrG.z));
        refractionDisplacement = refrG.xy * lenG;
        float2 uvG = p + refractionDisplacement;
        
        float3 refrB = refract(incident, normal, 1.0 / iorB);
        float lenB = (height + baseHeight) / max(0.001, fabs(refrB.z));
        float2 uvB = p + refrB.xy * lenB;
        
        half red   = applyKawaseBlurTex(bgTex, s, uvR, uSize, blurRadius).r;
        half4 gSmp = applyKawaseBlurTex(bgTex, s, uvG, uSize, blurRadius);
        half blue  = applyKawaseBlurTex(bgTex, s, uvB, uSize, blurRadius).b;
        
        return half4(red, gSmp.g, blue, gSmp.a);
    } else {
        float3 refr = refract(incident, normal, 1.0 / refractiveIndex);
        float len   = (height + baseHeight) / max(0.001, fabs(refr.z));
        refractionDisplacement = refr.xy * len;
        float2 uv = p + refractionDisplacement;
        return applyKawaseBlurTex(bgTex, s, uv, uSize, blurRadius);
    }
}

inline half4 renderLiquidGlassTex(
                                  float2 p, float2 uSize, float sd, float thickness, float refractiveIndex, float chromaticAberration,
                                  half4 glassColor, float lightAngle, float lightIntensity, float ambientStrength,
                                  texture2d<half> bgTex, sampler s, float3 normal, float foregroundAlpha,
                                  float blurRadius, float isRefractionEnabled, float isLightingEnabled,
                                  float isGlassColorEnabled, float isBlurEnabled
                                  ){
    if (foregroundAlpha < 0.001) return bgTex.sample(s, p / uSize);
    if (thickness < 0.01)        return bgTex.sample(s, p / uSize);
    
    float height = getHeight(sd, thickness);
    
    float2 refDisp = float2(0.0);
    half4 refractColor;
    if (isRefractionEnabled > 0.5) {
        refractColor = calculateRefractionTex(
                                              p, normal, height, thickness, refractiveIndex, chromaticAberration,
                                              uSize, bgTex, s, (isBlurEnabled > 0.5 ? blurRadius : 0.0), refDisp
                                              );
    } else {
        refractColor = (isBlurEnabled > 0.5)
        ? applyKawaseBlurTex(bgTex, s, p, uSize, blurRadius)
        : bgTex.sample(s, p / uSize);
    }
    
    half4 liquidColor = refractColor;
    
    float3 lighting = (isLightingEnabled > 0.5)
    ? calculateLighting(normal, height, refDisp, thickness, lightAngle, lightIntensity, ambientStrength)
    : float3(0.0);
    
    half4 finalColor = (isGlassColorEnabled > 0.5)
    ? applyGlassColor(liquidColor, glassColor)
    : liquidColor;
    
    finalColor.rgb += half3(lighting);
    
    half4 bg = bgTex.sample(s, p / uSize);
    return mix(bg, finalColor, foregroundAlpha);
}


inline float sdfCircle(float2 p, float r) { return length(p) - r; }

// ring signed distance: outside outer → +, inside inner hole → +, ring interior → -
inline float sdfRing(float2 p, float ro, float ri) {
    float dOuter = sdfCircle(p, ro);
    float dInner = -sdfCircle(p, ri);
    return max(dOuter, dInner);
}

struct VSOut {
    float4 pos [[position]];
    float2 uv;
};

struct Uniforms {
    float2 size;          // drawable size in pixels
    float4 glassColor;    // rgba 0..1
    float  lightAngle;
    float  lightIntensity;
    float  ambient;
    float  thickness;
    float  refrIdx;
    float  blurRadius;
    float  chromAb;
    float4 flags;         // x:refraction, y:lighting, z:glassColor, w:blur (1/0)
    
    // ring shape (screen space pixels)
    float2 center;        // ring center in pixels
    float  outerRadius;   // pixels
    float  innerRadius;   // pixels (0 for a solid disk)
};

vertex VSOut fullscreenVertex(uint vid [[vertex_id]]) {
    // Big triangle trick: covers the whole screen with 3 verts
    float2 positions[3] = {
        float2(-1.0, -1.0),
        float2( 3.0, -1.0),
        float2(-1.0,  3.0)
    };
    
    VSOut out;
    out.pos = float4(positions[vid], 0.0, 1.0);
    out.uv  = (out.pos.xy * 0.5) + 0.5; // uv in [0,1] if you need it
    return out;
}

fragment half4 liquidGlassFragment(
                                   VSOut in [[stage_in]],
                                   constant Uniforms& U [[buffer(0)]],
                                   texture2d<half> bgTex [[texture(0)]],
                                   sampler s [[sampler(0)]]
                                   ){
    float2 p = in.uv * U.size;              // pixel coords
    float2 q = p - U.center;                // ring-centered
    
    // ring SDF and normal
    float sd = sdfRing(q, U.outerRadius, U.innerRadius);
    
    // screen-space derivatives for normal like original
    float dx = dfdx(sd), dy = dfdy(sd);
    float n_cos = max(U.thickness + sd, 0.0) / U.thickness;
    float n_sin = sqrt(max(0.0, 1.0 - n_cos * n_cos));
    float3 normal = normalize(float3(dx * n_cos, dy * n_cos, n_sin));
    
    float foregroundAlpha = 1.0 - smoothstep(-2.0, 0.0, sd);
    
    return renderLiquidGlassTex(
                                p, U.size, sd, U.thickness, U.refrIdx, U.chromAb,
                                half4(U.glassColor), U.lightAngle, U.lightIntensity, U.ambient,
                                bgTex, s, normal, foregroundAlpha, U.blurRadius,
                                U.flags.x, U.flags.y, U.flags.z, U.flags.w
                                );
}
