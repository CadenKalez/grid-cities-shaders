// Shader fragment  [PS slot 498]  edgeDetectPS

// ---- declarations / helper functions ----
extern uniform sampler rtDepth   : register(s15);
float unpackDepth(float2 depthSampled)
{
return depthSampled.x;
}

// ---- fragment body (spliced into the generated main()) ----
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
