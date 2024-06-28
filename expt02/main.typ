#set text(lang: "zh", cjk-latin-spacing: auto, font: "Noto Serif CJK SC")
#set page(numbering: "1", margin: (left: 1.4cm, right: 1.9cm))
#show figure.caption: set text(font: "Zhuque Fangsong (technical preview)")
#show "。": "．"
#show heading: set text(font: "Noto Sans CJK SC", size: 1.15em)
#import "../expt01/blockcode.typ": bc
#show raw.where(block: true): bc
#show raw.where(): set text(size: 1.15em, font: "JetBrains Mono")
#let FT = $cal(F)$
#let IFT = $FT^(-1)$

= 数字图像处理 第二次实验

== 实验 1（P185例4.23）

使用陷波滤波减少莫尔（波纹）模式。@img1 是来自扫描报纸的图像，它显示了突出的莫尔模式，设计一个 Butterworth 陷波带阻滤波器消除图像中的莫尔条纹。

#figure(
  caption: "莫尔模式的取样过的报纸图像",
  image("Images/1.png"),
)<img1>

Butterworth 带阻滤波器的公式为
$ H(u, v) = 1 / (1 + (display((D(u, v)W) / (D^2(u, v) - D_0^2)))^(2 n)) $

=== 频率域滤波的基本步骤

1. 已知一幅大小为 $M times N$ 的输入图像 $f(x,y)$，取填充零后的尺寸 $P >= 2M - 1$ 和 $ >= 2N - 1$，一般 $P=2M$ 和 $Q=2N$。
2. 使用零填充、镜像填充或复制填充，形成大小为 $P times Q$ 的填充后的图像 $f_p (x,y)$。
3. 将 $f(x,y)$ 乘以 $(-1)^{x+y}$，使傅里叶变换位于 $P times Q$ 大小的频率矩形的中心。
4. 计算步骤3得到的图像的 DFT，即 $F(u,v)$。
5. 构建一个实对称滤波器传递函数 $H(u,v)$，其大小为 $P times Q$，中心在 $(P/2, Q/2)$ 处。
6. 采用对应像素相乘得到 $G(u,v) = H(u,v)F(u,v)$，即 $G(i,k) = H(i,k) F(i,k)$，$i=0,1,2,...,M-1$ 和 $k=0,1,2,...,N-1$。
7. 计算 $G(u,v)$ 的 IDFT 得到滤波后的图像（大小为 $P times Q$）
$ g_p (x,y) = { Re [IFT [G(u,v)]] }(-1)^(x+y). $
8. 最后，从 $g_p (x,y)$ 的左上象限提取一个大小为 $M times N$ 的区域，得到与输入图像大小相同的滤波后的结果 $g(x,y)$。

=== 图像预处理

在代码中，我们首先获取输入图像 `img` 的宽度 `img.width` 和高度 `img.height`，分别对应 $M$ 和 $N$。由于所用的 FFT 实现仅支持 2 的幂次大小，通过 `min2power` 函数计算出大于等于图像尺寸且最接近 2 的幂的数的2倍，作为填充后的图像尺寸 `dims[0]` 和 `dims[1]`，分别对应 $P$ 和 $Q$。

```javascript
dims[0] = min2power(img.width)[1];
dims[1] = min2power(img.height)[1];
```

代码中提供了两种填充方式：黑色填充和原图重复填充。

/ *黑色填充*: 通过设置 `ctxs[ai].fillStyle = 'black'` 并调用 `ctxs[ai].fillRect(0, 0, canvases[ai].width, canvases[ai].height)`，将四个画布 `canvases[ai]` 全部填充为黑色。
/ *原图重复填充*: 通过多次调用 `ctxs[0].drawImage`，将原图 `img` 重复绘制到画布 `canvases[0]` 上，覆盖整个画布区域。

```javascript
if (useBlack) {
    ctxs[ai].fillStyle = 'black';
    ctxs[ai].fillRect(0, 0, canvases[ai].width, canvases[ai].height);
} else {
    ctxs[0].drawImage(img, img.width, 0, img.width, img.height);
    ctxs[0].drawImage(img, 0, img.height, img.width, img.height);
    ctxs[0].drawImage(img, img.width, img.height, img.width, img.height);
}
```

=== 傅里叶变换和中心化

在实验中，我们没有使用书中的方法，而是先进行傅里叶变换，再在频域中心化。


