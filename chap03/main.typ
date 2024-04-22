#import "@preview/unify:0.4.3": num, qty
#import "@preview/gentle-clues:0.7.0": clue
#set text(font:("STIX Two Text", "Noto Serif CJK SC"))
#set page(paper: "iso-b5", numbering: "1")
#let problemCounter = counter("mycounter")

#let problem(icon: emoji.quest , ..args) = clue(
  accent-color: green,
  title: [问题#problemCounter.display("一")],
  icon: icon,
  ..args
)
#show heading.where(level: 1): it => [
  #set text(font: ("Noto Sans CJK SC"), size: 18pt)
  #it.body
]
#show heading.where(level: 2): it => [
  #problem[
    #set text(font: ("Noto Sans CJK SC"), size: 11pt, weight: "medium")
    #it.body
  ]
]


= 数字图像处理　第三章作业

#problemCounter.step()
== 为了展开一幅图像的灰度，使其最低灰度为 $C$、最高灰度为 $L-1$，试给出一个单调的变换函数．

记图像中的灰度值的最大值为 $r_max$，最小值为 $r_min$，则可给出一个符合要求的函数

$ T(r) = C + (L - 1 - C)/(r_max - r_min) (r-r_min). $

#problemCounter.step()
== 试解释为什么离散直方图均衡技术一般不能得到平坦的直方图？

原图像一般只有有限个灰度级，部分灰度级像素较多，部分灰度级中没有像素．由于均衡化时的变换函数是单调递增的，每个灰度级只能映射到同一个灰度级，所以均衡化后的图像的灰度级数小于等于原图像的灰度级数．

#problemCounter.step()
== 假设对一幅数字图像进行直方图均衡处理．试证明（对直方图均衡后的图像）进行第二次直方图均衡处理的结果与第一次直方图均衡处理的结果相同．

由

$ s_k = T(r_k) = (L-1) sum^k_(j=0) p_r(r_j),
quad k = 0,1,2, dots.c ,L-1 $

和

$ p_r(r_k) = n_k / (M N), $

得第一次直方图均衡化

$ s_k = T(r_k) = (L-1) sum^k_(j=0) p_r(r_j) = (L-1) sum^k_(j=0) n_k/(M N) = (L-1)/(M N) sum^k_(j=0) n_j. $

其中，$M N$ 是图像中的像素总数，$n_k$ 表示灰度值为 $r_k$ 的像素数．

记 $n'_k$ 表示灰度值为 $s_k$ 的像素数，则第二次直方图均衡化的结果为

$ s'_k = s' = T(s) = (L - 1) / (M N) sum^k_(j=0) n'_j. $

由于直方图均衡化使原有的每个灰度级的像素数量保持不变，只是灰度值发生了变化，因此，映射后的每个新灰度级依然保有相同数量的像素，即 $n'_k = n_k$，所以 $ s'_k = s' = T(s) = (L - 1) / (M N) sum^k_(j=0) n_j = s_k. $

#problemCounter.step()
== 4、（a）证明式（3.3.8）中给出的离散变换函数对直方图均衡处理满足3.3.1节中的条件（a）和（b）．

对于 $ s_k = T(r_k) = (L-1)/(M N) sum^k_(j=0) n_j, 
quad k = 0,1,2, dots.c ,L-1, $

// 其导数 $ s'_k () = T(r_k) = (L-1)/(M N) sum^k_(j=0) n_j, 
// quad k = 0,1,2, dots.c ,L-1, $

设 $r_k_1 < r_k_2$，
// 设 $r_1< r_2$，

$ s_k_2 - s_k_1
=& T(r_(k_2)) - T(r_(k_1)) \
=& (L-1)/(M N) sum^(k_2)_(j=0) n_j - (L-1)/(M N) sum^(k_1)_(j=0) n_j\
=& (L-1)/(M N) sum^(k_2)_(j=k_1+1) n_j >= 0. $

故 $T(r)$ 在区间 $0 <= r <= L-1$ 上是一个单调递增函数，条件 (a) 得证．

$
s_(k max)& = T(r)_max =&(L-1)/(M N) M N &= L-1,\
s_(k min)& = T(r)_min =&(L-1)/(M N) dot 0 &= 0,
$

