// Shader fragment  [PS slot 57]  particlesNormalMapDir

// ---- uniform parameters ----
uniform float4 ambient;   // reg-meta 002300230001000000000020
uniform struct { float4 mDir; float4 mColor; } dirLightsWorld[4];   // reg-meta 021402140008000000003fc0
uniform float4x3 cameraToWorld;   // reg-meta 000d000d0003000000004000

// ---- fragment body (spliced into the generated main()) ----
float4 texColor = tex2D(Sampler0, In.texcoord0);
// compute normal map
float4 texNMap = tex2D(Sampler1, In.texcoord0);
float3 nmapNormal = 2 * texNMap.rgb - 1;
nmapNormal.z = -nmapNormal.z;   // flip z to point towards camera
nmapNormal = mul(nmapNormal, cameraToWorld);
float4 dotNL;
dotNL.x = dot(dirLightsWorld[0].mDir.xyz, nmapNormal);
dotNL.y = dot(dirLightsWorld[1].mDir.xyz, nmapNormal);
dotNL.z = dot(dirLightsWorld[2].mDir.xyz, nmapNormal);
dotNL.w = dot(dirLightsWorld[3].mDir.xyz, nmapNormal);
float4 intensity = saturate(dotNL);
float3 light = ambient.rgb;
light = ambient.rgb;
light += intensity.x * dirLightsWorld[0].mColor.rgb;
light += intensity.y * dirLightsWorld[1].mColor.rgb;
light += intensity.z * dirLightsWorld[2].mColor.rgb;
light += intensity.w * dirLightsWorld[3].mColor.rgb;
Current.color.rgb *= light;
