// Material shader: effectSimpleShaderZOffset
// Reassembled from fragment library. Fragments are spliced in order into one main();
// "Current" is the running vertex/pixel state, "In" the stage input, <tN> interpolator slots.

//==============================================================================
// VERTEX SHADER  (3 fragments; each may be conditionally enabled)
//==============================================================================
uniform float4 customParams[2];
uniform float4x4 modelToClip;
uniform float4x3 modelToCamera;
uniform float4x4 cameraToClip;
uniform float4 nearFar;

void main_vertex()
{
    // --- fragment: effectSimpleSetupVF   (cond 0000000000000000000000000000000000000000000000ff)
    float3 position  = modelPosition.xyz;
    float4 color = In.color;
    float2 tileSize = In.texcoord0.xy;
    float age = In.weights.x;
    float frameDelta = In.weights.y;
    // Rotation value range is [-128, 127] (i.e [-1, 1]) but has been scaled to 0-255 (well, really [0,1] because
    // it's normalized for floating point read back so we need to unscale the data. The input value is also in
    // number of turns so we need to turn that into radians
    float rotation = ((In.weights.z * 255.0f) - 127.0f) / 128.0f * 6.28318531f;
    float4 tiles = In.color1.xyzw * 255;
    int corner = int(In.weights.w * 255);
    int cx = corner % 2;
    int cy = corner / 2;
    tiles += float4(cx, 1 - cy, cx, 1 - cy);
    float2 uvTile1 = tileSize * tiles.xy;
    float2 uvTile2 = tileSize * tiles.zw;
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
    // --- fragment: effectSimpleZOffsetOutputVF   (cond 0000000000000000000000000000000000000000000000ff)
    float3 viewPos;
    viewPos = mul( float4( modelPosition.xyz, 1 ), modelToCamera );
    //HACK, do not allow vertices to exceed far clip plane
    if ( viewPos.z > nearFar.y )
    {
    viewPos.z=nearFar.y - 5.0f; 
    }
    Current.position            = mul( float4( viewPos.xyz, 1 ), cameraToClip ); 
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
uniform float4 renderTargetInfo0;
uniform float4 nearFar;
uniform float4 customParams[2];
extern uniform sampler depthMap  : register(s15);
float UnpackDepth(float4 rgbaDepth)
{
return dot( rgbaDepth.xyz, float3( 1, 1 / 255.0, 1 / (255.0*255.0) ) );
}

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
    // --- fragment: effectSimpleSampleDiffusePF   (cond 0000000000000000000000000000000000000000000000ff)
    float4 diffuse     = (lerp(tex2D(map, uvTile1), tex2D(map, uvTile2), frameDelta)) ;
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
    // --- fragment: effectSimpleMultiplyAndBlendPF   (cond 0000000000000000000000000000000000000000000000ff)
    float colorMultiply = customParams[0].z;
    diffuse *= color;
    diffuse.rgb *= colorMultiply;
    if (customParams[1].x >= 4.0f)  
    {
    float2 screenUV = (In.vpos.xy + float2(0.5, 0.5)) * renderTargetInfo0.zw;
    float4 rgbaDepth = tex2D(depthMap, screenUV);
    float depth = UnpackDepth(rgbaDepth);
    float existingDepth = depth * nearFar.y;
    float depthDiff = existingDepth - particleClipPos.w;
    float depth_difference_threshold = customParams[1].y;
    diffuse.a *= 1-saturate(depthDiff / depth_difference_threshold);
    diffuse.a *= saturate(depthDiff / depth_difference_threshold);
    }
    else if (customParams[1].x >= 3.0f)
    {
    float2 screenUV = (In.vpos.xy + float2(0.5, 0.5)) * renderTargetInfo0.zw;
    float4 rgbaDepth = tex2D(depthMap, screenUV);
    float depth = UnpackDepth(rgbaDepth);
    float existingDepth = depth * nearFar.y;
    float depthDiff = abs(existingDepth - particleClipPos.w);
    float depth_difference_threshold = customParams[1].y;
    diffuse.a *= saturate(depthDiff / depth_difference_threshold);
    float normalizeDistanceFromCamera=particleClipPos.w/(nearFar.y * frac(customParams[1].x));
    diffuse.a *=( 1.0- normalizeDistanceFromCamera);
    }
    else if (customParams[1].x >= 2.0f)  
    {
    float2 screenUV = (In.vpos.xy + float2(0.5, 0.5)) * renderTargetInfo0.zw;
    float4 rgbaDepth = tex2D(depthMap, screenUV);
    float depth = UnpackDepth(rgbaDepth);
    float normalizeDistanceFromCamera=particleClipPos.w/ (nearFar.y * frac(customParams[1].x) );
    diffuse.a  *=( 1.0- normalizeDistanceFromCamera);
    }
    else if (customParams[1].x > 0.0f)  
    {
    float2 screenUV = (In.vpos.xy + float2(0.5, 0.5)) * renderTargetInfo0.zw;
    float4 rgbaDepth = tex2D(depthMap, screenUV);
    float depth = UnpackDepth(rgbaDepth);
    float existingDepth = depth * nearFar.y;
    float depthDiff = abs(existingDepth - particleClipPos.w);
    float depth_difference_threshold = customParams[1].y;
    diffuse.a *= saturate(depthDiff / depth_difference_threshold);
    }
    // --- fragment: effectSimpleOutputPF   (cond 0000000000000000000000000000000000000000000000ff)
    Current.color.a = diffuse.a;
    Current.color.rgb = diffuse.rgb;
}
