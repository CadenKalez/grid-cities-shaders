// Shader fragment  [PS slot 390]  unitParticleDeferredPS

// ---- fragment body (spliced into the generated main()) ----
float outputDepth = In.texcoord<t1>.x;
clip( diffuseMapSample.a - 1.0f );
outputDepth    = saturate( outputDepth + normalDepth.w * In.texcoord<t1>.y );
Current.color  = float4( floor( outputDepth * 255.0f ) / 255.0f, frac( outputDepth * 255.0f ), frac( frac( outputDepth * 255.0f ) * 255.0f ), 8.0f / 255.0f);
Current.color1 = float4( normalDepth.xyz * 0.5f + 0.5f, 1.0f );
