// Shader fragment  [PS slot 437]  spotFoggingPixelTPF

// ---- declarations / helper functions ----
// Working around the fact that argscript treats ampersand as escape character.
bool AND(bool a, bool b)
{
return bool(int(a) * int(b));
}
// Returns t1, t2 first and second intersection with cone. t1 is 0 if rayOrigin is inside the cone..
// This function expects all input to be in world-space.
float2 intersectRayCone(float3 coneOrigin, float3 coneAxis, float3 rayOrigin, float3 rayDir, float coneHeight, float cosHalfAngle)
{
// http://www.geometrictools.com/LibMathematics/Intersection/Intersection.html
float AdD = dot(coneAxis, rayDir);  // 0
float cosSqr = cosHalfAngle*cosHalfAngle;   // 0.75
float3 E = rayOrigin - coneOrigin;  // -1,0,0
float AdE = dot(coneAxis, E);       // 0
float DdE = dot(rayDir, E);         // -1
float EdE = dot(E,E);               // 1
//float c2 = AdD*AdD - cosSqr;        // -0.75
//float c1 = AdD*AdE - cosSqr*DdE;    // 0.75
//float c0 = AdE*AdE - cosSqr*EdE;    // -0.75
float3 dotResults = float3(AdD, AdD, AdE);
float3 coeff = float3(AdD, AdE, AdE);
float3 sub = float3(cosSqr, cosSqr*DdE, cosSqr*EdE);
float3 cs = dotResults * coeff - sub;
//float discr = c1*c1 - c0*c2;  // 0
float discr = cs.y * cs.y - cs.z * cs.x;
float root = sqrt(max(0.0,discr));
//float invC2 = 1.0f/c2;  // -1.33333333
float invC2 = 1.0f / cs.x;
//float t2 = (-c1 - root) * invC2;  // (-0.75 - 0) * -1.33333 = 1
//float t1 = (-c1 + root) * invC2;  // (-0.75 + 0) * -1.33333 = 1
float3 ts = float3((-cs.y - root), (-cs.y + root), 0.0f) * invC2;
// Ray/plane for base intersection
float3 basePos = coneOrigin + coneAxis * coneHeight;
float3 Pn = -coneAxis;
float3 Rd = rayDir;
float Vd = dot(Pn, Rd);
float V0 = dot(basePos - rayOrigin, Pn);
//float t3 = V0 / Vd;
ts.z = V0/ Vd;
// Intersection results.
float3 r1 = rayOrigin + (rayDir * ts.y) - coneOrigin;
float3 r2 = rayOrigin + (rayDir * ts.x) - coneOrigin;
float3 r3 = rayOrigin + (rayDir * ts.z) - coneOrigin;
// Range checks; discard results above or below the cone
float dotResult = dot(r1, coneAxis);
bool b1 = AND(dotResult > 0.0f, dotResult <= coneHeight);
dotResult = dot(r2, coneAxis);
bool b2 = AND(dotResult > 0.0f, dotResult <= coneHeight);
// Discard base results outside the cone
float angle = dot(normalize(r3), coneAxis);
bool b3 = (angle >= cosHalfAngle);
// Fix t's that are behind us.
//t1 = max(t1, 0);
//t3 = max(t3, 0);
ts = max(ts, float3(0,0,0));
float2 res = float2(0,0);
//res = AND(b1, b2) ? float2(t1, t2) : res;
//res = AND(b1, b3) ? float2(t1, t3) : res;
//res = AND(b2, b3) ? float2(t3, t2) : res;
res = AND(b1, b2) ? ts.yx : res;
res = AND(b1, b3) ? ts.yz : res;
res = AND(b2, b3) ? ts.zx : res;
res.xy = res.x<=res.y ? res.xy : res.yx;  // Sort.
return res;
}

// ---- fragment body (spliced into the generated main()) ----
float3 rayOrigin = float3(0,0,0);
float3 coneOrigin = crwpLightPos;
float3 coneAxis = -spotDir;
float3 cosHalfAngle = radius;
float2 tValues = intersectRayCone(coneOrigin, coneAxis, rayOrigin, rayDir, falloffDist, cosHalfAngle);
