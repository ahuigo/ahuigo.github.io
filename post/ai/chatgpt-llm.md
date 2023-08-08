# ---
title: chatgpt 大语言模型LLM
date: 2023-07-20
private: true
---
# chatgpt 大模型
Large Language Models（LLMs）是在自然语言处理（NLP）和自然语言生成（NLG）任务中利用深度学习的基础模型. 例如模型GPT-3、PaLM、Galactica 和LLaMA
1. model (mosaicml/mpt-7b). 
    浏览器上调用 LLM API 的浏览器插件 https://v2ex.com/t/954707#reply2
    API 是通过一个去中心化的计算框架实现的( https://ocf.autoai.org/), 
2. chatpdf
    1. https://www.v2ex.com/t/954967
    https://github.com/austin2035/chatpdf/
    2. https://www.v2ex.com/t/927940
    github: https://github.com/daodao97/chatdoc

baichuan-13b chatglm-6b-int4-qe chatglm-6b-int4 chatglm-6b-int8 chatglm-6b chatglm2-6b chatyuan moss vicuna-13b-hf fastchat-chatglm-6b fastchat-chatglm2-6b fastchat-vicuna-13b-hf

## 大模型集成
多模式api集成：https://github.com/sunner/ChatALL
Open Prompt :https://v2ex.com/t/934197

# chatpdf 原理
chatpdf 原理 https://v2ex.com/t/921750 https://www.v2ex.com/t/927940
具体的实现原理是

    利用 embedding 接口对文章内容进行向量化, 存储索引
    提问的问题再次利用 embedding 接口进行向量化
    根据 问题的向量数据在 文章的索引中进行搜索, 找寻到近似的章节
    将 问题和近似的 embedding 一同提交到 complation 接口, 获取到 openai 的回复

可以参考 https://github.com/hwchase17/langchain
和 https://gpt-index.readthedocs.io/en/latest/index.html