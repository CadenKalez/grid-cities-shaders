// Shader fragment  [VS slot 28]  unpackNormalTangent

// ---- fragment body (spliced into the generated main()) ----
Current.normal.xyz  = Current.normal.xyz  * 1.0/127.0 - 1;
Current.tangent.xyz = Current.tangent.xyz * 1.0/127.0 - 1;
