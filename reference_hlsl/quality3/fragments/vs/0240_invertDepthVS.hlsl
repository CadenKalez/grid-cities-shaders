// Shader fragment  [VS slot 240]  invertDepthVS

// ---- fragment body (spliced into the generated main()) ----
Current.position.z = Current.position.w - Current.position.z;
