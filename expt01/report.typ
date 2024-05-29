#set page(margin: (left: 1.6cm, right: 1.6cm, top: 2.4cm, bottom: 2.4cm), numbering: "1")
#set text(font:("STIX Two Text", "Noto Serif CJK SC"), size: 1.07em, lang: "zh", cjk-latin-spacing: auto)
#set par(leading: 0.96em, justify: true)
#show par: set block(spacing: 1.25em)
#set heading(bookmarked: true)
#show heading: set text(size: 1.1em)
#show figure.caption: set text(font: "Zhuque Fangsong (technical preview)", size: 1.1em, fill: rgb(55, 55, 55))
#set math.equation(numbering: "(1)")
#show link: underline
#show link: set text(fill: rgb(32, 120, 150))

// #set page(paper: "iso-b5")
#import "blockcode.typ": bc

#let em = (body) => {
  set text(font:("Zhuque Fangsong (Technical Preview)"), size: 1.1em)
  [#body]
}

= 数字图像处理$quad$实验一

#include "./private.typ"

#stack(dir: rtl, spacing: 2em,
[
  #figure(caption: "绕在支架上的钨丝的
  扫描电子显微镜图像", image("images/Fig0327(a)(tungsten_original).png", width: 25%))<orig>
], block(width: 11.8cm)[

== 实验目的

+ #em[完成图像统计算法]：计算给定图像@orig 的直方图、均值和方差；
+ #em[实现图像增强算法]：根据教材提供的方案，完成选择性局部图像增强功能；
+ #em[探究参数选择方法]：通过实验分析增强关键参数对图像质量的影响规律，寻找合适的参数．

== 实验准备

压缩包中提供了源代码和编译后的单个网页文件，后者可以直接运行在浏览器中．

=== 使用编译后的代码
])



用浏览器打开压缩包中提供的 `第一次实验.html` 即可．打开后界面如@ui 所示．

#figure(caption: "UI 使用示例")[
  #image("images/ui.png")
]<ui>

=== 开发环境配置

源代码需要编译后运行．如果需要修改源码，需要安装 #link("https://nodejs.org/")[Node.js] 并使用 npm 安装依赖，命令如下．

```sh
npm i -g pnpm
pnpm i
pnpm dev
```

然后，按照终端输出提示，打开 http://localhost:8080．

=== 开发环境介绍

为了方便查看效果，我采用了 Web 相关技术进行开发，编译后可以运行在任意操作系统的浏览器环境中．可以方便地选择本地的任意图片（受浏览器限制，仅限 `png` 和 `jpg` 格式），并且可以通过 UI 调整各个参数并实时查看结果．

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

=== 显示直方图

为显示直方图，我采用了#link("https://echarts.apache.org/zh/index.html")[Apache ECharts]，是最初由百度开发的一个基于 JavaScript 的开源可视化图表库．我们只需传入 $x$ 轴（0 ～ 255的一个递增数组）和 $y$ 轴（```ts data``` 或 ```ts normalizedDate```）两部分数据，后者需要设置 ```ts type: "bar"``` 指定为直方图．点击右上角的下载图标可以保存图片到本地．

#figure(caption: "直方图")[
  #image("images/直方图.png", width: 91%)
]

将所有灰度的分量除以 $M times N$，即可得到如@normalized 所示的归一化的直方图：

#figure(caption: [规一化的直方图])[
  #image("images/规一化的直方图.png", width: 88%)
]<normalized>

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

== 选择性局部图像增强

=== 计算局部直方图

计算局部直方图的算法与全局直方图类似，只是对于只是对于每个像素，都需取邻域（一个子图像）进行计算．我们可以像@sub 这样设置，来查看一个 $5 times 5$ 子图像的直方图．

#figure(caption: "查看子图像的直方图", image("images/5x5.png"))<sub>

要计算一个局部直方图，为了性能考虑，我们不应复制一份子图像出来，而是根据坐标遍历局部．先封装一个计算给定的子图像的直方图的函数．我们在函数输入中用 $x$ 和 $y$ 表示子图像的左上角坐标（包含），$x_"end"$ 和 $y_"end"$ 表示右下角坐标（包含）．

