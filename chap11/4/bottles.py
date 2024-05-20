import cv2
import numpy as np

# 读取图像
gray_image = cv2.imread("bottles-assembly-line.tif", 0)  # 0 表示以灰度模式读取

# 二值化
BW_THRESHOLD = 170  # 阈值
_, binary_image = cv2.threshold(gray_image, BW_THRESHOLD, 255, cv2.THRESH_BINARY)

# 对图片进行开操作
kernel = np.ones((3, 7), np.uint8)
opened_image = cv2.morphologyEx(
    binary_image,
    cv2.MORPH_OPEN,  # = 2: 开操作
    # cv2.MORPH_ERODE  = 0：腐蚀
    # MORPH_DILATE     = 1：膨胀处理
    # MORPH_CLOSE      = 3：闭运算处理
    kernel,
)

# 获取连通分量及其统计信息
num_labels, labels_im, stats, centroids = cv2.connectedComponentsWithStats(opened_image)

# 显示每个连通分量
output_image = np.zeros((gray_image.shape[0], gray_image.shape[1], 3), dtype=np.uint8)

# 为每个连通分量赋予随机颜色
for label in range(1, num_labels):  # 从1开始，0是背景
    mask = labels_im == label
    output_image[mask] = np.random.randint(0, 255, 3)

AREA_THRESHOLD = 900  # 面积阈值
components = [
    stats[i]
    for i in range(1, num_labels)
    # 保存面积大于阈值的连通分量
    if stats[i, cv2.CC_STAT_AREA] > AREA_THRESHOLD
]
components.sort(
    key=lambda x: x[cv2.CC_STAT_LEFT],
)  # 按照左上角 x 的坐标排序，从左到右


for i, component in enumerate(components):
    x, y, width, height, area = component
    bottom = y + height  # 液面位置的 y 坐标

    is_full = bottom < 100

    print(
        f"第 {i+1} 个连通分量的面积为 {area}，高度为 {height}，液面位置的 y 坐标为 {bottom}，"
        + ("是满的" if is_full else "不是满的")
    )

    # 绘制矩形框
    color = (0, 255, 0) if is_full else (0, 0, 255)
    cv2.rectangle(output_image, (x, y), (x + width, y + height), color, 2)
    cv2.putText(
        output_image,
        f"{i + 1}",
        (x, y + height + 25),
        cv2.FONT_HERSHEY_SIMPLEX,
        0.75,
        color,
        2,
        cv2.LINE_AA,
    )

# 显示结果
cv2.imshow("Output", output_image)

# 保存到文件
cv2.imwrite("output.png", output_image)

cv2.waitKey(0)
cv2.destroyAllWindows()
