// Shader fragment  [VS slot 312]  compositeVS

// ---- uniform parameters ----
uniform float4 renderTargetInfo0;   // reg-meta 025a025a0001000000004000

// ---- fragment body (spliced into the generated main()) ----
float2 uv = In.texcoord0.xy;
float2 uvOffset0 = uv + float2( -1.0f, -1.0f ) * renderTargetInfo0.zw;
float2 uvOffset1 = uv + float2(  1.0f, -1.0f ) * renderTargetInfo0.zw;
float2 uvOffset2 = uv + float2( -1.0f,  1.0f ) * renderTargetInfo0.zw;
float2 uvOffset3 = uv + float2(  1.0f,  1.0f ) * renderTargetInfo0.zw;
Current.position     = modelPosition;
Current.texcoord<t0> = float4( uv, 0.0f, 0.0f );
Current.texcoord<t1> = float4( uvOffset0, uvOffset1 );
Current.texcoord<t2> = float4( uvOffset2, uvOffset3 );
