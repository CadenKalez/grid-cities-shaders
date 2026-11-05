// Shader fragment  [VS slot 168]  planeWaterSkirtColorVS

// ---- uniform parameters ----
uniform struct { float4 mWaterInfo; float4 mReflectionParams; float4 mScaleAndBias1; float4 mScaleAndBias2; } terrainSurfaceInfoVS;   // reg-meta 028102810004000000000008

// ---- fragment body (spliced into the generated main()) ----
{
Current.position.x *= 0.99;
Current.position.y *= 0.99;
Current.position.z *= 1.01;
}
