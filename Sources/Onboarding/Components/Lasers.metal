#include <metal_stdlib>
using namespace metal;

static inline float glslMod(float x, float y) {
    return x - y * floor(x / y);
}

static inline float3 glslMod(float3 x, float y) {
    return x - y * floor(x / y);
}

[[ stitchable ]] half4 Lasers(
    float2 position,
    half4 color,
    float2 size,
    float time,
    float3 accentColor,
    float speedMultiplier
) {
    (void)color;
    float2 safeSize = max(size, float2(1.0, 1.0));
    float t = time * 0.01 * max(speedMultiplier, 0.01);
    float2 uv = position / safeSize - 0.5;
    float2 originalUV = uv;
    uv.x *= safeSize.x / safeSize.y;

    float3 rd = normalize(float3(uv, 2.0));
    float ct = cos(t);
    float st = sin(t);
    rd.xy = float2(
        rd.x * ct + rd.y * st,
        -rd.x * st + rd.y * ct
    );

    float3 ro = float3(
        t + sin(t * 6.53583) * 0.05,
        0.01 + sin(t * 352.4855) * 0.0015,
        -t * 3.0
    );

    float3 p = ro;
    float v = 0.0;
    float td = -glslMod(ro.z, 0.005);

    for (int i = 0; i < 150; i++) {
        float ring = max(0.0, 0.01 - length(abs(0.01 - glslMod(p, 0.02))));
        float glow = pow(ring / 0.01, 10.0) * exp(-2.0 * pow(1.0 + td, 2.0));
        v += glow;
        p = ro + rd * td;
        td += 0.005;
    }

    float vignette = max(0.0, 1.0 - length(originalUV * originalUV) * 2.5);
    float3 accent = clamp(accentColor, 0.0, 1.0);
    float laserStrength = max(v, 0.0) * 8.0 * vignette;
    float3 lasers = laserStrength * (0.2 + accent * 1.6);
    float pulse = 0.5 + 0.5 * sin(time * 0.8 + originalUV.x * 8.0 + originalUV.y * 6.0);
    float3 baseline = float3(0.03, 0.05, 0.08) + accent * 0.10 + pulse * accent * 0.28;
    float3 rgb = baseline * vignette * 0.35 + lasers * 1.75;
    rgb = clamp(rgb, 0.0, 1.0);
    return half4(half3(rgb), 1.0h);
}
