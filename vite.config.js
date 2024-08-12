import { defineConfig } from 'vite'
import RubyPlugin from 'vite-plugin-ruby'
import FullReload from "vite-plugin-full-reload"
import inject from "@rollup/plugin-inject"

export default defineConfig({
  plugins: [
    inject({
      $: 'jquery',
      jQuery: 'jquery',
    }),
    RubyPlugin(),
    FullReload(["config/routes.rb", "app/views/**/*"], { delay: 100 }),
  ],
})
