// Material shader: generic_zone
// Reassembled from fragment library. Fragments are spliced in order into one main();
// "Current" is the running vertex/pixel state, "In" the stage input, <tN> interpolator slots.

//==============================================================================
// VERTEX SHADER  (8 fragments; each may be conditionally enabled)
//==============================================================================
uniform float4 materialColor;
uniform float4 worldCameraPosition;
uniform float4x4 modelToClip;
uniform float4x3 modelToWorld;
uniform float4 objectTypeColor;

void main_vertex()
{
    // --- fragment: copyVertexColor   (cond 0000000000000000000008000000000000000100000001ff)
    // --- fragment: whiteVertexColor   (cond 0000000000000000000000000000000000000100000001ff)
    Current.color = float4(1, 1, 1, 1);
    // --- fragment: applyMaterialColor   (cond 0000000000000000000000000000000000000000000000ff)
    Current.color *= materialColor;
    // --- fragment: copyZoneUVsNormals   (cond 0000000000000000000000000000000000000000000000ff)
    int lotsIndex1 = toInt(In.indices.x);
    Current.texcoord<t0> = In.texcoord0;
    Current.texcoord<t1> = float4(In.normal.xyz,lotsIndex1);
    Current.texcoord<t2> = float4(In.tangent.xyz,In.position.z);
    // --- fragment: cameraDistance   (cond 0000000000000000000000000000000000000000000000ff)
    float3 vertexToCamera = modelPosition.xyz - worldCameraPosition.xyz;
    Current.texcoord<t0> = sqrt(dot(vertexToCamera, vertexToCamera));
    // --- fragment: toClipSpace   (cond 0000000000000000000000000000000000000000000000ff)
    float4 worldPosition = float4(mul(Current.position, modelToWorld), 1);
    float4 clipPosition = mul(Current.position, modelToClip);
    Current.position = clipPosition;
    // --- fragment: zoneDepthBias   (cond 0000000000000000000000000000000000000000000000ff)
    Current.position.z -= 5.0;
    // --- fragment: highlightsVS   (cond 0102020000000000000000000000000000000000000000ff)
    Current.color = objectTypeColor;
}

//==============================================================================
// PIXEL SHADER  (5 fragments; each may be conditionally enabled)
//==============================================================================
float calculateEdge(float4 texCoord, float4 tangent, float edgeWidth)
{
float minMin = min(min(texCoord.x,texCoord.y),texCoord.z);
minMin = min(min(min(tangent.x,tangent.y),tangent.z),minMin);
float width = saturate(fwidth(minMin) + 0.5);
//return smoothstep(edgeWidth+width,edgeWidth-width,minMin);
return smoothstep(10,-10,minMin);
//return step(minMin,edgeWidth);
}
uniform float4 zoneFill;
uniform float4 tintParams;

void main_pixel()
{
    // --- fragment: copyVertexColor   (cond 0000000000000000000000000000000000000000000000ff)
    // --- fragment: setupZonePS   (cond 0000000000000000000000000000000000000000000000ff)
    float4 texCoord = In.texcoord<t0>;
    float4 tangent = In.texcoord<t2>;
    float camDistance = In.texcoord<t3>.x;
    float vertAlpha = In.color.a;
    // --- fragment: applyEdge   (cond 0000000000000000000000000000000000000000000000ff)
    const float MIN_STROKE = 0.9f;
    const float MAX_STROKE = 1.3f;
    // Relies on the fact that the hover lot has an alpha of 1
    float edgeMult = 1.f;
    if (vertAlpha > 0.95f)
    {
    edgeMult = 2.f;
    vertAlpha = 0.1;
    }
    float edgeAlpha = calculateEdge(texCoord, tangent, edgeMult * clamp(camDistance/600.f, MIN_STROKE, MAX_STROKE));
    //Current.color.a = 1.0-edgeAlpha;
    // --- fragment: applyVertFill   (cond 0000000000000000000000000000000000000000000000ff)
    // This is set by the data layer system. Normally it is 1.0f
    float zoneAlpha = zoneFill.x;//1.0 + (1.0-zoneFill.x);
    float cameraFadeInDist = zoneFill.y;
    float cameraFadeOutDist = zoneFill.z;
    float camFade = saturate((camDistance - cameraFadeOutDist) / (cameraFadeInDist - cameraFadeOutDist));
    Current.color.a = saturate((zoneAlpha * vertAlpha * camFade)-edgeAlpha);
    // --- fragment: tint   (cond 0000000000000000000000000000000000000000000000ff)
    Current.color *= tintParams;
}
