#set text(lang: "zh", cjk-latin-spacing: auto, font: "Noto Serif CJK SC")
#set page(numbering: "1", margin: (left: 1.4cm, right: 1.9cm))
#show figure.caption: set text(font: "Zhuque Fangsong (technical preview)")
#show "。": "．"

= 第九章作业

1. 较小的方块在腐蚀后完全消失，而较大的方块超过了结构元大小这一阈值，并且和结构元形状一致，没有被完全腐蚀，所以能够保留下来。

2. 可以，因为两张图片都是类似的互不接触的圆点。
  
  #figure(caption: "处理结果", image("9-50/result.svg", height: 6cm, width: 125%))
  
  代码如下：

  #raw(read("9-50/p2.m"), lang: "m")

3. #set enum(numbering: "(a)")

  + 找出所有触碰到图像边界的粒子，可通过在图像边缘一圈的值为 1 的像素开始，寻找 4 连通分量。

  + 可以根据面积确定。先找一个合适的面积值 $A$ 和标准差 $sigma$，查找所有连通分量并分别计算面积 $A_i$，若 $A_i$ 在 $A plus.minus 3 sigma$ 外可认为是仅彼此重叠的颗粒；

  + 在 $A plus.minus 3 sigma$ 内的连通分量可认为是仅彼此重叠的颗粒。

4. 将图像二值化处理，然后与取反后的标准图像进行 AND 操作，留下的差异区域为 1。然后根据连通分量将这些差异区域分组，并根据连通分量的数量、大小、形状等特征判断垫圈是否合格。如果连通分量为 0 说明垫圈非常完美，个数越多、大小越大说明质量越低，以此类推。