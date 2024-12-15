---
title: deno vite tailwind
date: 2024-11-28
private: true
---
# deno vite tailwind
> https://stackoverflow.com/questions/74497327/how-to-configure-tailwindcss-with-a-deno-vite-project

    eno run --allow-read --allow-write --allow-env npm:create-vite-extra@latest

    deno add npm:tailwindcss npm:postcss npm:autoprefixer

postcss.config.js

    import tailwindcss from "tailwindcss";
    import autoprefixer from "autoprefixer";

    export default {
        plugins: [tailwindcss, autoprefixer],
    };

tailwind.config.js

    /** @type {import('tailwindcss').Config} */
    export default {
        content: ["./index.html", "./src/**/*.{js,ts,jsx,tsx}"],
        theme: {
            extend: {},
        },
        plugins: [],
    };

src/style.css

    @tailwind base;
    @tailwind components;
    @tailwind utilities;


最后执行:　`deno task dev`
