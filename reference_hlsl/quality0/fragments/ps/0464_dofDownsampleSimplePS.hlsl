// Shader fragment  [PS slot 464]  dofDownsampleSimplePS

// ---- uniform parameters ----
uniform float4 screenInfo;   // reg-meta 020402040001000000000008

// ---- declarations / helper functions ----
extern uniform sampler colorTex : register(s0);

// ---- fragment body (spliced into the generated main()) ----
float2 dofRowDelta = float2(0.0f,0.25f*screenInfo.w * 2.0f);
float2 rowOfs[4];
// "rowOfs" reduces how many moves PS2.0 uses to emulate swizzling.
rowOfs[0] = float2(0, 0);
rowOfs[1] = dofRowDelta.xy;
rowOfs[2] = dofRowDelta.xy * 2;
rowOfs[3] = dofRowDelta.xy * 3;
// Use bilinear filtering to average 4 color samples for free.
Current.color.rgba = float4(0, 0, 0, 0);
Current.color.rgba += tex2D( colorTex, In.texcoord0.xy + rowOfs[0] ).rgba;
Current.color.rgba += tex2D( colorTex, In.texcoord0.zw + rowOfs[0] ).rgba;
Current.color.rgba += tex2D( colorTex, In.texcoord0.xy + rowOfs[2] ).rgba;
Current.color.rgba += tex2D( colorTex, In.texcoord0.zw + rowOfs[2] ).rgba;
Current.color.rgba /= 4;
