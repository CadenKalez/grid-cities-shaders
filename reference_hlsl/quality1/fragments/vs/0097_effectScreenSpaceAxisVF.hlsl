// Shader fragment  [VS slot 97]  effectScreenSpaceAxisVF

// ---- uniform parameters ----
uniform float4 cameraParams[1];   // reg-meta 022202220001000000004000

// ---- fragment body (spliced into the generated main()) ----
float2 axis;
{
float screenWidth = cameraParams[0].x;
float screenHeight = cameraParams[0].y;
float ratio = screenHeight / screenWidth;
axis = saturate( 1 - clipPos.z ) * scale;
axis.x *= ratio;
}
