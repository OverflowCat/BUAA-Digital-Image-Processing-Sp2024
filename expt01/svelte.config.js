import sveltePreprocess from "svelte-preprocess";
import adapter from "@sveltejs/adapter-static";

export default {
  preprocess: sveltePreprocess(),
  kit: {
    adapter: adapter({
      fallback: "200.html", // may differ from host to host
    }),
  },
  basePath: "/expt01",
};
