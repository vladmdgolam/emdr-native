#include <metal_stdlib>
using namespace metal;

struct VertexOut {
    float4 position [[position]];
    float2 uv;
};

vertex VertexOut vertex_passthrough(uint vertexID [[vertex_id]]) {
    float2 positions[3] = {
        float2(-1.0, -1.0),
        float2( 3.0, -1.0),
        float2(-1.0,  3.0)
    };

    VertexOut out;
    float2 pos = positions[vertexID % 3];
    out.position = float4(pos, 0.0, 1.0);
    out.uv = pos * 0.5 + 0.5; // map clip space to 0..1
    return out;
}

struct Uniforms {
    float2 resolution; // width, height in pixels
    float   time;      // seconds since start
    float   radius;    // circle radius in pixels
    float4  color;     // RGBA 0..1
    float   speed;     // points per second
};

// Ping-pong function for bounce motion over [0, range]
inline float pingpong(float t, float range) {
    float twoRange = 2.0 * range;
    float m = fmod(t, twoRange);
    return (m <= range) ? m : (twoRange - m);
}

fragment float4 fragment_dot(VertexOut in [[stage_in]], constant Uniforms& u [[buffer(0)]]) {
    // Pixel position in screen space
    float2 p = in.uv * u.resolution;

    // Horizontal center travels back and forth between radius and width - radius
    float travelRange = max(0.0, u.resolution.x - 2.0 * u.radius);
    float traveled = pingpong(u.time * u.speed, travelRange);
    float2 center = float2(u.radius + traveled, u.resolution.y * 0.5);

    float dist = distance(p, center) - u.radius;
    float alpha = smoothstep(1.0, 0.0, dist); // anti-aliased edge

    // Black background + circle color
    float4 dotColor = float4(u.color.rgb, alpha);
    float4 bg = float4(0.0, 0.0, 0.0, 1.0);
    // Alpha composite over black (alpha is already against black effectively)
    return mix(bg, dotColor, alpha);
}

