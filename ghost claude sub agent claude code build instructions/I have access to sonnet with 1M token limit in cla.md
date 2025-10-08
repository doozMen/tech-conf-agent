<img src="https://r2cdn.perplexity.ai/pplx-full-logo-primary-dark%402x.png" style="height:64px;margin-right:32px"/>

# I have access to sonnet with 1M token limit in claude code. This is good for writing blog post and being informed. For a second agent I would like it to use that model. Can you add info to the agent for writing based on the content I give him a well formatted ghost blog post?

Here’s how to set up a Claude Code agent (subagent) designed specifically for **writing well-formatted Ghost blog posts with Sonnet 1M context**, using your content as input:

***

### Recommended Agent Configuration (Markdown + YAML)

Create a file in your `.claude/agents/` directory, e.g., `blog-writer-agent.md`, and use YAML frontmatter to specify the agent’s role and model:

```markdown
---
name: blog-writer-agent
description: |
  Takes incoming content, drafts and formats a Ghost-ready blog post.
  Optimizes structure, Markdown, headings, tables, images, and code blocks for Ghost.
  Uses advanced reasoning to organize large input, and ensures final post is ready for direct API upload.
model: sonnet-1m
permissions:
  - posts.create
  - posts.edit
  - content.structure
tools:
  - FormatMarkdown
  - StructureContent
  - GhostAPI
---

## Instructions for the agent

1. Take the input content (can be very large: full research articles, notes, etc.).
2. Structure as a readable, well-formatted blog post:
   - Use proper Markdown for headings, lists, tables, code blocks (with language tags).
   - Ensure code examples are fenced and use language hint for highlighting.
   - Use Markdown for images (`![alt text](image url)`) and links.
   - Split content into logical sections (Intro, main points, conclusion).
   - Add meta description, suggested title, and tags if not provided.
   - Insert a table of contents for long posts.
3. Output your draft as Markdown, ready for Ghost.
4. Validate Ghost markdown compatibility (avoid unsupported syntax or raw HTML).
5. Output full blog draft for preview or upload by parent agent.

---

**Tip**: For persistent, stateful multi-turn writing, use the Sonnet 1M context to serialize all input notes and feedback, and save progress with Claude Code’s new checkpointing feature. The agent should *never* truncate the post near the token limit—save state and continue as needed!

---

### Usage Pattern

- **Manual**: `/blog-writer-agent “paste content here”`
- **Automated**: Trigger the agent via workflow when content arrives in MCP.

Advanced: Chain a reviewer subagent after the writer agent to check tone, grammar, and SEO for Ghost.

---

### Further Reading and Best Practices

- [Multi-agent configuration guide](https://docs.claude.com/en/docs/claude-code/sub-agents)[^33]
- [Prompt engineering for long-context Sonnet](https://docs.claude.com/en/docs/build-with-claude/prompt-engineering/claude-4-best-practices)[^55]
- [Sonnet 1M token context usage](https://ki-ecke.com/insights/claude-sonnet-4-1m-token-guide-how-to-process-codebases/)[^63]

---

This setup takes full **advantage of Sonnet’s large context** and agentic reasoning. Your input (“content I give him”) gets converted to a robust, Ghost-ready Markdown post—split into sections, with code blocks, tables, images and more, ready for publishing. Add checkpoints and feedback hooks for iterative editing if needed.
<span style="display:none">[^1][^10][^11][^12][^13][^14][^15][^16][^17][^18][^19][^2][^20][^3][^4][^5][^6][^7][^8][^9]</span>

<div align="center">⁂</div>

[^1]: https://www.anthropic.com/news/claude-sonnet-4-5
[^2]: https://anthropic.com/news/enabling-claude-code-to-work-more-autonomously
[^3]: https://docs.claude.com/en/docs/claude-code/sub-agents
[^4]: https://www.reddit.com/r/ClaudeAI/comments/1mdyc60/whats_your_best_way_to_use_subagents_in_claude/
[^5]: https://www.youtube.com/watch?v=50tzzaOvcO0
[^6]: https://www.reddit.com/r/ClaudeAI/comments/1htkcvs/claude_35_for_blogging/
[^7]: https://www.claudelog.com/mechanics/custom-agents/
[^8]: https://docs.claude.com/en/docs/build-with-claude/prompt-engineering/claude-4-best-practices
[^9]: https://www.youtube.com/watch?v=U9bjOBOU7Nc
[^10]: https://github.com/wshobson/agents
[^11]: https://www.anthropic.com/news/claude-3-7-sonnet
[^12]: https://docs.claude.com/en/docs/claude-code/settings
[^13]: https://www.reddit.com/r/ClaudeCode/comments/1mm0pu8/claude_code_studio_how_the_agentfirst_approach/
[^14]: https://www.anthropic.com/engineering/building-agents-with-the-claude-agent-sdk
[^15]: https://www.cursor-ide.com/blog/claude-subagents
[^16]: https://www.linkedin.com/posts/jpoulter_claude-just-got-a-massive-upgrade-for-writing-activity-7300132750336966657-TdBc
[^17]: https://www.anthropic.com/engineering/claude-code-best-practices
[^18]: https://ki-ecke.com/insights/claude-sonnet-4-1m-token-guide-how-to-process-codebases/
[^19]: https://blog.langchain.com/how-to-turn-claude-code-into-a-domain-specific-coding-agent/
[^20]: https://aws.amazon.com/blogs/aws/introducing-claude-sonnet-4-5-in-amazon-bedrock-anthropics-most-intelligent-model-best-for-coding-and-complex-agents/```

