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
2. chatpdf
    1. https://www.v2ex.com/t/954967
    https://github.com/austin2035/chatpdf/
    2. https://www.v2ex.com/t/927940
    github: https://github.com/daodao97/chatdoc

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
## chatpdf 原理
chatpdf 原理 https://v2ex.com/t/921750 https://www.v2ex.com/t/927940
具体的实现原理是

    利用 embedding 接口对文章内容进行向量化, 存储索引
    提问的问题再次利用 embedding 接口进行向量化
    根据 问题的向量数据在 文章的索引中进行搜索, 找寻到近似的章节
    将 问题和近似的 embedding 一同提交到 complation 接口, 获取到 openai 的回复

可以参考 https://github.com/hwchase17/langchain
和 https://gpt-index.readthedocs.io/en/latest/index.html

# ai体验-平台-应用
## Ai 体验
https://cap.chatyy.com
合租 https://nf.video/
https://chatgpt123.com/#term-82

## 申请帐号
GPT4的PLUS会员 https://adaptive-birch-2ff.notion.site/AI-ChatGPT-PLUS-07651a29a7834e57aa938ee78bf743a0

## 应用
Ai打游戏：https://github.com/linyiLYi/street-fighter-ai
awesome aitools: https://github.com/ikaijua/Awesome-AITools/blob/main/README-CN.md 

# 提示词
## 吴恩达提示工程
参考:
- 吴恩达提示工程教程：https://www.bilibili.com/video/BV1Z14y1Z7LJ/?spm_id_from=333.337.search-card.all.click&vd_source=c19c4980a244fedcc729762ff654bbc9
- 提示工程技术（简版）： https://learn.microsoft.com/zh-cn/azure/ai-services/openai/concepts/advanced-prompt-engineering?pivots=programming-language-chat-completions

原则：
1. 分隔符可以是任何一种清晰的符号，避免提示词冲突。
2. 少量的训练. 少量的例子。
3. 让他多思考。否则有幻觉。 要求step by step。

后退提问相关资料 Step-back prompting
https://www.unite.ai/zh-CN/analogical-step-back-prompting-a-dive-into-recent-advancements-by-google-deepmind/
https://kaoutartarik.substack.com/p/prompt-tutorial-how-step-back-prompting
思维链相关资料 Chains of thoughts
https://zhuanlan.zhihu.com/p/629087587
https://deepgram.com/learn/chain-of-thought-prompting-guide

## 公开的Prompt 库
- AI教练——展示了提示语强大的定制能力：https://github.com/JushBJJ/Mr.-Ranedeer-AI-Tutor
- https://prompt-shortcut.writeathon.cn/
- https://github.com/f/awesome-chatgpt-prompts
- https://publicprompts.art/
