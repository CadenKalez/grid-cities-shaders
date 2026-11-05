// Shader fragment  [PS slot 32]  outputDeferredNormalUpPS

// ---- declarations / helper functions ----
float3 getBestFitNormal( float3 inNormal )
{
return inNormal.xyz * 0.5 + 0.5;
}

// ---- fragment body (spliced into the generated main()) ----
float3 normal = float3(0,0,1);
Current.color.w = 8/255.0;
Current.color1 = float4( getBestFitNormal(normal.xyz), 0 );
