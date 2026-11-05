// Shader fragment  [VS slot 63]  positionInfoFromDepth

// ---- uniform parameters ----
uniform float4 worldCameraPosition;   // reg-meta 001f001f0001000000004000
uniform float4x4 clipToWorld;   // reg-meta 022802280004000000004000

// ---- fragment body (spliced into the generated main()) ----
{
// Find viewer-relative point on far clip plane for this vertex
float4 farPoint = mul(Current.position.xyww, clipToWorld);
farPoint /= farPoint.w;
farPoint.xyz -= worldCameraPosition.xyz;
farPoint *= hw; // adjust so we don't interpolate with perspective correction. It's important that farPoint.w == hw.
Current.texcoord<t0> = farPoint.xyz;
}
