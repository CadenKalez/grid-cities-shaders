// Shader fragment  [VS slot 48]  uvExploder

// ---- uniform parameters ----
uniform float pulse;   // reg-meta 0028002800010000000ffffd
uniform float4x4 modelToClip;   // reg-meta 000600060004000000004001
uniform float4 mousePosition;   // reg-meta 021f021f00010000000ffffd

// ---- fragment body (spliced into the generated main()) ----
{
const bool kExplodeNormals = false;
float t = saturate(mousePosition.w); // saturate(sin(gameInfo.x) * 0.5 + 0.5);
if (!kExplodeNormals)
{
float2 pos0 = In.texcoord0.xy;
pos0.y = -pos0.y;     // rw
if (pos0.y < 0)
pos0.y += 1;
pos0 = 2 * pos0 - float2(1, 1);
pos0.x *= 0.75;  // hack for screen ratio
float4 pos1 = float4(pos0, 0, 1);
float4 pos2 = Current.position;
Current.position = lerp(pos1, pos2, t);
}
else
{
Current.position += Current.normal * t * 5;
}
}
