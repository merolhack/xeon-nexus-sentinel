import type { Config } from "tailwindcss";

const config: Config = {
  content: [
    "./src/pages/**/*.{js,ts,jsx,tsx,mdx}",
    "./src/components/**/*.{js,ts,jsx,tsx,mdx}",
    "./src/app/**/*.{js,ts,jsx,tsx,mdx}",
  ],
  theme: {
    extend: {
      colors: {
        darkbg: "#0b0f19",
        cardbg: "#111827",
        bordercolor: "#1f2937",
        accent: "#3b82f6",
        neoncyan: "#06b6d4",
        neongreen: "#10b981",
        neonorange: "#f59e0b",
      },
    },
  },
  plugins: [],
};
export default config;
