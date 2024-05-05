= 数字图像处理 第一次实验报告

== 全局直方图

=== 直方图计算

```ts
function histogram(imgData: SingleChannelImageData): number[] {
  // 初始化一个长度为 256 的全 0 数组
  let h = new Array(256).fill(0);
  
  for (let i = 0; i < imgData.data.length; i++) {
    const gray = imgData.data[i];
    h[gray]++;
  }
  return h; 
}
```

=== 直方图绘制

ECharts 是百度的可视化图表库。依据文档传入 $x$ 轴和 $y$ 轴数据的数组即可。此处生成一个 0 $0 ～ 255$ 的数组作为 $x$ 轴，直方图的值作为 $y$ 轴。

计算全局均值

```ts
function calculateMean(imgData: SingleChannelImageData) {
  let sum = 0;
  for (let i = 0; i < imgData.length; i++) {
    sum += imgData.data[i];
  }
  return sum / imgData.length;
}
```

计算全局方差

```ts
function calculateSigma2(imgData: SingleChannelImageData, m: number) {
  let sum = 0;
  for (let i = 0; i < imgData.length; i++) {
    sum += Math.pow(imgData.data[i] - m, 2);
  }
  return sum / imgData.length;
}
```

== 图像增强

=== 计算局部直方图

对于给定图像中任意像素的坐标，$S_(x y)$ 表示规定大小的以 $(x," "y)$ 为中心的邻域（子图像），记 $p_S_(x y)$ 为区域 $S_(x y)$ 中像素的规一化直方图，$r_i$ 为灰度，则该邻域中像素的均值

$ m_S_(x y) = sum^(L-1)_(i=0) r_i p_S_(x y) (r_i) $

$ sigma_S_(x y) = sum^(L-1)_(i=0) (sigma_S_(x y)-m)^2 p_S_(x y) $


在算法实现上，我们可以预先计算每一个像素的均值和方差，然后在计算局部直方图时，直接使用这两个值，而不是每次都重新计算。


对于 $x=0,1,2,dots.c,M-1,quad y=0,1,2,dots.c,N-1$，有

=== 亮度及对比度增强

$
g(x,y) = cases(
 E dot.c f(x","y)","quad &m_S_(x y) <= k_0 m_G "且 " k_1 sigma_G <= sigma_S_(x y) <= k_2 sigma_G",",
 f(x,y)"," quad &"其他，"
)
$


调整输入框内数字，可以即时观察到图像的变化。

对于 $E, k_0, k_1, k_2$ 参数选择，

发现 $E = 5.0, k_0 = $

== 

#let typst = {
  text(font: "Linux Libertine", weight: "semibold", fill: eastern)[typst]
}

#let latex = {
    set text(font: "New Computer Modern")
    box(width: 2.55em, {
      [L]
      place(top, dx: 0.3em, text(size: 0.7em)[A])
      place(top, dx: 0.7em)[T]
      place(top, dx: 1.26em, dy: 0.22em)[E]
      place(top, dx: 1.8em)[X]
    })
}

// #show "Typst": typst
// #show "LaTeX": latex

#typst is a great alternative to #latex

提供了 html 可以直接在浏览器中打开并使用。 需要网络以加载 $latex$ 字体。

```sh
npm i -g pnpm
pnpm i
pnpm dev
```