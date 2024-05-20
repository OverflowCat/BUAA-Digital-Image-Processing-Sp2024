#set text(lang: "zh", cjk-latin-spacing: auto, font: "Noto Serif CJK SC")
#set page("iso-b5")

+ 教材P554页，第11.1题
  + 重新定义链码的一个起始点，以便所得的数字序列形成一个最小值整数。请证明该编码与边界上的初始起点无关。

    设链码 $A = {a_1, a_2, a_3, dots, a_n }$。重新定义链码的一个起始点，相当于将该链码循环移动若干位。设循环左移 $k$ 位，得到链码 $A' = {a_k, a_(k+1), a_(k+2), dots, a_n, a_1, a_2, dots, a_(k-1)}.$ 在边界上选取另一个起点，得到的链码 $B$ 相当于将 $A$ 循环移动若干位。设循环左移 $m$ 位。则
  
  + 求编码10176722335422的归一化起始点。

    编码

+ 教材P554页，第11.2题
  + 如11.1.2节中解释的那样，证明链码的一次差分会将该链码关于旋转归一化。
  + #include "chain.typ"

+ 求@shape 中图形的链码、一阶差分、形状数和形状数的阶（起点在左上角，按照顺时针方向）。

  #figure(caption: "形状")[#include "shape.typ"]<shape>

  #import "chain.typ": calcChain, calcShape, lShift

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

+ 一家使用瓶子盛装各种工业化学品的公司在听说您成功地解决了图像处理问题后，雇用您来设计一种检测瓶子未装满的方法。瓶子在传送带上移动并通过自动装填和封盖机时的情形如下图所示。当液位低于瓶颈底部和瓶子肩部的中间点时，则认为瓶子未装满。瓶子横断面的侧面与倾斜面的区域定义为瓶子的肩部。瓶子在不断移动，但该公司有一个成像系统，该系统装备了一个前端照明闪光灯，可有效地停止瓶子的移动，所以您可以得到非常接近于这里显示的样例图像。基于上述资料，请您提出一个检测未完全装满的瓶子的解决方案。清楚地陈述您所做的那些可能会影响到解决方案的所有假设。

  #include "4/answer.typ"
