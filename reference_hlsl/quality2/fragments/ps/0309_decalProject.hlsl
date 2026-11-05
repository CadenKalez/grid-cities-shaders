// Shader fragment  [PS slot 309]  decalProject

// ---- uniform parameters ----
uniform float4 viewFarCorners[4];   // reg-meta 02a902a90004000000000008

// ---- fragment body (spliced into the generated main()) ----
 float screenV = screenUV.y;

float3 farPlaneXYZ =
lerp(
lerp(viewFarCorners[1].xyz, viewFarCorners[3].xyz, screenUV.x),
lerp(viewFarCorners[0].xyz, viewFarCorners[2].xyz, screenUV.x),
screenV);
float3 camXYZ = farPlaneXYZ * depth;
float4x4 camToTexture = float4x4(In.texcoord<t0>, In.texcoord<t1>, In.texcoord<t2>, float4(0,0,0,1));
float3 texturePosition = mul(camToTexture, float4(camXYZ, 1)).xyz;
float2 uvOrig = texturePosition.xy * -0.5 + 0.5;
float2 uv = uvOrig * texXform.xy + texXform.zw;
float4 decalTexture = tex2D(Sampler<s0>, uv);
Current.color = decalTexture;
