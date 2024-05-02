<script>
  import { Chart } from "svelte-echarts";
  import Katex from "svelte-katex";
  export let data = [];
  export let normalize = true;
  let xAxisData = [];
  let options;
  export let width, height;
  $: data,
    (xAxisData = data.map((_, i) => i)),
    console.log({ xAxisData, data, normalizedData });
  let normalizedData = [];
  $: normalizedData = normalize ? data.map((n) => n / (width * height)) : data;
  $: options = {
    title: {
      text: "直方图",
    },
    legend: {
      data: ["灰度"],
    },
    toolbox: {
      feature: {
        magicType: {
          type: ["stack"],
        },
        dataView: {},
        saveAsImage: {
          pixelRatio: 3,
        },
      },
    },
    tooltip: {},
    xAxis: {
      data: xAxisData,
      splitLine: {
        show: false,
      },
    },
    yAxis: {},
    series: [
      {
        name: "灰度",
        type: "bar",
        data: normalizedData,
        emphasis: {
          focus: "series",
        },
      },
    ],
  };
</script>

<div class="app">
  <div id="normalize">
    <label>
      <input type="checkbox" bind:checked={normalize} />
      归一化（<Katex
        >{normalize ? `p_r(k) = \\dfrac{n_k}{M N}` : `p_r'(k) = n_k`}</Katex
      >）
    </label>
  </div>
  <Chart {options} />
</div>

<style>
  .app {
    width: 890px;
    height: 500px;
  }

  #normalize {
    min-height: 55px;
  }
</style>
