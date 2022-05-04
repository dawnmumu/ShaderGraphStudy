# 为什么选择URP
现在所在项目为SLG类项目，有同屏200+英雄的需求。
Unity传统渲染管线的动态批处理有个限制是Skined Mesh Renderer不能进行动态批处理。
英雄如果不采用Skined Mesh Renderer又不能满足美术的需求。
URP 的 SRP Batcher的功能恰好可以完美解决这个问题。
UPR在灯光处理上可以极大的降低消耗，在高模英雄展示上我们可以增加一些辅助光源来提高展示质量。

## SRP Batcher
SRP Batcher 是一个渲染循环，可通过许多使用同一着色器变体的材质来加快场景中的 CPU 渲染速度。
## SRP Batcher 的工作原理
Unity 中，可以在一帧内的任何时间修改任何材质的属性。但是，这种做法有一些缺点。例如，DrawCall 使用新材质时，要执行许多作业。因此，场景中的材质越多，Unity 必须用于设置 GPU 数据的 CPU 也越多。解决此问题的传统方法是减少 DrawCall 的数量以优化 CPU 渲染成本，因为 Unity 在发出 DrawCall 之前必须进行很多设置。实际的 CPU 成本便来自该设置，而不是来自 GPU DrawCall 本身（DrawCall 只是 Unity 需要推送到 GPU 命令缓冲区的少量字节）。

SRP Batcher 通过批处理一系列 Bind 和 Draw GPU 命令来减少 DrawCall 之间的 GPU 设置。
其实简单的说就是SPR Batcher通过一系列操作，减少了CPU和GPU之间的交互，以此来达到快速渲染。
![sroshaderpass.png](https://note.youdao.com/yws/res/222/WEBRESOURCE18919c5e77c6c0424ea9591df3469b81)

为了获得最大渲染性能，这些批次必须尽可能大。为了实现这一点，可以使用尽可能多具有相同着色器的不同材质，但是必须使用尽可能少的着色器变体。

在内渲染循环中，当 Unity 检测到新材质时，CPU 会收集所有属性并在 GPU 内存中设置不同的常量缓冲区。GPU 缓冲区的数量取决于着色器如何声明其 CBUFFER。

为了在场景使用很多不同材质但很少使用着色器变体的一般情况下加快速度，SRP 在原生集成了范例（例如 GPU 数据持久性）。

SRP Batcher 是一个低级渲染循环，使材质数据持久保留在 GPU 内存中。如果材质内容不变，SRP Batcher 不需要设置缓冲区并将缓冲区上传到 GPU。实际上，SRP Batcher 会使用专用的代码路径来快速更新大型 GPU 缓冲区中的 Unity 引擎属性，如下所示：
![srp_batcher_loop.png](https://note.youdao.com/yws/res/228/WEBRESOURCEd2d14d9d0996403f20c0141b70764b87)
