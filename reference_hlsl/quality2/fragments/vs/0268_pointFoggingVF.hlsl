// Shader fragment  [VS slot 268]  pointFoggingVF

// ---- uniform parameters ----
uniform float4 worldCameraPosition;   // reg-meta 001f001f0001000000004000

// ---- declarations / helper functions ----
// Returns t1, t2 first and second intersection with sphere. t1 is 0 if rayOrigin is inside the sphere.
float2 intersectRaySphere(float3 rayOrigin, float3 rayDir, float3 sphereOrigin, float radius)
{
// http://wiki.cgsociety.org/index.php/Ray_Sphere_Intersection
float3 diff = rayOrigin - sphereOrigin;
float a = dot(rayDir, rayDir);
float b = 2.0f * dot(diff, rayDir);
float c = dot(diff, diff) - (radius * radius);
// Because we aren't using this function in the arbitrary, general sense, we know that we always have
// at least one intersection with the sphere so we don't need to check to for non-negative discriminant.
float discriminant = (b * b) - (4.0f * a * c);
float discrSqrt = sqrt(discriminant);
float q = b < 0.0f ? (-b + discrSqrt) * 0.5f : (-b - discrSqrt) * 0.5f;
float t1 = max(0, q / a);
float t2 = c / q;
float2 res = float2(t1,t2);
res.xy = res.x<res.y ? res.xy : res.yx;  // Sort.
return res;
}

// ---- fragment body (spliced into the generated main()) ----
float3 rayOrigin = worldCameraPosition.xyz;
float3 rayDir = normalize(pos.xyz - worldCameraPosition.xyz);
float3 sphereOrigin = crwpLightPos + worldCameraPosition.xyz;
// 1.1 is a magic tuning factor for spheres. Because we do this per-vertex, low
// tessellation geometry can result in junk results where the vertices don't lie
// exactly on the sphere surface so we compensate by expanding our actual sphere.
float sphereRadius = radius * 1.1f;
float2 tValues = intersectRaySphere(rayOrigin, rayDir, sphereOrigin, radius * 1.1f);
Current.texcoord4.zw = tValues;
