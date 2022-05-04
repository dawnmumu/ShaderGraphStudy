Shader "Mark/Unlit" {  //名字
	Properties {
		_MainTex ("Base (RGB)", 2D) = "white" {} //定义贴图属性
	    _Color("Main Color", Color) = (1,1,1,1)     //定义一个主颜色
	}

	SubShader { 
		Tags {"RenderPipeline"="UniversalRenderPipeline" "RenderType"="transparent" "Queue" = "transparent"  }   //指明Shader为URPshader、渲染类型为不透明
        Blend SrcAlpha OneMinusSrcAlpha 
		Pass {
			HLSLPROGRAM   //指明这是一个HLSL代码片段
            #pragma vertex vert   //定义顶点着色器的函数名
            #pragma fragment frag   //定义片段着色器的函数名
            #pragma target 3.0   //定义支持的OpenGL的版本
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"   //引入core库
            //定义输入数据结构
            struct appdata_t {
                float4 vertex : POSITION;   //顶点坐标
                float2 texcoord : TEXCOORD0;    //贴图
            };
            //定义输出数据结构
            struct v2f {
                float4 vertex : SV_POSITION; //顶点坐标  必须有
                float2 texcoord : TEXCOORD0; //uv坐标
            };
            //定义和属性定义中同名的属性，以便在代码片段中使用。
            sampler2D _MainTex;  
            CBUFFER_START(UnityPerMaterial)
            half4 _Color;
            float4 _MainTex_ST;  //_ST是一个内置的规则、这个存储的是贴图的Tilling和Offset
            CBUFFER_END
            v2f vert (appdata_t v)
            {
                v2f o;
                o.vertex = TransformObjectToHClip(v.vertex.xyz);     //可以简单的理解为将世界坐标转换到屏幕坐标。
                o.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex); //获取贴图的UV
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                half4 col = tex2D(_MainTex,i.texcoord);
                return col*_Color;
            }
			ENDHLSL
		}
	}
}