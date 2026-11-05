// Material shader: FXAA
// Reassembled from fragment library. Fragments are spliced in order into one main();
// "Current" is the running vertex/pixel state, "In" the stage input, <tN> interpolator slots.

//==============================================================================
// VERTEX SHADER  (1 fragments; each may be conditionally enabled)
//==============================================================================

void main_vertex()
{
    // --- fragment: copyPositionUV0   (cond 0000000000000000000000000000000000000000000000ff)
    Current.texcoord<t0> = In.texcoord0.xy;
}

//==============================================================================
// PIXEL SHADER  (1 fragments; each may be conditionally enabled)
//==============================================================================
uniform float4 screenInfo;
float4 FxaaPixelShader(
//
// Use noperspective interpolation here (turn off perspective interpolation).
// {xy} = center of pixel
float2 pos,
//
// Input color texture.
// {rgb_} = color in linear or perceptual color space
// if (FXAA_GREEN_AS_LUMA == 0)
//     {___a} = luma in perceptual color space (not linear)
sampler2D tex,
//
// Only used on FXAA Quality.
// This must be from a constant/uniform.
// {x_} = 1.0/screenWidthInPixels
// {_y} = 1.0/screenHeightInPixels
float2 fxaaQualityRcpFrame,
//
// Only used on FXAA Quality.
// This used to be the FXAA_QUALITY__SUBPIX define.
// It is here now to allow easier tuning.
// Choose the amount of sub-pixel aliasing removal.
// This can effect sharpness.
//   1.00 - upper limit (softer)
//   0.75 - default amount of filtering
//   0.50 - lower limit (sharper, less sub-pixel aliasing removal)
//   0.25 - almost off
//   0.00 - completely off
float fxaaQualitySubpix,
//
// Only used on FXAA Quality.
// This used to be the FXAA_QUALITY__EDGE_THRESHOLD define.
// It is here now to allow easier tuning.
// The minimum amount of local contrast required to apply algorithm.
//   0.333 - too little (faster)
//   0.250 - low quality
//   0.166 - default
//   0.125 - high quality
//   0.063 - overkill (slower)
float fxaaQualityEdgeThreshold,
//
// Only used on FXAA Quality.
// This used to be the FXAA_QUALITY__EDGE_THRESHOLD_MIN define.
// It is here now to allow easier tuning.
// Trims the algorithm from processing darks.
//   0.0833 - upper limit (default, the start of visible unfiltered edges)
//   0.0625 - high quality (faster)
//   0.0312 - visible limit (slower)
// Special notes when using FXAA_GREEN_AS_LUMA,
//   Likely want to set this to zero.
//   As colors that are mostly not-green
//   will appear very dark in the green channel!
//   Tune by looking at mostly non-green content,
//   then start at zero and increase until aliasing is a problem.
float fxaaQualityEdgeThresholdMin
) {
/*--------------------------------------------------------------------------*/
float2 posM;
posM.x = pos.x;
posM.y = pos.y;
float4 rgbyM = tex2Dlod(tex, float4(posM, 0.0, 0.0));
float lumaS = (tex2Dlod(tex, float4(posM + (float2( 0, 1) * fxaaQualityRcpFrame.xy), 0, 0))).w;
float lumaE = (tex2Dlod(tex, float4(posM + (float2( 1, 0) * fxaaQualityRcpFrame.xy), 0, 0))).w;
float lumaN = (tex2Dlod(tex, float4(posM + (float2( 0,-1) * fxaaQualityRcpFrame.xy), 0, 0))).w;
float lumaW = (tex2Dlod(tex, float4(posM + (float2(-1, 0) * fxaaQualityRcpFrame.xy), 0, 0))).w;
/*--------------------------------------------------------------------------*/
float maxSM = max(lumaS, rgbyM.w);
float minSM = min(lumaS, rgbyM.w);
float maxESM = max(lumaE, maxSM);
float minESM = min(lumaE, minSM);
float maxWN = max(lumaN, lumaW);
float minWN = min(lumaN, lumaW);
float rangeMax = max(maxWN, maxESM);
float rangeMin = min(minWN, minESM);
float rangeMaxScaled = rangeMax * fxaaQualityEdgeThreshold;
float range = rangeMax - rangeMin;
float rangeMaxClamped = max(fxaaQualityEdgeThresholdMin, rangeMaxScaled);
bool earlyExit = range < rangeMaxClamped;
/*--------------------------------------------------------------------------*/
if(earlyExit)
return rgbyM;
/*--------------------------------------------------------------------------*/
float lumaNW = (tex2Dlod(tex, float4(posM + (float2(-1,-1) * fxaaQualityRcpFrame.xy), 0, 0))).w;
float lumaSE = (tex2Dlod(tex, float4(posM + (float2( 1, 1) * fxaaQualityRcpFrame.xy), 0, 0))).w;
float lumaNE = (tex2Dlod(tex, float4(posM + (float2( 1,-1) * fxaaQualityRcpFrame.xy), 0, 0))).w;
float lumaSW = (tex2Dlod(tex, float4(posM + (float2(-1, 1) * fxaaQualityRcpFrame.xy), 0, 0))).w;
/*--------------------------------------------------------------------------*/
float lumaNS = lumaN + lumaS;
float lumaWE = lumaW + lumaE;
float subpixRcpRange = 1.0/range;
float subpixNSWE = lumaNS + lumaWE;
float edgeHorz1 = (-2.0 * rgbyM.w) + lumaNS;
float edgeVert1 = (-2.0 * rgbyM.w) + lumaWE;
/*--------------------------------------------------------------------------*/
float lumaNESE = lumaNE + lumaSE;
float lumaNWNE = lumaNW + lumaNE;
float edgeHorz2 = (-2.0 * lumaE) + lumaNESE;
float edgeVert2 = (-2.0 * lumaN) + lumaNWNE;
/*--------------------------------------------------------------------------*/
float lumaNWSW = lumaNW + lumaSW;
float lumaSWSE = lumaSW + lumaSE;
float edgeHorz4 = (abs(edgeHorz1) * 2.0) + abs(edgeHorz2);
float edgeVert4 = (abs(edgeVert1) * 2.0) + abs(edgeVert2);
float edgeHorz3 = (-2.0 * lumaW) + lumaNWSW;
float edgeVert3 = (-2.0 * lumaS) + lumaSWSE;
float edgeHorz = abs(edgeHorz3) + edgeHorz4;
float edgeVert = abs(edgeVert3) + edgeVert4;
/*--------------------------------------------------------------------------*/
float subpixNWSWNESE = lumaNWSW + lumaNESE;
float lengthSign = fxaaQualityRcpFrame.x;
bool horzSpan = edgeHorz >= edgeVert;
float subpixA = subpixNSWE * 2.0 + subpixNWSWNESE;
/*--------------------------------------------------------------------------*/
if(!horzSpan) lumaN = lumaW;
if(!horzSpan) lumaS = lumaE;
if(horzSpan) lengthSign = fxaaQualityRcpFrame.y;
float subpixB = (subpixA * (1.0/12.0)) - rgbyM.w;
/*--------------------------------------------------------------------------*/
float gradientN = lumaN - rgbyM.w;
float gradientS = lumaS - rgbyM.w;
float lumaNN = lumaN + rgbyM.w;
float lumaSS = lumaS + rgbyM.w;
bool pairN = abs(gradientN) >= abs(gradientS);
float gradient = max(abs(gradientN), abs(gradientS));
if(pairN) lengthSign = -lengthSign;
float subpixC = saturate(abs(subpixB) * subpixRcpRange);
/*--------------------------------------------------------------------------*/
float2 posB;
posB.x = posM.x;
posB.y = posM.y;
float2 offNP;
offNP.x = (!horzSpan) ? 0.0 : fxaaQualityRcpFrame.x;
offNP.y = ( horzSpan) ? 0.0 : fxaaQualityRcpFrame.y;
if(!horzSpan) posB.x += lengthSign * 0.5;
if( horzSpan) posB.y += lengthSign * 0.5;
/*--------------------------------------------------------------------------*/
float2 posN;
posN.x = posB.x - offNP.x * 1.0;
posN.y = posB.y - offNP.y * 1.0;
float2 posP;
posP.x = posB.x + offNP.x * 1.0;
posP.y = posB.y + offNP.y * 1.0;
float subpixD = ((-2.0)*subpixC) + 3.0;
float lumaEndN = (tex2Dlod(tex, float4(posN, 0.0, 0.0))).w;
float subpixE = subpixC * subpixC;
float lumaEndP = (tex2Dlod(tex, float4(posP, 0.0, 0.0))).w;
/*--------------------------------------------------------------------------*/
if(!pairN) lumaNN = lumaSS;
float gradientScaled = gradient * 1.0/4.0;
float lumaMM = rgbyM.w - lumaNN * 0.5;
float subpixF = subpixD * subpixE;
bool lumaMLTZero = lumaMM < 0.0;
/*--------------------------------------------------------------------------*/
lumaEndN -= lumaNN * 0.5;
lumaEndP -= lumaNN * 0.5;
bool doneN = abs(lumaEndN) >= gradientScaled;
bool doneP = abs(lumaEndP) >= gradientScaled;
if(!doneN) posN.x -= offNP.x * 1.5;
if(!doneN) posN.y -= offNP.y * 1.5;
bool doneNP = (!doneN) || (!doneP);
if(!doneP) posP.x += offNP.x * 1.5;
if(!doneP) posP.y += offNP.y * 1.5;
/*--------------------------------------------------------------------------*/
if(doneNP) {
if(!doneN) lumaEndN = (tex2Dlod(tex, float4(posN.xy, 0.0, 0.0))).w;
if(!doneP) lumaEndP = (tex2Dlod(tex, float4(posP.xy, 0.0, 0.0))).w;
if(!doneN) lumaEndN = lumaEndN - lumaNN * 0.5;
if(!doneP) lumaEndP = lumaEndP - lumaNN * 0.5;
doneN = abs(lumaEndN) >= gradientScaled;
doneP = abs(lumaEndP) >= gradientScaled;
if(!doneN) posN.x -= offNP.x * 2.0;
if(!doneN) posN.y -= offNP.y * 2.0;
doneNP = (!doneN) || (!doneP);
if(!doneP) posP.x += offNP.x * 2.0;
if(!doneP) posP.y += offNP.y * 2.0;
/*--------------------------------------------------------------------------*/
if(doneNP) {
if(!doneN) lumaEndN = (tex2Dlod(tex, float4(posN.xy, 0.0, 0.0))).w;
if(!doneP) lumaEndP = (tex2Dlod(tex, float4(posP.xy, 0.0, 0.0))).w;
if(!doneN) lumaEndN = lumaEndN - lumaNN * 0.5;
if(!doneP) lumaEndP = lumaEndP - lumaNN * 0.5;
doneN = abs(lumaEndN) >= gradientScaled;
doneP = abs(lumaEndP) >= gradientScaled;
if(!doneN) posN.x -= offNP.x * 2.0;
if(!doneN) posN.y -= offNP.y * 2.0;
doneNP = (!doneN) || (!doneP);
if(!doneP) posP.x += offNP.x * 2.0;
if(!doneP) posP.y += offNP.y * 2.0;
/*--------------------------------------------------------------------------*/
if(doneNP) {
if(!doneN) lumaEndN = (tex2Dlod(tex, float4(posN.xy, 0.0, 0.0))).w;
if(!doneP) lumaEndP = (tex2Dlod(tex, float4(posP.xy, 0.0, 0.0))).w;
if(!doneN) lumaEndN = lumaEndN - lumaNN * 0.5;
if(!doneP) lumaEndP = lumaEndP - lumaNN * 0.5;
doneN = abs(lumaEndN) >= gradientScaled;
doneP = abs(lumaEndP) >= gradientScaled;
if(!doneN) posN.x -= offNP.x * 4.0;
if(!doneN) posN.y -= offNP.y * 4.0;
doneNP = (!doneN) || (!doneP);
if(!doneP) posP.x += offNP.x * 4.0;
if(!doneP) posP.y += offNP.y * 4.0;
/*--------------------------------------------------------------------------*/
if(doneNP) {
if(!doneN) lumaEndN = (tex2Dlod(tex, float4(posN.xy, 0.0, 0.0))).w;
if(!doneP) lumaEndP = (tex2Dlod(tex, float4(posP.xy, 0.0, 0.0))).w;
if(!doneN) lumaEndN = lumaEndN - lumaNN * 0.5;
if(!doneP) lumaEndP = lumaEndP - lumaNN * 0.5;
doneN = abs(lumaEndN) >= gradientScaled;
doneP = abs(lumaEndP) >= gradientScaled;
if(!doneN) posN.x -= offNP.x * 12.0;
if(!doneN) posN.y -= offNP.y * 12.0;
doneNP = (!doneN) || (!doneP);
if(!doneP) posP.x += offNP.x * 12.0;
if(!doneP) posP.y += offNP.y * 12.0;
/*--------------------------------------------------------------------------*/
}
/*--------------------------------------------------------------------------*/
}
/*--------------------------------------------------------------------------*/
}
/*--------------------------------------------------------------------------*/
}
/*--------------------------------------------------------------------------*/
float dstN = posM.x - posN.x;
float dstP = posP.x - posM.x;
if(!horzSpan) dstN = posM.y - posN.y;
if(!horzSpan) dstP = posP.y - posM.y;
/*--------------------------------------------------------------------------*/
bool goodSpanN = (lumaEndN < 0.0) != lumaMLTZero;
float spanLength = (dstP + dstN);
bool goodSpanP = (lumaEndP < 0.0) != lumaMLTZero;
float spanLengthRcp = 1.0/spanLength;
/*--------------------------------------------------------------------------*/
bool directionN = dstN < dstP;
float dst = min(dstN, dstP);
bool goodSpan = directionN ? goodSpanN : goodSpanP;
float subpixG = subpixF * subpixF;
float pixelOffset = (dst * (-spanLengthRcp)) + 0.5;
float subpixH = subpixG * fxaaQualitySubpix;
/*--------------------------------------------------------------------------*/
float pixelOffsetGood = goodSpan ? pixelOffset : 0.0;
float pixelOffsetSubpix = max(pixelOffsetGood, subpixH);
if(!horzSpan) posM.x += pixelOffsetSubpix * lengthSign;
if( horzSpan) posM.y += pixelOffsetSubpix * lengthSign;
return float4(tex2Dlod(tex, float4(posM, 0.0, 0.0)).xyz, rgbyM.w);
}
/*==========================================================================*/
extern uniform sampler map : register(s0);

