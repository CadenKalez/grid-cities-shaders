// Shader fragment  [PS slot 210]  terrainNormalsBlurPS

// ---- uniform parameters ----
uniform struct { float4 mParams; } terrainNormalsInfo;   // reg-meta 028e028e0001000000000008

// ---- declarations / helper functions ----
extern uniform sampler srcMap : register(s1);

// ---- fragment body (spliced into the generated main()) ----
const float mapSize = terrainNormalsInfo.mParams.x;
float kernelSize=4; 
float cutOff=0.025;
float texelDimension=1.0/mapSize;
float2 uv = float2(In.texcoord<t0>.x, In.texcoord<t0>.y);
float4 pixel = tex2D(srcMap, uv).rgba;
float x=0;
float y=0;
float4 blurredTexel=float4(0,0,0,0);
for (x=-kernelSize/2; x<kernelSize/2; ++x)
{
for (y=-kernelSize/2; y<kernelSize/2; ++y)
{
float2 uvSample = float2(In.texcoord<t0>.x + x*texelDimension, In.texcoord<t0>.y + y*texelDimension);
blurredTexel += tex2D(srcMap, uvSample).rgba;
}
}
blurredTexel=blurredTexel/(kernelSize*kernelSize);
float4 diff=abs( pixel - blurredTexel);
diff.r=(diff.r>cutOff) ? 1.0 : diff.r/cutOff;
diff.g=(diff.g>cutOff) ? 1.0 : diff.g/cutOff;
diff.b=(diff.b>cutOff) ? 1.0 : diff.b/cutOff;
float4 finalColor=lerp(blurredTexel, pixel, diff);
Current.color = finalColor;
