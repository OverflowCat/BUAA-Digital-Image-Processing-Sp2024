export function histogram(imgData: SingleChannelImageData): number[] {
  const hist = new Array(256).fill(0);
  for (let i = 0; i < imgData.data.length; i++) {
    const gray = imgData.data[i];
    hist[gray]++;
  }
  return hist;
}

export function calculateMean(imgData: SingleChannelImageData) {
  let sum = 0;
  for (let i = 0; i < imgData.data.length; i++) {
    sum += imgData.data[i];
  }
  return sum / imgData.data.length;
}

export function calculateSigma2(imgData: SingleChannelImageData, m: number) {
  let sum = 0;
  for (let i = 0; i < imgData.length; i++) {
    sum += Math.pow(imgData.data[i] - m, 2);
  }
  return sum / imgData.data.length;
}

export function calcLocal(
  imgData: SingleChannelImageData,
  neighborhood: number
) {
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
      let m = 0,
        sigma2 = 0;
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
  return {
    ms,
    sigmas,
  };
}

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
  const y_start = Math.max(y, 0);
  y_end = Math.min(y_end, imgData.height - 1); // 如果超出图像边界，将其限制在图像边界内
  const x_start = Math.max(x, 0);
  x_end = Math.min(x_end, imgData.width - 1); // 同上
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