void main_pixel()
{
    // --- fragment: FXAAPS   (cond 0000000000000000000000000000000000000000000000ff)
    //float4 diffuse        = tex2D( map, In.texcoord0.xy );
    float4 diffuse = FxaaPixelShader( In.texcoord0.xy, map, screenInfo.zw,
    // Choose the amount of sub-pixel aliasing removal.
    // This can effect sharpness.
    //   1.00 - upper limit (softer)
    //   0.75 - default amount of filtering
    //   0.50 - lower limit (sharper, less sub-pixel aliasing removal)
    //   0.25 - almost off
    //   0.00 - completely off
    0.75,
    // The minimum amount of local contrast required to apply algorithm.
    //   0.333 - too little (faster)
    //   0.250 - low quality
    //   0.166 - default
    //   0.125 - high quality
    //   0.063 - overkill (slower)
    0.063,
    // Trims the algorithm from processing darks.
    //   0.0833 - upper limit (default, the start of visible unfiltered edges)
    //   0.0625 - high quality (faster)
    //   0.0312 - visible limit (slower)
    0.0312 );
    Current.color.rgba  = diffuse.rgba;
    // if we sqrt'ed the color in RGBCube then fixup.  doesn't seem to make much difference.
    //Current.color.rgb *= Current.color.rgb;
}
