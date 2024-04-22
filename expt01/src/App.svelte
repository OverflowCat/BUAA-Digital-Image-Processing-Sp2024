<script>
  import Katex from "svelte-katex";
  import Hist from "./Hist.svelte";
  let files;
  let canvas;
  let x = 0;
  let y = 0;
  let m = 0;
  let sigma2 = 0;
  let width = 100;
  let height = 100;
  let histData = [];
  $: ctx = canvas?.getContext("2d");
  $: disabled = !files || files.length === 0;
  const throttledShowHist = throttle(showHist, 300);
  $: x,
    y,
    width,
    height,
    throttledDrawBox(x, y, width, height),
    histData && histData.length > 0 && throttledShowHist();
  async function onFileChange() {
    await drawImg();
    x = 0;
    y = 0;
    width = canvas.width / 2;
    height = canvas.height / 2;
  }
  function histogram(imgData) {
    const hist = new Array(256).fill(0);
    for (let i = 0; i < imgData.data.length; i += 4) {
      // 灰度图像 r == g == b，alpha == 255，取 r 通道
      const gray = imgData.data[i];
      hist[gray]++;
    }
    return hist;
  }

  function throttle(fn, delay) {
    let last = 0;
    return function (...args) {
      const now = new Date().getTime();
      if (now - last < delay) {
        return;
      }
      last = now;
      return fn(...args);
    };
  }

  async function drawImg() {
    if (files) {
      const reader = new FileReader();

      const readAsDataURL = (file) =>
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

  async function drawBox(x, y, width, height) {
    if (!ctx) return;
    await drawImg();
    ctx.strokeStyle = "red";
    ctx.lineWidth = 2;
    ctx.strokeRect(x, y, width, height);
  }

  const throttledDrawBox = throttle(drawBox, 200);

  function calculateMean(imgData) {
    let sum = 0;
    for (let i = 0; i < imgData.data.length; i += 4) {
      sum += imgData.data[i];
    }
    return sum / (imgData.data.length / 4);
  }

  function calculateSigma2(imgData, m) {
    let sum = 0;
    for (let i = 0; i < imgData.data.length; i += 4) {
      sum += Math.pow(imgData.data[i] - m, 2);
    }
    return sum / (imgData.data.length / 4);
  }

  async function showHist() {
    await drawImg();
    const imgData = ctx.getImageData(x, y, width, height);
    m = calculateMean(imgData);
    sigma2 = calculateSigma2(imgData, m);
    histData = histogram(imgData);
    drawBox(x, y, width, height);
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
      <label>x <input type="number" id="x" bind:value={x} /></label>
      <label>y <input type="number" id="y" bind:value={y} /></label>
      <div>
        <label
          >宽度 <input type="number" id="width" bind:value={width} />
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
          >高度 <input type="number" id="height" bind:value={height} />
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
  <div>
    {#if histData && histData.length > 0}
      <h2>直方图</h2>
      <Hist data={histData} {width} {height}></Hist>
      <h2>均值</h2>
      <Katex displayMode
        >{`m = \\dfrac{1}{${width} \\times ${height}} \\sum^{${width - 1}}_{x=0} \\sum^{${height - 1}}_{y=0} f(x, y)
      \\ \\approx ${Math.round(m)}
      `}</Katex
      >
      <h2>方差</h2>
      <Katex displayMode
        >{`\\sigma^2 = \\dfrac{1}{${width} \\times ${height}} \\sum^{${width - 1}}_{x=0} \\sum^{${height - 1}}_{y=0} (f(x, y) - m)^2
      \\ \\approx ${Math.round(sigma2)}
      `}</Katex
      >
    {/if}
  </div>
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
    font-weight: 100;
  }

  @media (min-width: 640px) {
    main {
      max-width: none;
    }
  }
</style>
