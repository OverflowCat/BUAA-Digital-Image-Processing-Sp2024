#set text(lang: "zh", cjk-latin-spacing: auto, font: "Noto Serif CJK SC")
#set page(numbering: "1", margin: (left: 1.4cm, right: 1.9cm))
#show figure.caption: set text(font: "Zhuque Fangsong (technical preview)")
#show "。": "．"
#show heading: set text(font: "Noto Sans CJK SC", size: 1.15em)
#import "helper.typ": *

= 数字图像处理#h(1em)第4章#h(1em)频率域滤波#h(1em)作业

#v(1em)

#Q[完成由式（4.3-11）和式（4.3-12）给出的步骤。（教材P192页，第4.6题。）]

#let PIT = $display(pi dot.c (t - n Delta T) / (Delta T))$

$
f(t)
&= IFT {F(mu)}
= IFT {H(mu) tilde(F)(mu)}
= h(t) CONV overline(f)(t)\
&= INTOO h(z) tilde(f)(t - z) dif z\
&= INTOO (sin(pi z / Delta T))/((pi z / Delta T)) SUMOO f(t - z) delta(t - n Delta T - z) dif z\
&= SUMOO INTOO (sin(pi z / Delta T))/((pi z / Delta T)) f(t - z) delta(t - n Delta T - z) dif z\
&= SUMOO f(n Delta T) (sin(PIT))/(PIT)\
&= SUMOO f(n Delta T) sinc((t - n Delta T) / (Delta T)).
$

#Q[写出二维连续卷积的表达式（教材P192页，第4.11题。）]

$ f(t, z) CONV h(t, z) = INTOO INTOO f(alpha, beta) h(t - alpha, z - beta) dif alpha dif beta. $

#include "3.typ"

#Q[由4.5.4节中的讨论可知，收缩一幅图像会导致混淆现象。放大一幅图像也会导致混淆现象吗？请解释。（教材P192页，第4.13题。）]

缩小图像时可能会导致混叠是因为采样率降低。放大操作引入了更多的样本，所以不会导致混叠。

#Q[4.6.6节中在讨论频率域滤波时需要对图像进行填充。在该节中给出的图像填充方法是，在图像中行和列的末尾填充0值（见左图）。如果我们把图像放在中心，四周填充0值（见右图而不改变所用0值的总数，会有区别吗？试解释原因。（教材P193页，第4.21题。）]

DFT 是周期延拓的，填充零值相当于多个周期的图像间插入空区域，减少相互干扰。无论是在图像末尾还是周围填充，只要其数量相同，效果就等同。填充后的图像就像棋盘，原始图像或位于方格中心或占据整个方格，但每个方格内容相同，数学上等价。两种填充方式都能有效防止 DFT 周期性延拓，可根据实际需要选择，通常在图像末尾填充零更方便。

#include "6.typ"

#Q[
  一种成熟的医学技术被用于检测电子显微镜生成的某类图像。为简化检测任务，技术人员决定采用数字图像增强技术，并在处理结束后，检查了一组具有代表性的图像，发现了如下问题：

  + 明亮且孤立的点是不感兴趣的点；
  + 清晰度不够；
  + 一些图像的对比度不够；
  + 平均灰度值已被改变，而正确地执行某种灰度度量的这个值应是 $V$。

  技术人员想要纠正这些问题，然后将 $I_1$ 和 $I_2$ 波段之间的所有灰度显示为白色，同时保持其余灰度的正常色调。请为技术人员提出达到期望目的的处理步骤。可以使用第3章和第4章的技术。（教材P195页，第4.43题。）
]

+ 进行中值滤波；
+ 利用高斯高通滤波器进行高频强调；
+ 将 $I_1$ 和 $I_2$ 波段之间的所有像素的灰度级设为最高。
