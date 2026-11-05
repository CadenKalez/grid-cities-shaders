// Shader fragment  [PS slot 448]  clipOutlineBasedOnHeightPS

// ---- declarations / helper functions ----
extern uniform sampler2D currentHeightMap : register(s15);

// ---- fragment body (spliced into the generated main()) ----
// Mask out geometry beneath the terrain. Needed for roads because of their retaining
// walls.
float4 worldPos = In.texcoord<t0>;
worldPos.z += 0.5f; // z-bias for terrain clipping through road
float2 topDownUV = (worldPos.xy / 2048.0f) + 0.5f;
//float4 controlMap = tex2D(currentHeightMap, topDownUV);
//float height = controlMap.x + controlMap.y / 255.0; // [0,1]
float height = tex2D(currentHeightMap, topDownUV).r;
height *= 2048.0f;
height -= 1024.0f;
clip(worldPos.z - height);
