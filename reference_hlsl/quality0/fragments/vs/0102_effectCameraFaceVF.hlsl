// Shader fragment  [VS slot 102]  effectCameraFaceVF

// ---- uniform parameters ----
uniform float4 worldCameraDirection;   // reg-meta 002100210001000000004000

// ---- fragment body (spliced into the generated main()) ----
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
