// Shader fragment  [PS slot 319]  decalAnimateSDF

// ---- uniform parameters ----
uniform float4 gameInfo;   // reg-meta 024802480001000000000008

// ---- fragment body (spliced into the generated main()) ----
float4 animResults;
float4 useV;
{
float4 animParameters = decalMaterialData[3];
useV = float4(animParameters.x > 0 ? 0 : 1, animParameters.y > 0 ? 0 : 1, animParameters.z > 0 ? 0 : 1, animParameters.w > 0 ? 0 : 1);
animParameters = abs(animParameters);
animParameters += 0.0001; 
float animSpeed = decalMaterialInfo.y;
float animTime = frac(gameInfo.x * animSpeed + 0.9999);  
float4 animOffsets = frac(animParameters);
float4 animChunks = max(float4(1.0, 1.0, 1.0, 1.0), floor(animParameters));
float4 compares = floor((animTime * 3 - animOffsets) * animChunks) * (1 / animChunks);
float4 uvCompare = lerp(uvOrig.xxxx, uvOrig.yyyy, useV.xyzw);
animResults = uvCompare - compares;
}
