---
title: vscode copilot
date: 2023-09-25
private: true
---
# Preface
- copilot
- fitten code https://code.fittentech.com/
- Codeium 作为copilot 的实例替代（替代不了copilot chat）
- cody: https://about.sourcegraph.com/cody
- codewhisper (aws)

# vsc copilot
## 快捷键 
vscode 为例(cmd+K cmd+s)

    Ctrl+Cmd+I      toggle copilot chat sidebar
    Shift+Cmd+I     ask copilot chat
    Tab             接受当前建议
    Esc             取消当前行的建议
    Alt + ]         展示下一个建议
    Alt + [         展示上一条建议
    Ctl + Shift + P  GitHub Copilot 指令命令选择
    Cmd+I           generate copilot code
    Trigger auto completion
        Alt + \  触发当前行的建议(Trigger inline suggestion)
        Ctrl + Enter 打开GitHub Copilot建议面板
        ctrl+/  accept panel suggestion

另外，在copilot chat 中按 `Up/Down` 键，可以切换历史输入
# 配置
## 上下文管理
Copilot 现在也可以在对话中通过#添加其他文件来作为上下了

## instructions
https://docs.github.com/zh/copilot/customizing-copilot/adding-custom-instructions-for-github-copilot
创建名为 .github/copilot-instructions.md 的文件。
以 Markdown 格式在该文件中添加自然语言说明。

    We use Bazel for managing our Java dependencies, not Maven, so when talking about Java packages, always give me instructions and code samples that use Bazel.

    We always write JavaScript with double quotes and tabs for indentation, so when your responses include JavaScript code, please follow those conventions.

    Our team uses Jira for tracking items of work.