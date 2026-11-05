// Shader fragment  [PS slot 174]  grassSlicePS

// ---- fragment body (spliced into the generated main()) ----
static const float distAcrossClump = 16.0;  
float delme1 = abs(In.texcoord<t1>.x) - (distAcrossClump*0.5);
delme1 = (delme1 > 0) ? -1 : 0;
float delme2 = abs(In.texcoord<t1>.y) - (distAcrossClump*0.5);
delme2 = (delme2 > 0) ? -1 : 0;
float delme3 = abs(In.texcoord<t1>.z) - (distAcrossClump*0.5);
delme3 = (delme3 > 0) ? -1 : 0;
clip(delme1);
clip(delme2);
clip(delme3);
clip(In.texcoord<t1>.z);  
float bladeID = In.texcoord<t0>.w;
Current.color = float4(In.texcoord<t0>.xyz * 0.5 + 0.5, bladeID);  
Current.color1 = float4(In.texcoord<t2>.rgb, 1.0);
