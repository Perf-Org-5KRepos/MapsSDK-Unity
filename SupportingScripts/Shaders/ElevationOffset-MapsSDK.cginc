// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#ifndef ELEVATION_OFFSET
#define ELEVATION_OFFSET

#if ENABLE_ELEVATION_TEXTURE

sampler2D _ElevationTex;
float4 _ElevationTexScaleAndOffset;
float _ZComponent;

float2 CalculateElevationOffset(sampler2D elevationTex, float2 uv, float scale, float2 offset, float elevationScale)
{
    float2 scaledAndOffsetUv = (uv * scale) + offset;

    // Elevation texture's origin is flipped. Fix it here.
    scaledAndOffsetUv.y = 1.0 - scaledAndOffsetUv.y;

    float elevation = tex2Dlod(elevationTex, float4(scaledAndOffsetUv, 0, 0)).r;
    return float2(elevation * elevationScale, elevation);
}

float3 FilterNormal(sampler2D elevationTex, float2 uv, float scale, float2 offset, float elevationScale, float texelSize)
{
    float2 scaledAndOffsetUv = (uv * scale) + offset;

    // Elevation texture's origin is flipped. Fix it here.
    scaledAndOffsetUv.y = 1.0 - scaledAndOffsetUv.y;
    scaledAndOffsetUv = scaledAndOffsetUv - float2(0.5 * texelSize, 0.5 * texelSize);

    float xy = tex2Dlod(elevationTex, float4(scaledAndOffsetUv + float2(0, 0), 0, 0)).r;
    float xy1 = tex2Dlod(elevationTex, float4(scaledAndOffsetUv + float2(0, texelSize), 0, 0)).r;
    float x1y = tex2Dlod(elevationTex, float4(scaledAndOffsetUv + float2(texelSize, 0), 0, 0)).r;
    float x1y1 = tex2Dlod(elevationTex, float4(scaledAndOffsetUv + float2(texelSize, texelSize), 0, 0)).r;
    float averageLeftX = xy + x1y;
    float averageRightX = xy1 + x1y1;
    float averageTopY = xy + xy1;
    float averageBottomY = x1y + x1y1;
    float averageX = 0.5 * (averageRightX - averageLeftX);
    float averageY = 0.5 * (averageTopY - averageBottomY);

    return normalize(float3(averageY, _ZComponent, averageX));
}

#endif

#endif
