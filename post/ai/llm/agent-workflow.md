---
title: agent workflow
date: 2025-05-21
private: true
---
# Agent framework
- LangChain
简介: 最流行和功能最全面的框架之一。它提供了构建 LLM 应用的模块化组件，包括模型I/O、数据连接、Chains (序列)、Agents 和 Memory。
- LlamaIndex (Python)
优点: 在 RAG 方面非常强大，数据处理能力出色。
缺点: Agent 功能虽然有，但可能不如 LangChain 那么灵活或历史悠久。
# LangChain (Python & JavaScript/TypeScript)

本地代码执行: 你可以非常容易地将任何 Python 函数定义为一个 Tool。Agent 在决定需要执行某个操作时，会调用你定义的这个本地函数。

```
from langchain.agents import tool

@tool
def run_local_script(command: str) -> str:
    """Runs a local shell command and returns its output."""
    import subprocess
    try:
        result = subprocess.run(command, shell=True, capture_output=True, text=True, check=True)
        return result.stdout
    except subprocess.CalledProcessError as e:
        return f"Error: {e.stderr}"
```
## RAG
RAG 流程（使用 LangChain）:

    Ingestion (一次性或定期更新):
        Load: 使用 DocumentLoaders 加载原始数据。
        Split: 使用 TextSplitters 将文档分割成块。
        Embed: 使用 Embeddings 模型将文本块转换为向量。
        Store: 将嵌入向量和文本块存入 VectorStore。
        Retrieval & Generation (每次用户查询时):

    Retrieve: 用户输入查询，使用 Retriever 从 VectorStore 中检索最相关的文档块。
        Augment & Generate:
        将检索到的文档块作为上下文。
        使用 PromptTemplate 结合上下文和用户问题构建提示。
        将提示传递给 LLM (如 ChatOpenAI) 生成答案。
        (可选) 使用 OutputParser 格式化输出。