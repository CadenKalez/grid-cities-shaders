// Shader fragment  [PS slot 333]  regionDecalProject

// ---- uniform parameters ----
uniform float4 viewFarCorners[4];   // reg-meta 02a902a90004000000000008

// ---- fragment body (spliced into the generated main()) ----
// project screen space into camera position.
float3 farPlaneXYZ =
lerp(
lerp( viewFarCorners[1].xyz, viewFarCorners[3].xyz, screenUV.x ),
lerp( viewFarCorners[0].xyz, viewFarCorners[2].xyz, screenUV.x ),
screenUV.y );
float3   camXYZ          = farPlaneXYZ * depth;
float4x4 camToTexture    = float4x4( In.texcoord<t1>, In.texcoord<t2>, In.texcoord<t3>, float4( 0.0f, 0.0f, 0.0f, 1.0f ) );
float3   texturePosition = mul( camToTexture, float4( camXYZ, 1.0f ) ).xyz * ( 1.0f / 1024.0f );
// convert to uv space with texture transform
float4 texXform = In.texcoord<t0>;
float2 uv       = ( texturePosition.xy * -0.5f + 0.5f ) * texXform.xy + texXform.zw;
float4 decalTexture = tex2D( Sampler<s0>, uv );
Current.color = decalTexture;
