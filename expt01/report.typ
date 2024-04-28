#set page(margin: 1.5cm)
#set text(font:("STIX Two Text", "Noto Serif CJK SC"), size:1.08em, lang: "zh", cjk-latin-spacing: auto)
// #set page(paper: "iso-b5", numbering: "1")
#import "blockcode.typ": bc

#let em = (body) => {
  set text(font:("Zhuque Fangsong (Technical Preview)"), size: 1.1em)
  [#body]
}

= 数字图像处理  实验一

== 实验目的

+ #em[完成图像统计算法]：计算图像的直方图、均值和方差；
+ #em[实现图像增强算法]：根据教材提供的方案，完成选择性局部图像增强功能；
+ #em[探究参数选择方法]：通过实验分析增强关键参数对图像质量的影响规律，寻找合适的参数．

== 实验准备

=== 开发环境介绍

为了方便查看效果，我采用了 Web 相关技术进行开发，编译后可以运行在任意操作系统的浏览器环境中。可以方便地选择本地的任意图片（仅限 `png` 和 `jpg` 格式），可以通过 UI 调整各个参数并实时查看结果。

同时，由于没有使用相关的图像处理库，所以在自行实现的过程中能够深入了解底层原理．

=== 图片的读取和显示

本实验中，代码允许用户选择本地图片作为输入．首先，用户通过 HTML 的文件选择器选择一张图片．接着，我们将图片绘制到 canvas 画布上，此时图片数据可以读取为 RGBA 形式的数组，即每个像素包含红、绿、蓝和透明度四个通道的值，范围皆为 0 $~$ 255．

由于我们假定实验处理的是灰度图像，因此我们定义了 ```ts toSingleChannel()``` 函数，将RGBA形式的数组转换为单通道的灰度值数组，以便后续处理．#em[灰度图像的红、绿、蓝三个通道的值相等]，因此我们可以以任意三个通道中任意一个通道的值作为灰度值．

由于canvas的数据返回的是 ```ts Uint8ClampedArray``` 类型，即一个 8 位无符号整数数组．数据的排列为 $[r_0, g_0, b_0,a_0, r_1, g_1, b_1, a_1, dots, r_(n-1), g_(n-1), b_(n-1), a_(n-1)]$，我们需要将其转换为 $[r_0, r_1, dots, r_(n-1)]$ 的形式．

#bc(filename: "src/imageUtils.ts")[
  ```ts
function toSingleChannel(imgData: ImageData): SingleChannelImageData {
  const length = imgData.width * imgData.height;
  const data = new Uint8ClampedArray(length);
  for (let i = 0; i < imgData.data.length; i++) {
    // 灰度图像 r == g == b，alpha == 255，取 r 通道即可
    data[i] = imgData.data[i * 4];
  }
  return {
    data,
    width: imgData.width,
    height: imgData.height,
    length,
  };
}
  ```
]

处理图像完成后，我们又需要将处理后的单通道灰度值数组转换为 RGBA 形式的数组，才能绘制到canvas画布上显示或者转换成图片下载．因此我们定义了 ```ts toRGBA()``` 函数，将 $[h_0, h_1, dots, h_(n-1)]$ 转换为 $[h_0, h_0, h_0, 255, h_1, h_1, h_1, 255, dots, h_(n-1), h_(n-1), h_(n-1), 255]$ 的形式．

#bc(filename: "src/imageUtils.ts")[
  ```ts
function toRGBA(imageData: SingleChannelImageData): ImageData {
  const rgba = new Uint8ClampedArray(imageData.length * 4);
  for (let i = 0; i < imageData.length; i++) {
    rgba[i * 4] = imageData.data[i];
    rgba[i * 4 + 1] = imageData.data[i];
    rgba[i * 4 + 2] = imageData.data[i];
    rgba[i * 4 + 3] = 255;
  }
  return new ImageData(rgba, imageData.width, imageData.height);
}
  ```
]

== 图像统计特征

=== 计算全局直方图

首先创建一个长度为 256 的数组，并将所有元素初始化为 0．然后，遍历图像数据中的每个像素，并#em[将其灰度值作为索引]，将对应灰度级的计数加 1．最后，返回计算得到的直方图数组．

