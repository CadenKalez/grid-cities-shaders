// Material shader: rgbUseCubeNoVignette
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
// PIXEL SHADER  (8 fragments; each may be conditionally enabled)
//==============================================================================
uniform float4x4 colorMatrix;
extern uniform sampler      screenSampler   : register( s0 );
extern uniform sampler      screenSampler   : register( s0 );
extern uniform sampler      stripSampler    : register( s1 );

void main_pixel()
{
    // --- fragment: rgbColorGradePF   (cond 0702a70001000000000000000000000000000100000001ff)
    float2 uv                   = In.texcoord0.xy;
    float4 color                = tex2D( screenSampler, uv );
    Current.color.rgb           = float3( dot( colorMatrix[0], color.rgb ), dot( colorMatrix[1], color.rgb ), dot( colorMatrix[2], color.rgb ) );
    Current.color.a             = sqrt(dot(Current.color.rgb, float3(0.299, 0.587, 0.114))); // compute luma;
    // --- fragment: rgbCubeStripPF   (cond 0702a70002000000000000000000000000000100000001ff)
    float2 uv                   = In.texcoord0.xy;
    float4 color                = tex2D( screenSampler, uv );
    color *= 30;
    color += 0.5;
    color /= 32;
    color  = saturate( color );
    float2 index0               = float2( color.r, 1-saturate( ( floor( color.b * 32 ) + color.g ) / 32 ) );
    float2 index1               = float2( color.r, 1-saturate( ( ceil( color.b * 32 ) + color.g ) / 32 ) );
    float3 clut0                = tex2D( stripSampler, index0 ).rgb;
    float3 clut1                = tex2D( stripSampler, index1 ).rgb;
    Current.color.rgb           = lerp(clut0.rgb,clut1.rgb,frac(color.b*32));
    // supposedly doing this will result in better FXAA, but i didn't see much difference.
    //Current.color.rgb  = sqrt(Current.color.rgb);
    //Current.color.a               = dot(Current.color.rgb, float3(0.299, 0.587, 0.114)); // compute luma;
    Current.color.a             = sqrt(dot(Current.color.rgb, float3(0.299, 0.587, 0.114))); // compute luma;
    // --- fragment: rgbColorGradePF   (cond 0702a70003000000000000000000000000000100000001ff)
    float2 uv                   = In.texcoord0.xy;
    float4 color                = tex2D( screenSampler, uv );
    Current.color.rgb           = float3( dot( colorMatrix[0], color.rgb ), dot( colorMatrix[1], color.rgb ), dot( colorMatrix[2], color.rgb ) );
    Current.color.a             = sqrt(dot(Current.color.rgb, float3(0.299, 0.587, 0.114))); // compute luma;
    // --- fragment: rgbColorGradePF   (cond 0702a70004000000000000000000000000000100000001ff)
    float2 uv                   = In.texcoord0.xy;
    float4 color                = tex2D( screenSampler, uv );
    Current.color.rgb           = float3( dot( colorMatrix[0], color.rgb ), dot( colorMatrix[1], color.rgb ), dot( colorMatrix[2], color.rgb ) );
    Current.color.a             = sqrt(dot(Current.color.rgb, float3(0.299, 0.587, 0.114))); // compute luma;
    // --- fragment: rgbCubeStripPF   (cond 0702a70005000000000000000000000000000100000001ff)
    float2 uv                   = In.texcoord0.xy;
    float4 color                = tex2D( screenSampler, uv );
    color *= 30;
    color += 0.5;
    color /= 32;
    color  = saturate( color );
    float2 index0               = float2( color.r, 1-saturate( ( floor( color.b * 32 ) + color.g ) / 32 ) );
    float2 index1               = float2( color.r, 1-saturate( ( ceil( color.b * 32 ) + color.g ) / 32 ) );
    float3 clut0                = tex2D( stripSampler, index0 ).rgb;
    float3 clut1                = tex2D( stripSampler, index1 ).rgb;
    Current.color.rgb           = lerp(clut0.rgb,clut1.rgb,frac(color.b*32));
    // supposedly doing this will result in better FXAA, but i didn't see much difference.
    //Current.color.rgb  = sqrt(Current.color.rgb);
    //Current.color.a               = dot(Current.color.rgb, float3(0.299, 0.587, 0.114)); // compute luma;
    Current.color.a             = sqrt(dot(Current.color.rgb, float3(0.299, 0.587, 0.114))); // compute luma;
    // --- fragment: rgbCubeStripPF   (cond 0702a70006000000000000000000000000000100000001ff)
    float2 uv                   = In.texcoord0.xy;
    float4 color                = tex2D( screenSampler, uv );
    color *= 30;
    color += 0.5;
    color /= 32;
    color  = saturate( color );
    float2 index0               = float2( color.r, 1-saturate( ( floor( color.b * 32 ) + color.g ) / 32 ) );
    float2 index1               = float2( color.r, 1-saturate( ( ceil( color.b * 32 ) + color.g ) / 32 ) );
    float3 clut0                = tex2D( stripSampler, index0 ).rgb;
    float3 clut1                = tex2D( stripSampler, index1 ).rgb;
    Current.color.rgb           = lerp(clut0.rgb,clut1.rgb,frac(color.b*32));
    // supposedly doing this will result in better FXAA, but i didn't see much difference.
    //Current.color.rgb  = sqrt(Current.color.rgb);
    //Current.color.a               = dot(Current.color.rgb, float3(0.299, 0.587, 0.114)); // compute luma;
    Current.color.a             = sqrt(dot(Current.color.rgb, float3(0.299, 0.587, 0.114))); // compute luma;
    // --- fragment: rgbCubeStripPF   (cond 0702a70007000000000000000000000000000100000001ff)
    float2 uv                   = In.texcoord0.xy;
    float4 color                = tex2D( screenSampler, uv );
    color *= 30;
    color += 0.5;
    color /= 32;
    color  = saturate( color );
    float2 index0               = float2( color.r, 1-saturate( ( floor( color.b * 32 ) + color.g ) / 32 ) );
    float2 index1               = float2( color.r, 1-saturate( ( ceil( color.b * 32 ) + color.g ) / 32 ) );
    float3 clut0                = tex2D( stripSampler, index0 ).rgb;
    float3 clut1                = tex2D( stripSampler, index1 ).rgb;
    Current.color.rgb           = lerp(clut0.rgb,clut1.rgb,frac(color.b*32));
    // supposedly doing this will result in better FXAA, but i didn't see much difference.
    //Current.color.rgb  = sqrt(Current.color.rgb);
    //Current.color.a               = dot(Current.color.rgb, float3(0.299, 0.587, 0.114)); // compute luma;
    Current.color.a             = sqrt(dot(Current.color.rgb, float3(0.299, 0.587, 0.114))); // compute luma;
    // --- fragment: rgbCubeStripPF   (cond 0702a70008000000000000000000000000000100000001ff)
    float2 uv                   = In.texcoord0.xy;
    float4 color                = tex2D( screenSampler, uv );
    color *= 30;
    color += 0.5;
    color /= 32;
    color  = saturate( color );
    float2 index0               = float2( color.r, 1-saturate( ( floor( color.b * 32 ) + color.g ) / 32 ) );
    float2 index1               = float2( color.r, 1-saturate( ( ceil( color.b * 32 ) + color.g ) / 32 ) );
    float3 clut0                = tex2D( stripSampler, index0 ).rgb;
    float3 clut1                = tex2D( stripSampler, index1 ).rgb;
    Current.color.rgb           = lerp(clut0.rgb,clut1.rgb,frac(color.b*32));
    // supposedly doing this will result in better FXAA, but i didn't see much difference.
    //Current.color.rgb  = sqrt(Current.color.rgb);
    //Current.color.a               = dot(Current.color.rgb, float3(0.299, 0.587, 0.114)); // compute luma;
    Current.color.a             = sqrt(dot(Current.color.rgb, float3(0.299, 0.587, 0.114))); // compute luma;
}
