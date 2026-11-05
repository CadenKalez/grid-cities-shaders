// Shader fragment  [PS slot 334]  regionDecalClip

// ---- fragment body (spliced into the generated main()) ----
// clip to within the volume
// TODO: should probably change the volume matrix to 0..1 instead of -1..1, to avoid the multiplies below
clip( 1.0f - abs( texturePosition ) );
