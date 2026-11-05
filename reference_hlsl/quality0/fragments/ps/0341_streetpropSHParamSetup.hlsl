// Shader fragment  [PS slot 341]  streetpropSHParamSetup

// ---- declarations / helper functions ----
const static float kSH_A1 = 2.0 / 3.0;
const static float kSH_A2 = 1.0 / 4.0;
const static float kSH_A3 = 0;
const static float kSH_A4 = -1.0 / 24.0;
const static float kDefaultGloss = 0.00;
const static float kGlossyMax    = 1.0; // threshold at which glossy maxes out
const static float kCelOutlineThreshold        = 0.25;
const static float kCelOutlineThresholdRange   = 0.075;
const static float kCelStrength                = 0.3;
const static float kSpecExponentMaxValue = 60.0;
const static bool kSaveInstructions = false;

// ---- fragment body (spliced into the generated main()) ----
float specE        = 15.0;
float specStrength = 1.0;
float gloss        = 0.1;
