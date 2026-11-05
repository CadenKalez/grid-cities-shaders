// Material shader: effectSimpleClampScreenShader
// Reassembled from fragment library. Fragments are spliced in order into one main();
// "Current" is the running vertex/pixel state, "In" the stage input, <tN> interpolator slots.

//==============================================================================
// VERTEX SHADER  (2 fragments; each may be conditionally enabled)
//==============================================================================
uniform float4x4 modelToClip;
uniform float4x4 worldToClip;
uniform float4 customParams[2];

void main_vertex()
{
    // --- fragment: effectSimpleSetupInstancedVF   (cond 0000000000000000000000000000000000000000000000ff)
    float3 position  = modelPosition.xyz;
    float3 up = In.texcoord0.xyz;
    float3 across = In.texcoord1.xyz;
    float4 color = In.color;
    float2 tileSize = In.texcoord2.xy;
    float age = In.weights.x;
    float frameDelta = In.weights.y;
    float size = In.weights.z;
    float4 tiles = In.color1.xyzw * 255;
    int corner = int(In.weights.w * 255);
    int cx = corner % 2;
    int cy = corner / 2;
    tiles += float4(cx, 1 - cy, cx, 1 - cy);
    float2 uvTile1 = tileSize * tiles.xy;
    float2 uvTile2 = tileSize * tiles.zw;
    // --- fragment: effectSimpleOutputScreenClampVF   (cond 0000000000000000000000000000000000000000000000ff)
    float clampScreenSizeMin = customParams[1].z;
    float clampScreenSizeMax = customParams[1].w;
    // This is far from optimal. At some point this calculation (sxyz) needs to be
    // done in the runtime and passed int via constant.
    // Find the scale factors for x' and y'
    float sx2  = dot( worldToClip[0], worldToClip[0] );
    float sy2  = dot( worldToClip[1], worldToClip[1] );
    float sz2  = dot( worldToClip[2], worldToClip[2] );
    float sxyz = sqrt( sx2 + sy2 + sz2 );
    // Find w'
    float sw;
    sw = worldToClip[0].w * modelPosition.x +
    worldToClip[1].w * modelPosition.y +
    worldToClip[2].w * modelPosition.z +
    worldToClip[3].w;
    float relSize = 10.0f * sxyz / sw; // 10 is just to nudge into a "sensible" range around 1.
    float clampedRelSize = clamp( relSize, clampScreenSizeMin, clampScreenSizeMax );
    float scale = ( sw > 0.0f ) ? ( clampedRelSize / relSize ) : 1.0f;
    position += ( ( up  + across ) * scale );
    float4 clipPosition = mul( float4( position, 1 ), modelToClip );
    Current.position            = clipPosition; 
    Current.color               = color;
    Current.texcoord<t0>        = float4( uvTile1.xy, uvTile2.xy );
    Current.texcoord<t1>        = float4( frameDelta, 0, 0, 0 );
    Current.texcoord<t2>        = Current.position;
}

//==============================================================================
// PIXEL SHADER  (4 fragments; each may be conditionally enabled)
//==============================================================================
extern uniform sampler map : register(s0);
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
    // --- fragment: effectSimpleSampleDiffuseMinSpecPF   (cond 0000000000000000000000000000000000000000000000ff)
    float4 diffuse     = tex2D(map, uvTile1);
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
