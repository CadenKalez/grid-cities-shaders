// Shader fragment  [VS slot 139]  networkRoadBasicSHVS

// ---- uniform parameters ----
uniform float4 materialColor;   // reg-meta 002200220001000000000010
uniform float4x3 modelToWorld;   // reg-meta 000800080003000000000001
uniform float4x4 modelToClip;   // reg-meta 000600060004000000004001

// ---- fragment body (spliced into the generated main()) ----
Current.position = mul( modelPosition, modelToClip );
Current.color = materialColor;
Current.texcoord<t0>.xyz = float3( In.texcoord0.xy, 0.0f );
Current.texcoord<t1>.xyz = mul( modelPosition.xyz, modelToWorld );
Current.texcoord<t2>.xyz = mul( In.normal.xyz, make_float3x3(modelToWorld) );
Current.texcoord<t3>.xyz = mul( In.tangent.xyz, make_float3x3(modelToWorld) );
