// Shader fragment  [VS slot 161]  cityBoundaryVS

// ---- uniform parameters ----
uniform float4x4 worldToClip;   // reg-meta 000c000c0004000000004000
uniform float4 customParams[4];   // reg-meta 020602060004000000000008

// ---- declarations / helper functions ----
sampler HeightMapVS : register(s0);

// ---- fragment body (spliced into the generated main()) ----
// Total hack to compute top-down UV: we know the city box is limited to 2048x2048
// so we just take our current xy positions (given in world space) and scale and
// bias them to get UV coords
float2 topDownUV = (Current.position.xy + 1024.0f) / 2048.0f;
// Height is [0,1] so we need to unnormalize to get correct value
float height = tex2Dlod(HeightMapVS, float4(topDownUV, 0, 0)).x;
height *= 2048.0f;
height -= 1024.0f;
// Clamp to sea level
height = max(height, customParams[0].y);
// Slight bias to pass depth testing with terrain
height += 2.5f;
float4 worldPos = float4(Current.position.xy, height, 1);
Current.position = mul(worldPos, worldToClip);
Current.texcoord<t0> = In.texcoord0.xy;
