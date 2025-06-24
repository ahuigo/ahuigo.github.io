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

## llm 排名比较
https://www.reddit.com/r/LocalLLaMA/comments/1e4unuz/any_up_to_date_benchmarking_sites_for_coding_llms/
- https://chat.lmsys.org/?leaderboard
- https://aider.chat/docs/leaderboards/
```bash
模型	上下文窗口	定位	适用场景	API 成本	模态支持	响应速度
GPT-4	8000 - 32000 tokens	通用语言模型	文本处理多领域	输入 0.03 美元 / 1K tokens，输出 0.06 美元 / 1K tokens	文本	适中
    GPt-4: Much slower, but somewhat smarter.
GPT-4o:45	128k tokens	多模态旗舰	多模态交互、文档对话	未详，比 GPT-4 Turbo 成本低 50%	文本、音频、图像	快（音频输入 232 毫秒响应）
    GPT-4o: all-purpose, powerful model. Used to be way too verbose, a bit better now.
    GPT-4o mini:4 A knowledge repository with no access to the internet. Good if you want to save resources and have marginally less of an impact on the environment.
GPT-4.1:52	100 万 tokens	旗舰多模态	复杂任务、长文档处理	输入 2 美元 / 百万 tokens，输出 8 美元 / 百万 tokens（75% 折扣）	文本	未详，性能强

O 系列（推理）
O3-mini:60	20 万 tokens	平衡速度与精度	不同需求的数学等领域	未明确	未明确	比 O1-mini 快 24%
O1:61	未明确	数学编程推理	复杂问题求解	未明确	未明确	相对慢
O4-mini:72	未明确	        实时低成本部署	边缘设备 AI 应用	    O3的1/3	未明确	相对快
o3:80

DeepSeek V3:55	128k tokens	聊天编码	聊天、编码、翻译等	输入约 0.55 美元 / 百万 tokens，输出约 2.19 美元 / 百万 tokens	主要文本	推理快，生成速度提升三倍
DeepSeek R1:57	12.8 - 13 万 tokens	复杂任务推理	数学、代码、逻辑任务	输入 0.5 元 / 百万 tokens，输出 8 元 / 百万 tokens	主要文本	快
Gemma3:5	12.8 万 tokens	开源 AI 应用开发	内容分析、创意场景	未明确	文本、图像、视频	未详，单 GPU 表现好
Gemini 2.0 flash:47	100 万 tokens	多模态高频处理	多模态大规模实时任务	未明确	文本、音频、图像、视频	超低延迟
Gemini 2.5pro:73	100 - 200 万 tokens	强推理多模态	复杂多源信息处理	未明确	文本、音频、图像、视频	未详，推理响应强
Claude 3.5:52	未明确	多模态跨推理	文档图像分析生成	未明确	文本、图像	支持实时功能，较快
Claude 3.7:65	未明确	混合推理	多领域复杂任务	未明确	文本、图像（跨模态）	依任务复杂度变化
```

- gpt
    - gpt3.5
    - gpt-4: 早期版本，慢, 比较智能
    - gpt-4o: 多模态
    - gpt-4.1: 
    - gpt-4.5
    - gpt-o1
- DeepSeek
    - DeepSeek V3(对标GPT4.5, 混合专家（MoE）): 数学、代码类相关评测集上取得了超过 GPT-4.5
    - DeepSeek-R1 「满血版」COT思维链(MoE + 强化学习微调): 数学、代码、自然语言性能和gpt-o1 相似. 相对没有COT思考的的v3 会更慢
- Qwen
    - Qwen2.5 是最新的 Qwen 大型语言模型系列, 支持多模态
        - Qwen2.5-VL-32B: 理解长视频并捕捉事件
    - QwQ-32B: QwQ 是 Qwen 系列的推理模型MoE，类似deepseek-R1, o1-mini
    - Qwen3: 全球最强开源模型（MoE+Dense），是国内首个支持 **“混合推理”** 的模型(非思考模式下响应快速，适用于简单任务,思考模式适用于复杂问题)
- Gemma:
    - Gemma3-27B-IT: 来自 Google 的一系列轻量级、最先进的多模态开放模型

copilot 高级请求默认300 额度：https://docs.github.com/zh/copilot/managing-copilot/monitoring-usage-and-entitlements/about-premium-requests
- 4o free(付费用户)
- o3-mini: 0.33/req
- claude 3.5/3.7: 1/req

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

# 提示词
17岁高中生写了个神级Prompt，直接把Claude强化成了满血o1。
    https://mp.weixin.qq.com/s/IAKD0FfcYehs5FsDkLbTJQ

# ai体验-平台-应用
## API 平台
1. https://docs.fal.ai/
    语音转文字，文字转图片　API
    https://fal.ai/flux
    AI图像生成迎来新霸主:开源模型FLUX.1横空出世
2.　https://openrouter.ai/
    gpt4, claude 等llm api

## 应用
AI开发的菜品应用(gpt+cursor+windsurf+...): 
    https://www.youtube.com/watch?v=w1Mo0NoiO7U
Ai打游戏：https://github.com/linyiLYi/street-fighter-ai
awesome aitools: https://github.com/ikaijua/Awesome-AITools/blob/main/README-CN.md 
