<script lang="ts">
  import { throttle } from "@martinstark/throttle-ts";
  import {
    calculateMean,
    calculateSigma2,
    localHistogram,
    histogram,
  } from "./histogram";
  import Katex from "svelte-katex";
  import Hist from "./Hist.svelte";
  import { toRGBA, toSingleChannel } from "./imageUtils";

  let files: FileList;
  let canvas: HTMLCanvasElement;
  let canvasEnhanced: HTMLCanvasElement;
  let x = 0;
  let y = 0;
  let m = 0;
  let sigma2 = 0;
  let width = 100;
  let height = 100;
  let histData = [];

  let showEnhanced = false;
  let neighborhoodSize = 3;
  /** 教材中推荐的参数 */
  let E = 4.0,
    k0 = 0.4,
    k1 = 0.02,
    k2 = 0.4;
  $: ctx = canvas?.getContext("2d");
  $: disabled = !files || files.length === 0;
  $: x,
    y,
    width,
    height,
    throttledDrawBox(x, y, width, height),
    histData && histData.length > 0 && throttledShowHist();
  $: showEnhanced = canvasEnhanced?.width && neighborhoodSize % 2 === 1;
  $: neighborhoodSize,
    E,
    k0,
    k1,
    k2,
    files,
    x,
    y,
    width,
    height,
    showEnhanced &&
      throttledEnhanceImage(getSingleChannelData(), neighborhoodSize);

  async function onFileChange() {
    await drawImg();
    x = 0;
    y = 0;
    width = canvas.width / 2;
    height = canvas.height / 2;
  }

  async function drawImg() {
    if (files) {
      const reader = new FileReader();
      const readAsDataURL = (file: File) =>
        new Promise((resolve, reject) => {
          reader.onload = resolve;
          reader.onerror = reject;
          reader.readAsDataURL(file);
        });

      try {
        await readAsDataURL(files[0]);
        const img = new Image();

        await new Promise((resolve, reject) => {
          img.onload = resolve;
          img.onerror = reject;
          // @ts-ignore
          img.src = reader.result;
        });

        canvas.width = img.width;
        canvas.height = img.height;
        ctx.drawImage(img, 0, 0);
      } catch (error) {
        console.error("Error loading image", error);
      }
    }
  }

  async function drawBox(x: number, y: number, width: number, height: number) {
    if (!ctx) return;
    await drawImg();
    ctx.strokeStyle = "red";
    ctx.lineWidth = 2;
    ctx.strokeRect(x, y, width, height);
  }

  async function showHist() {
    await drawImg();
    const imgData = toSingleChannel(ctx.getImageData(x, y, width, height));
    m = calculateMean(imgData);
    sigma2 = calculateSigma2(imgData, m);
    histData = histogram(imgData);
    drawBox(x, y, width, height);
  }

  function enhanceImage(
    origImage: SingleChannelImageData,
    neighborhood: number
  ) {
    /** 全局均值 */
    const m_G = calculateMean(origImage);
    /** 全局标准差 */
    const sigma_G = Math.sqrt(calculateSigma2(origImage, m));

    /** 局部均值和方差 */
    const { ms, sigmas } = localHistogram(origImage, neighborhood);

    const enhanced = new Uint8ClampedArray(origImage.data); // 复制原图像数据
    const k0mg = k0 * m_G;
    const k1sigmaG = k1 * sigma_G;
    const k2sigmaG = k2 * sigma_G;
    for (let idx = 0; idx < origImage.length; idx++) {
      const m_S = ms[idx];
      const sigma_S = sigmas[idx];
      if (
        m_S <= k0 * m_G &&
        k1 * sigma_G <= sigma_S &&
        sigma_S <= k2 * sigma_G
      ) {
        let px = Math.round(E * origImage.data[idx]);
        if (px < 0) {
          // console.error("px out of range", px);
          px = 0;
        } else if (px > 255) {
          // console.error("px out of range", px);
          px = 255;
        }
        enhanced[idx] = px; // 更新增强后的像素值
      }
    }
    const enhancedImageData = toRGBA({
      data: enhanced,
      width: origImage.width,
      height: origImage.height,
      length: enhanced.length,
    });
    canvasEnhanced.width = origImage.width;
    canvasEnhanced.height = origImage.height;
    const ctx = canvasEnhanced.getContext("2d");
    ctx.putImageData(enhancedImageData, 0, 0);
  }

  function getSingleChannelData() {
    return toSingleChannel(ctx.getImageData(x, y, width, height));
  }

  const [throttledDrawBox] = throttle(drawBox, 200);
  const [throttledShowHist] = throttle(showHist, 300);
  const [throttledEnhanceImage] = throttle(enhanceImage, 400);

  function downloadEnhanced(_: any) {
    // Ensure the canvas is not empty
    if (!canvasEnhanced) return;

    // Create a data URL for the canvas
    const imageUrl = canvasEnhanced.toDataURL("image/png");

    // Create a temporary link element
    const link = document.createElement("a");
    link.download = `${files[0].name}-E ${E}-K0 ${k0}-K1 ${k1}-K2 ${k2}.png`;
    link.href = imageUrl;
    link.click(); // Trigger the download
  }
