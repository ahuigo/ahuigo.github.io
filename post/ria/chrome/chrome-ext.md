---
title: Chrome Extension 使用
date: 2019-10-06
private: 
---
# Chrome Extension 使用
# 安全
1. 右键设置 Read and Change site Data(或者在detail中设置): https://www.howtogeek.com/291095/why-do-chrome-extensions-need-all-your-data-on-the-websites-you-visit/

# CSP(content-security-policy)
https://www.uriports.com/blog/creating-a-content-security-policy-csp/

## unsafe-inline 不再有效
新chrome 无效:

    <meta http-equiv="Content-Security-Policy" content="script-src 'self' 'unsafe-inline'; style-src 'self' 'unsafe-inline'">

## nonce和sha256同样无效

    <meta http-equiv="Content-Security-Policy" content="script-src 'self'  'sha256-m1SkrZVLRPjpQzG15ytmzxX='">

    <meta http-equiv="Content-Security-Policy" content="script-src 'self' 'nonce-EDNnf03nceIOfn39fn3e9h3sdfa'">

## 只能不用inline script
    <script src="fiddle.js"> </script>
