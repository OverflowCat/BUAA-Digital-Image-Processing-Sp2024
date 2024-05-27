#import "chain.typ": calcChain, calcShape, lShift
#import "util.typ": problem
#set text(lang: "zh", cjk-latin-spacing: auto, font: "Noto Serif CJK SC")
#set page("iso-b5", numbering: "1", margin: (left: 1.4cm, right: 1.9cm))
#set par(leading: 1.1em)
#show table: set text(font: "Zhuque Fangsong (technical preview)")
#show figure.caption: set text(font: "Zhuque Fangsong (technical preview)")
#show "。": "．"
#show heading: set text(font: "Noto Sans CJK SC", size: 1.15em)

= 数字图像处理  第11章 形状表示与描述 作业

// #show math.equation: set text(font: "Fira Math")
#set enum(numbering: "1.a.1.")

+ 教材P554页，第11.1题

  + #problem[重新定义链码的一个起始点，以便所得的数字序列形成一个最小值整数。请证明该编码与边界上的初始起点无关。]

    设链码 $A = {a_1, a_2, a_3, dots, a_n }$。另选一个初始起点，相当于循环位移该链码。设循环左移 $k$ 位，得到链码 $B = {a_k, a_(k+1), a_(k+2), dots, a_n, a_1,a_2, dots,$ $a_(k-1)}.$
    
    // 在边界上选取另一个起点，得到的链码 $B$ 相当于将 $A$ 循环移动若干位。设 $A$ 循环左移 $m$ 位得到最小值 $a$，$B$ 循环左移 $n$ 位得到最小值 $b$。
    
    重新定义链码的一个起始点，相当于将该链码循环移动若干位。假设最小数字为 $a_m$。$A$ 循环左移 $m$ 位得到最小值 $A' = {a_m, a_(m+1), a_(m+2), dots,$ $a_n, a_1, a_2, dots, a_(m-1)}$；由于最小值唯一，所以将 $B$ 循环左移 $m+k$ 位得到 $B' = {a_m, a_(m+1), a_(m+2), dots, a_n, a_1, a_2, dots, a_(m-1)} = A'$。
    
    // 由于循环移位不改变数字串中数字的相对顺序，因此最小数字 $a_m$ 在 $B$ 中的位置为 $(m+k) mod n$。将 $B$ 循环左移 $k$ 位得到 $B' = {a_(m+k), a_(m+k+1), a_(m+k+2), dots, a_n, a_1, a_2, dots, a_(m+k-1)}$。

    // 因此，无论对原始数字串进行多少次循环移位，要使其最小数字位于首位，所需的额外循环移位次数总是 $(n-m) mod n$，这个值是固定的。
  
  #let enc = "10176722335422"
  #let nml = calcShape(enc)
  #let idx = enc.position(nml.first())

  + #problem[求编码#enc 的归一化起始点。]

    编码 #enc 归一化后为#nml，起始点为原始链码的第#(idx + 1)
    个数字。

+ 教材P554页，第11.2题

  + #problem[如11.1.2节中解释的那样，证明链码的一次差分会将该链码关于旋转归一化。]
  + #include "chain.typ"

+ #problem[求@shape 中图形的链码、一阶差分、形状数和形状数的阶（起点在左上角，按照顺时针方向）。]

  #figure(caption: "形状")[#include "shape.typ"]<shape>

  #let chain = "000332123211"
  #let (res, first) = calcChain(chain)
  #let chain- = "300303311330"
  #assert(str(first) + res == chain-)
  #let shape-no = calcShape(chain-)
  // - 链码：$chain$
  // - 一阶差分：$#chain-$
  // - 形状数：$#shape-no$
  // - 形状数的阶：$#shape-no.len()$
  // #show table: it => align(center, it)
  #figure(caption: "答案")[
  #table(
    columns: (auto, auto),
    align: right,
    [链码], $chain$,
    [一阶差分], $#chain-$,
    [形状数], $#shape-no$,
    [形状数的阶], $#shape-no.len()$
  )
  ]

+ 教材P556页，第11.26题

  #problem[
    一家使用瓶子盛装各种工业化学品的公司在听说您成功地解决了图像处理问题后，雇用您来设计一种检测瓶子未装满的方法。瓶子在传送带上移动并通过自动装填和封盖机时的情形如下图所示。当液位低于瓶颈底部和瓶子肩部的中间点时，则认为瓶子未装满。瓶子横断面的侧面与倾斜面的区域定义为瓶子的肩部。瓶子在不断移动，但该公司有一个成像系统，该系统装备了一个前端照明闪光灯，可有效地停止瓶子的移动，所以您可以得到非常接近于这里显示的样例图像@bottles。基于上述资料，请您提出一个检测未完全装满的瓶子的解决方案。清楚地陈述您所做的那些可能会影响到解决方案的所有假设。
  ]

  #figure(caption: "原图", image("4/bottles-assembly-line.png", width: 7cm))<bottles>

  #include "4/answer.typ"
