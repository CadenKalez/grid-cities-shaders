// Shader fragment  [PS slot 125]  roadDemolishTilePS

// ---- fragment body (spliced into the generated main()) ----
Current.color.rgb = In.color.rgb * In.color.a;
Current.color.a = In.color.a;
