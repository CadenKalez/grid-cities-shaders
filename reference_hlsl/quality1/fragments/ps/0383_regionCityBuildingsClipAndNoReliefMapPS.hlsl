// Shader fragment  [PS slot 383]  regionCityBuildingsClipAndNoReliefMapPS

// ---- fragment body (spliced into the generated main()) ----
float2 uv_ddx1 = ddx( uv * regionXform.xy );
float2 uv_ddy1 = ddy( uv * regionXform.xy );
float2 uv_ddx2 = ddx( uv2 * regionXform2.xy );
float2 uv_ddy2 = ddy( uv2 * regionXform2.xy );
float2 baseUv = frac( uv ) * regionXform.xy + regionXform.zw;
float4 baseTintValues = tex2Dgrad( tintMapSampler, baseUv, uv_ddx1, uv_ddy1 );
clip( baseTintValues.a - 0.5f );
// handle padding and tiling
float2 relief_tc;
relief_tc = frac( uv2 );
relief_tc = relief_tc * ( 1.0f + tilePadding ) - ( tilePadding * 0.5f );
float4 tcBoundary = float4( 0.0f - relief_tc.xy, relief_tc.xy - 1.0f );
float outsideTile = dot( saturate( tcBoundary ), 1.0f );  // we really just care about this being > 0, the magnitude is irrelevant
relief_tc = relief_tc * regionXform2.xy + regionXform2.zw;