```javascript
function FFT2D(imageData) {
  const width = imageData.width;
  const height = imageData.height;
  const data = imageData.data;

  // 1. 将图像数据转换为复数形式
  const complexData = [];
  for (let i = 0; i < data.length; i += 4) {
    complexData.push(new Complex(data[i], 0)); // 只取红色通道，其他通道类似
  }

  // 2. 对每一行进行一维 FFT
  const rowTransforms = [];
  for (let y = 0; y < height; y++) {
    const row = complexData.slice(y * width, (y + 1) * width);
    const rowTransform = [];
    FFT(row, rowTransform);
    rowTransforms.push(rowTransform);
  }

  // 3. 对每一列进行一维 FFT
  const transform = [];
  for (let x = 0; x < width; x++) {
    const col = rowTransforms.map(row => row[x]);
    const colTransform = [];
    FFT(col, colTransform);
    transform.push(...colTransform); // 展开列变换结果
  }

  // 4. 中心化频谱
  const shiftedTransform = Fourier.shift(transform, [height, width]); 

  return shiftedTransform;
}
```

1. *图像数据转换*：首先，我们将图像数据（通常是 RGBA 格式）转换为复数形式，以便进行傅里叶变换。这里为了简化，只取了红色通道，其他通道处理方式类似。

2. *逐行一维 FFT*：接着，我们对图像的每一行进行一维快速傅里叶变换（FFT）。`FFT` 函数实现了基-2 快速傅里叶变换算法，将时域信号转换为频域表示。

3. *逐列一维 FFT*：然后，对每一列进行一维 FFT。这里我们遍历每一列，将各行的对应位置的复数取出，组成一个新的数组，再对其进行 FFT。

4. *频谱中心化*：最后，我们使用 `Fourier.shift` 函数（即 `shiftFFT`）将频谱进行平移，使得零频分量位于中心。中心化后的频谱图像更易于理解和分析。原始频谱中零频分量位于左上角，平移后低低频分量位于中心，高频分量向外辐射，符合我们对频率分布的直观认知。

  ```js
function halfShiftFFT(transform, dims) {
  var ret = [];
  var N = dims[1];
  var M = dims[0];

  // 处理上半部分
  for (var n = 0, vOff = N/2; n < N; n++) {
    // 遍历每一列的上半部分
    for (var m = 0; m < M/2; m++) {
      // 计算当前元素的索引
      var idx = vOff*dims[0] + m;
      // 将变换后的结果添加到结果数组中
      ret.push(transform[idx]);
    }
    // 更新偏移量
    vOff += vOff >= N/2 ? -N/2 : (N/2)+1;
  }

  // 处理下半部分
  for (var n = 0, vOff = N/2; n < N; n++) {
    // 遍历每一列的下半部分
    for (var m = M/2; m < M; m++) {
      // 计算当前元素的索引
      var idx = vOff*dims[0] + m;
      // 将变换后的结果添加到结果数组中
      ret.push(transform[idx]);
    }
    // 更新偏移量
    vOff += vOff >= N/2 ? -N/2 : (N/2)+1;
  }

  // 返回结果数组
  return ret;
}
  ```
  
  具体实现上，`shiftFFT` 先通过 `halfShiftFFT` 函数将每行频谱左右两半交换，使零频分量移到行中。再通过 `flipRightHalf` 函数将图像右半部分翻转，使零频分量移到整个图像中心。整个过程是两次 `halfShiftFFT` 调用，中间夹杂一次 `flipRightHalf`，确保零频分量最终位于正中。

=== 施加滤波器

代码中通过 `drawCanvas1` 将频谱画在了界面上。首先遍历频域数据，找到其中的最大振幅 `maxMagnitude`，然后遍历每个像素，计算最大振幅的对数 `logOfMaxMag`，其中 `cc` 是一个用于调整对比度的常数。

因此，本实验中可通过在频谱上交互式操作施加 Butterworth 陷波带阻滤波器。鼠标悬浮在频谱上可以看到对应位置的坐标。点击对应位置可设置下方输入框中的 $(u_0, v_0)$。设置 $D_0$ 后点击“施加滤波器”按钮可以应用滤波器。此时可以看到在图像上对应位置由亮变暗。根据卷积运算的性质，可多次施加不同的滤波器。

界面和最终的滤波器公式 $H_"NR"$ 如@step2 所示。

#figure(caption: "施加1次滤波器后，正在对称位置施加第二次滤波器", image("step-2.svg", width: 73%))<step2>

每次施加滤波器，我们都创建了一个 $P times Q$ 的滤波器，为一个值都是 $0" ~ " 1$ 的双精度浮点数的二维数组，最后与图片上的每一个像素点乘。滤波器的实现如下：

