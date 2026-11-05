// Material shader: renderDepth
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
// PIXEL SHADER  (1 fragments; each may be conditionally enabled)
//==============================================================================
extern uniform sampler map : register(s0);
static const int kNumBands = 14;
        static const float3 kBands[kNumBands] = {

float3(1,0,0),
float3(0,1,0),
float3(0,0,1),
float3(0,1,1),
float3(1,0,1),
float3(1,1,0),
float3(1,1,1),
float3(0.5,0,0),
float3(0,0.5,0),
float3(0,0,0.5),
float3(0,0.5,0.5),
float3(0.5,0,0.5),
float3(0.5,0.5,0),
float3(0.5,0.5,0.5)
};
static const float kBandsInScene = 2000;

void main_pixel()
{
    // --- fragment: renderDepthPS   (cond 0000000000000000000000000000000000000000000000ff)
            float4 depthBuf = tex2D( map, In.texcoord0 );
    
    float depth = dot( depthBuf.xyz, float3( 1, 1 / 255.0f, 1 / (255.0*255.0) ) );
    int band = int(floor(depth * kBandsInScene));
    float subAmount = frac(depth * kBandsInScene);
    band = band % kNumBands;
    float3 color = lerp(kBands[band] * 0.2, kBands[band], subAmount);
    Current.color = float4(color, 1);
}
