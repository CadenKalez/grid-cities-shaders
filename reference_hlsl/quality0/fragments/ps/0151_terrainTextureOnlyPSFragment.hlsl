// Shader fragment  [PS slot 151]  terrainTextureOnlyPSFragment

// ---- declarations / helper functions ----
extern uniform sampler textureMap : register(s0);

// ---- fragment body (spliced into the generated main()) ----
//get uv texture coordinate from interpolators
float2 uv = float2(In.texcoord<t0>.x, In.texcoord<t0>.y);
//read texel value
float texelValue = tex2D(textureMap, uv).r;
//add the value from previously rendered RTT and the texture in brush via alpha blend operation in RT
float finalValue=texelValue;
Current.color = float4( finalValue, finalValue, finalValue, 1.0);
