---
title: chatgpt 大语言模型LLM
date: 2023-07-20
private: true
---
# chatgpt 大模型
Large Language Models（LLMs）是在自然语言处理（NLP）和自然语言生成（NLG）任务中利用深度学习的基础模型. 例如模型GPT-3、PaLM、Galactica 和LLaMA
1. model (mosaicml/mpt-7b). 
    浏览器上调用 LLM API 的浏览器插件 https://v2ex.com/t/954707#reply2
    API 是通过一个去中心化的计算框架实现的( https://ocf.autoai.org/), 

有非常多的llm 模型：
baichuan-13b chatglm-6b-int4-qe chatglm-6b-int4 chatglm-6b-int8 chatglm-6b chatglm2-6b chatyuan moss vicuna-13b-hf fastchat-chatglm-6b fastchat-chatglm2-6b fastchat-vicuna-13b-hf

## llm 排名
https://chat.lmsys.org/?leaderboard

## 大模型集成
多模式api集成：https://github.com/sunner/ChatALL
Open Prompt :https://v2ex.com/t/934197

# 原理
- AI 神笔马良工作原理揭秘 https://www.bilibili.com/video/BV1de411r7uU/
    1. openai clip ：可以用来计算文本与图片匹配度
        1. 将图片及其文本(不是单一标签，而是一段文本)，分别提取特征值 量化向量
        2. 将两组向量关联，与单一标签相比信息含量大大增加。
    2. deepmind flamingo:
        1. 首先将图文相间的内容，转换成词语和图片
        2. 然后处理转换成词图向量：
           1. 文本词语，用gpt之类的的转换
           1. 图片，用clip 转换
        3. 最后采用生成式模型的思路，将词图向量，采用自注意力机制再进行一轮理解（自关联向量）
        4. 这样就可以用于读取图片（根据图片，生成文字、图片）-- tldraw 是这样实现的

- base llm和rlhf人类反馈强化学习

# ai体验-平台-应用
## API 平台
1. https://docs.fal.ai/
    语音转文字，文字转图片　API
    https://fal.ai/flux
    AI图像生成迎来新霸主:开源模型FLUX.1横空出世
2.　https://openrouter.ai/
    gpt4, claude 等llm api

## IDE
- windsurf 重构项目擅长，相比cursor, 联网搜索和读图功能都没有，还不能预设prompt…
- cursor
- devin: 搏一搏，$20变$500：一小时魔改Cursor变身Devin https://yage.ai/cursor-to-devin.html
    1. Devin有理解图像的能力

## 应用
AI开发的菜品应用(gpt+cursor+windsurf+...): 
    https://www.youtube.com/watch?v=w1Mo0NoiO7U
Ai打游戏：https://github.com/linyiLYi/street-fighter-ai
awesome aitools: https://github.com/ikaijua/Awesome-AITools/blob/main/README-CN.md 