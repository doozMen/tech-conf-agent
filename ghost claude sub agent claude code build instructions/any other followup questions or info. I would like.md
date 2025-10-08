<img src="https://r2cdn.perplexity.ai/pplx-full-logo-primary-dark%402x.png" style="height:64px;margin-right:32px"/>

# any other followup questions or info. I would like to build an anthropic subagent to use with claude code to handle posting. Any suggentions for claude code?

Here are **recommended follow-up questions** and detailed **suggestions** for building an Anthropic subagent (for Ghost posting) with Claude Code:

***

### Follow-up Questions to Clarify Your System Design

- **What subagent roles do you want?**
    - Example: “Author” for post creation, “Reviewer” for edits, “Scheduler” for timed publishing.
- **Should the subagent have access to all API endpoints, or only post-related endpoints?**
    - Fine-tuning permissions improves security and context preservation.[^1][^2]
- **Do you need hooks or chained workflows?**
    - Anthropic best practices recommend chaining subagent actions via *hooks*—e.g., one agent drafts, another reviews, a third publishes.[^3][^1]
- **How will you manage context and output between agents?**
    - Subagents use separate context windows and should summarize their work for the parent agent; this keeps your workflow modular and scalable.[^4][^5][^6]
- **Will your subagent need to fetch, convert, and validate Markdown -> HTML before posting, or should the parent agent handle some steps?**
- **How do you want to trigger the subagent?**
    - Automated via event/hook, or manual via slash command (e.g. `/ghost-post “My Draft”`).[^7][^3]

***

### Suggestions for Building a Claude Code Subagent

1. **Set Up a Dedicated Subagent**
    - Use Claude Code’s subagent interface (`/agents` command) to create a project-level or user-level agent, with a Markdown + YAML config specifying its role, permissions, and tools.[^8][^4][^1]
2. **Define Your Subagent Carefully**
    - Write a detailed system prompt describing its posting responsibilities, error handling, allowed endpoints, and expected output formatting.[^5][^4]
    - Example YAML frontmatter:

```markdown
---
name: ghost-poster
description: Handles posting and editing blog entries on Ghost via MCP API
tools:
  - ghost-mcp
permissions:
  - posts.create
  - posts.edit
---
```

    - Place the config in `.claude/agents/ghost-poster.md` to make it discoverable.[^1][^5]
3. **Connect to Your MCP/Ghost Server**
    - Use the latest TypeScript/Node MCP server for Ghost (`ghost-mcp` NPM package), which leverages official Ghost Admin API. Configure via environment variables for streamlined setup.[^9][^10][^11]
    - Example:

```
npm install @fanyangmeng/ghost-mcp
```

4. **Craft Modular Automation**
    - Use dynamic templates or scripts stored in your `.claude` folder for input/output scaffolding.[^12][^7]
    - Trigger with custom slash commands; e.g., `/ghost-post` invokes the posting subagent.[^3]
5. **Chain Agents for Advanced Workflows**
    - Assign single-responsibility roles, and use hooks to serialize or parallelize tasks (draft, edit, publish).[^6][^1]
    - Store reusable agents in `.claude/agents/`, share across projects.
6. **Testing and Validation**
    - Build tests for input/output, run TDD cycles using Claude’s automation features. Ask subagents to check implementation against your expected output.[^13]

***

### Key Resources

- [Claude Code Subagent Docs](https://docs.claude.com/en/docs/claude-code/sub-agents)[^4]
- [Best Practices for Subagents](https://www.pubnub.com/blog/best-practices-for-claude-code-sub-agents/)[^1]
- [Ghost MCP NPM Package](https://github.com/MFYDev/ghost-mcp)[^10]
- [Ghost MCP Server Setup \& Integration](https://fanyangmeng.blog/introducing-ghost-mcp-a-model-context-protocol-server-for-ghost-cms/)[^9]
- [Subagent Step-by-Step Guide (video)](https://www.youtube.com/watch?v=DNGxMX7ym44)[^8]
- [Hooks and Automation Guide](https://www.arsturn.com/blog/a-beginners-guide-to-using-subagents-and-hooks-in-claude-code)[^3]

***

**Tip:** Subagents in Claude Code are *most efficient for modular, testable, and repeatable blog automation*—especially via MCP servers and hooks. Use YAML for config, restrict tool permissions, chain workflows with hooks, and document interaction rules in your `.claude` project for stability and reuse.[^5][^10][^7][^9][^1][^3]
<span style="display:none">[^14][^15][^16][^17][^18][^19][^20]</span>

<div align="center">⁂</div>

[^1]: https://www.pubnub.com/blog/best-practices-for-claude-code-sub-agents/

[^2]: https://www.eesel.ai/blog/subagents-in-claude-code

[^3]: https://www.arsturn.com/blog/a-beginners-guide-to-using-subagents-and-hooks-in-claude-code

[^4]: https://docs.claude.com/en/docs/claude-code/sub-agents

[^5]: https://dev.to/oikon/enhancing-claude-code-with-mcp-servers-and-subagents-29dd

[^6]: https://skywork.ai/blog/claude-code-2-0-checkpoints-subagents-autonomous-coding/

[^7]: https://www.eesel.ai/blog/claude-code-automation

[^8]: https://www.youtube.com/watch?v=DNGxMX7ym44

[^9]: https://fanyangmeng.blog/introducing-ghost-mcp-a-model-context-protocol-server-for-ghost-cms/

[^10]: https://github.com/MFYDev/ghost-mcp

[^11]: https://forum.ghost.org/t/i-built-a-ghost-mcp-server-so-that-you-can-control-ghost-from-claude/55236

[^12]: https://www.sidetool.co/post/how-to-automate-tasks-with-claude-code-workflow-for-developers

[^13]: https://www.anthropic.com/engineering/claude-code-best-practices

[^14]: https://www.anthropic.com/engineering/building-agents-with-the-claude-agent-sdk

[^15]: https://www.tinybird.co/blog-posts/multi-agent-claude-code-tinybird-code

[^16]: https://albato.com/connect/claude_ai_anthropic-with-ghost

[^17]: https://gorannikolovski.com/blog/building-a-claude-code-subagent-to-automate-drupal-core-updates

[^18]: https://www.reddit.com/r/ClaudeAI/comments/1l9ja9h/psa_dont_forget_you_can_invoke_subagents_in/

[^19]: https://dev.to/ujjavala/a-week-with-claude-code-lessons-surprises-and-smarter-workflows-23ip

[^20]: https://zapier.com/apps/ghost/integrations/anthropic-claude

