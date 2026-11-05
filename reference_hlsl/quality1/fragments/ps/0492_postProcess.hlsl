// Shader fragment  [PS slot 492]  postProcess

// ---- uniform parameters ----
uniform float4 gameInfo;   // reg-meta 024802480001000000000008
uniform float4 screenInfo;   // reg-meta 020402040001000000000008

// ---- declarations / helper functions ----
extern uniform sampler      lensVignetteRadial   : register( s2 );

// ---- fragment body (spliced into the generated main()) ----
float4 vignetteTint = float4(0.25,0.25,0.25,0.75); //Color (RGB) & Opacity (A) This needs to be external and per CLUT
float4 vignetteTex = tex2D(lensVignetteRadial, In.texcoord0.xy);
vignetteTint.a *= vignetteTex.a;
Current.color.rgb = ((Current.color.rgb * vignetteTint.rgb) * vignetteTint.a) + (Current.color.rgb * (1-vignetteTint.a));
