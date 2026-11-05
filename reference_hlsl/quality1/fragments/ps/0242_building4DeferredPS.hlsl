// Shader fragment  [PS slot 242]  building4DeferredPS

// ---- declarations / helper functions ----
float3 ApplyNormalMap(float3 vertNormal, float3 vertDS, float3 nmapNormal)
{
float3 vn = normalize(vertNormal);
float3 dt = normalize(cross(vn, vertDS));
float3 ds = cross(dt, vn);
nmapNormal = normalize(nmapNormal.r * ds + nmapNormal.g * dt + nmapNormal.b * vn);
return nmapNormal;
}
float3 getBestFitNormal( float3 inNormal )
{
return inNormal.xyz * 0.5 + 0.5;
}

// ---- fragment body (spliced into the generated main()) ----
// sample textures
float4 facadeTintValues = tex2Dgrad(tintMapSampler,    relief_tc,  uv_ddx, uv_ddy);
float4 normalMapBase    = tex2Dgrad(normalMapSampler,  baseUv,     uv_ddx, uv_ddy);
float4 normalMapTop     = tex2Dgrad(normalMapSampler,  relief_tc,  uv_ddx, uv_ddy);
facadeTintValues.a = (outsideTile > 0) ? 0 : facadeTintValues.a;
// Is normal lerp good enough?  Should renormalize?
float4 normalMapSampled = lerp(normalMapBase, normalMapTop, facadeTintValues.a);
// unpack
float3 normalMap = normalMapSampled.rgb;
float3 nmapNormal = normalMap.rgb * 2 - 0.9985;
float3 bumpNormal = ApplyNormalMap(worldNormal, worldTangent, nmapNormal);
specE = 8;
outputDepth *= 255.0;
Current.color.xyz = float3(floor(outputDepth) / 255.0, floor(frac(outputDepth)*255.0) / 255.0, frac(outputDepth*255.0));
Current.color.w = Current.color.w*specE/255.0;  // current.color.w should be 0 or 1 before this
Current.color1 = float4( getBestFitNormal(bumpNormal.xyz), 1 );
