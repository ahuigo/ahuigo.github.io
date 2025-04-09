---
title: chrome ext capture
date: 2025-03-31
private: true
---
# chrome ext capture
caputre 方法有许多

# 原生js: 利用canvas dom
    const canvas = document.createElement('canvas');
    const ctx = canvas.getContext('2d');
    img = document.getElementsByTagName('image')[0] // |'canvas'
    x=0, y = 0
    ctx.fillText('text123', x, y);
    ctx.drawImage(
            img,
            0, // 源图像x坐标
            10, // 源图像y坐标（跳过标题部分）
            50, // 源图像宽度
            50, // 源图像高度（排除标题部分和重叠部分），确保至少为1
            0, // 目标x坐标
            10, // 目标y坐标（当前已绘制的高度）
            100, // 目标宽度
            100// 目标高度，确保至少为1
        );
    dataUrl =  canvas.toDataURL('image/jpeg', 0.6)

    img = new Image(dataURL) 
    ctx.drawImage(
            img,
            0, // 源图像x坐标
            headerHeight, // 源图像y坐标（跳过标题部分）
            img.width, // 源图像宽度
            Math.max(1, keepHeight - headerHeight), // 源图像高度（排除标题部分和重叠部分），确保至少为1
            0, // 目标x坐标
            y, // 目标y坐标（当前已绘制的高度）
            drawWidth, // 目标宽度
            drawHeight // 目标高度，确保至少为1
            );
    dataUrl =  smallCanvas.toDataURL('image/jpeg', 0.6)

html2canvas 就是用dom+css 生成的canvas: 

    html2canvas(element, {
        useCORS: true,       // 启用跨域图片
        allowTaint: true,    // 允许污染 Canvas（慎用）
        scale: 2             // 高分屏适配
    });

特点:
1. 性能差, css支持有限
1. 浏览器差异	不同浏览器对 getComputedStyle 的返回值有差异（如 Flexbox 布局计算）
2. CSS 支持不全	部分属性无法完美转换（mix-blend-mode、clip-path、filter 等）
3. 动态内容	截图瞬间的页面状态（如动画帧、滚动位置）可能无法准确捕获
4. 跨域限制	未配置 CORS 的图片会导致 Canvas 污染（tainted）

# 使用Chrome DevTools Protocol
> 只能用于chrome extension
```js
// 在扩展的background.js中
chrome.browserAction.onClicked.addListener(function(tab) {
  // captureVisibleTab 只截取当前视窗可见区域（viewport）内的内容
  // 不包括需要滚动才能看到的页面部分
  chrome.tabs.captureVisibleTab(null, {format: 'png'}, function(dataUrl) {
    // 处理截图
  });
  
  // 或者使用CDP
  chrome.debugger.attach({tabId: tab.id}, '1.3', function() {
    chrome.debugger.sendCommand({tabId: tab.id}, 'Page.captureScreenshot', {
      format: 'png',
      captureBeyondViewport: true,  // 这个选项可以截取整个页面，包括不可见区域
      fromSurface: true,
    }, function(response) {
      if (chrome.runtime.lastError) {
        console.error('截图失败:', chrome.runtime.lastError);
        return;
      }

      // 获取完整的截图 dataUrl
      const fullScreenshotDataUrl = `data:image/png;base64,${response.data}`;
      console.log('完整截图 dataUrl:', fullScreenshotDataUrl);
      // 处理截图数据
      chrome.debugger.detach({tabId: tab.id});
    });
  });
});
```