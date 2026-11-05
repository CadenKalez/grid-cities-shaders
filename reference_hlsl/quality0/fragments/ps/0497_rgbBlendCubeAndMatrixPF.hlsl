// Shader fragment  [PS slot 497]  rgbBlendCubeAndMatrixPF

// ---- uniform parameters ----
uniform float4 cubeInfo;   // reg-meta 02a702a70001000000000008
uniform float4x4 colorMatrix;   // reg-meta 02a602a60004000000000008

// ---- declarations / helper functions ----
extern uniform sampler base : register(s10);
extern uniform sampler map : register(s1);

// ---- fragment body (spliced into the generated main()) ----
float t                 = cubeInfo[0].x;
float4 colorValues      = tex2D( base, In.texcoord0.xy );
float4 diffuseValues    = tex2D( map, In.texcoord0.xy );
colorValues.rgb         = float3( dot( colorMatrix[0], colorValues.rgb ), dot( colorMatrix[1], colorValues.rgb ), dot( colorMatrix[2], colorValues.rgb ) );
Current.color           = lerp( colorValues, diffuseValues, t );
