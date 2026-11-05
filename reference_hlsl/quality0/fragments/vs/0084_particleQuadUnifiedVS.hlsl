// Shader fragment  [VS slot 84]  particleQuadUnifiedVS

// ---- uniform parameters ----
uniform float4x4 modelToClip;   // reg-meta 000600060004000000004001
uniform float4 worldCameraDirection;   // reg-meta 002100210001000000004000

// ---- fragment body (spliced into the generated main()) ----
float4 tiles = Current.color1.xyzw * 255;
int corner = 0;
int cx = corner % 2;
int cy = corner / 2;
tiles += float4(cx, 1 - cy, cx, 1 - cy);
float2 uv0 = Current.texcoord0 * tiles.xy;
float2 uv1 = Current.texcoord0 * tiles.zw;
Current.position = mul(float4(Current.position, 1), modelToClip);
Current.texcoord0 = uv0;
Current.texcoord1 = uv1;