#bc(filename: "src/histogram.ts")[
  ```ts
/**
 * 计算图像的局部直方图
 * @param imgData 单通道图像数据
 * @param x 邻域左上角 x 坐标
 * @param y 邻域左上角 y 坐标
 * @param x_end 邻域右下角 x 坐标
 * @param y_end 邻域右下角 y 坐标
 * @returns 邻域内的直方图，长度为 256
 */
function localHistogram(
  imgData: SingleChannelImageData,
  x: number,
  y: number,
  x_end: number,
  y_end: number
): number[] {
  const hist = new Uint8Array(256).fill(0);
  
  // 如果超出图像边界，将其限制在图像边界内
  const y_start = Math.max(y, 0); 
  y_end = Math.min(y_end, imgData.height - 1); 
  const x_start = Math.max(x, 0);
  x_end = Math.min(x_end, imgData.width - 1);

  /** 局部区域面积，在边界处会小于邻域面积 */
  const area = (y_end - y_start + 1) * (x_end - x_start + 1);

  for (let j = y_start; j <= y_end; j++) {
    const base = j * imgData.width;
    for (let i = x_start; i <= x_end; i++) {
      // 由于图像数据是一维数组，我们需要将二维坐标转换为一维坐标
      const idx = base + i;
      // 取灰度值作为索引
      const gray = imgData.data[idx];
      hist[gray]++;
    }
  }
  // 将 Uint8Array 转换为浮点数数组再对每个值除以面积，否则精度会丢失
  return Array.from(hist).map((x) => x / area);
}
  ```
]

书中并没有提到在边界处对邻域的处理．原先的计算方法是将未归一化的直方图除以邻域的大小的平方，但这样实质上相当于在图像的行和列的首末填充0值，导致边界处出现全黑边框．

#bc(filename: "src/histogram.ts", type: "wrong")[
  ```ts
const area = neighborhood * neighborhood;
```
]

正确的计算方法是计算邻域的面积，即 $(y_"end" - y_"start" + 1) times (x_"end" - x_"start" + 1)$，其中 $x, y, x_"end", y_"end"$ 都应限制在图像边界内．

/*
#figure(caption: [错误（左）和正确（右）的计算方法结果])[
  #stack(
    dir: ltr, spacing: 2mm,
    image("images/Fig0327(a)(tungsten_original).png-E 4-K0 0.37-K1 0.02-K2 0.4 N7.png", width: 12em),
    image("images/correct-neighbor.png", width: 12em),
  )
  ]
]
*/

=== 计算局部均值和方差

计算局部直方图的目的是计算局部均值和方差．

对于给定图像中任意像素的坐标，$S_(x y)$ 表示规定大小的以 $(x," "y)$ 为中心的邻域（子图像），记 $p_S_(x y)$ 为区域 $S_(x y)$ 中像素的规一化直方图，$r_i$ 为灰度，规定的邻域的边长为 $l$，则对于 $x=l,#h(.5em)l+1,#h(.5em)l+2,#h(.25em)dots.c,M-l-2,#h(.5em)M-l-1,quad y=l,#h(.5em)l+1,#h(.5em)l+2,#h(.25em)dots.c,N-l-2,#h(.5em)N-l-1$，像素的均值和方差分别如@mS 和@mSigma 所示．

$ m_S_(x y) = sum^(L-1)_(i=0) r_i p_S_(x y) (r_i) $<mS>

$ sigma_S_(x y) = sum^(L-1)_(i=0) (r_i - m_S_(x y))^2 p_S_(x y)(r_i) $<mSigma>



我们将每个像素邻域的均值和方差分别储存在两个数组中返回．

