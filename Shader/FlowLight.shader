Shader "Unlit/FlowLight"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _FlowTex ("Flow Texture",2D)="black"{}
        _FlowColor("Flow Color",color)=(0,0,0,0)
        _FlowSpeed("Flow Speed",vector)=(0, 0, 0, 0)
    }
    SubShader
    {
        Tags { 
            "RenderPipeline"="UniversalPipeline"
            "RenderType"="Transparent"
            "Queue"="Transparent"
         }

        Pass
        {

            Name "Pass"
            Tags {}
        
            // Render State
            Blend SrcAlpha OneMinusSrcAlpha
            Cull Back
            ZTest LEqual
            ZWrite Off
            

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            struct appdata_t {
                float4 vertex : POSITION;
                float2 texcoord : TEXCOORD0;
            };

            struct v2f {
                float4 vertex : SV_POSITION; 
                float2 texcoord : TEXCOORD0; 
            };
            
            sampler2D _MainTex,_FlowTex;  
            CBUFFER_START(UnityPerMaterial)
            half4 _FlowSpeed;
            half4 _FlowColor;
            float4 _MainTex_ST,_FlowTex_ST;
            CBUFFER_END
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
                half3 flowCol=tex2D(_FlowTex,_Time.y*half2(_FlowSpeed.x,_FlowSpeed.y)+i.texcoord.xy).rgb;
                
                finalCol.rgb+=flowCol*_FlowColor.rgb;
                
                return finalCol;
            }
            ENDHLSL
        }
    }
}
