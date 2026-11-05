// Shader fragment  [PS slot 342]  streetpropIllumPS

// ---- declarations / helper functions ----
static const float3 kRedLight     = float3( 50.0f, 0.0f, 0.0f );
static const float3 kYellowLight  = float3( 50.0f,50.0f, 0.0f );
static const float3 kGreenLight   = float3(  0.0f,50.0f, 0.0f  );

// ---- fragment body (spliced into the generated main()) ----
float3 selfIllumMask = tex2D( illumSampler, In.texcoord0.xy ).rgb;
// red light, yellow light, green light
float3 inputSelfIllumMask = In.texcoord<t0>.xyz;//miscParams.xyz;
float3 emissiveMask = saturate( selfIllumMask.xyz * inputSelfIllumMask );
float emissiveScale = dot(selfIllumMask.xyz, inputSelfIllumMask);
float3 emissiveColorA = kRedLight       * emissiveMask.x;
float3 emissiveColorB = kYellowLight    * emissiveMask.y;
float3 emissiveColorC = kGreenLight     * emissiveMask.z;
Current.color.rgb += emissiveColorA + emissiveColorB + emissiveColorC;
