// Shader fragment  [VS slot 165]  strataWaterVS

// ---- uniform parameters ----
uniform struct { float4 mWaterInfo; float4 mReflectionParams; float4 mScaleAndBias1; float4 mScaleAndBias2; } terrainSurfaceInfoVS;   // reg-meta 028102810004000000000008
uniform float4x4 modelToClip;   // reg-meta 000600060004000000004001

// ---- declarations / helper functions ----
sampler HeightMap : register(s0);       
sampler ThicknessMap : register(s1);

// ---- fragment body (spliced into the generated main()) ----
{
Current.texcoord0 = Current.position.xyxy / 1024;  
Current.texcoord0 = 0.5 * (Current.texcoord<t0> + 1);
Current.texcoord1 = float4( Current.normal.xyz, 0 );
Current.texcoord2.w = 1;
float2 uv1 = Current.position.xy;
uv1 /= 2048.0;
uv1 += 0.5;
uv1 = saturate(uv1);
float height = tex2Dlod(HeightMap, float4(uv1.x, uv1.y, 0, 0)).x * 2048 - 1024;
float thickness = tex2Dlod(ThicknessMap, float4(uv1.x, uv1.y, 0, 0)).x * 2048;
Current.texcoord2.w = thickness;  
Current.position.z += height;
float4 clipPosition = mul(Current.position, modelToClip);
Current.texcoord<t3>.xyzw = clipPosition;
Current.texcoord2.xyz = Current.position.xyz;
}
