// Shader fragment  [VS slot 126]  effectSimpleSetupVF

// ---- fragment body (spliced into the generated main()) ----
float3 position  = modelPosition.xyz;
float4 color = In.color;
float2 tileSize = In.texcoord0.xy;
float age = In.weights.x;
float frameDelta = In.weights.y;
// Rotation value range is [-128, 127] (i.e [-1, 1]) but has been scaled to 0-255 (well, really [0,1] because
// it's normalized for floating point read back so we need to unscale the data. The input value is also in
// number of turns so we need to turn that into radians
float rotation = ((In.weights.z * 255.0f) - 127.0f) / 128.0f * 6.28318531f;
float4 tiles = In.color1.xyzw * 255;
int corner = int(In.weights.w * 255);
int cx = corner % 2;
int cy = corner / 2;
tiles += float4(cx, 1 - cy, cx, 1 - cy);
float2 uvTile1 = tileSize * tiles.xy;
float2 uvTile2 = tileSize * tiles.zw;