#bc(filename: "src/histogram.ts")[
```ts
function calcLocal(imgData: SingleChannelImageData, neighborhood: number) {
  if (neighborhood % 2 === 0) throw new Error("邻域必须为奇数");
  /** 邻域半径，例如 3x3 邻域半径为 1 */
  const half = Math.floor(neighborhood / 2);
  /** 存储每个像素根据邻域计算的均值 */
  console.log(imgData.length);
  const ms = new Array(imgData.length).fill(0);
  /** 存储每个像素根据邻域计算的标准差 */
  const sigmas = new Array(imgData.length).fill(0);
  for (let j = 0; j < imgData.height; j++) {
    for (let i = 0; i < imgData.width; i++) {
      /** p 是邻域 $S_(x y)$ 的未规一化直方图，需要除以面积得到规一化直方图 */
      const p = localHistogram(imgData, i - half, j - half, i + half, j + half);
      let m = 0;
      let sigma2 = 0;
      for (let r = 0; r < 256; r++) {
        m += r * p[r];
      }
      for (let r = 0; r < 256; r++) {
        sigma2 += Math.pow(r - m, 2) * p[r];
      }
      const idx = j * imgData.width + i;
      ms[idx] = m;
      sigmas[idx] = Math.sqrt(sigma2);
    }
  }
  return { ms, sigmas };
}
```
  ]

=== 逐像素处理

我们在之前计算了全局的均值 $m_G$ 和标准差 $sigma_G$，以及每个像素邻域的局部均值 $m_S$ 和标准差 $sigma_S$．这些统计特征将用于判断每个像素是否满足选择性增强的条件．接下来，我们遍历图像的每个像素．

$
g(x,y) = cases(
 E dot.c f(x","y)","quad &m_S_(x y) <= k_0 m_G " 且 " k_1 sigma_G <= sigma_S_(x y) <= k_2 sigma_G,
 f(x,y)"," quad &"其他"
)
$<enhance>



根据@enhance，对于每个像素，我们判断其局部均值 $m_S$ 和局部标准差 $sigma_S$ 是否满足以下条件：

- $m_S <= k_0 m_G$，即局部均值小于等于全局均值的 $k_0$ 倍；
- $k_1 sigma_G <= sigma_S <= k_2 sigma_G$，即局部标准差在全局标准差的 $k_1$ 倍和 $k_2$ 倍之间．

其中，$k_0$、$k_1$ 和 $k_2$ 是预设的常数，用于控制选择性增强的范围．

如果某个像素满足上述两个条件，我们就对其进行增强处理，将该像素的灰度值 $f(x,y)$ 乘以一个增强因子 $E$，即 $g(x,y) = E dot f(x,y)$，以提高满足条件的像素的对比度；如果像素不满足条件，我们就保持其灰度值不变，即 $g(x,y) = f(x,y)$．

