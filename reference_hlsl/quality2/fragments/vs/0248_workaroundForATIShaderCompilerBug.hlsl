// Shader fragment  [VS slot 248]  workaroundForATIShaderCompilerBug

// ---- fragment body (spliced into the generated main()) ----
// Apparently if we don't send anything depending on this value
// to an interpolator, all of Current.color gets optimized out
// of the shader, and so all the camerafacing stuff gets thrown out.
// Yay!
Current.texcoord<t0> = Current.color;
