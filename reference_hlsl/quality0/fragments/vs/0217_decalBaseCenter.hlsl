// Shader fragment  [VS slot 217]  decalBaseCenter

// ---- uniform parameters ----
uniform float4 SkinBones[(192)];   // reg-meta 0004000400c0000000000008
uniform float4x4 worldToClip;   // reg-meta 000c000c0004000000004000

// ---- fragment body (spliced into the generated main()) ----
int xformIdx = toInt(Current.indices.x);
float3x4 modelToWorld = float3x4(SkinBones[xformIdx + 0], SkinBones[xformIdx + 1], SkinBones[xformIdx + 2]);
float3x4 modelToTexture = float3x4(In.texcoord1, In.texcoord2, In.texcoord3);
float3 modelPos = Current.position.xyz;
float3 texturePosition = mul(modelToTexture, float4(modelPos,1));
float sqrScale = dot(modelToTexture[2].xyz, modelToTexture[2].xyz);
float invSqrScale = 1.0 / sqrScale;
modelPos += (modelToTexture[2].xyz * invSqrScale) * -texturePosition.z;
float3 worldPosition = mul(modelToWorld, float4(modelPos,1));
Current.position = mul(float4(worldPosition,1), worldToClip);
Current.texcoord<t0> = In.texcoord0;
