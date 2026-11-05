// Shader fragment  [VS slot 176]  decalVS

// ---- uniform parameters ----
uniform float4x4 modelToClip;   // reg-meta 000600060004000000004001

// ---- declarations / helper functions ----
sampler HeightMap : register(s0);

// ---- fragment body (spliced into the generated main()) ----
{
Current.texcoord1 = In.texcoord0;  
Current.texcoord0 = Current.position.xyxy / 1024;  
Current.texcoord0 = 0.5 * (Current.texcoord<t0> + 1);
Current.texcoord2 = float4(Current.position.xyz, 1);
float2 uv1 = Current.position.xy;
uv1 /= 2048.0;
uv1 += 0.5;
uv1 = saturate(uv1);
float height = tex2Dlod(HeightMap, float4(uv1.x, uv1.y, 0, 0)).x * 2048 - 1024;
height += 0.25;
Current.position.z = height;
float4 clipPosition = mul(Current.position, modelToClip);
Current.texcoord3.xyzw = clipPosition;
}
