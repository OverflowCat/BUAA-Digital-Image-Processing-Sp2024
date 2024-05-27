#set text(lang: "zh", cjk-latin-spacing: auto, font: "Noto Serif CJK SC")
#set page("iso-b5", numbering: "1", margin: (left: 1.4cm, right: 1.9cm))
#set par(leading: 1.1em)
#show table: set text(font: "Zhuque Fangsong (technical preview)")
#show figure.caption: set text(font: "Zhuque Fangsong (technical preview)")
#show "。": "．"
#show heading: set text(font: "Noto Sans CJK SC", size: 1.15em)

= 数字图像处理  第10章 形状表示与描述 作业

#quote(block: true)[
1. 教材P509页，第10.7题。第1题图如下。
]

// #box(image("media/image2.png", height: 2.7559055118110236in, width: 3.8149606299212597in))

假设我们已使用示于如图中的边缘模型代替了图10.10中的斜坡模型。请写出每个剂面的梯度和拉普拉斯算子。（教材P509页，第10.7题。）

// #box(image("media/image3.png", height: 1.5748031496062993in, width: 1.5669291338582678in))
2. 右图所示图像中的物体和背景，在标度范围 内具有的平均灰度分别为180和70。该图像被均值为0、标准差为10个灰度级的高斯噪声污染了。请提出一种正确分割率为90%或更高百分比的阈值处理方法。（回忆一下，高斯曲线下99.7%的面积位于均值的 区间内，其中 是标准差。）（教材P512页，第10.36题。）

3. 提出一个区域生长算法来分割习题10.36中的图像。

// #box(image("media/image7.png", height: 1.8503937007874016in, width: 1.8070866141732282in))（教材P512页，第10.38题。）

4. 使用10.4.2节中讨论过的分裂和聚合过程来分割右图所示的图像。如果 中的所有像素都有相同的灰度，则令 。给出对应于您的分割的四叉树。

#include "quadtree.typ"

（教材P512页，第10.39题。）

题目解答请写清题号，按照顺序写在如下空白处，页数不限。
