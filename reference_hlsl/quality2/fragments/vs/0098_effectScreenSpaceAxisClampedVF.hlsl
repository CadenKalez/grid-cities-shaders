// Shader fragment  [VS slot 98]  effectScreenSpaceAxisClampedVF

// ---- uniform parameters ----
uniform float4 cameraParams[1];   // reg-meta 022202220001000000004000
uniform float4 customParams[2];   // reg-meta 020602060002000000000008

// ---- fragment body (spliced into the generated main()) ----
float2 axis;
{
float screenWidth = cameraParams[0].x;
float screenHeight = cameraParams[0].y;
float ratio = screenHeight / screenWidth;
axis = saturate( 1 - clipPos.z ) * scale;
float minScaleRatio = customParams[0].z;
float maxScaleRatio = customParams[0].w;
axis = clamp( axis, minScaleRatio, maxScaleRatio );
axis.x *= ratio;
}
