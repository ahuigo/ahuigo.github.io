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
## agent mode
开启： https://techcommunity.microsoft.com/blog/educatordeveloperblog/use-github-copilot-agent-mode-to-create-a-copilot-chat-application-in-5-minutes/4375689

    vscode >= 1.98
    cmd+, 打开 chat agent

https://www.youtube.com/watch?v=KSxUr0BU9ig

## 上下文管理
Copilot 现在也可以在对话中通过#添加其他文件来作为上下了

## repo instructions

https://docs.github.com/zh/copilot/customizing-copilot/adding-custom-instructions-for-github-copilot

`cmd+, :  copilot instruction` 可看到有几种:
- instruction file: `.github/copilot-instructions.md` 的文件。勾选上
- Prompt files(预览): `.github/prompts/*.prompt.md`
    - 用途: 分割成多个提示词文件, 方便链接到其它提示文件作为依赖(复用)
    - 使用: 在chat中通过附件手动引用(非全局的)

### instruct file
创建名为 `.github/copilot-instructions.md` 的文件。

    # 以 Markdown 格式在该文件中添加自然语言说明。
    We use Bazel for managing our Java dependencies, not Maven, so when talking about Java packages, always give me instructions and code samples that use Bazel.

    We always write JavaScript with double quotes and tabs for indentation, so when your responses include JavaScript code, please follow those conventions.

    Our team uses Jira for tracking items of work.

以下类型的说明不太可能起到预期的作用，并可能导致 Copilot 的其他内容出现问题：

    要求在提供的回答中引用外部资源
    有关按特定风格回答的说明
    要求始终以特定详细级别的信息来回答

因此，以下说明不太可能获得预期结果：

    Always conform to the coding styles defined in styleguide.md in repo my-org/my-repo when generating code.

    Use @terminal when answering questions about Git.

    Answer all questions in the style of a friendly colleague, using informal language.

    Answer all questions in less than 1000 characters, and words of no more than 12 characters.

#### 使用
开启后才能使用, 在chat 输入问题后, 只有回答时它会显示

    used 1 reference (.github/copilot-instructions.md)

注意: copilot如果需要调用`python tools/*` 它只需要显示这个执行语句, 它不能自动调用

### prompt files 示例
1. 启用: cmd+shift+p: `Open Workspace Settings (JSON)`
    1. settings.json 文件中，添加 "chat.promptFiles": true 以启用 .github/prompts 文件夹作为提示文件的位置
2. 创建:
    1. cmd+shift+p: “Chat: Create Prompt”
    2. 输入unittest, 编辑`.github/prompts/apitest.prompt.md`
        1. 可使用link `[link](url)` 或`#file:../../web/index.ts` 引用工作区其它文件.  路径是相对于提示文件的
3. 使用prompt files:
    1. Copilot Chat 视图底部，单击“Attach context”附件图标 
    2. 单击“Prompt...”并选择要使用的提示文件: `apitest.prompt.md`

`apitest.prompt.md`

    你的目标是生成api test 代码, 要求:
    - 使用goitest 进行测试, 参考 #file:../../server/task_test.go

`New React form.prompt.md` - 包含有关使用 React 生成窗体的可重用任务的说明。

    Your goal is to generate a new React form component.

    Ask for the form name and fields if not provided.

    Requirements for the form:
    - Use form design system components: [design-system/Form.md](../docs/design-system/Form.md)
    - Use `react-hook-form` for form state management:
    - Always define TypeScript types for your form data

## person custom instructions
https://docs.github.com/en/copilot/customizing-copilot/adding-personal-custom-instructions-for-github-copilot

> cmd+, :  copilot instruction
个人自定义说明优先于存储库自定义说明, 比如

    Always respond in Spanish.
    Your style is a helpful colleague, minimize explanations but provide enough context to understand the code.
    Always provide examples in TypeScript.

添加personal custom instructions, 步骤
1. 在github page中 click Immersive to open Copilot Chat in the full-page(https://github.com/copilot)
2. Select the  dropdown menu at the top right of the immersive page, then **click Personal instructions**. 
3. Add natural language instructions to the text box.
