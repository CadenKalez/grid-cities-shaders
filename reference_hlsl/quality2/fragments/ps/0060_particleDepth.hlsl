// Shader fragment  [PS slot 60]  particleDepth

// ---- uniform parameters ----
uniform float4 nearFar;   // reg-meta 002e002e00010000000ffffd

// ---- fragment body (spliced into the generated main()) ----
float particleDepth = In.texcoord<t0>.x;
float worldDelta = (depth - particleDepth) * nearFar.y; // farClip
