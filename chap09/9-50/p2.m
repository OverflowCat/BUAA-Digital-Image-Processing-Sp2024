a = imread('image.png');
structuringElement = strel('disk', 13);
b = imclose(a, structuringElement);
c = imopen(b, structuringElement);

% 删除 c 中大斑点间亮间距后得到边缘
c2 = imerode(c, strel('disk', 17));
edge = c - c2;

% 对 c 进行梯度运算得到 c 的边缘图像（与 b 无关）
% edge = imgradient(c);

subplot(1, 4, 1), imshow(a), title('Original Image');
subplot(1, 4, 2), imshow(b), title('imclose');
subplot(1, 4, 3), imshow(c), title('imopen');
subplot(1, 4, 4), imshow(edge), title('边缘');
