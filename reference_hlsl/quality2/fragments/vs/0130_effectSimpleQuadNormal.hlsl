// Shader fragment  [VS slot 130]  effectSimpleQuadNormal

// ---- uniform parameters ----
uniform float4 worldCameraDirection;   // reg-meta 002100210001000000004000

// ---- declarations / helper functions ----
// Implementation of Rodrigues' formula. Axis must be normalized before being passed in.
float3 RotateVector(float3 v, float3 axis, float angle)
{
float cosAngle = cos(angle);
return v * cosAngle + cross(axis, v) * sin(angle) + axis * dot(axis, v) * (1-cosAngle);
}
static const float2 offsets[4] = {
float2(-1,-1),
float2( 1,-1),
float2(-1, 1),
float2( 1, 1)
};

// ---- fragment body (spliced into the generated main()) ----
// Assuming the particle quad is always camera facing, camera-forward defines the plane of the quad,
// camera-right defines a horizontal direction in the plane, and camera-up defines a vertical direction, which
// combined with the current corner, we can figure out the "outward" diagonal direction at the current vertex.
// Corner numbering is as follows based on StreamParticlesUnified in SPGraphicsEffectsRenderer:
//      0 -> Bottom-Left
//      1 -> Bottom-Right
//      2 -> Top-Left
//      3 -> Top-Right
float3 normal = normalize(-worldCameraDirection.xyz);
float3 horizontalDirection = cross(worldCameraDirection.xyz, float3(0,0,1));
float3 verticalDirection = cross(horizontalDirection, worldCameraDirection.xyz);
// Compute the "outward" direction
float2 offset = offsets[corner];
float3 direction = offset.x * horizontalDirection + offset.y * verticalDirection;
// Rotate by current particle rotation
direction = normalize(RotateVector(direction, normal, rotation));
// Offset normal in the outward diagonal direction
normal += 1.0f * direction;
normal = normalize(normal);
