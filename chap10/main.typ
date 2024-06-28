#set text(lang: "zh", cjk-latin-spacing: auto, font: "Noto Serif CJK SC")
#set page("iso-b5", numbering: "1", margin: (left: 1.4cm, right: 1.9cm))
#set par(leading: 1.1em)
#show table: set text(font: "Zhuque Fangsong (technical preview)")
#show figure.caption: set text(font: "Zhuque Fangsong (technical preview)")
#show "。": "．"
#show heading: set text(font: "Noto Sans CJK SC", size: 1.15em)

= 数字图像处理 第10章 形状表示与描述 作业

== 1

#stack(
  dir: ltr,
  spacing: 4%,
  box(width: 38%)[
    #set text(weight: "bold")
    教材P509页，第10.7题。

假设我们已使用示于如图中的边缘模型代替了图10.10中的斜坡模型。请写出每个剂面的梯度和拉普拉斯算子。（教材P509页，第10.7题。）],
  figure(
    caption: "斜坡1",
    image("./1.svg", width: 28%),
  ),
  figure(
    caption: "斜坡2",
    image("./2.svg", width: 25%),
  ),
)


== 2

#let stderr = $plus.minus 3 sigma$
#let I1 = 60
#let I2 = 180
#let span = 10 * 3
*右图所示图像中的物体和背景，在标度范围 $[0, 255]$ 内具有的平均灰度分别为180和70。该图像被均值为0、标准差为10个灰度级的高斯噪声污染了。请提出一种正确分割率为90%或更高百分比的阈值处理方法。（回忆一下，高斯曲线下99.7%的面积位于均值的 $plus.minus 3 sigma$ 区间内。）（教材P512页，第10.36题。）
*

均值为 $I_1 = 60$ 灰度级和 $I_2 = 180$ 灰度级，噪声的标准差为 $sigma = 10$ 灰度级，则 $I_1 stderr = [#(I1 - span), #(I1 + span)] $，$I_2 stderr = [#(I2 - span), #(I2 + span)]$。因此，可选择阈值 $T = 120$，此时正确分割率在 99% 以上。

// 因此两个亮度群体之间存在明显的分离。因此选择170作为种子值来生长对象是相当合适的。一种方法是通过将任何与先前附加到该种子的任何像素8连通的像素附加到种子上，并且其亮度为170±3σ为生长区域。

== 3

*提出一个区域生长算法来分割习题10.36中的图像。（教材P512页，第10.38题。）*

根据上一题，可以以灰度级为 $I_2 = I2$ 的点为种子点，并选择八连通的、灰度级在 $170 stderr$ 内的像素点为生长区域。

#include "quadtree.typ"
