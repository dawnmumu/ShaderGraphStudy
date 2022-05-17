Shader "Unlit/SpriteOutline"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _OutlineColor("Outline Color",Color)=(0,0,0,0)
        _Width("Width",Range(0,0.1))=0.01
    }
    SubShader
    {
        Tags {
            "RenderPipeline"="UniversalPipeline"
            "RenderType"="Transparent"
            "Queue"="Transparent"
        }
        LOD 100

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
            
            sampler2D _MainTex;  
            CBUFFER_START(UnityPerMaterial)
            half4 _OutlineColor;
            half _Width;
            float4 _MainTex_ST;
            CBUFFER_END
            v2f vert (appdata_t v)
            {
                v2f o;
                o.vertex = TransformObjectToHClip(v.vertex.xyz); 
                o.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);
                return o;
            }


            half4 frag (v2f IN) : SV_Target
            {
                half4 finalCol = tex2D(_MainTex,IN.texcoord);
                finalCol.rgb=finalCol.rgb*finalCol.a;
                half4 spriteLeft = tex2D(_MainTex, IN.texcoord + float2(_Width, 0)).a;
                half4 spriteRight = tex2D(_MainTex, IN.texcoord - float2(_Width,  0)).a;
                half4 spriteBottom = tex2D(_MainTex, IN.texcoord + float2(0 ,_Width)).a;
                half4 spriteTop = tex2D(_MainTex, IN.texcoord - float2(0 , _Width)).a;
                half4 result = (spriteRight + spriteLeft + spriteTop + spriteBottom);
                result *= (1 - finalCol.a);
                result=saturate( result*10);
                finalCol.rgb=finalCol.rgb+result*_OutlineColor.rgb;
                finalCol.a=finalCol.a+result;
                return finalCol;
            }
            ENDHLSL
        }
    }
}
