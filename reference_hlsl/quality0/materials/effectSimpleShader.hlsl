// Material shader: effectSimpleShader
// Reassembled from fragment library. Fragments are spliced in order into one main();
// "Current" is the running vertex/pixel state, "In" the stage input, <tN> interpolator slots.

//==============================================================================
// VERTEX SHADER  (3 fragments; each may be conditionally enabled)
//==============================================================================
uniform float4 customParams[2];
uniform float4x4 modelToClip;

void main_vertex()
{
    // --- fragment: effectSimpleSetupMinSpecVF   (cond 0000000000000000000000000000000000000000000000ff)
    float3 position  = modelPosition.xyz;
    float4 color = In.color;
    float2 tileSize = In.texcoord0.xy;
    float age = In.weights.x;
    float frameDelta = In.weights.y;
    float2 tiles = In.color1.xy * 255;
    int corner = int(In.weights.w * 255);
    int cx = corner % 2;
    int cy = corner / 2;
    tiles += float2(cx, 1 - cy);
    float2 uvTile1 = tileSize * tiles.xy;
    float2 uvTile2 = uvTile1;
    // --- fragment: effectSimpleCrushVF   (cond 0000000000000000000000000000000000000000000000ff)
    float blackPoint;
    float midPoint;
    float fadeRate = customParams[0].w;
    blackPoint = 0.0f;
    if ( fadeRate > 1.f )
    {
    blackPoint = saturate( 1-age * (fadeRate - 1) );
    }
    else
    {
    blackPoint = saturate( age * fadeRate );
    }
    midPoint = ( 1.0 + blackPoint ) * 0.5;
    // --- fragment: effectSimpleOutputVF   (cond 0000000000000000000000000000000000000000000000ff)
    Current.position            = mul( float4( modelPosition.xyz, 1 ), modelToClip ); 
    Current.color               = color;
    Current.texcoord<t0>        = float4( uvTile1.xy, uvTile2.xy );
    Current.texcoord<t1>        = float4( frameDelta, 0, blackPoint, midPoint );
    Current.texcoord<t2>        = Current.position;
}

//==============================================================================
// PIXEL SHADER  (5 fragments; each may be conditionally enabled)
//==============================================================================
extern uniform sampler map : register(s0);
uniform float4 customParams[2];
uniform float4 customParams[2];

void main_pixel()
{
    // --- fragment: effectSimpleInputPF   (cond 0000000000000000000000000000000000000000000000ff)
    float4  color           =  In.color;
    float2  uvTile1         =  In.texcoord0.xy;
    float2  uvTile2         =  In.texcoord0.zw;
    float   frameDelta      =  In.texcoord1.x;
    float   blackPoint      =  In.texcoord1.z;
    float   midPoint        =  In.texcoord1.w;
    float4  particleClipPos  =  In.texcoord2;
    // --- fragment: effectSimpleSampleDiffuseMinSpecPF   (cond 0000000000000000000000000000000000000000000000ff)
    float4 diffuse     = tex2D(map, uvTile1);
    // --- fragment: effectSimpleCrushPF   (cond 0000000000000000000000000000000000000000000000ff)
    float crushAlpha = customParams[0].x;
    float crushRGB   = customParams[0].y;
    if ( crushAlpha != 0 )
    {
    float4 crush = float4(0, 0, 0, 0);
    if ( diffuse.a < midPoint )
    crush += midPoint * ( diffuse - blackPoint ) / ( midPoint - blackPoint + 0.0001 );
    else
    crush += diffuse;
    diffuse.rgb     = lerp(diffuse.rgb, crush.rgb, crushRGB);
    diffuse.a       = lerp(diffuse.a, crush.a, crushAlpha);
    }
    // --- fragment: effectSimpleMultiplyAndBlendMinSpecPF   (cond 0000000000000000000000000000000000000000000000ff)
    float colorMultiply = customParams[0].z;
    diffuse *= color;
    diffuse.rgb *= colorMultiply;
    // --- fragment: effectSimpleOutputPF   (cond 0000000000000000000000000000000000000000000000ff)
    Current.color.a = diffuse.a;
    Current.color.rgb = diffuse.rgb;
}
