#set text(lang: "zh", cjk-latin-spacing: auto, font: "Noto Serif CJK SC")
#set page(numbering: "1", margin: (left: 1.4cm, right: 1.9cm))
// #set par(leading: 1em)
#show figure.caption: set text(font: "Zhuque Fangsong (technical preview)")
#show "。": "．"
#show heading: set text(font: "Noto Sans CJK SC", size: 1.15em)
#import "../expt01/blockcode.typ": bc
#show raw.where(block: true): bc
#show raw.where(): set text(size: 1.15em, font: "JetBrains Mono")

#strong[《数字图像处理》（课程代码：B3I173330）]
= 数字图像处理  实验3  实验报告

#align(center)[#table(
  columns: 3,
  align: (col, row) => (auto,auto,auto,).at(col),
  inset: 6pt,
  [
    #strong[实验小组成员]
    #strong[（学号+班级+姓名）]
  ], [#strong[分工及主要完成任务]], [#strong[成绩]],
  include "private.typ",
  [实验报告和代码],
  h(7em),
)
]

== 实验目的
#figure(
    caption: "原始图片",
    image("Images/MutipleObject.png", width: 40%)
)

完成如图所示的多目标分割，基于分割获取的数据（可以是边界像素或者区域像素）计算各目标的特征参数（比如圆度:
$"circularity"=4 pi S / P^2$，s为面积，p为周长;也可以依据椭圆或者矩形定义相关形状特征)，然后对目标进行分类，编程语言可以选择C++，Matlab，Python等。设计方案可参照Matlab帮助文献的方案（见附件材料），也可以自行设计新的方案。

原始图像的电子版图像在Images文件夹中。实验报告写在如下空白处，页数不限。

== 图像预处理

首先，我们使用OpenCV库读取待处理的图像，并将其转换为灰度图：

```python
image = cv2.imread("./Images/MutipleObject.png")
image = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
```

接着，通过阈值化将图像二值化，区分目标区域与背景。本实验中，我们选取170作为阈值。结果如
@thresh 所示。

```python
_, image = cv2.threshold(image, 150, 255, cv2.THRESH_BINARY)
```

#figure(caption: "二值化后的图片", image("Assets/ThresholdImage.png", width: 40%), placement: top)<thresh>

为进一步消除噪声并平滑目标边缘，我们对二值图像进行形态学闭操作，使用 $9 times 9$ 的矩形结构元素。结果如@closed 所示。

```python
cv2.morphologyEx(image, cv2.MORPH_CLOSE, cv2.getStructuringElement(cv2.MORPH_RECT, (9, 9)))
```

#figure(caption: "预处理后的图片", image("Assets/ClosedImage.png", width: 40%))<closed>

== 计算特征

=== 轮廓提取

预处理完成后，我们使用`cv2.findContours`函数获取图像中的轮廓。`findContours` 的原理如下：

#include "findContours.typ"

为排除噪声干扰，我们过滤掉面积小于800像素#super("2")的轮廓：

```python
contours, hierarchy = cv2.findContours(image, cv2.RETR_TREE, cv2.CHAIN_APPROX_SIMPLE)

for i, contour in enumerate(contours):
    if cv2.contourArea(contour) < 800:
        continue
...
```

=== 多边形逼近

对于每个保留的轮廓，我们进行多边形逼近，并计算其顶点数。

```python
...
    epsilon = 0.008 * cv2.arcLength(contour, True)
    approx = cv2.approxPolyDP(contour, epsilon, True)
...
```

此处的 $epsilon$ 参数用于控制逼近精度。

根据逼近后的顶点数 `count`，我们对目标形状进行分类：

```python
...
    count = len(approx)
    if count == 3:
        shape = "Triangle"
    elif count == 4:
        shape = "Quadrilateral"
    elif count == 5:
        shape = "Pentagon"
    elif count == 6:
        shape = "Hexagon"
...
```

=== 椭圆拟合

重点是对于圆、椭圆和不规则形状的分类。我们可以通过拟合椭圆的方法，判断目标形状是否为圆或椭圆。通过 `cv2.fitEllipse` 函数，我们可以获取拟合椭圆的中心 $(x_upright(c), y_upright(c))$、两轴 $a, b$ 和旋转角度 $angle#raw("angle")$。先将其绘制在图像上。

随后，我们计算椭圆的离心率 $e = sqrt(1 - (b / a)^2)$，并根据其大小判断目标形状——圆的离心率接近0，而椭圆的离心率较大。我们将离心率小于0.25的目标判定为圆形，否则判定为椭圆。注意 OpenCV 给出的椭圆长轴 $a$ 和短轴 $b$ 的顺序可能不同，因此我们需要先对其进行排序。

```python
...
    elif count > 10:
        (cx, cy), (a, b), angle = cv2.fitEllipse(contour)
        cv2.ellipse(image, (int(cx), int(cy)), (int(a / 2), int(b / 2)), angle, 0, 360, (133, 81, 252), 2)

        a, b = max(a, b), min(a, b) # b 是长轴，调整顺序
        eccentricity = math.sqrt(1 - (b / a) ** 2)
        print(f"eccentricity: {eccentricity}")
        if eccentricity < .25:
            cv2.putText(image, "Circle", coords, font, .75, colour, 1)
        else:
            cv2.putText(image, "Oval", coords, font, .75, colour, 1)
...
```

如果目标顶点数不在上述范围内，我们将其判定为不规则形状。

```python
...
    else:
        shape = "Irregular"
```

#figure(
    caption: "检测结果",
    // placement: bottom,
    image("Assets/Result.png", width: 40%)
)<result>

== 结果展示

我们预先计算了轮廓的中点坐标，并根据目标形状绘制了相应的标签。

```python
    ...
    # 获取轮廓的坐标
    x, y, w, h = cv2.boundingRect(approx)
    x_mid = int(
        x + (w / 3)
    )  # 对形状的x轴中点的估计
    y_mid = int(
        y + (h / 1.5)
    )  # 对形状的x轴中点的估计
    coords = (x_mid, y_mid)
    colour = (82, 171, 61)
    font = cv2.FONT_HERSHEY_SIMPLEX
    ...
```

最终，我们通过 `cv2.imshow` 函数展示了检测结果，如@result 所示。

```
cv2.imshow("图形检测", image)
cv2.waitKey(0)
```

== 实验总结

本实验成功实现了多目标图像的分割与分类。通过合理运用图像处理技术，我们能够从复杂图像中提取有意义的信息，并对其进行分析与理解。

在实验中，我们对于一些关键的常数，都是根据具体效果使用的魔法数字（magic number）。这些数字的选择对于最终的结果有着重要的影响；在实际应用中，我们可以进一步优化算法，提高分类算法的自适应性，以应对更加复杂多变的场景。
