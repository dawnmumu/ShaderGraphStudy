
Shader "Unlit/ModelShadow" {
    Properties {
        _MainTex ("Texture", 2D) = "white" {}
        _Color ("Color", Color) = (0.9926471,0.233564,0.233564,1)

        _ShadowFalloff ("ShadowFalloff",Range(0,10))  = 0.5
        _LightDir ("灯光相对模型位置",Vector) = (0,100,0)  //灯光相对模型位置
        _ShadowColor("ShadowColor", Color) = (0.03529,0.02745,0.05098,1)
        _ShadowAlpha ("阴影整体透明度", Range(0,1)) = 0.9

        _ShadowY ("阴影Y轴偏移", Range(-10,10)) = 0

    }
    SubShader {
        Tags {
            "RenderPipeline" = "UniversalPipeline"
            "RenderType"="Opaque"
        }
        LOD 100
        Blend SrcAlpha OneMinusSrcAlpha
        Pass {
            Tags { "LightMode" = "UniversalForward" }

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            CBUFFER_START(UnityPerMaterial)

            float _ShadowY;
            float3 _LightDir;
            half4 _ShadowColor;
            half _ShadowFalloff;
            half _ShadowAlpha;
            CBUFFER_END
            
            struct appdata_t {
                float4 vertex : POSITION;
                float2 texcoord : TEXCOORD0;
            };

            struct v2f {
                float4 vertex : SV_POSITION;
                float2 texcoord : TEXCOORD0;
            };

            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);
            float4 _MainTex_ST;
            v2f vert (appdata_t v)
            {
                v2f o;
                o.vertex = TransformObjectToHClip(v.vertex.xyz);
                o.texcoord =TRANSFORM_TEX(v.texcoord,_MainTex);
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                half4 color = SAMPLE_TEXTURE2D(_MainTex,sampler_MainTex, i.texcoord);



                return half4(color.xyz,1);
            }
            ENDHLSL
        }
        Pass{
            Name "Plane Shadow"
            Tags{ "LightMode" = "SRPDefaultUnlit" }


            ZWrite off
            Stencil
            {
                Ref 0  //当前像素stencil值与0进行比较
                Comp equal //在参考值等于模板缓冲区中的当前值时渲染像素。
                Pass incrWrap //递增缓冲区中的当前值。如果该值已经是 255，则变为 0。
                Fail keep //保持模板缓冲区的当前内容。
                ZFail keep  //保持模板缓冲区的当前内容。
            }

            Offset -1 , -1

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            CBUFFER_START(UnityPerMaterial)
            float _ShadowY;
            float3 _LightDir;
            half4 _ShadowColor;
            half _ShadowFalloff;
            half _ShadowAlpha;
            CBUFFER_END
            
            
            struct Attributes {
                float4 positionOS	: POSITION;
            };

            struct Varyings {
                float4 positionCS	: SV_POSITION;
                float4 color : COLOR;
            };

            float3 ShadowProjectPos(float4 vertPos,float3 lightDir)
            {
                float3 shadowPos;

                //得到顶点的世界空间坐标
                float3 worldPos = TransformObjectToWorld(vertPos.xyz);

                //阴影的世界空间坐标（低于地面的部分不做改变）
                shadowPos.y = min(worldPos.y, _ShadowY);
                shadowPos.xz = worldPos.xz - lightDir.xz * max(0, worldPos.y - _ShadowY) / lightDir.y;

                return shadowPos;
            }
            Varyings vert(Attributes IN) {
                Varyings OUT;

                

                //得到阴影的世界空间坐标
                float3 shadowPos = ShadowProjectPos(IN.positionOS, _LightDir);

                OUT.positionCS = TransformWorldToHClip(shadowPos);

                //得到中心点世界坐标
                float3 center = float3(unity_ObjectToWorld[0].w, _ShadowY, unity_ObjectToWorld[2].w);
                //计算阴影衰减
                float falloff =(_ShadowFalloff- distance(shadowPos, center)) / _ShadowFalloff;

                //阴影颜色
                OUT.color = _ShadowColor;
                OUT.color.a *= falloff*_ShadowAlpha;


                return OUT;
            }
            half4 frag(Varyings IN) : SV_Target{
                return IN.color;
            }
            ENDHLSL
        }
    }
   
}
