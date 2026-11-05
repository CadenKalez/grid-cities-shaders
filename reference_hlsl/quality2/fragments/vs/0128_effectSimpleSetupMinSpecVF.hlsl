// Shader fragment  [VS slot 128]  effectSimpleSetupMinSpecVF

// ---- fragment body (spliced into the generated main()) ----
float3 position  = modelPosition.xyz;
float4 color = In.color;
float2 tileSize = In.texcoord0.xy;
float age = In.weights.x;
float frameDelta = In.weights.y;
float2 tiles = In.color1.xy * 255;
int corner = int(In.weights.w * 255);
int cx = corner % 2;
int cy = corner / 2;
tiles += float2(cx, 1 - cy);
float2 uvTile1 = tileSize * tiles.xy;
float2 uvTile2 = uvTile1;
