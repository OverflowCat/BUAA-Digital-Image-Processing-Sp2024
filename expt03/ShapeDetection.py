import cv2
import math

image = cv2.imread("./Images/MutipleObject.png")

image = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)  # Converting to gray image

_, image = cv2.threshold(image, 170, 255, cv2.THRESH_BINARY)

cv2.imwrite("./Assets/ThresholdImage.png", image)

cv2.morphologyEx(
    image, cv2.MORPH_CLOSE, cv2.getStructuringElement(cv2.MORPH_RECT, (9, 9))
)

# cv2.imshow("Image", image)
# write to Assets/ClosedImage.png
cv2.imwrite("./Assets/ClosedImage.png", image)
# cv2.waitKey(0)

# 获取新阈值图像中的外边缘坐标
contours, hierarchy = cv2.findContours(image, cv2.RETR_TREE, cv2.CHAIN_APPROX_SIMPLE)

image = cv2.cvtColor(image, cv2.COLOR_GRAY2RGB)

for i, contour in enumerate(contours):
    # 忽略较小的区域，去除噪点
    if cv2.contourArea(contour) < 800:
        continue

    epsilon = 0.008 * cv2.arcLength(contour, True)
    approx = cv2.approxPolyDP(contour, epsilon, True)
    if len(approx) < 6:
        cv2.drawContours(image, contours, i, (201, 193, 63), 4)
    # cv2.drawContours(image, contour, -1, (100, 100, 200), 4)

    # 获取轮廓的坐标，以便放置文本
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

    # 检测轮廓/形状的边缘数量，然后根据该结果猜测形状
    count = len(approx)
    if count == 3:
        cv2.putText(image, "Triangle", coords, font, .75, colour, 1)  # Text on the image
    elif count == 4:
        cv2.putText(image, "Quadrilateral", coords, font, .75, colour, 1)
    elif count == 5:
        cv2.putText(image, "Pentagon", coords, font, .75, colour, 1)
    elif count == 6:
        cv2.putText(image, "Hexagon", coords, font, .75, colour, 1)
    elif count > 10:
        (cx, cy), (a, b), angle = cv2.fitEllipse(contour)
        cv2.ellipse(image, (int(cx), int(cy)), (int(a / 2), int(b / 2)), angle, 0, 360, (133, 81, 252), 2)

        a, b = max(a, b), min(a, b)
        eccentricity = math.sqrt(1 - (b / a) ** 2)
        print(f"eccentricity: {eccentricity}")
        if eccentricity < .25:
            cv2.putText(image, "Circle", coords, font, .75, colour, 1)
        else:
            cv2.putText(image, "Oval", coords, font, .75, colour, 1)
    else:
        cv2.putText(image, "Irregular", coords, font, .75, colour, 1)

cv2.imshow("图形检测", image)
cv2.waitKey(0)

cv2.imwrite("./Assets/Result.png", image)