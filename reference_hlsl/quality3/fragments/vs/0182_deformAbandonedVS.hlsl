// Shader fragment  [VS slot 182]  deformAbandonedVS

// ---- declarations / helper functions ----
static const int kNumDeforms = 2;
static const float3 kDeformDir[kNumDeforms] = {
normalize(float3(1,1,0)),
normalize(float3(0,-1,1))
};
static const float3 kDeformUpAxis[kNumDeforms] = {
normalize(float3(1,0.1,0)),
normalize(float3(0.1,1,0))
};
static const float3 kDeformAxis[kNumDeforms] = {
normalize(cross(kDeformDir[0], kDeformUpAxis[0])),
normalize(cross(kDeformDir[1], kDeformUpAxis[1]))
};
static const float kDeformWavelength[kNumDeforms] = {
5,
6.5
};
static const float kDeformAmplitude[kNumDeforms] = {
.5, //0.5,
.8  //0.75,
};

// ---- fragment body (spliced into the generated main()) ----
{
for(int i = 0; i < kNumDeforms; ++i)
{
float len = dot(Current.position.xyz, kDeformDir[i]);
float amount = kDeformAmplitude[i] * sin(len / kDeformWavelength[i]);
Current.position.xyz += amount * kDeformAxis[i];
}
}
