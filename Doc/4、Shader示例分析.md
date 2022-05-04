先来看一下之前介绍Shader基本结构的shaser 示例代码。
关键位置都已经加了注释、了解一下就可以，后面我们会用示例的方式一点点的去了解、学习。
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
            half4 _Color;
            float4 _MainTex_ST;  //_ST是一个内置的规则、这个存储的是贴图的Tilling和Offset

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
- "RenderPipeline"="UniversalRenderPipeline"
RenderPipeline 标签向 Unity 告知子着色器是否与通用渲染管线 (URP) 或高清渲染管线 (HDRP) 兼容。
- "RenderType"="Opaque"
RenderType是用来指定shader的渲染类型。可以没有。
- “Queue” = “[queue name]”
queue name值为：Background、Geometry、AlplhTest、 Transparent 、Overlay
Queue标签是向Unity告知对象的默认渲染队列。该值可以在shader赋予材质球后，在材质球上进行更改。
同时可以说使用Offset方式使用：“Queue” = “Transparent+100”，Transparent的默认值是3000，这种offset写法，表示默认渲染队列是3100。
- SV_POSITION与SV_Target
SV_POSITION和SV_Target都是语义绑定(semantics binding) ，可以理解为关键字吧，图形渲染是按照固定的流程一步一步走的，所以也叫管线，在这个过程中，前面流程处理完的数据是需要传到下一个流程继续处理的，因为gpu和cpu的架构不同，gpu并不能像cpu一样有内存堆栈可以用来存取变量和值，只有通过语义绑定(semantics binding) 将处理好的值存到一个物理位置，方便下一个流程去取，一般的可编程管线主要处理vertext(顶点)函数和fragment(片段)函数，当然也有叫片元函数的，一个意思。
SV_前缀的变量代表system value的意思，在DX10+的语义绑定中被使用代表特殊的意义，SV_POSITION在用法上和POSITION是一样的，区别是 SV_POSTION一旦被作为vertex函数的输出语义，那么这个最终的顶点位置就被固定了，不得改变。DX10+推荐使用SV_POSITION作为vertex函数的输出和fragment函数的输入，而vertex函数的输入还是使用POSITION。不过DX10以后的代码依旧兼容POSITION作为全程表达，估计编译器会自动判断并替换的吧。
SV_Target是DX10+用于fragment函数着色器颜色输出的语义。DX9使用COLOR作为fragment函数输出语义，但是也有一些着色器语言使用COLOR来表示网格数据和顶点输出语义，效果和功能是一样的，没有什么区别，同时使用COLOR的话DX10+也会兼容。

- OpenGL 版本 #pragma target
这个标记用来表示该代码片段所支持的最低的OpenGL版本。
2018年之后的手机基本上都是已经支持OpenGL 3.1+了。如果需要支持特别老的手机，可能需要最低设置到2.0.
但2.0很多shader特性会不支持，包括属性的数量、贴图数量都有很大的现在。现在这个阶段写shader基本都可以设置到3.0了。
