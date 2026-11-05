// Material shader: dofDownsampleShader
// Reassembled from fragment library. Fragments are spliced in order into one main();
// "Current" is the running vertex/pixel state, "In" the stage input, <tN> interpolator slots.

//==============================================================================
// VERTEX SHADER  (1 fragments; each may be conditionally enabled)
//==============================================================================
uniform float4 screenInfo;
uniform float4x4 worldToClip;

void main_vertex()
{
    // --- fragment: dofDownsampleVS   (cond 0000000000000000000000000000000000000000000000ff)
    //Current.position = mul( float4(position,1), worldToClip );
    Current.texcoord<t0>.xy = In.texcoord0.xy + float2( -1.0, -1.0 ) * screenInfo.zw;
    Current.texcoord<t0>.zw = In.texcoord0.xy + float2( +1.0, -1.0 ) * screenInfo.zw;
    Current.texcoord<t1>.xy = In.texcoord0.xy + float2( -1.5, -1.5 ) * screenInfo.zw;
    Current.texcoord<t1>.zw = In.texcoord0.xy + float2( -0.5, -1.5 ) * screenInfo.zw;
    Current.texcoord<t2>.xy = In.texcoord0.xy + float2( +0.5, -1.5 ) * screenInfo.zw;
    Current.texcoord<t2>.zw = In.texcoord0.xy + float2( +1.5, -1.5 ) * screenInfo.zw;
}

//==============================================================================
// PIXEL SHADER  (1 fragments; each may be conditionally enabled)
//==============================================================================
uniform struct { float4 dofFocusPlane; float4 dofFocusDistances; float4 dofLerpScale;float4 dofLerpBias;} tiltShiftDOFInfo;
uniform float4 screenInfo;
uniform struct { float4 mTargetSizes; float4 mViewportSizes; float4 mNearFar;} cameraParams;
extern uniform sampler colorTex : register(s0);
extern uniform sampler depthTex : register(s15);
float UnpackDepth(float4 rgbaDepth)
{
float farClip = cameraParams.mNearFar.y;
return (tiltShiftDOFInfo.dofFocusPlane.z * (farClip*(rgbaDepth.x*255.0 + rgbaDepth.y + rgbaDepth.z/255.0)/255.0)) - tiltShiftDOFInfo.dofFocusPlane.w;
// todo:  translate to world space/whatever, then find dist to arbitrary FocalPlane
}

void main_pixel()
{
    // --- fragment: dofDownsamplePS   (cond 0000000000000000000000000000000000000000000000ff)
    float2 dofRowDelta = float2(0.0f,0.25f*screenInfo.w*2.0f);
    float3 color;
    float maxCoc;
    float4 depth;
    float4 viewCoc;
    float4 sceneCoc;
    float4 curCoc;
    float4 coc;
    float2 rowOfs[4];
    // "rowOfs" reduces how many moves PS2.0 uses to emulate swizzling.
    rowOfs[0] = float2(0, 0);
    rowOfs[1] = dofRowDelta.xy;
    rowOfs[2] = dofRowDelta.xy * 2;
    rowOfs[3] = dofRowDelta.xy * 3;
    // Use bilinear filtering to average 4 color samples for free.
    color = float3(0, 0, 0);
    color += tex2D( colorTex, In.texcoord0.xy + rowOfs[0] ).rgb;
    color += tex2D( colorTex, In.texcoord0.zw + rowOfs[0] ).rgb;
    color += tex2D( colorTex, In.texcoord0.xy + rowOfs[2] ).rgb;
    color += tex2D( colorTex, In.texcoord0.zw + rowOfs[2] ).rgb;
    color /= 4;
    // Process 4 samples at a time to use vector hardware efficiently.
    // The CoC will be 1 if the depth is negative, so use "min" to pick
    // between "sceneCoc" and "viewCoc".
    depth[0] = UnpackDepth(tex2D( depthTex, In.texcoord1.xy + rowOfs[0] ));
    depth[1] = UnpackDepth(tex2D( depthTex, In.texcoord1.zw + rowOfs[0] ));
    depth[2] = UnpackDepth(tex2D( depthTex, In.texcoord2.xy + rowOfs[0] ));
    depth[3] = UnpackDepth(tex2D( depthTex, In.texcoord2.zw + rowOfs[0] ));
    curCoc = saturate( tiltShiftDOFInfo.dofFocusDistances.x * depth + tiltShiftDOFInfo.dofFocusDistances.y );
    coc = curCoc;
    depth[0] = UnpackDepth(tex2D( depthTex, In.texcoord1.xy + rowOfs[1] ));
    depth[1] = UnpackDepth(tex2D( depthTex, In.texcoord1.zw + rowOfs[1] ));
    depth[2] = UnpackDepth(tex2D( depthTex, In.texcoord2.xy + rowOfs[1] ));
    depth[3] = UnpackDepth(tex2D( depthTex, In.texcoord2.zw + rowOfs[1] ));
    curCoc = saturate( tiltShiftDOFInfo.dofFocusDistances.x * depth + tiltShiftDOFInfo.dofFocusDistances.y );
    coc = max( coc, curCoc );
    depth[0] = UnpackDepth(tex2D( depthTex, In.texcoord1.xy + rowOfs[2] ));
    depth[1] = UnpackDepth(tex2D( depthTex, In.texcoord1.zw + rowOfs[2] ));
    depth[2] = UnpackDepth(tex2D( depthTex, In.texcoord2.xy + rowOfs[2] ));
    depth[3] = UnpackDepth(tex2D( depthTex, In.texcoord2.zw + rowOfs[2] ));
    curCoc = saturate( tiltShiftDOFInfo.dofFocusDistances.x * depth + tiltShiftDOFInfo.dofFocusDistances.y );
    coc = max( coc, curCoc );
    depth[0] = UnpackDepth(tex2D( depthTex, In.texcoord1.xy + rowOfs[3] ));
    depth[1] = UnpackDepth(tex2D( depthTex, In.texcoord1.zw + rowOfs[3] ));
    depth[2] = UnpackDepth(tex2D( depthTex, In.texcoord2.xy + rowOfs[3] ));
    depth[3] = UnpackDepth(tex2D( depthTex, In.texcoord2.zw + rowOfs[3] ));
    curCoc = saturate( tiltShiftDOFInfo.dofFocusDistances.x * depth + tiltShiftDOFInfo.dofFocusDistances.y );
    coc = max( coc, curCoc );
    maxCoc = max( max( coc[0], coc[1] ), max( coc[2], coc[3] ) );
    Current.color.rgba  = float4(color, maxCoc);
}
