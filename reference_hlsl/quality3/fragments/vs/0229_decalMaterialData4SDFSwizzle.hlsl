// Shader fragment  [VS slot 229]  decalMaterialData4SDFSwizzle

// ---- fragment body (spliced into the generated main()) ----
Current.color = float4(In.texcoord4.x,In.texcoord5.x,In.texcoord6.x,In.texcoord7.x);
Current.color1 = float4(In.texcoord4.y,In.texcoord5.y,In.texcoord6.y,In.texcoord7.y);
Current.texcoord<t0> = float4(In.texcoord4.z,In.texcoord5.z,In.texcoord6.z,In.texcoord7.z);
Current.texcoord<t1> = float4(In.texcoord4.w,In.texcoord5.w,In.texcoord6.w,In.texcoord7.w);
