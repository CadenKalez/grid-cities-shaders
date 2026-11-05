// Shader fragment  [PS slot 34]  outputDeferredBumpNormalPS

// ---- declarations / helper functions ----
float3 getBestFitNormal( float3 inNormal )
{
return inNormal.xyz * 0.5 + 0.5;
}

// ---- fragment body (spliced into the generated main()) ----
Current.color.w = specE/255.0;
Current.color1 = float4( getBestFitNormal(bumpNormal.xyz), 1 );
