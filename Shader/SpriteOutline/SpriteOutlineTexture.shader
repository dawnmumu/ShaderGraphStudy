Shader "Unlit/SpriteOutlineTexture"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _OutlineColor("Outline Color",Color)=(0,0,0,0)
        _Width("Width",Range(0,0.1))=0.01
        _Pattern("Pattern",2D)="black"{}
        _PatternScale("Pattern Scale",range(0,20))=2
        _SpeedX("SpeecX",range(-1,1))=0
        _SpeedY("SpeecY",range(-1,1))=0
        _OutlineStrength("Outline Strength",range(0,10))=1
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
            
            sampler2D _MainTex,_Pattern;  
            CBUFFER_START(UnityPerMaterial)
            half4 _OutlineColor;
            half _Width,_PatternScale,_SpeedX,_SpeedY,_OutlineStrength;
            float4 _MainTex_ST,_Pattern_ST;
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
                half4 patternCol=tex2D(_Pattern,_Time.y*half2(_SpeedX,_SpeedY)+IN.texcoord*_PatternScale);
                finalCol.rgb=finalCol.rgb*finalCol.a;
                half spriteLeft = tex2D(_MainTex, IN.texcoord + half2(_Width, 0)).a;
                half spriteRight = tex2D(_MainTex, IN.texcoord - half2(_Width,  0)).a;
                half spriteBottom = tex2D(_MainTex, IN.texcoord + half2(0 ,_Width)).a;
                half spriteTop = tex2D(_MainTex, IN.texcoord - half2(0 , _Width)).a;
                half result = (spriteRight + spriteLeft + spriteTop + spriteBottom);
                result *= (1 - finalCol.a);
                result=saturate(result*10);
                finalCol+=result*_OutlineColor*patternCol*_OutlineStrength;
            
                return finalCol;
            }
            ENDHLSL
        }
    }
}
