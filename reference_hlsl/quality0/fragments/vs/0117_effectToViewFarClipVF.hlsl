// Shader fragment  [VS slot 117]  effectToViewFarClipVF

// ---- uniform parameters ----
uniform float4 cameraParams[3];   // reg-meta 022202220003000000004000

// ---- fragment body (spliced into the generated main()) ----
float3 toViewFarClip;
{
float farClip = cameraParams[2].y;
toViewFarClip = viewPos * farClip / viewPos.z;
}
