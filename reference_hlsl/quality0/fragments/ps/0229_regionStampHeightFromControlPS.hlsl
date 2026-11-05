// Shader fragment  [PS slot 229]  regionStampHeightFromControlPS

// ---- uniform parameters ----
uniform struct { float4 mXYWH; float4 mScaleAndBias; } blitInfo;   // reg-meta 029702970002000000000008
uniform float4 renderTargetInfo0;   // reg-meta 025a025a0001000000004000

// ---- declarations / helper functions ----
sampler srcMap : register(s0);
sampler controlMap : register(s1);
float GetHeightAtUV(float2 uv)
{
float pixel = tex2D(srcMap, uv).x;
float4 control = tex2D(controlMap, uv);
if(control.b > 0)
{
pixel = control.x + control.y / 255.0;
pixel -= control.z * (0.25 / 2048.0); // just a little bias to force us under the roads/lots
}
return pixel;
}

// ---- fragment body (spliced into the generated main()) ----
float2 uv = In.texcoord<t0>.xy;
float2 uvOffset = float2(0,0);
float2 uvDeltaX = ddx(uv);
float2 uvDeltaY = ddy(uv);
uvOffset += -1 * saturate(1 - In.vpos.xy);                         // -1 if vpos = 0, otherwise 0
uvOffset += 1 * saturate(In.vpos.xy + 2 - renderTargetInfo0.xy);  //  1 if vpos = max, otherwise 0
// uvOffset is 0 *except* when we are rendering the edge texel of the render target, in which
// case it's -1 (if vpos.x/y = 0), or +1 (if vpos.x/y are at the far edge of the RT).
// We use this combined with the ddx/ddy of the uv to offset the height map sample by 1 pixel,
// and take the minimum, causing the edges of adjacent maps to match!
float pixelCur = GetHeightAtUV(uv);
float pixelX = GetHeightAtUV(uv + uvDeltaX * uvOffset.x);
float pixelY = GetHeightAtUV(uv + uvDeltaY * uvOffset.y);
float pixelXY = GetHeightAtUV(uv + uvDeltaX * uvOffset.x + uvDeltaY * uvOffset.y);
float pixel = pixelCur;
pixel = min(min(pixelCur, pixelXY), min(pixelX, pixelY));
pixel *= blitInfo.mScaleAndBias.x;
pixel += blitInfo.mScaleAndBias.y;
Current.color = float4(pixel, 0, 0, 0);