故对于 $0 < r < L-1$，有 $0 <= T(r) <= L-1$，条件 (b) 得证．


== （b）证明只有在灰度不丢失的情况下，式（3.3-9）表示的离散直方图反变换才满足3.3.1节中的条件（a′）和（b）．

对于 $0 < s_k < L-1$，有 $0 <= r_k = T^(-1)(s_k) <= L-1$，条件 (b) 得证．

由 (a)，设 $r_k_1 < r_k_2$ 时，若 $r_k_2 = r_k_1 + 1$ 且 $r_k_2$ 丢失，则 $n_k_2 = 0$，
$ s_k_2 - s_k_1
=& T(r_(k_2)) - T(r_(k_1)) \
=& (L-1)/(M N) sum^(k_2)_(j=k_1+1) n_j = 0. $

$T(r_k_2)$ 可能等于 $T(r_k_2)$，不符合单调递增的要求．

而当灰度不丢失时，$n_k_2>0$，$ s_k_2 - s_k_1
=& T(r_(k_2)) - T(r_(k_1)) \
=& (L-1)/(M N) sum^(k_2)_(j=k_1+1) n_j \
=& (L-1)/(M N) (n_(k_1+1) + dots.c + n_k_2) \
>=& (L-1)/(M N) (n_k_2) \
>& 0,
$

此时 $T(r)$ 在区间 $0 <= r <= L-1$ 上是一个严格单调递增函数．

下面证明严格单调递增函数 $T(r)$ 的反函数 $r = T^(-1)(s)$ 严格单调递增．取 $0 <= s_k_1 < s_k_2 <= L-1$，有 $r_k_1 = T^(-1)(s_k_1),$ $r_k_2 = T^(-1)(s_k_2)$，因为 $T(r)$ 严格递增，所以 $r_k_1 < r_k_2 $ ，所以 $T^(-1)(s)$ 在 $0 <= s <= L-1$ 上严格递增．

#problemCounter.step()
== 在给定应用中，一个均值模板被用于输入图像以减少噪声，然后再用一个拉普拉斯模板来增强图像中的细节．如果交换一下这两个步骤的顺序，结果是否会相同？

两个模板均为线性变换，顺序不影响最终结果．即交换前后结果相同．
/*
g(x, y) = f(x - 1, y - 1) + f(x, y - 1) + f(x + 1, y - 1) + 
          f(x - 1, y) + f(x, y) + f(x + 1, y) +
            f(x - 1, y + 1) + f(x, y + 1) + f(x + 1, y + 1)
h(x, y) = 5 g(x, y) - g(x + 1, y) - g(x - 1, y) - g(x, y + 1) - g(x, y - 1) = 
*/

#problemCounter.step()
== 使用式（3.6-6）给出的拉普拉斯定义，证明从一幅图像中减去相应的拉普拉斯图像等同于对图像进行非锐化模板处理．

非锐化处理中，

$ g_"1mask"(x, y) = f(x, y) - overline(f) (x, y) $

$ g_1(x, y) = f(x, y) + k_1 dot g_"1mask"(x, y) = (1 + k_1) f(x, y) - k_1 overline(f) (x, y). $

由拉普拉斯定义

$ nabla^2 f(x,y) = f(x+1, y) + f(x-1, y) + f(x, y+1) + f(x, y-1) - 4f(x, y), $

$ g_2(x, y) 
= &f(x, y) - nabla^2 f(x,y) \
= &f(x, y) - (f(x+1, y) + f(x-1, y) + f(x, y+1) + f(x, y-1) - 4f(x, y)) \
=&5f(x, y) - (f(x+1, y) + f(x-1, y) + f(x, y+1) + f(x, y-1)) \
=&5f(x, y) - k_2 overline(f)(x, y).　$

// $ f_2(x, y) = f(x, y) - g(x, y) = nabla^2 f(x,y). $

有 $g_1(x, y)bar_(k_1 = 4) = g_2(x, y)bar_(k_2 = 4)$．即从一幅图像中减去相应的拉普拉斯图像等同于对图像进行非锐化模板处理．
