// Shader fragment  [PS slot 83]  effectSoftPS

// ---- declarations / helper functions ----
extern uniform sampler depthMap : register(s15);

// ---- fragment body (spliced into the generated main()) ----
float4 depthValues = tex2D( depthMap, screenUV );
float depth = dot( depthValues.xy, float2( 65536.0 / 65535.0, 256.0 / 65535.0 ) );
float level = saturate( depth * farClip - vertDepth );
Current.color = diffuse * float4( 1, 1, 1, level );
