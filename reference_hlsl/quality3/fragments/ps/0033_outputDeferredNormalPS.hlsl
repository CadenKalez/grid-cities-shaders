// Shader fragment  [PS slot 33]  outputDeferredNormalPS

// ---- declarations / helper functions ----
float3 getBestFitNormal( float3 inNormal )
{
return inNormal.xyz * 0.5 + 0.5;
}

// ---- fragment body (spliced into the generated main()) ----
float3 normal      = In.texcoord<t0>.xyz;
Current.color.w = 8/255.0;
Current.color1 = float4( getBestFitNormal(normal.xyz), 0 );
