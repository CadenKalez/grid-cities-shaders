// Material shader: effectShader
// Reassembled from fragment library. Fragments are spliced in order into one main();
// "Current" is the running vertex/pixel state, "In" the stage input, <tN> interpolator slots.

//==============================================================================
// VERTEX SHADER  (5 fragments; each may be conditionally enabled)
//==============================================================================
uniform float4 worldCameraPosition;
uniform float4 worldCameraDirection;
uniform float4x4 modelToClip;

void main_vertex()
{
    // --- fragment: effectTransSetupVF   (cond 0000000000000000000000000000000000000000000000ff)
    float2 uv = Current.color1.rg;
    float scale = In.normal.w;
    {
    Current.texcoord<t0> = Current.color1;
    }
    // --- fragment: effectSetupVF   (cond 0000000000000000000000000000000000000000000000ff)
    float age = modelPosition.w;
    float4 color = In.color;
    float3 cameraPos = worldCameraPosition.xyz;
    float3 toCamera = cameraPos - modelPosition.xyz;
    float cameraDist = length( toCamera );
    float3 toCamNormal = toCamera / cameraDist;
    // --- fragment: effectCameraFaceVF   (cond 0000000000000000000000000000000000000000000000ff)
    float3 quadPos;
    {
    float3 up = normalize( In.normal.xyz );
    float3 tangent  = cross( worldCameraDirection.xyz, up );
    tangent = normalize( tangent );
    up = normalize( cross( tangent, worldCameraDirection.xyz ) );
    quadPos = modelPosition.xyz;
    quadPos += tangent * scale * (uv.x - 0.5);
    quadPos += up * scale * (0.5 - uv.y);
    }
    // --- fragment: effectToClipVF   (cond 0000000000000000000000000000000000000000000000ff)
    float4 clipPos;
    {
    clipPos = mul( float4( quadPos, 1 ), modelToClip );
    }
    // --- fragment: effectOutputVF   (cond 0000000000000000000000000000000000000000000000ff)
    Current.position            = clipPos;
    Current.color               = color;
    Current.texcoord<t0>.xy     = uv;
    Current.texcoord<t0>.zw     = float2(0, 0);
}

//==============================================================================
// PIXEL SHADER  (4 fragments; each may be conditionally enabled)
//==============================================================================
extern uniform sampler map : register(s0);
uniform float4 customParams[1];

void main_pixel()
{
    // --- fragment: effectInputPF   (cond 0000000000000000000000000000000000000000000000ff)
    float4   color           = In.color;
    float2   uv              = In.texcoord0.xy;
    // --- fragment: effectSampleDiffusePS   (cond 0000000000000000000000000000000000000000000000ff)
    float4 diffuse		= tex2D( map, uv ) * color;
    // --- fragment: effectPostMultiply   (cond 0000000000000000000000000000000000000000000000ff)
    diffuse.rgb *= customParams[0].z;
    // --- fragment: effectPS   (cond 0000000000000000000000000000000000000000000000ff)
    Current.color.rgb   = diffuse.rgb;
    Current.color.a		= diffuse.a;
}
