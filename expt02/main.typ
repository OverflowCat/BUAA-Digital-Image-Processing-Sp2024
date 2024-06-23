#set text(lang: "zh", cjk-latin-spacing: auto, font: "Noto Serif CJK SC")
#set page(numbering: "1", margin: (left: 1.4cm, right: 1.9cm))
#show figure.caption: set text(font: "Zhuque Fangsong (technical preview)")
#show "。": "．"
#show heading: set text(font: "Noto Sans CJK SC", size: 1.15em)
#import "../expt01/blockcode.typ": bc
#show raw.where(block: true): bc
#show raw.where(): set text(size: 1.15em, font: "JetBrains Mono")

== 1、（P185例4.23）

使用陷波滤波减少莫尔（波纹）模式。@img1 是来自扫描报纸的图像，它显示了突出的莫尔模式，设计一个 Butterworth 陷波带阻滤波器消除图像中的莫尔条纹。

#figure(
  caption: "莫尔模式的取样过的报纸图像",
  image("Images/1.png"),
)<img1>

Butterworth 带阻滤波器的公式为
$ H(u, v) = 1 / (1 + (display((D(u, v)W) / (D^2(u, v) - D_0^2)))^(2 n)) $


(a) 用零填充图像会增加其大小，但不会改变其灰度级内容。因此，填充后图像的平均灰度级低于原始图像。这意味着填充后图像频谱中的 F(0,0) 小于原始图像中的 F(0,0)（回想一下，F(0,0) 是相应图像的平均值）。因此，我们可以看到右边频谱中的 F(0,0) 较低，远离原点的其他值也较低，并且覆盖的值范围更窄。这就是右边图像整体对比度较低的原因。

(b) 用 0 填充图像会在原始图像的边界处引入明显的间断。这个过程会引入强烈的水平和垂直边缘，图像在这些边缘处突然结束，然后继续为 0 值。这些急剧的过渡对应于频谱中沿水平轴和垂直轴的强度。

== 2、（P186例4.24）

使用陷波滤波增强恶化的卡西尼土星图像。@img2 显示了部分环绕土星的土星环的图像。太空船第一次进入该行星的轨道时由“卡西尼”首次拍摄了这幅图像。垂直的正弦模式是在对图像数字化之前由叠加到摄影机视频信号上的AC信号造成的。这是一个想不到的问题，它污染了来自某些任务的图像。设计一种陷波带阻滤波器，消除干扰信号。


#figure(
  caption: "近似周期性干扰的土星环图像，图像大小为674×674像素",
  image("Images/2.png", width: 55%),
)<img2>