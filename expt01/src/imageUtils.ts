/**
 * 将 ImageData 转换为单通道图像数据，假定输入图像为灰度图像
 * @param imgData 输入图像数据，包含一个一维的 Uint8ClampedArray。canvas 中图像编码仅支持 RGBA，方式为 [R G B A R G B A ...]，每个像素占 4 个字节。透明度通道 A 为 255，灰度图像的 R G B 通道值相等。
 */
export function toSingleChannel(imgData: ImageData): SingleChannelImageData {
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

/**
 * 将单通道图像数据转换为 ImageData
 */
export function toRGBA(imageData: SingleChannelImageData): ImageData {
  const rgba = new Uint8ClampedArray(imageData.length * 4);
  for (let i = 0; i < imageData.length; i++) {
    // rgba.set([imageData.data[i], imageData.data[i], imageData.data[i], 255], i * 4);
    rgba[i * 4] = imageData.data[i];
    rgba[i * 4 + 1] = imageData.data[i];
    rgba[i * 4 + 2] = imageData.data[i];
    rgba[i * 4 + 3] = 255;
  }
  return new ImageData(rgba, imageData.width, imageData.height);
}
