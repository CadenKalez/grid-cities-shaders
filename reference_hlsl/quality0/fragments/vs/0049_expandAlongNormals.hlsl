// Shader fragment  [VS slot 49]  expandAlongNormals

// ---- uniform parameters ----
uniform float4 expandAmount;   // reg-meta 022002200001000000000008

// ---- fragment body (spliced into the generated main()) ----
Current.position.xyz = Current.position.xyz + Current.normal.xyz * expandAmount.x;
