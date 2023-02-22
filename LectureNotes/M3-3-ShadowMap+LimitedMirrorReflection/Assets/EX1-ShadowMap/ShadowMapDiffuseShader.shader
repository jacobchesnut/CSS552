Shader "Unlit/ShadowDiffuseShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass 
        {   
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            
            #include "UnityCG.cginc"

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
                float2 lightNDC : TEXCOORD2;  // uv in light space
                float3 normal : NORMAL;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;

            sampler2D _ShadowMap;
            float _DepthBias;
            float _NormalBias;
            float4x4 _WorldToLightNDC;
            
            // For debugging
            uint _MapFlag;
            float _DebugDistScale;  // to scale down distance for drawing
            static const int kShowMapDistance = 0x01;
            static const int kShowMapDistanceWithBias = 0x02;
            static const int kShowLightDistance = 0x04;
            static const int kShowShadowInRed = 0x08;
            static const int kShowMapWC = 0x10;

            #define DEBUG_SHOW(FLAG, VALUE, SCALE) {        \
                if (_MapFlag & FLAG) {                      \
                    float4 c = VALUE * SCALE;               \
                    return c;                               \
                }                                           \
            }

            float4 _LightPos;

            v2f vert (appdata v)
            {
                v2f o;
                float4 p = mul(unity_ObjectToWorld, v.vertex);  // objcet to world
                o.worldPos = p.xyz;  // p.w is 1.0 at this poit

                p = mul(UNITY_MATRIX_V, p);  // To view space
                o.vertex = mul(UNITY_MATRIX_P, p);  // Projection 
                            
                o.normal = normalize(mul(v.normal, (float3x3)unity_WorldToObject)); 
                o.uv = v.uv;

                // compute for shadow
                float4 lNDC = mul(_WorldToLightNDC, float4(o.worldPos, 1));
                o.lightNDC = lNDC.xy / lNDC.w; // light NDC, -1 to 1
                o.lightNDC = (o.lightNDC + 1) * 0.5; // conver to 0 to 1
                return o;
            }    

            float4 frag (v2f i) : SV_Target
            {
                // sample the texture
                float4 col = float4(0.9, 0.7, 0.7, 1.0);
                if ((i.uv.x != 0) && (i.uv.y != 0))
                    col = tex2D(_MainTex, i.uv);
                float3 worldPos = i.worldPos + _NormalBias * i.normal;  // push the position out of the surface a little
                float3 L = _LightPos - worldPos;
                float distToLight = length(L);
                L = L / distToLight;  // normalize L
                float NdotL = dot(i.normal, L);

                // now, we are being illuminated by the light ... 
                DEBUG_SHOW(kShowLightDistance, distToLight, _DebugDistScale)

                if (NdotL < 0.2) {   // use 0.1 as cut off
                    // normal is point almost in the same direction as L
                    // illumination from this light is minimum 
                    // should not consider shadow for this point
                    return 0.2 * col; // 
                }
                                
                // now, let's do shadow compuration
                float4 wcPt = tex2D(_ShadowMap, i.lightNDC);
                float distFromMap = wcPt.a;  // this is distance
                DEBUG_SHOW(kShowMapDistance, distFromMap, _DebugDistScale)
                DEBUG_SHOW(kShowMapWC, wcPt, _DebugDistScale)

                distFromMap += _DepthBias;  // push slightly outward to avoid self-shadowing
                DEBUG_SHOW(kShowMapDistanceWithBias, distFromMap, _DebugDistScale)

                if (distToLight > distFromMap) { // in shadow!
                    NdotL *= 0.2;
                    DEBUG_SHOW(kShowShadowInRed, (1, 0, 0, 1), 0.5)
                }               

                return col * NdotL;
            }
           
            ENDCG
        }
    }
}