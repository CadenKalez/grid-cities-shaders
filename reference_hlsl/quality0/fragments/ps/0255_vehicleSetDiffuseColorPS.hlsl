// Shader fragment  [PS slot 255]  vehicleSetDiffuseColorPS

// ---- fragment body (spliced into the generated main()) ----
float3 paintColor   = tex2D( paintPaletteSampler, float2( miscParams.x, 0.0f ) ).rgb;
float4 diffuseTex   = tex2D( diffuseSampler, uv0 );
float4 diffuseColor = float4( lerp( paintColor, diffuseTex.rgb, diffuseTex.a ), 1.0f );
