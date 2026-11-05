// Shader fragment  [PS slot 203]  planeWaterDataViewPS

// ---- uniform parameters ----
uniform struct { float4 baseColor; float4 fadeInfo; } globalDataView;   // reg-meta 02c602c60002000000000008

// ---- fragment body (spliced into the generated main()) ----
{
Current.color.rgba = float4(globalDataView.baseColor.rgb * 0.2, 1);
}
