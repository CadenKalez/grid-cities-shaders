// Shader fragment  [VS slot 127]  effectSimpleSetupInstancedVF

// ---- fragment body (spliced into the generated main()) ----
float3 position  = modelPosition.xyz;
float3 up = In.texcoord0.xyz;
float3 across = In.texcoord1.xyz;
float4 color = In.color;
float2 tileSize = In.texcoord2.xy;
float age = In.weights.x;
float frameDelta = In.weights.y;
float size = In.weights.z;
float4 tiles = In.color1.xyzw * 255;
int corner = int(In.weights.w * 255);
int cx = corner % 2;
int cy = corner / 2;
tiles += float4(cx, 1 - cy, cx, 1 - cy);
float2 uvTile1 = tileSize * tiles.xy;
float2 uvTile2 = tileSize * tiles.zw;
