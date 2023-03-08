#pragma once
    // This is based on NVidia's GPU shader web-site: Vertex Noise shader:
    //    http://http.download.nvidia.com/developer/SDK/Individual_Samples/samples.html#glsl_vnoise
    //
    // Where, the noice function is more or less based on:
    // Perlin's original code:
    //
    //     http://mrl.nyu.edu/~perlin/doc/oscar.html
    //
    // Implementation based on:
    //     http://mrl.nyu.edu/~perlin/noise/
    // 
    // Copied (cut/paste) from:
    //     https://forum.unity.com/threads/2d-3d-4d-optimised-perlin-noise-cg-hlsl-library-cginc.218372/
    //      Scroll to the posting on by xesiomterim on Sep 25, 2020
    //
    //     Reference paper: http://mrl.nyu.edu/~perlin/paper445.pdf
    //
    // Added: 2D and 1D access to noise


static const int permutation[256] =
{
    151, 160, 137, 91, 90, 15,
    131, 13, 201, 95, 96, 53, 194, 233, 7, 225, 140, 36, 103, 30, 69, 142, 8, 99, 37, 240, 21, 10, 23,
    190, 6, 148, 247, 120, 234, 75, 0, 26, 197, 62, 94, 252, 219, 203, 117, 35, 11, 32, 57, 177, 33,
    88, 237, 149, 56, 87, 174, 20, 125, 136, 171, 168, 68, 175, 74, 165, 71, 134, 139, 48, 27, 166,
    77, 146, 158, 231, 83, 111, 229, 122, 60, 211, 133, 230, 220, 105, 92, 41, 55, 46, 245, 40, 244,
    102, 143, 54, 65, 25, 63, 161, 1, 216, 80, 73, 209, 76, 132, 187, 208, 89, 18, 169, 200, 196,
    135, 130, 116, 188, 159, 86, 164, 100, 109, 198, 173, 186, 3, 64, 52, 217, 226, 250, 124, 123,
    5, 202, 38, 147, 118, 126, 255, 82, 85, 212, 207, 206, 59, 227, 47, 16, 58, 17, 182, 189, 28, 42,
    223, 183, 170, 213, 119, 248, 152, 2, 44, 154, 163, 70, 221, 153, 101, 155, 167, 43, 172, 9,
    129, 22, 39, 253, 19, 98, 108, 110, 79, 113, 224, 232, 178, 185, 112, 104, 218, 246, 97, 228,
    251, 34, 242, 193, 238, 210, 144, 12, 191, 179, 162, 241, 81, 51, 145, 235, 249, 14, 239, 107,
    49, 192, 214, 31, 181, 199, 106, 157, 184, 84, 204, 176, 115, 121, 50, 45, 127, 4, 150, 254,
    138, 236, 205, 93, 222, 114, 67, 29, 24, 72, 243, 141, 128, 195, 78, 66, 215, 61, 156, 180
};
 
static const int p[512] =
{
    151, 160, 137, 91, 90, 15,
    131, 13, 201, 95, 96, 53, 194, 233, 7, 225, 140, 36, 103, 30, 69, 142, 8, 99, 37, 240, 21, 10, 23,
    190, 6, 148, 247, 120, 234, 75, 0, 26, 197, 62, 94, 252, 219, 203, 117, 35, 11, 32, 57, 177, 33,
    88, 237, 149, 56, 87, 174, 20, 125, 136, 171, 168, 68, 175, 74, 165, 71, 134, 139, 48, 27, 166,
    77, 146, 158, 231, 83, 111, 229, 122, 60, 211, 133, 230, 220, 105, 92, 41, 55, 46, 245, 40, 244,
    102, 143, 54, 65, 25, 63, 161, 1, 216, 80, 73, 209, 76, 132, 187, 208, 89, 18, 169, 200, 196,
    135, 130, 116, 188, 159, 86, 164, 100, 109, 198, 173, 186, 3, 64, 52, 217, 226, 250, 124, 123,
    5, 202, 38, 147, 118, 126, 255, 82, 85, 212, 207, 206, 59, 227, 47, 16, 58, 17, 182, 189, 28, 42,
    223, 183, 170, 213, 119, 248, 152, 2, 44, 154, 163, 70, 221, 153, 101, 155, 167, 43, 172, 9,
    129, 22, 39, 253, 19, 98, 108, 110, 79, 113, 224, 232, 178, 185, 112, 104, 218, 246, 97, 228,
    251, 34, 242, 193, 238, 210, 144, 12, 191, 179, 162, 241, 81, 51, 145, 235, 249, 14, 239, 107,
    49, 192, 214, 31, 181, 199, 106, 157, 184, 84, 204, 176, 115, 121, 50, 45, 127, 4, 150, 254,
    138, 236, 205, 93, 222, 114, 67, 29, 24, 72, 243, 141, 128, 195, 78, 66, 215, 61, 156, 180,
 
    151, 160, 137, 91, 90, 15,
    131, 13, 201, 95, 96, 53, 194, 233, 7, 225, 140, 36, 103, 30, 69, 142, 8, 99, 37, 240, 21, 10, 23,
    190, 6, 148, 247, 120, 234, 75, 0, 26, 197, 62, 94, 252, 219, 203, 117, 35, 11, 32, 57, 177, 33,
    88, 237, 149, 56, 87, 174, 20, 125, 136, 171, 168, 68, 175, 74, 165, 71, 134, 139, 48, 27, 166,
    77, 146, 158, 231, 83, 111, 229, 122, 60, 211, 133, 230, 220, 105, 92, 41, 55, 46, 245, 40, 244,
    102, 143, 54, 65, 25, 63, 161, 1, 216, 80, 73, 209, 76, 132, 187, 208, 89, 18, 169, 200, 196,
    135, 130, 116, 188, 159, 86, 164, 100, 109, 198, 173, 186, 3, 64, 52, 217, 226, 250, 124, 123,
    5, 202, 38, 147, 118, 126, 255, 82, 85, 212, 207, 206, 59, 227, 47, 16, 58, 17, 182, 189, 28, 42,
    223, 183, 170, 213, 119, 248, 152, 2, 44, 154, 163, 70, 221, 153, 101, 155, 167, 43, 172, 9,
    129, 22, 39, 253, 19, 98, 108, 110, 79, 113, 224, 232, 178, 185, 112, 104, 218, 246, 97, 228,
    251, 34, 242, 193, 238, 210, 144, 12, 191, 179, 162, 241, 81, 51, 145, 235, 249, 14, 239, 107,
    49, 192, 214, 31, 181, 199, 106, 157, 184, 84, 204, 176, 115, 121, 50, 45, 127, 4, 150, 254,
    138, 236, 205, 93, 222, 114, 67, 29, 24, 72, 243, 141, 128, 195, 78, 66, 215, 61, 156, 180
};
 
