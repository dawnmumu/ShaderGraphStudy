# 什么是Shader
## Shader，中文名为着色器。
Shader其实就是专门用来渲染图形的一种技术，通过shader，我们可以自定义显卡渲染画面的算法，使画面达到我们想要的效果。小到每一个像素点，大到整个屏幕。
## Shader分为两类 ：
- 顶点Shader
3D图形都是由一个个三角面片组成的，顶点Shader就是计算每个三角面片上的顶点，并为最终像素渲染做准备。
- 像素（片段）Shader
顾名思义，就是以像素为单位，计算光照、颜色的一系列算法。 几个不同的图形API都有各自的Shader语言，在DirectX中，顶点shader叫做 Vertex Shader ，像素Shader叫做 Pixel Shader； 在OpenGL中，顶点Shader也叫做 Vertex Shader ，但像素Shader叫做 Fragment Shader，也就是我们常说的片段Shader或者片元Shader。
说白了，Shader其实就是一段代码，这段代码的作用是告诉GPU具体怎样去绘制模型的每一个顶点的颜色以及最终每一个像素点的颜色。
- Shader编程语言
既然Shader是一段代码，那必然要用一种语言来书写它，目前主流的有三种语言：
基于OpenGL的OpenGL Shading Language，简称GLSL。
基于DirectX的High Level Shading Language,简称HLSL。
还有NVIDIA公司的C for Graphic，简称Cg语言。
GLSL与HLSL分别是基于OpenGL和Direct3D的接口，两者不能混用。而Cg语言是用于图形的C语言，这其实说明了当时设计人员的一个初衷，就是让基于图形硬件的编程变得和C语言编程一样方便，自由。正如C++和 Java的语法是基于C的，Cg语言本身也是基于C语言的。如果您使用过C、C++、Java其中任意一个，那么Cg的语法也是比较容易掌握的。Cg语言极力保留了C语言的大部分语义，力图让开发人员从硬件细节中解脱出来，Cg同时拥有高级语言的好处，如代码的易重用性，可读性高等。
Cg语言是Microsoft和NVIDIA相互协作在标准硬件光照语言的语法和语义上达成了一致，所以，HLSL和Cg其实是同一种语言。
美术人员看到这里时也不用害怕，语法上并不难，而且在后续的章节中碰到相关的语法时我们会详细的进行说明。

## 什么是Unity Shader
显卡有NVIDIA、ATI、Intel等等。。。
图形API有OpenGL、DirectX、OpenglES、Vulkan、Metal等等。。。
Shader编程语言有GLSL、HLSL、Cg等等。。。
是不是有点头晕，该怎么去选择呢？在Unity中我们又应该如何做呢？
其实在Unity中反而一切变的简单起来了，我们只需关心如何去这实现我们想要的效果就好了，其余的事情全部交给Unity来自动处理。因为我们在Unity中编写的Shader最终会根据不同的平台来编绎成不同的着色器语言，那么我们在Unity中应该用什么语言来书写Shader呢？
官方的建议是用Cg/HLSL来编写，当然你也可以使用GLSL，主要是因为Cg/HLSL有更好的跨平台性，更倾向于使用Cg/HLSL来编写Shader程序。
对于Unity新的渲染管线URP（最早名称是LWRP）、HDRP默认全部才用HLSL编写，同时也支持Cg编写。
Unity Shader严格来说并不是传统上的Shader,而是Unity自身封装后的一种便于书写的Shader，又称为ShaderLab。
- 在Unity中有3种Shader（其实就是三种不同的写法）：
Surface Shaders 表面着色器
Vertex/Fragment Shaders 顶点/片断着色器
Fixed Function Shaders 固定管线着色器
其中Fixed Function Shaders已经被淘汰，完全没有学习的必要了。
Surface Shader其实就是Unity对Vertex/Fragment Shader的又一层包装，以使Shader的制作方式更符合人类的思维模式，同时可以以极少的代码来完成不同的光照模型与不同平台下需要考虑的事情。
Unity新的渲染管线URP也抛弃了Surface Shaders。只支持Vertex/Fragment Shader.
对于新入门的同学只学习Vertex/Fragment Shaders就可以了。
从性能上将，Surface shaders也性能低很多。
另外，学会Shader也会给我们带来很多的好处：
游戏中模型显示粉色的情况你一定碰到过吧，是Shader丢失呢，还是Shader不符合当前平台呢，又或者是Shader上有语法的错误呢？如果我们有了解并学会Shader的话，这些问题就不会再是一脸懵逼啦。
內建Unity Shader仅仅只是“通用”用例，不足以满足我们所有的画面表现需求。
一旦掌握Shader，可以为游戏/应用创造独一无二的视觉享受。根据实际需求，为游戏和应用实现特定功能的Shader。
能大大的帮助我们做渲染上的性能优化，因为通过Shader可以控制渲染什么以及如何渲染。
撰写Shader的能力对于游戏团队非常重要，掌握Shader技能的开发一直是炙手可热的职位。现在一个不争的事实就是，技术美术永远是各大厂商的稀缺资源。