#set par(leading: 1em)

== 假设

- *瓶子位置和尺寸一致*：假设瓶子不倾斜，垂直位置和尺寸大致一致。
- *图片拍摄条件一致*：假设拍摄条件一致，瓶子在传送带上的位置和角度相对固定。
- *灰度对比明显*：假设图像中瓶子和背景有明显的灰度对比，能够通过二值化处理有效区分。
- *传送带速度合适、恒定*：假设传送带的速度恒定，瓶子在传送带上的运动速度和方向一致，瓶子中液体不会摇晃。
- *整齐排列*：假设瓶子在传送带上排列整齐，水平位置和大小差异不大，便于排序和检测。

== 方案

#set enum(numbering: "1.")
1. *图像预处理*：读取灰度图像并进行二值化处理，将图像转换为黑白图，以区分瓶子和背景。
2. *形态学操作*：对二值化图像进行形态学开操作，去除图像噪声，确保瓶子轮廓清晰。
3. *连通分量分析*：使用连通分量分析技术检测瓶子位置，计算各瓶子的统计信息，如面积和位置。
4. *液位检测*：根据瓶子的高度和液面位置判断瓶子是否装满。如果液面低于设定的阈值，则认为瓶子未装满。
5. *结果显示*：在图像上标注检测结果，使用不同颜色框和编号表示检测结果。

== 实现

#show raw: set text(font: "Sarasa Term Slab SC", size: 1.08em)

=== 图像预处理与二值化

```python
gray_image = cv2.imread("bottles-assembly-line.tif", 0) # 0 表示以灰度模式读取
BW_THRESHOLD = 170 # 二值化阈值
_, binary_image = cv2.threshold(gray_image, BW_THRESHOLD, 255, cv2.THRESH_BINARY)
```

读取灰度图像，并使用阈值170进行二值化处理，将图像转换为黑白图。

=== 形态学操作
```python
kernel = np.ones((3, 7), np.uint8)
opened_image = cv2.morphologyEx(binary_image, cv2.MORPH_OPEN, kernel)
```

使用形态学开操作去除噪声，确保瓶子的轮廓更加清晰。若不进行形态学操作，可能会导致连通分量分析不准确，如@bottles_notopen 所示。

#figure(caption: "未进行形态学开操作，直接处理的结果", image("./colored.png", width: 7cm))<bottles_notopen>

=== 连通分量分析
```python
num_labels, labels_im, stats, centroids = cv2.connectedComponentsWithStats(opened_image)
```
使用 ```python cv2.connectedComponentsWithStats``` 获取连通分量及其统计信息。

=== 液位检测与结果显示
```python
AREA_THRESHOLD = 900 # 面积阈值
components = [
  stats[i]
  for i in range(1, num_labels)
  if stats[i, cv2.CC_STAT_AREA] > AREA_THRESHOLD
]
components.sort(key=lambda x: x[cv2.CC_STAT_LEFT]) # 按水平位置排序

for i, component in enumerate(components):
  x, y, width, height, area = component
  bottom = y + height
  is_full = bottom < 100 # 液面阈值
  color = (0, 255, 0) if is_full else (0, 0, 255) # 满的为绿色，未满的为红色
  cv2.rectangle(output_image, (x, y), (x + width, y + height), color, 2)
  cv2.putText(output_image, f"{i + 1}", (x, y + height + 25), cv2.FONT_HERSHEY_SIMPLEX, 0.75, color, 2, cv2.LINE_AA)
```

根据连通分量的面积和位置筛选出有效的瓶子，计算液面位置，判断是否装满，并在图像上绘制矩形框和编号。液面低于100像素认为瓶子未装满，用红色框表示；否则用绿色框表示。

=== 结果输出

最终输出图片结果如@bottles_out 所示。
#figure(caption: "检测结果", image("./output.png", width: 9cm))<bottles_out>

控制台输出结果如下：

```shell
第 0 个连通分量的面积为 2607，高度为 65，液面位置的 y 坐标为 83，是满的
第 1 个连通分量的面积为 3132，高度为 63，液面位置的 y 坐标为 81，是满的
第 2 个连通分量的面积为 8606，高度为 119，液面位置的 y 坐标为 136，不是满的
第 3 个连通分量的面积为 3132，高度为 63，液面位置的 y 坐标为 81，是满的
第 4 个连通分量的面积为 1871，高度为 65，液面位置的 y 坐标为 83，是满的
```

通过以上方法，能够有效检测传送带上未完全装满液体的瓶子，并在图像上直观展示检测结果。

#"\n"
#"\n"
#"\n"
#"\n"

== 附：程序完整代码

#set par(leading: .85em)
#let file = read("./bottles.py")
#raw(file, lang: "python")
