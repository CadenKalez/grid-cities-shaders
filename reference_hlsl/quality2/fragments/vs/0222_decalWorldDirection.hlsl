// Shader fragment  [VS slot 222]  decalWorldDirection

// ---- declarations / helper functions ----
void BackTransformDirectionsNUS(float3x4 transform, out float3 x, out float3 y, out float3 z)
{
// assumes transform is non-uniform scale + rotation + translation
// i.e. M3x3 = NUS * Rot
//
// key insight here:
//   M3x3_inv
//   {def of M3x3}
//   = (NUS * Rot)_inv
//   {inv/* distribution law}
//   = Rot_inv * NUS_inv
//   {Rot is orthonormal, so inv == transpose}
//   = Rot_T * NUS_inv
//   {I}
//   = Rot_T * I * NUS_inv
//   {m * m_inv == I}
//   = Rot_T * NUS * NUS_inv * NUS_inv
//   {associate}
//   = (Rot_T * NUS) * NUS_inv^2
//   {for all NUS matrices m, m_T == m}
//   = (Rot_T * NUS_T) * NUS_inv^2
//   {transpose/* distribution law}
//   = (NUS * Rot)_T * NUS_inv^2
//   {def of M3x3}
//   = M3x3_T * NUS_inv^2
//
// Can extract NUS from M since Rot is orthonormal using dot of columns
float3 sqrScale;
sqrScale.x = dot(transform[0].xyz, transform[0].xyz);
sqrScale.y = dot(transform[1].xyz, transform[1].xyz);
sqrScale.z = dot(transform[2].xyz, transform[2].xyz);
float3 invSqrScale = 1.0 / sqrScale;
// apply M3x3_T * NUS_inv^2 to x=(1,0,0), y=(0,1,0), z=(0,0,1)
x = (transform[0] * invSqrScale.x).xyz;
y = (transform[1] * invSqrScale.y).xyz;
z = (transform[2] * invSqrScale.z).xyz;
}

// ---- fragment body (spliced into the generated main()) ----
// urk can't backtransform modeltotexture because nonuniform scale assumption is violated
float3 x, y, z;
BackTransformDirectionsNUS(modelToTexture, x, y, z);
float3 worldTextureDirection = mul(modelToWorld, float4(-z, 0));
// these calculations will get skipped if not needed
float3 worldTextureU = mul(modelToWorld, float4(-x, 0));
float3 worldTextureV = mul(modelToWorld, float4(-y, 0));
Current.texcoord<t0>.xyz = worldTextureDirection;
