# 如果查看Shader是否支持SPR Batcher
我们可以在Unity里面看一下我们之前写的示例Shader
![image.png](https://note.youdao.com/yws/res/309/WEBRESOURCE4f0d9a8af7abcd6a946a161965e66eda)
红框位置是直接回显示是否适配SPR Batcher，我们的示例Shader是不适配的。
白色叹号后面是具体的说明。
下面我们来改一下示例Shader,在pass的自定义属性加上CBUFFER_START、CUBFFER_END。
```
Shader "Mark/Unlit" {  //名字
	Properties {
		_MainTex ("Base (RGB)", 2D) = "white" {} //定义贴图属性
	    _Color("Main Color", Color) = (1,1,1,1)     //定义一个主颜色
	}

	SubShader {
		Tags {"RenderPipeline"="UniversalRenderPipeline" "RenderType"="Opaque" "Queue" = "Geometry"}   //指明Shader为URPshader、渲染类型为不透明

		Pass {
			HLSLPROGRAM   //指明这是一个HLSL代码片段
            #pragma vertex vert   //定义顶点着色器的函数名
            #pragma fragment frag   //定义片段着色器的函数名
            #pragma target 3.0   //定义支持的opengl的版本
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

            half4 frag (v2f i)
            {
                half4 col = tex2D(_MainTex,i.texcoord);  //获取贴图在该顶点的颜色信息
                return col*_Color;   //贴图颜色混合叠加的主色。
            }
			ENDHLSL
		}
	}
}
```

现在我们再去看一下shader的适配情况
![image.png](https://note.youdao.com/yws/res/322/WEBRESOURCEef25be0bf5bb59bb6e34b923ab855ee6)
我们可以看到现在我们的shader就已经开始支持SPR Batcher了。
# CBUFFER_START CUBFF_END
如果需要我们的Shader支持SPR Batcher，那么就要将我们的属性加到这两个中间。
同时Unity在进行批处理是，所有的在CBUFFER中间的属性，都是可以更改的。
也就是说我们可以更改不同的材质球用不同的颜色，但是是可以进行批处理的。
# 我们先来看一下没有进行SPR Batcher适配之前的消耗情况
![image.png](https://note.youdao.com/yws/res/333/WEBRESOURCEac80bba48e6db0d110abe9fe1bc33162)
- 只有单个Cube，场景的SetPass Calls是3
![image.png](https://note.youdao.com/yws/res/336/WEBRESOURCEbca5120076b1b1c1a3c96e74f845aade)
- 增加3个不同材质球的Cube，SetPass Calls变为5
# 加入SPR Batcher适配
![image.png](https://note.youdao.com/yws/res/340/WEBRESOURCE44548bd783c5248b72bf082f6296ec01)
我们可以看到SetPass Calls 变为了3，同时我们给每个材质球指定了不同的颜色。