</script>

<main>
  <div>
    <h1>第一次实验</h1>
    <p>
      请选择图片
      <input
        type="file"
        id="file"
        accept="image/*"
        bind:files
        on:change={onFileChange}
      />
    </p>
    <div class="form">
      直方图统计
      <label
        >x <input
          type="number"
          id="x"
          bind:value={x}
          max={canvas?.width - 1}
          min="0"
        /></label
      >
      <label
        >y <input
          type="number"
          id="y"
          bind:value={y}
          max={canvas?.height - 1}
          min="0"
        /></label
      >
      <div>
        <label
          >宽度 <input
            type="number"
            id="width"
            bind:value={width}
            max={canvas?.width - x}
            min="1"
          />
          <button
            {disabled}
            on:click={() => {
              width = canvas.width - x;
            }}
          >
            设置为图片宽度
          </button></label
        >
      </div>
      <div>
        <label
          >高度 <input
            type="number"
            id="height"
            bind:value={height}
            max={canvas?.height - y}
            min="1"
          />
          <button
            {disabled}
            on:click={() => {
              height = canvas.height - y;
            }}
          >
            设置为图片高度
          </button></label
        >
      </div>
      <button on:click={showHist} class="final" {disabled}>显示直方图</button>
    </div>
    <canvas id="img" bind:this={canvas}></canvas>
  </div>
  {#if histData && histData.length > 0}
    <div>
      <h2>直方图</h2>
      <Hist data={histData} {width} {height}></Hist>
      <h2>全局均值</h2>
      <Katex displayMode
        >{`m_\\text G = \\dfrac{1}{${width} \\times ${height}} \\sum^{${width - 1}}_{x=0} \\sum^{${height - 1}}_{y=0} f(x, y)
      \\ \\approx ${Math.round(m)}
      `}</Katex
      >
      <h2>全局方差</h2>
      <Katex displayMode
        >{`\\sigma^2_\\text G = \\dfrac{1}{${width} \\times ${height}} \\sum^{${width - 1}}_{x=0} \\sum^{${height - 1}}_{y=0} (f(x, y) - m)^2
      \\ \\approx ${Math.round(sigma2)}
      `}</Katex
      >
    </div>
    <div id="enhance">
      <h2>增强图像</h2>
      <div>
        <label>
          邻域大小 <input
            type="number"
            bind:value={neighborhoodSize}
            step="2"
            min="1"
            max="45"
          />
          ×
          <input type="number" bind:value={neighborhoodSize} />
        </label>
        <label>
          <Katex>E</Katex> <input type="number" bind:value={E} step={0.1} />
        </label>
        <label>
          <Katex>k_0</Katex>
          <input type="number" bind:value={k0} min={0} max={1} step={0.02} />
        </label>
        <label>
          <Katex>k_1</Katex>
          <input type="number" bind:value={k1} step={0.002} />
        </label>
        <label>
          <Katex>k_2</Katex> <input type="number" bind:value={k2} step={0.02} />
        </label>
        <button
          on:click={() => {
            enhanceImage(getSingleChannelData(), neighborhoodSize);
          }}>增强图像</button
        >
      </div>
      <canvas bind:this={canvasEnhanced} width="0" height="0"></canvas>
      <div class="download">
        {#if canvasEnhanced?.width}
          <button on:click={downloadEnhanced}> 下载 PNG 图片 </button>
        {/if}
      </div>
    </div>
  {/if}
</main>

<style>
  .final {
    font-weight: 600;
  }
  input {
    font-family: monospace;
  }
  button {
    user-select: none;
  }
  main {
    text-align: center;
    padding: 1em;
    margin: 0 auto;
    display: flex;
  }

  h1 {
    color: #ff3e00;
    text-transform: uppercase;
    font-size: 4em;
    font-weight: 700;
  }

  input[type="number"] {
    width: 9ch;
  }

  #enhance {
    min-width: 300px;
  }
  @media (min-width: 640px) {
    main {
      max-width: none;
    }
  }
</style>
