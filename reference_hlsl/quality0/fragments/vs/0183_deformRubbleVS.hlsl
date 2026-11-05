// Shader fragment  [VS slot 183]  deformRubbleVS

// ---- uniform parameters ----
uniform float4 gameInfo;   // reg-meta 024802480001000000000008

// ---- declarations / helper functions ----
static const int kNumPlanes = 4;
static const float4 kPlanes[kNumPlanes] = {
float4(normalize(float3(0,0.2,1)),1),
float4(normalize(float3(0,-0.2,1)),1),
float4(normalize(float3(0.2,0,1)),1),
float4(normalize(float3(-0.2,0,1)),1)
};
static const float3 kMove = float3(0,0,1);
static const float kOffs[kNumPlanes] = {
1.0/dot(kPlanes[0].xyz, kMove),
1.0/dot(kPlanes[1].xyz, kMove),
1.0/dot(kPlanes[2].xyz, kMove),
1.0/dot(kPlanes[3].xyz, kMove)
};

// ---- fragment body (spliced into the generated main()) ----
{
float planeOff = 0;
int maxPlane = 0;
float maxPlaneDist = dot(Current.position, float4(kPlanes[0].xyz, planeOff)) * kOffs[0];
for(int i = 1; i < kNumPlanes; ++i)
{
float thisPlaneDist = dot(Current.position, float4(kPlanes[i].xyz, planeOff)) * kOffs[i];
if(thisPlaneDist < maxPlaneDist)
{
maxPlane = i;
maxPlaneDist = thisPlaneDist;
}
}
Current.position.xyz += kMove * -max(maxPlaneDist,0.0) * 0.99;
}
