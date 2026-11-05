// Shader fragment  [VS slot 190]  building4DeferredVS

// ---- uniform parameters ----
uniform float4x4 modelToClip;   // reg-meta 000600060004000000004001
uniform float4 nearFar;   // reg-meta 002e002e00010000000ffffd

// ---- fragment body (spliced into the generated main()) ----
// Code from toClipSpace
float4 clipPosition = mul(Current.position, modelToClip);
Current.position = clipPosition;
Current.texcoord<t0> = float4(uv, uv2);
Current.texcoord<t1> = float4(eyeDir, clipPosition.w * nearFar.w);
Current.texcoord<t2> = float4(tileSize, tileOffset);
Current.texcoord<t3> = float4(tileSize2, tileOffset2);
Current.texcoord<t4> = float4(worldNormal, tilePadding.x);
Current.texcoord<t5> = float4(worldTangent, tilePadding.y);
