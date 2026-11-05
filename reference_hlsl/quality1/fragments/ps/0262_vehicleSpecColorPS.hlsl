// Shader fragment  [PS slot 262]  vehicleSpecColorPS

// ---- declarations / helper functions ----
static const float specColorOverbright = 5.0f;

// ---- fragment body (spliced into the generated main()) ----
specularColor = finalColor * specColorOverbright;