#bc(filename: "src/histogram.ts")[
  ```ts
function histogram(imgData: SingleChannelImageData): number[] {
  const hist = new Array(256).fill(0);
  for (let i = 0; i < imgData.data.length; i++) {
    const gray = imgData.data[i];
    hist[gray]++;
  }
  return hist;
}
  ```
]

=== 计算全局均值

首先初始化一个累加变量 `sum` 为 0．然后，遍历图像数据中的每个像素，将其灰度值累加到 `sum` 中．最后，将 `sum` 除以图像数据长度，得到图像的全局均值并返回．

#bc(filename: "src/histogram.ts")[
  ```ts
function calculateMean(imgData: SingleChannelImageData) {
  let sum = 0;
  for (let i = 0; i < imgData.data.length; i++) {
    sum += imgData.data[i];
  }
  return sum / imgData.data.length;
}
  ```
]

=== 计算全局方差

首先初始化一个变量 `sum` 为 0．然后，遍历图像数据中的每个像素，计算其灰度值与均值的差的平方，并累加到 `sum` 中．最后，将 `sum` 除以图像数据长度，得到图像的全局方差并返回．

#bc(filename: "src/histogram.ts")[
  ```ts
function calculateSigma2(imgData: SingleChannelImageData, m: number) {
  let sum = 0;
  for (let i = 0; i < imgData.length; i++) {
    sum += Math.pow(imgData.data[i] - m, 2);
  }
  return sum / imgData.data.length;
}
  ```
]

=== 计算局部直方图

对于给定图像中任意像素的坐标，$S_(x y)$ 表示规定大小的以 $(x," "y)$ 为中心的邻域（子图像），记 $p_S_(x y)$ 为区域 $S_(x y)$ 中像素的规一化直方图，$r_i$ 为灰度，则该邻域中像素的均值

$ m_S_(x y) = sum^(L-1)_(i=0) r_i p_S_(x y) (r_i) $

$ sigma_S_(x y) = sum^(L-1)_(i=0) $


对于 $x=0,1,2,dots.c,M-1,quad y=0,1,2,dots.c,N-1$，有

== 选择性局部图像增强

=== 计算局部直方图



=== 逐像素处理

$
g(x,y) = cases(
 E dot.c f(x","y)","quad &m_S_(x y) <= k_0 m_G " 且 " k_1 sigma_G <= sigma_S_(x y) <= k_2 sigma_G,
 f(x,y)"," quad &"其他"
)
$

#bc(filename: "src/App.svelte")[
```ts
function enhanceImage(origImage: SingleChannelImageData, neighborhood: number) {
  /** 全局均值 */
  const m_G = calculateMean(origImage);
  /** 全局标准差 */
  const sigma_G = Math.sqrt(calculateSigma2(origImage, m));
  /** 局部均值和方差 */
  const { ms, sigmas } = localHistogram(origImage, neighborhood);

  const enhanced = new Uint8ClampedArray(origImage.data); // 复制原图像数据

  for (let idx = 0; idx < origImage.length; idx++) {
    const m_S = ms[idx];
    const sigma_S = sigmas[idx];
    if (m_S <= k0 * m_G && k1 * sigma_G <= sigma_S && sigma_S <= k2 * sigma_G) {
      let px = Math.round(E * origImage.data[idx]);
      if (px < 0) px = 0;
      else if (px > 255) px = 255; // 确保像素值在 0~255 内
      enhanced[idx] = px; // 更新增强后的像素值
    }
  }
  ... // 转换为 RGBA 图像数据并绘制到 canvas 上的代码省略
}
```]

=== 增强关键参数选择方法

/ $E$: 增大 $E$ 会增强图像整体对比度，但可能导致细节丢失和噪声放大．实验中，图片增强效果最好的是 $E=5.1$．
/ $K_0, K_1, K_2$: 调整阈值参数可以控制增强区域的选择性，从而突出特定特征．
/ $S_(x y)$: 增大局部区域大小可以平滑图像，但可能导致边缘模糊．
