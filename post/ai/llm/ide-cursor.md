程序员如果用好cursor?
# ide cline
## 配置文件：
- .clineignore
https://docs.cline.bot/improving-your-prompting-skills/prompting#clineignore-file-guide
- .clinerules
https://docs.cline.bot/improving-your-prompting-skills/prompting#clinerules-file




## 制定Cursor Rule，让AI扮演各种专家角色

目前用的非常顺手的Rule：RIPER-5，制定Cursor Rule，让AI扮演各种专家角色（类型cline/Roo）

配置：cursor 打开project rules. 配置5种模式的prompt， 使用示例：我正在学习某个库的源码，我可以要求：进入研究模式，帮我xxxxxxxx。
 *  “ENTER RESEARCH MODE”//进入研究模式
 *  “ENTER INNOVATE MODE”//进入创新模式
 *  “ENTER PLAN MODE”//进入规划模式
 *  “ENTER EXECUTE MODE”//进入执行模式
 *  “ENTER REVIEW MODE”//进入审查模式


# cline mcp 接入

## context7
Context 7可以直接集成到现有的AI编程助手中，如Cursor、Windsurf、Claude Desktop/Code等，无需频繁切换到文档网站。

Context 7的工作流程通常包括用户在提示词中添加关键的触发词（如"use context7"），然后Context7会拦截该提示，解析出所请求的库，拉取对应版本的文档，并将最新的内容注入到LLM的上下文中。这样，当AI生成代码时，它将基于最新且准确的信息，提高代码的质量和可靠性。

## 接入 mysql mcp
MySQL MCP Server https://github.com/benborla/mcp-server-mysql。

## pg mcp

    "postgres": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-postgres",
        "postgresql://localhost/mydb"
      ]
    }
