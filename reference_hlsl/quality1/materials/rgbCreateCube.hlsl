// Material shader: rgbCreateCube
// Reassembled from fragment library. Fragments are spliced in order into one main();
// "Current" is the running vertex/pixel state, "In" the stage input, <tN> interpolator slots.

//==============================================================================
// VERTEX SHADER  (1 fragments; each may be conditionally enabled)
//==============================================================================

void main_vertex()
{
    // --- fragment: copyPositionColorUV0   (cond 0000000000000000000000000000000000000000000000ff)
    Current.texcoord<t0> = In.texcoord0.xy;
}

//==============================================================================
// PIXEL SHADER  (5 fragments; each may be conditionally enabled)
//==============================================================================
extern uniform sampler map : register(s0);
uniform float4 cubeInfo;
uniform float4x4 colorMatrix;
extern uniform sampler base : register(s10);
extern uniform sampler map : register(s1);
uniform float4 cubeInfo;
extern uniform sampler map0 : register(s10);
extern uniform sampler map1 : register(s1);

void main_pixel()
{
    // --- fragment: rgbBltCubePF   (cond 0702a70002000000000000000000000000000100000001ff)
    // identity texture:
    //Current.color       = float4(In.texcoord0.x, 1-frac(In.texcoord0.y * 32.0f), 1-(floor(In.texcoord0.y*32))/32, 1.0f);
    Current.color       = tex2D( map, In.texcoord0 );
    // --- fragment: rgbBlendCubeAndMatrixPF   (cond 0702a70005000000000000000000000000000100000001ff)
    float t                 = cubeInfo[0].x;
    float4 colorValues      = tex2D( base, In.texcoord0.xy );
    float4 diffuseValues    = tex2D( map, In.texcoord0.xy );
    colorValues.rgb         = float3( dot( colorMatrix[0], colorValues.rgb ), dot( colorMatrix[1], colorValues.rgb ), dot( colorMatrix[2], colorValues.rgb ) );
    Current.color           = lerp( colorValues, diffuseValues, t );
    // --- fragment: rgbBltCubePF   (cond 0702a70006000000000000000000000000000100000001ff)
    // identity texture:
    //Current.color       = float4(In.texcoord0.x, 1-frac(In.texcoord0.y * 32.0f), 1-(floor(In.texcoord0.y*32))/32, 1.0f);
    Current.color       = tex2D( map, In.texcoord0 );
    // --- fragment: rgbBlendCubeAndMatrixPF   (cond 0702a70007000000000000000000000000000100000001ff)
    float t                 = cubeInfo[0].x;
    float4 colorValues      = tex2D( base, In.texcoord0.xy );
    float4 diffuseValues    = tex2D( map, In.texcoord0.xy );
    colorValues.rgb         = float3( dot( colorMatrix[0], colorValues.rgb ), dot( colorMatrix[1], colorValues.rgb ), dot( colorMatrix[2], colorValues.rgb ) );
    Current.color           = lerp( colorValues, diffuseValues, t );
    // --- fragment: rgbBlendCubesPF   (cond 0702a70008000000000000000000000000000100000001ff)
    float t             = cubeInfo[0].x;
    float4 diffuse0     = tex2D( map0, In.texcoord0.xy );
    float4 diffuse1     = tex2D( map1, In.texcoord0.xy );
    Current.color.rgba  = lerp( diffuse0.rgba, diffuse1.rgba, t );
}
