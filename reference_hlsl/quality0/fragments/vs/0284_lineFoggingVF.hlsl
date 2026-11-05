// Shader fragment  [VS slot 284]  lineFoggingVF

// ---- uniform parameters ----
uniform float4 worldCameraPosition;   // reg-meta 001f001f0001000000004000

// ---- declarations / helper functions ----
// Working around the fact that argscript treats ampersand as escape character.
bool AND(bool a, bool b)
{
return bool(int(a) * int(b));
}
// This function generates two mutually orthogonal vectors from input
// axis (which must be normalized).
float2x3 GenerateComplementBasis(float3 w)
{
float3 u,v;
float select = float(abs(w.x) >= abs(w.y));
float invLength = rsqrt(lerp(w.y * w.y, w.x * w.x, select) + w.z * w.z);
float3 u1 = float3(-w.z * invLength, 0.0f, w.x * invLength);
float3 u2 = float3(0.0f, w.z * invLength, -w.y * invLength);
u = lerp(u2, u1, select);
v = cross(u,w);
return float2x3(u,v);
}
// Returns t1, t2 first and second intersection with cylinder. t1 is 0 if rayOrigin is inside the cylinder.
// CylinderOrigin must be the midway point between the end caps of the cylinder, along the cylinder axis.
float2 intersectRayCylinder(float3 rayOrigin, float3 rayDir, float3 cylinderOrigin, float3 cylinderAxis,
float cylinderHeight, float cylinderRadius)
{
// http://www.geometrictools.com/LibMathematics/Intersection/Intersection.html
float2x3 basis = GenerateComplementBasis(cylinderAxis);
float3 u = basis[0];
float3 v = basis[1];
float3 w = cylinderAxis;
float halfHeight = cylinderHeight * 0.5f;
float rsqr = cylinderRadius * cylinderRadius;
// Convert incoming ray origin to cylinder coordinates.
float3 diff = rayOrigin - cylinderOrigin;
float3 p = float3(dot(diff,u), dot(diff,v), dot(diff,w));
// Convert the incoming ray direction to cylinder coordinates.
float3 d = float3(dot(rayDir,u), dot(rayDir,v), dot(rayDir,w));
// Test intersection with planes of end caps. If we're inside the cylinder,
// one of the t-values will be negative.
float3 planePosTop = cylinderOrigin + (cylinderAxis * halfHeight);
float Vd = dot(rayDir, cylinderAxis);
float V0 = dot(planePosTop - rayOrigin, cylinderAxis);
float tp0 = V0 / Vd;
float3 planePosBottom = cylinderOrigin - (cylinderAxis * halfHeight);
Vd = dot(rayDir, -cylinderAxis);
V0 = dot(planePosBottom - rayOrigin, -cylinderAxis);
float tp1 = V0 / Vd;
bool intersectsTop = length((rayOrigin + rayDir * tp0) - planePosTop) <= cylinderRadius;
bool intersectsBottom = length((rayOrigin + rayDir * tp1) - planePosBottom) <= cylinderRadius;
// Test intersection with cylinder wall
float a0 = p.x * p.x + p.y * p.y - rsqr;
float a1 = p.x * d.x + p.y * d.y;
float a2 = d.x * d.x + d.y * d.y;
float discr = max(0, a1 * a1 - a0 * a2);
float root = sqrt(discr);
float inv2 = 1.0f / (a2 + 0.00000000001f);
float tc0 = (-a1 - root) * inv2;
float tc1 = (-a1 + root) * inv2;
// Intersection results
float3 rc0 = rayOrigin + rayDir * tc0;
float3 rc1 = rayOrigin + rayDir * tc1;
// Check bounds of cylinder wall t-values as that tests against the infinite cylinder wall.
bool b1 = abs(dot(rc0 - cylinderOrigin, cylinderAxis)) <= halfHeight;
bool b2 = abs(dot(rc1 - cylinderOrigin, cylinderAxis)) <= halfHeight;
tc0 = max(tc0, 0);
tc1 = max(tc1, 0);
tp0 = max(tp0, 0);
tp1 = max(tp1, 0);
// Determine results. Only four cases:
//      1. End-to-end.
//      2. Wall-to-end cap.
//      3. Wall-to-top cap.
//      4. Wall-to-wall.
float2 res = float2(tc0, tc1);
res = AND(intersectsTop, intersectsBottom) ? float2(tp0, tp1) : res;
res = AND(AND(intersectsTop, !intersectsBottom),b1) ? float2(tp0, tc0) : res;
res = AND(AND(intersectsTop, !intersectsBottom),b2) ? float2(tp0, tc1) : res;
res = AND(AND(!intersectsTop, intersectsBottom),b1) ? float2(tp1, tc0) : res;
res = AND(AND(!intersectsTop, intersectsBottom),b2) ? float2(tp1, tc1) : res;
// Sort
res.xy = res.x<=res.y ? res.xy : res.yx;
return res;
//return float2(intersectsTop, intersectsBottom);
}

// ---- fragment body (spliced into the generated main()) ----
float height = length(ray);
float3 rayOrigin = worldCameraPosition.xyz;
float3 rayDir = normalize(vertexWorldPos.xyz - rayOrigin);
float3 cylinderOrigin = p0 + rayNormal * height * 0.5f;
float3 cylinderAxis = rayNormal;
float cylinderRadius = radius;
float2 tValues = intersectRayCylinder(rayOrigin, rayDir, cylinderOrigin, cylinderAxis, height, cylinderRadius);
Current.texcoord0.w = tValues.x;
Current.texcoord1.w = tValues.y;
