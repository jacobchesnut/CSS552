Shader "Unlit/FractalNoise"
{
    Properties
    {
        _Frequency("Frequency", Range(1, 9)) = 5
        _Color1 ("Color-1", Color) = (0, 0, 0, 1)
        _Color2 ("Color-2", Color) = (1, 1, 1, 1)
    }
    
    SubShader
    {
        Tags { "RenderType"="Opaque"}
        LOD 100
        // Cull Off

        Pass 
        {   
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
                float3 objPos : TEXCOORD2;  // !! HEY!!: Passing Object Space Position to Fragment Shader!
                float3 normal : NORMAL;
                float4 vertex : SV_POSITION;
            };

            v2f vert (appdata v)
            {
                v2f o;

                o.objPos = v.vertex.xyz;   // Object space to fragment shader

                float4 p = mul(unity_ObjectToWorld, v.vertex);  // objcet to world
                o.worldPos = p.xyz;  // p.w is 1.0 at this poit

                p = mul(UNITY_MATRIX_V, p);  // To view space
                o.vertex = mul(UNITY_MATRIX_P, p);  // Projection 
                            
                o.normal = normalize(mul(v.normal, (float3x3)unity_WorldToObject)); 
                o.uv = v.uv;
                return o;
            }

            float4 _Color1;
            float4 _Color2;
            float _Frequency;

            #include "./PerlinNoise.cginc"

            float4 frag(v2f i) : SV_TARGET { 
                float o = pow(2, _Frequency);
                float n = perlinNoise(i.objPos);  // f = 1
                for (int f = 2; f < kMaxFrequency; f *= 2)
                    n += HigherFrequency(o, f, i.objPos);
                    
                return n * _Color1 + (1-n) * _Color2;
            }
           
            ENDCG
        }
    }
}
