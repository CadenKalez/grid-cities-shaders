// Material shader: edgeDetect
// Reassembled from fragment library. Fragments are spliced in order into one main();
// "Current" is the running vertex/pixel state, "In" the stage input, <tN> interpolator slots.

//==============================================================================
// VERTEX SHADER  (1 fragments; each may be conditionally enabled)
//==============================================================================
uniform float4 screenInfo;

void main_vertex()
{
    // --- fragment: edgeDetectVS   (cond 0000000000000000000000000000000000000000000000ff)
    float2 texOffset    = screenInfo.zw;
    Current.texcoord<t0> = In.texcoord0.xxxy + texOffset.xxxx * float4(-1,0,1,0); // horiz offsets
    Current.texcoord<t1> = In.texcoord0.yyyx + texOffset.yyyy * float4(-1,0,1,0); // vert offsets
}

//==============================================================================
// PIXEL SHADER  (1 fragments; each may be conditionally enabled)
//==============================================================================
extern uniform sampler rtDepth   : register(s15);
float unpackDepth(float2 depthSampled)
{
return depthSampled.x;
}

void main_pixel()
{
    // --- fragment: edgeDetectPS   (cond 0000000000000000000000000000000000000000000000ff)
    float4 texh          = In.texcoord0;
    float4 texv          = In.texcoord1;
    float4 depthValues00 = tex2D( rtDepth, texh.yw );
    float4 depthValues0  = tex2D( rtDepth, texh.xw );
    float4 depthValues1  = tex2D( rtDepth, texh.zw );
    float4 depthValues2  = tex2D( rtDepth, texv.wx );
    float4 depthValues3  = tex2D( rtDepth, texv.wz );
    // read the control buffer for this pixel and its immediate neighbors
    float depth_z_z = unpackDepth( depthValues00.xyz );
    float4 depth;
    depth.x = unpackDepth( depthValues0.xyz );
    depth.y = unpackDepth( depthValues1.xyz );
    depth.z = unpackDepth( depthValues2.xyz );
    depth.w = unpackDepth( depthValues3.xyz );
    float depth_z_z_2 = 2 * depth_z_z;
    // sample ID map palette (3 dep reads!, can this be reduced/unpacked ?)
    float4 idParameters = float4(.2, .3, 0, 0);
    float4 internalLineColor = float4(0,0,0,.4);
    float4 externalLineColor = float4(0,0,0,.4);
    float2 sensitivity = idParameters.xx * 5000;
    float  senseguard  = idParameters.y;
    Current.color = internalLineColor;
    // TODO: switch line color based on where the contribution to the line comes from (x vs. y)
    float4 cmp = float4(0, 0, 0, 0);
    if(any(cmp.xy))
    {
    sensitivity.x = -5000;
    Current.color = externalLineColor;
    }
    if(any(cmp.zw))
    {
    sensitivity.y = -5000;
    Current.color = externalLineColor;
    }
    //Current.color.a *= 5.0f; // $$$REI TEMP
    //sensitivity = -5000; // $$$REI TEMP
    float2 detect = make_float2(depth_z_z_2) - depth.xz - depth.yw;
    detect *= sensitivity;
    detect = max(detect, 0);
    float edge = detect.x + detect.y;
    float toonResult = saturate(edge - senseguard);
    Current.color.a *= toonResult;
}
