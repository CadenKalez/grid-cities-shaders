// Shader fragment  [VS slot 179]  clipAgainstPlaneVSOnly

// ---- uniform parameters ----
uniform float4 customClipPlane;   // reg-meta 02c502c50001000000000008

// ---- fragment body (spliced into the generated main()) ----
{
float clipDist = dot(Current.position, customClipPlane * 0.99);
Current.position.xyz = Current.position.xyz - min(clipDist, 0) * customClipPlane.xyz;
}