我们还需要确保增强后的像素值仍然在 $0～255$ 的范围内．如果计算得到的像素值小于 0，我们将其设为 0；如果大于 255，我们将其设为 255．最后，将处理后的像素值存储到新的图像数据中，并将其转换为 RGBA 格式，绘制到 canvas 上显示．

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
      if (px < 0)
        px = 0;
      else if (px > 255)
        px = 255; // 确保像素值在 0~255 内
      enhanced[idx] = px; // 更新增强后的像素值
    }
  }
  ... // 转换为 RGBA 图像数据并绘制到 canvas 上的代码省略
}
```]

通过这样的逐像素处理，我们实现了选择性局部图像增强．满足条件的像素得到增强，其他像素保持不变，从而提高了图像的整体质量．

== 增强关键参数选择

#set image(width: 25%)
#set stack(spacing: 2mm)
#let optimal = image("images/Fig0327(a)(tungsten_original).png-E 4-K0 0.4-K1 0.02-K2 0.4.png")


/ $E$ 参数: 增大 $E$ 会增强图像整体对比度，但可能导致细节丢失和噪声放大，如@E 所示．
  - $E=3$ 时，暗区域的对比度偏小；
  - $E=5$ 时，我们可以明显看出黑色和白色的噪点；
  - 增强效果最好的是 $E=4$．

/ $K_0$ 参数: 控制了图像增强的整体阈值，如@K0 所示．
  - $k_0 = 0.16$ 时，图像对比度略有提升，但整体效果不明显；
  - $k_0 = 0.3$ 时，图像对比度进一步增强，但背景细节有部分失真；
  - $k_0 = 0.4$ 时，图像对比度显著提高，失真较少．
  - $k_0 = 0.5$ 时，图像对比度并未进一步增强，并且明亮区域的钨丝上出现了全白像素，过饱和导致出现了细节丢失的现象．

#figure(
  placement: bottom,
  stack(
    dir: ltr,       // left-to-right
    image("images/Fig0327(a)(tungsten_original).png-E 3-K0 0.4-K1 0.02-K2 0.4.png"),
    optimal,
    image("images/Fig0327(a)(tungsten_original).png-E 5-K0 0.4-K1 0.02-K2 0.4.png"),
  ),
  caption: [从左至右 $E = 3$，$E = 4$，$E = 5$ 时的增强效果]
)<E>
// / $K_0, K_1, K_2$: 调整阈值参数可以控制增强区域的选择性，从而突出特定特征．

#figure(
  caption: [从左至右 $K_0=0.16$，$K_0 = 0.3$，$K_0 = 0.4$，$K_0 = 0.5$ 时的增强效果],
  placement: bottom,
  stack(
    dir: ltr,
    image("images/k0=.16.png"),
    image("images/k0=.3.png"),
    optimal,
    image("images/k0=.5.png")
  )
)<K0>

#figure(
  caption: [从左至右 $K_1=0.008$，$K_1 = 0.020$，$K_1 = 0.048$ 时的增强效果],
  placement: bottom,
  stack(
    dir: ltr,
    image("images/Fig0327(a)(tungsten_original).png-E 4-K0 0.4-K1 0.008-K2 0.4.png"),
    optimal,
    image("images/Fig0327(a)(tungsten_original).png-E 4-K0 0.4-K1 0.048-K2 0.4.png"),
  )
)<K1>

/ $K_1$ 参数: 控制了图像的对比度，如@K1 所示．
  1. $K_1 = 0.008$ 是三张中增强最少的，纹理和细节较不明显，图像比其他两幅更平滑、细节较少；
  2. $K_1 = 0.020$ 时，与 $K_1 = 0.008$ 相比，清晰度和对比度有明显提高，钨丝的层次更加分明，表面特征也更清楚；
  3. $K_1 = 0.048$ 时，虽然支架上的白色噪点消失了，但暗处的细节出现了失真．

/ $K_2$ 参数: 控制了细节的提升幅度，如@K2 所示．
  - $K_2 = 0.05$ 及 $K_2 = 0.1$ 时，增强效果较弱，图像暗处细节提升有限，背景细节大幅度失真；
  - $K_2 = 0.2$ 时，增强效果显著；
  - $K_2 = 0.4$ 时，锐利边缘处出现伪影，而暗处细节并未进一步提升．

#figure(
  placement: top,
  stack(
      dir: ltr,       // left-to-right
      spacing: 2mm,   // space between contents
     image("images/Fig0327(a)(tungsten_original).png-E 4-K0 0.4-K1 0.02-K2 0.4.png", width: 25%),
     image("images/Fig0327(a)(tungsten_original).png-E 4-K0 0.4-K1 0.02-K2 0.2.png", width: 25%),
     image("images/Fig0327(a)(tungsten_original).png-E 4-K0 0.4-K1 0.02-K2 0.1.png", width: 25%),
     image("images/Fig0327(a)(tungsten_original).png-E 4-K0 0.4-K1 0.02-K2 0.05.png", width: 25%),
  ),
  caption: [从左至右 $K_2 = 0.4$，$K_2 = 0.2$，$K_2 = 0.1$，$K_2 = 0.05$ 时的增强效果]
)<K2>

/ $S_(x y)$ 参数: 增大局部区域大小可以平滑图像，但可能导致边缘模糊，并且在对比度较大的边缘处出现伪影，如@S 所示．

#figure(
    stack(
        dir: ltr,       // left-to-right
        spacing: 2mm,   // space between contents
       image("images/Fig0327(a)(tungsten_original).png-E 4-K0 0.37-K1 0.02-K2 0.4 N3.png"),
       image("images/Fig0327(a)(tungsten_original).png-E 4-K0 0.37-K1 0.02-K2 0.4 N5.png"),
       image("images/Fig0327(a)(tungsten_original).png-E 4-K0 0.37-K1 0.02-K2 0.4 N7.png", width: 25%),
    ),
    caption: [从左至右邻域大小为 $3$，$5$，$7$ px 时的增强效果]
)<S>
