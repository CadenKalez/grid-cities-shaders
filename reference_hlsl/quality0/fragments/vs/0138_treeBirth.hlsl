// Shader fragment  [VS slot 138]  treeBirth

// ---- uniform parameters ----
uniform float4 gameInfo;   // reg-meta 024802480001000000000008

// ---- fragment body (spliced into the generated main()) ----
const float kAnimSpeed       = 1.5; 
const float kTransitionSpeed = 2;   
const float kObjectHeight    = 10;
const float kVertFraction    = 0.3; 
float birthTime = Current.color.a;
Current.color.a = 1;
float t0 = kAnimSpeed * birthTime;
float t1 = saturate(t0 / kVertFraction);           
float t2 = saturate((t0 - kVertFraction) / (1 - kVertFraction));   
float relZ = Current.position.z  / kObjectHeight; 
Current.position.z *= t1;
Current.position.xy *= 0.1 + 0.9 * saturate(kTransitionSpeed * ((relZ - 1) + 2 * t2));
