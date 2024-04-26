<script>
  import { Chart } from "svelte-echarts";
  import Katex from 'svelte-katex'
  //   let xAxisData = [];
  //   let data1 = [];
  //   let data2 = [];
  //   for (let i = 0; i < 255; i++) {
  //     xAxisData.push(i);
  //     let num = (Math.sin(i / 5) * (i / 5 - 10) + i / 6) * 5 + 50;
  //     data1.push(num.toFixed(0));
  //     num = (Math.cos(i / 5) * (i / 5 - 10) + i / 6) * 5 + 50;
  //     data2.push(num.toFixed(0));
  //   }

  export let data = [];
  export let normalize = true;
  let xAxisData;
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
      // y: 'bottom',
      feature: {
        magicType: {
          type: ["stack"],
        },
        dataView: {},
        saveAsImage: {
          pixelRatio: 2,
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
        // animationDelay: function (idx) {
        //   return 10;
        // },
      },
      // {
      //   name: 'bar2',
      //   type: 'bar',
      //   data: data2,
      //   emphasis: {
      //     focus: 'series'
      //   },
      //   animationDelay: function (idx) {
      //     return idx * 10 + 100;
      //   }
      // }
    ],
    // animationEasing: "elasticOut",
    // animationDelayUpdate: function (idx) {
    //   return idx * 5;
    // },
  };
</script>

<div class="app">
  <div id="normalize">
    <label>
      <input type="checkbox" bind:checked={normalize} />
      归一化（<Katex>{
        normalize ? `p_r(k) = \\dfrac{n_k}{M N}` : `p_r'(k) = n_k`
      }</Katex>）
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
