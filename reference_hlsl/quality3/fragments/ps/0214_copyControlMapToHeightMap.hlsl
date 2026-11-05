// Shader fragment  [PS slot 214]  copyControlMapToHeightMap

// ---- uniform parameters ----
uniform float4 samplerInfo14;   // reg-meta 026c026c0001000000400000

// ---- declarations / helper functions ----
sampler controlMapSampler : register(s14);

// ---- fragment body (spliced into the generated main()) ----
float4 controlMap = tex2D(controlMapSampler, In.texcoord<t0>.xy).xyzw;
float height = controlMap.x + controlMap.y / 255.0;  
height -= controlMap.w / 2048.0;  
float final = height;
Current.color.rgba = float4(final, 0,0,0);
