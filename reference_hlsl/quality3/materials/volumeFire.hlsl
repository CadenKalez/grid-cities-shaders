// Material shader: volumeFire
// Reassembled from fragment library. Fragments are spliced in order into one main();
// "Current" is the running vertex/pixel state, "In" the stage input, <tN> interpolator slots.

//==============================================================================
// VERTEX SHADER  (2 fragments; each may be conditionally enabled)
//==============================================================================
uniform float4x4 modelToClip;
uniform float4x3 modelToWorld;
uniform float4 screenInfo;
uniform float4x3 worldToPatch;

void main_vertex()
{
    // --- fragment: toClipSpace   (cond 0000000000000000000000000000000000000000000000ff)
    float4 worldPosition = float4(mul(Current.position, modelToWorld), 1);
    float4 clipPosition = mul(Current.position, modelToClip);
    Current.position = clipPosition;
    // --- fragment: volumeFire   (cond 0000000000000000000000000000000000000000000000ff)
    Current.texcoord<t0> = In.texcoord0.xyz;
    Current.texcoord<t1> = mul(modelPosition, worldToPatch);
}

//==============================================================================
// PIXEL SHADER  (1 fragments; each may be conditionally enabled)
//==============================================================================
uniform struct { float4 mFrequencyMag; float mTime; } mNoiseScale;
/* This is a random number generator based
on the Blum Blum Shub algorithm. It is
considered cryptographically secure and
reletively cheap. Given the nth value in
a sequence and the key M, it will return
the next element in the sequence. The random
numbers in the sequency have a max value of M - 1.
Ideally M = p*q where p and q are prime numbers
*/
float  BBSRandomNumber( float  n, float M ) { return fmod( n * n, M ); }
float2 BBSRandomNumber( float2 n, float M ) { return fmod( n * n, M ); }
float3 BBSRandomNumber( float3 n, float M ) { return fmod( n * n, M ); }
float4 BBSRandomNumber( float4 n, float M ) { return fmod( n * n, M ); }
// This function hashing both z and z + 1.
// The ramp allows you to jump to a more interesting scale.
float2 mNoiseHash( int z, int ramp, float modulus )
{
float2 n = fmod( z * ramp + float2( 0, ramp ), modulus );
return BBSRandomNumber( n, modulus );
}
float2 mNoiseHash( int z, float2 hash, int ramp, float modulus )
{
float2 n = hash + fmod( z * ramp + float2( 0, ramp ), modulus );
return BBSRandomNumber( n, modulus );
}
float mNoise( float2 pos, sampler mNoiseSampler )
{
const float modulus = 61;
return tex2D( mNoiseSampler, pos / modulus ).x * 2 - 1;
}
float mNoise( float3 pos, sampler mNoiseSampler )
{
const float modulus = 61;	// modulus in random hash
// integer and fractional components of input, and fade blend function
int intArg;
float fracArg = modf( pos.z, intArg ); //seperating integral and fractional part
// hash z and z+1 for noise offset. Including a small mutually
// prime multiplier improved the visual quality of the hash near
// 0. This is because 0^2, 1^2, 2^2 are well under the hash
// modulus and close enough to appear correlated.
// So 3*(z+1) = 3*z + 3
float2 hash = mNoiseHash( intArg, 3, modulus ) / modulus ;	// hashing n and adjusting frequency to 1
float2 p = pos.xy / modulus;								//adjusting frequncy to 1
// lookup noise and blend slices
float4 g = float4(
tex2D( mNoiseSampler, float2( p.x, p.y + hash.x ) ).xy * 2 - 1,
tex2D( mNoiseSampler, float2( p.x, p.y + hash.y ) ).xy * 2 - 1 );
return lerp(
g.x + g.y * fracArg,
g.z + g.w * ( fracArg - 1 ),
smoothstep( 0, 1, fracArg )
);
}
float Turbulence( float2 pos, sampler mNoiseSampler, int octaves = 3, float lacunarity = 2.0, float gain = 0.5 )
{
float sum = 0;
float freq = 1.0;
float amp = 1.0;
for( int i = 0; i < octaves; i++ )
{
sum += mNoise( pos * freq, mNoiseSampler ) * amp;
freq *= lacunarity;
amp *= gain;
}
return sum;
}
float Turbulence( float3 pos, sampler mNoiseSampler, int octaves = 3, float lacunarity = 2.0, float gain = 0.5 )
{
float sum = 0;
float freq = 1.0;
float amp = 1.0;
for( int i = 0; i < octaves; i++ )
{
sum += mNoise( pos * freq, mNoiseSampler ) * amp;
freq *= lacunarity;
amp *= gain;
}
return sum;
}
sampler fireTexture   : register(s0);
sampler noiseTexture : register(s1);

void main_pixel()
{
    // --- fragment: volumeFire   (cond 0000000000000000000000000000000000000000000000ff)
    float3 uv3 = In.texcoord<t0>;
    float3 pos = In.texcoord<t1>;
    float u = length( uv3.xy * 2 - 1 );
    float3 noisePos = float3( pos.xy * mNoiseScale.mFrequencyMag.xy, mNoiseScale.mTime * 02.6 - pos.z * mNoiseScale.mFrequencyMag.z );
    float fNoise = mNoiseScale.mFrequencyMag.w * Turbulence( noisePos*.3 , noiseTexture, 1 );
    float v = 1 - ( uv3.z + In.texcoord0.z * fNoise );
    Current.color = tex2D( fireTexture, float2( u, v ) );
}