```js
function mask(data, dims, u0, v0, D0=9, n=2) {
  var M = dims[0];
  var N = dims[1];
  var halfM = M / 2;
  var halfN = N / 2;
  for (var u = 0; u < M; u++) {
    for (var v = 0; v < N; v++) {
      var idx = u * N + v;
      var Dminus = Math.sqrt(Math.pow(u - halfN - u0, 2) + Math.pow(v - halfM - v0, 2))
      var Dplus = Math.sqrt(Math.pow(u - halfN + u0, 2) + Math.pow(v - halfM + v0, 2))
      var h = 1 / (1 + Math.pow(D0 / (Dminus + 1e-6), 2*n)) * 1 / (1 + Math.pow(D0 / (Dplus + 1e-6), 2*n));
      data[idx] = data[idx].times(h);
    }
  }
}
```

#figure(caption: "施加了8次陷波带阻滤波器后的频谱", image("8.png", width: 61%))<f8次>

分析频谱中亮点，最终施加了8次陷波带阻滤波器，如@f8次 所示。

其 $(u_0, v_0)$ 分别在 $(81, plus.minus 87), (minus 92, plus.minus 78), (82, plus.minus 174), (minus 92, plus.minus 165) $ 附近，呈对称分布。

=== 傅里叶反变换

#figure(caption: "最终结果", image("result-1.png"))<res1>

#let chess = figure(caption: "重复填充的频谱", image("chess-pad.png", width: 47%))

由于要展示原理，所以实验并没有做最后取坐上角图片进行裁剪。

== 实验 2（P186例4.24）

#figure(
  caption: "近似周期性干扰的土星环图像，图像大小为674×674像素",
  image("Images/2.png", width: 52%),
)<img2>

使用陷波滤波增强恶化的卡西尼土星图像。@img2 显示了部分环绕土星的土星环的图像。太空船第一次进入该行星的轨道时由“卡西尼”首次拍摄了这幅图像。垂直的正弦模式是在对图像数字化之前由叠加到摄影机视频信号上的AC信号造成的。这是一个想不到的问题，它污染了来自某些任务的图像。设计一种陷波带阻滤波器，消除干扰信号。

使用与实验 1 中相似的办法，仅如@img2-3 所示施加 4 个滤波器便可取得较好的效果。

#figure(
  caption: "处理后的频谱",
  image("2/png (3).png", width: 61%),
)<img2-3>
#figure(
  caption: "结果和 diff",
  stack(
    dir: ltr,
    spacing: 1em,
    image("2/png (4).png", width: 47%),
    image("2/png (5).png", width: 47%),
  )
)<img2-4>

== 实验总结

=== 实验 2 的其他方法

书中提到，由于干扰信号是 AC 信号，为周期的垂直噪声，因此可通过@r2 所示的一个垂直限波带阻函数隔离纵轴上的频率。填写宽度、v span 值可设置其宽度和中心区域跳过的范围。

#figure(
  caption: "垂直限波带阻函数处理后的频谱",
  image("2/r3.png", width: 61%),
)<r2>

#figure(
  caption: "结果和 diff",
  stack(
    dir: ltr,
    spacing: 1em,
    image("2/r2.png", width: 47%),
    image("2/rdiff.png", width: 47%),
  )
)<img2-4>

滤波器实现如下：

```js
function mask2(data, dims, u0=-1, w=4, vspan=20) {
  var M = dims[0];
  var N = dims[1];
  var halfM = M / 2;
  var halfN = N / 2;
  u0 += halfM;
  w = parseInt((w / 2).toString());
  for (var u = u0 - w; u <= u0 + w; u++) {
    let idxBase = u * N;
    for (var v = 0; v < halfN - vspan; v++) {
      data[idxBase + v] = new Fourier.Complex(0, 0);
    }
    for (var v = halfN + vspan; v < N; v++) {
      data[idxBase + v] = new Fourier.Complex(0, 0);
    }
  }
}
```

#stack(
  dir: ltr,
  spacing: 3%,
  box(width: 50%)[

    === 图像填充
    用零填充图像会增加其大小，但不会改变其灰度级内容，导致填充后图像的平均灰度级低于原始图像，频谱中的 $F(0,0)$ 小于原始图像中的 $F(0,0)$。图像整体对比度较低。同时，用 0 填充图像会在原始图像的边界处引入明显的间断。这个过程会引入强烈的水平和垂直边缘，图像在这些边缘处突然结束，然后继续为 0 值。频谱中，这些急剧的过渡对应于沿水平轴和垂直轴的亮的线。

    使用重复图像填充在重复次数较多时会创造出更多的规律性频率分布，效果不如零填充好。
  ], chess
)

#"\n"

== 附：实验代码使用方式

解压后，用浏览器打开 `index.html` 即可。界面如下：
