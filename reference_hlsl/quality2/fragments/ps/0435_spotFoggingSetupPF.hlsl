// Shader fragment  [PS slot 435]  spotFoggingSetupPF

// ---- uniform parameters ----
uniform struct { float4 mGammaAndFog;float4 mFogInfo;float4 mWindInfo;} userGammaAndFog;   // reg-meta 02d402d40003000000000008
uniform float4 gameInfo;   // reg-meta 024802480001000000000008

// ---- fragment body (spliced into the generated main()) ----
float3 fogColor = userGammaAndFog.mFogInfo.xyz;
float fogQuality = userGammaAndFog.mFogInfo.w;
float3 fogStrengthInfo = userGammaAndFog.mGammaAndFog.yzw;
float minFogStrength = max(fogStrengthInfo.x, volStrength);
float fogStrength = lerp(minFogStrength, fogStrengthInfo.y, fogStrengthInfo.z);
 float farClip = cameraParams.mNearFar.y;

float3 rayDir = normalize(crwpFarClip);
// Construct UV coords from pixel world position
float2 worldUV = worldXY / 768.0f;
// Read in animation speed multiplier
float fogAnimSpeed = userGammaAndFog.mWindInfo.z;
// Wind direction is passed in in view space. We then scale by the game time to get
// our uv animation direction.
float2 windDirViewSpace = normalize(userGammaAndFog.mWindInfo.xy) * gameInfo.x * fogAnimSpeed;
float4 fogNoise = volStrength < 0 ? float4(1,1,1,1) : tex2D(lightFogSampler, worldUV - windDirViewSpace);
