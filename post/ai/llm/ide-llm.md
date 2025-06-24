---
title: ide cursor
date: 2025-03-29
private: true
---
# Preface
- windsurf 重构项目擅长，相比cursor, 联网搜索和读图功能都没有，还不能预设prompt…
- cursor
- cline:  开源/mcp
- devin: 搏一搏，$20变$500：一小时魔改Cursor变身Devin https://yage.ai/cursor-to-devin.html
    1. Devin有理解图像的能力

# mcp
https://github.com/aipotheosis-labs/aci-mcp

# cline

# cursor
- 搏一搏，$20变$500：一小时魔改Cursor变身Devin https://yage.ai/cursor-to-devin.html
- step by step: https://github.com/grapeot/devin.cursorrules/blob/master/step_by_step_tutorial.md

## ide配置
> https://github.com/grapeot/devin.cursorrules/blob/master/step_by_step_tutorial.md
1. shift+cmd+p 打开cursor settiong:
2. 在features 中打开: enable auto-run mode

## 基本配置
https://github.com/grapeot/devin.cursorrules

    cookiecutter gh:grapeot/devin.cursorrules --checkout template  

一键完成:
```bash
initide () {
    cp -r $HOME/cursor-rule/{tools,.cursorignore,.github,.cursorrules,requirements.txt} ./
    python3 -m venv ./venv
    echo venv/ >> .gitignore
    source venv/bin/activate
    pip install -r requirements.txt
    cat <<-MM >> .gitignore
.github/
venv/
.cursorignore
.cursorrules
requirements.txt
tools/
MM
}
```


主要文件: 

   $ ls tools
   $ cat .cursorignore 
   venv/
   $ cat .cursorrules

Copy the **tools** folder and the following **config files** into your project root folder:  

    Windsurf users need both: .windsurfrules and scratchpad.md files. 
    Cursor users only need the:  .cursorrules file. 
    Github Copilot users need the:  .github/copilot-instructions.md file.

## multi agent配置
> https://github.com/grapeot/devin.cursorrules/tree/multi-agent
high-level Planner (powered by o1) that coordinates complex tasks,
and an Executor (powered by Claude/GPT) that implements step-by-step actions.

    Copy all files from this repository to your project folder
    For Cursor users: The .cursorrules file will be automatically loaded
    For Windsurf users: Use both .windsurfrules and scratchpad.md for similar functionality

## curosr rules share
https://www.bilibili.com/video/BV1FfXtYQEYd/?vd_source=c19c4980a244fedcc729762ff654bbc9