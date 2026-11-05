// Shader fragment  [PS slot 349]  impostorTreeCommonPS

// ---- declarations / helper functions ----
float3 ApplyNormalMap(float3 vertNormal, float3 vertDS, float3 nmapNormal)
{
float3 vn = normalize(vertNormal);
float3 dt = normalize(cross(vn, vertDS));
float3 ds = cross(dt, vn);
nmapNormal = normalize(nmapNormal.r * ds + nmapNormal.g * dt + nmapNormal.b * vn);
return nmapNormal;
}

// ---- fragment body (spliced into the generated main()) ----
float3 clipPosition = In.texcoord<t1>.xyz;              
clip(float4(1 + clipPosition.xy, 1 - clipPosition.xy));
float2 uv0 = In.texcoord<t0>.xy;
float2 uv1 = In.texcoord<t0>.zw;
float3 vertNormal = In.texcoord<t2>.xyz;
float3 vertTangent = In.texcoord<t3>.xyz;
float leavesFallen = In.texcoord<t2>.w;
float4 diffuseMap = tex2D(Sampler<s0>, uv0);
float4 normalMap  = tex2D(Sampler<s1>, uv0);
float4 aoMap      = tex2D(Sampler<s2>, uv1);
Current.color.rgb = diffuseMap.rgb * aoMap.rgb;
float3 bumpNormal = vertNormal;
