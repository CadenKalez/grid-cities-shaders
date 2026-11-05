// Shader fragment  [VS slot 55]  impostorParticleDepthSpriteVS

// ---- fragment body (spliced into the generated main()) ----
float2 reconstructDepth = mul(float4(0,0,cardDepth.z*scale,0), cameraToClip).zw;
Current.texcoord<t0> = float4(Current.position.zw, reconstructDepth);
