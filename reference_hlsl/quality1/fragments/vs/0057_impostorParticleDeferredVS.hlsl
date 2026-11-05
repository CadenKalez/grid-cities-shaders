// Shader fragment  [VS slot 57]  impostorParticleDeferredVS

// ---- uniform parameters ----
uniform float4 nearFar;   // reg-meta 002e002e00010000000ffffd

// ---- fragment body (spliced into the generated main()) ----
Current.texcoord<t0>.x = pPos.w * nearFar.w;
Current.texcoord<t0>.y = cardDepth.z * scale * nearFar.w;
Current.texcoord<t0>.z = 0;
Current.texcoord<t1> = position.xyz;
