// Material shader: TerrainBrushAbsoluteMax
// Reassembled from fragment library. Fragments are spliced in order into one main();
// "Current" is the running vertex/pixel state, "In" the stage input, <tN> interpolator slots.

//==============================================================================
// VERTEX SHADER  (1 fragments; each may be conditionally enabled)
//==============================================================================

void main_vertex()
{
    // --- fragment: copyPositionUV0UV1   (cond 0000000000000000000000000000000000000000000000ff)
    Current.texcoord<t0> = In.texcoord0;
}

//==============================================================================
// PIXEL SHADER  (1 fragments; each may be conditionally enabled)
//==============================================================================
uniform struct { float4 mParams; } shaderDataTerrainInfo;
extern uniform sampler textureMap : register(s0);
extern uniform sampler textureMapPreviousRTT : register(s1);

void main_pixel()
{
    // --- fragment: terrainBrushAbsoluteMaxPSFragment   (cond 0000000000000000000000000000000000000000000000ff)
    const float param0 = shaderDataTerrainInfo.mParams.x;
    const float param1 = shaderDataTerrainInfo.mParams.y;
    const float param2 = shaderDataTerrainInfo.mParams.z;
    const float param3 = shaderDataTerrainInfo.mParams.w;
    //get uv texture coordinate from interpolators
    float2 uv = float2(In.texcoord<t0>.x, In.texcoord<t0>.y);
    float2 uv1 = float2(In.texcoord<t0>.z, 1.0 - In.texcoord<t0>.w); //world space position projected into uv space
    //intensity set in swarm
    float intensity=param3;
    //read texel value
    float texelValue = tex2D(textureMap, uv).r;
    texelValue*=intensity; //modulate
    texelValue*=tex2D(textureMap, uv).a; //alpha channel modulates value
    //read texel value from previous RTT (ie the current height map we are creating)
    float texelValueRTT = tex2D(textureMapPreviousRTT, uv1).r;
    //we want to map the range of values that the data in texture actually corrsponds to (eg we map the 0 to 1 value read from texture into a different numerical range
    //such as mapping (0 - 1) to (-1 - 1)
    float minValue=param0;
    float maxValue=param1;
    float rangeLength=maxValue - minValue;
    //we will need to scale and offset value read from texture into the range (assume texture data in 0 to 1 range )
    float scale =1.0f/rangeLength;
    float centerTextureRange = 0.5; //(assumes texture data in 0 to 1 range )
    float centerMinMaxRange=  (minValue + maxValue)/2.0f; //average of two end points gives center
    //calculate offset to move from texture range center to MinMax center
    float offset = centerMinMaxRange - centerTextureRange;
    //scale the value read from the texture ( 0 to 1 range ) into the range defined by min and max (min and max set via swarm file)
    float remappedValue=(texelValue * scale) + offset;
    //set final value to the remapped texel value
    float finalValue=remappedValue;
    //compare the brush texture's remapped value with the current terrain in RTT value, choose the higher value
    if (texelValueRTT > finalValue )
    {
    finalValue=texelValueRTT;
    }
    Current.color = float4(finalValue,finalValue,finalValue, 1.0);
}