float fade(float t) {
    return t * t * t * (t * (t * 6 - 15) + 10);
}
 
float lerp(float t, float a, float b) {
    return a + t * (b - a);
}
 
float grad(int hash, float x, float y, float z) {
    // CONVERT LO 4 BITS OF HASH CODE INTO 12 GRADIENT DIRECTIONS.
    int h = hash & 15;                    
    float u = h < 8 ? x : y;                
    float v = h < 4 ? y : h == 12 || h == 14 ? x : z;
    return ((h & 1) == 0 ? u : -u) + ((h & 2) == 0 ? v : -v);
}
 
float perlinNoise(float3 pos) {
    // FIND UNIT CUBE THAT CONTAINS POINT.
    int X = (int)floor(pos.x) & 255;
    int Y = (int)floor(pos.y) & 255;                            
    int Z = (int)floor(pos.z) & 255;
   
    // FIND RELATIVE X,Y,Z OF POINT IN CUBE.
    float x = pos.x - floor(pos.x);
    float y = pos.y - floor(pos.y);
    float z = pos.z - floor(pos.z);
   
    // COMPUTE FADE CURVES FOR EACH OF X,Y,Z.
    float u = fade(x);
    float v = fade(y);
    float w = fade(z);
   
    // HASH COORDINATES OF THE 8 CUBE CORNERS
    int A = p[X] + Y;
    int AA = p[A] + Z;
    int AB = p[A + 1] + Z;          
    int B = p[X + 1] + Y;
    int BA = p[B] + Z;
    int BB = p[B + 1] + Z;
 
    // AND ADD BLENDED RESULTS FROM  8 CORNERS OF CUBE
    return lerp(w, lerp(v, lerp(u, grad(p[AA], x, y, z),    // CORNER 0      
           grad(p[BA], x - 1, y, z)),                       // CORNER 1                              
           lerp(u, grad(p[AB], x, y - 1, z),                // CORNER 2                        
           grad(p[BB], x - 1, y - 1, z))),                  // CORNER 3                      
           lerp(v, lerp(u, grad(p[AA + 1], x, y, z - 1),    // CORNER 4            
           grad(p[BA + 1], x - 1, y, z - 1)),               // CORNER 5                  
           lerp(u, grad(p[AB + 1], x, y - 1, z - 1),        // CORNER 6  
           grad(p[BB + 1], x - 1, y - 1, z - 1))));         // CORNER 7
}

// End copied code
// Added in by Kelvin

float HigherFrequency(int ref, int v, float3 p) {
    float n = 0;
    if (v <= ref) {
        p = p * v;
        n = perlinNoise(p) / v;
    }
    return n;
}

static const int kMaxFrequency = 513;
// freq: cut-off frequency
float FractalNoise(float3 p, int freq) {
    float o = pow(2, freq);
    float n = perlinNoise(p);  // f = 1
    for (int f = 2; f < kMaxFrequency; f *= 2)
        n += HigherFrequency(o, f, p);
    return n;
}
