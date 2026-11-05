// Shader fragment  [PS slot 496]  rgbBlendCubesPF

// ---- uniform parameters ----
uniform float4 cubeInfo;   // reg-meta 02a702a70001000000000008

// ---- declarations / helper functions ----
extern uniform sampler map0 : register(s10);
extern uniform sampler map1 : register(s1);

// ---- fragment body (spliced into the generated main()) ----
float t             = cubeInfo[0].x;
float4 diffuse0     = tex2D( map0, In.texcoord0.xy );
float4 diffuse1     = tex2D( map1, In.texcoord0.xy );
Current.color.rgba  = lerp( diffuse0.rgba, diffuse1.rgba, t );
