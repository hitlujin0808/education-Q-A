/**
 * vue.config.js
 * ----------------------------------------
 * 本文件用于配置 Vue CLI 项目的开发服务器、代理、构建输出目录等。
 * 适用于本项目前端目录（frontend/），实现本地开发时跨域转发API请求到 Flask 后端。
 * 
 * 主要配置项说明：
 * - devServer.proxy: 配置 API 代理，将 /api/ 路径的请求转发到 Flask RAG API（假设运行在 http://localhost:5005）
 * - outputDir: 构建输出目录，默认 'dist'
 * - publicPath: 部署应用包时的基础路径
 */

const path = require('path');

module.exports = {
  // 构建输出目录，可根据需要调整
  outputDir: path.resolve(__dirname, './dist'),
  publicPath: './',

  devServer: {
    host: '0.0.0.0',
    port: 8080, // 前端开发服务器端口
    open: true, // 启动后自动打开浏览器
    proxy: {
      // 将前端的 /api 请求代理到 Flask 后端
      '/api': {
        target: 'http://localhost:5005', // Flask API 服务地址
        changeOrigin: true,
        ws: false,
        pathRewrite: {
          '^/api': '/api',
        },
      },
      // 可选：如有其他接口（如 /retrieve），也可以代理
      '/retrieve': {
        target: 'http://localhost:5005',
        changeOrigin: true,
        ws: false,
      },
    },
    // 允许前端本地开发页面刷新时路由可用
    historyApiFallback: true,
  },

  // 可选：配置别名
  configureWebpack: {
    resolve: {
      alias: {
        '@': path.resolve(__dirname, 'src'),
      },
    },
  },
};