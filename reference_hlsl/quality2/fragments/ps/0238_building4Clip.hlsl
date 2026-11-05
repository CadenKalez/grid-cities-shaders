// Shader fragment  [PS slot 238]  building4Clip

// ---- fragment body (spliced into the generated main()) ----
float2 uv_ddx = ddx(uv * regionXform.xy);
float2 uv_ddy = ddy(uv * regionXform.xy);
float2 baseUv = frac(uv) * regionXform.xy + regionXform.zw;
float4 baseTintValues = tex2Dgrad(tintMapSampler, baseUv, uv_ddx, uv_ddy);
Current.color.a = (baseTintValues.a - 0.5 < 0)?0:1;
