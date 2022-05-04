Shader "Unlit/DayNightBuilding"
{
    Properties
    {
        [NoScaleOffset]_MainTex("MainTexture", 2D) = "white" {}
        _Color("NightColor", Color) = (0, 0, 0, 0)
        [NoScaleOffset]_Control("Control", 2D) = "white" {}
        _RCut("RCut",Float)=0.01
        _GColor("GColor", Color) = (0, 0, 0, 0)
        _BColor("BColor", Color) = (0, 0, 0, 0)
        _Speed("Speed", Float) = 10

        
    }
    SubShader
    {
        Tags {"RenderPipeline"="UniversalRenderPipeline" "RenderType"="transparent" "Queue" = "transparent"  }   
        Blend SrcAlpha OneMinusSrcAlpha 
		Pass {
			HLSLPROGRAM  
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct appdata_t {
                float4 vertex : POSITION;
                float2 texcoord : TEXCOORD0;
            };
        
            struct v2f {
                float4 vertex : SV_POSITION; 
                float2 texcoord : TEXCOORD0; 
            };
            
            sampler2D _MainTex,_Control;  
            CBUFFER_START(UnityPerMaterial)
            half _Speed,_RCut;
            half4 _Color,_GColor,_BColor;
            float4 _MainTex_ST,_Control_ST;
            CBUFFER_END
            void Unity_Remap_half(half In, half2 InMinMax, half2 OutMinMax, out float Out)
            {
                Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
            }
            v2f vert (appdata_t v)
            {
                v2f o;
                o.vertex = TransformObjectToHClip(v.vertex.xyz); 
                o.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);
                return o;
            }


            half4 frag (v2f i) : SV_Target
            {
                half4 finalCol = tex2D(_MainTex,i.texcoord);
                finalCol=finalCol*_Color;
                half3 controlrgb=tex2D(_Control,i.texcoord).rgb;
                finalCol+=_GColor*controlrgb.g;
                half remap;
                Unity_Remap_half(sin(_Time.y*_Speed),half2(-1,1),half2(0.5,1),remap);
                finalCol+=_BColor*controlrgb.b*remap;
                finalCol.a=step(_RCut,controlrgb.r);
                return finalCol;
            }
			ENDHLSL
		}
    }
}
