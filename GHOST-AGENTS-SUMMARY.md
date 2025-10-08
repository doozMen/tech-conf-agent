# Ghost Blogging Agents - Summary

Two specialized Claude Code agents have been created for your Ghost blogging workflow:

## 1. blog-content-writer

**Location**: `~/.claude/agents/blog-content-writer.md`

**Purpose**: Transforms raw content (conference notes, technical docs, research) into well-structured, Ghost-ready blog posts

**Key Features**:
- Uses `sonnet-1m` model for 1M token context (handles large content)
- Belgian direct writing style (fact-based, no AI verbosity)
- Ghost-compatible markdown with proper code blocks
- Technical accuracy verification with inline documentation links
- SEO optimization (compelling titles, excerpts, tags)
- Comprehensive validation (code blocks, links, images)

**Tools**: Read, Edit, Glob, Grep, WebSearch, Bash

**Output**: Complete markdown file ready for ghost-publisher agent

## 2. ghost-publisher

**Location**: `~/.claude/agents/ghost-publisher.md`

**Purpose**: Publishes blog posts to Ghost CMS with duplicate detection and format validation

**Key Features**:
- Ghost MCP integration (uses ghost MCP server)
- Duplicate detection (searches before creating)
- Format validation (code blocks, links, images)
- Markdown-to-HTML conversion verification
- Tag management and consistency
- Post-publishing verification

**Tools**: Read, Bash, WebSearch

**MCP**: ghost (requires Ghost MCP configuration)

**Ghost MCP Tools Used**:
- mcp__ghost__create_post - Create new posts
- mcp__ghost__update_post - Update existing posts
- mcp__ghost__search_posts - Check for duplicates
- mcp__ghost__get_post - Verify post details
- mcp__ghost__list_tags - Tag management

## Complete Workflow

### Step 1: Create Content (blog-content-writer)

Agent Actions:
1. Reads all input files
2. Analyzes content type (conference, tutorial, migration guide)
3. Structures content with proper headings
4. Writes in Belgian direct style (no AI verbosity)
5. Adds code examples with language tags
6. Verifies all links are absolute URLs
7. Creates compelling title and excerpt
8. Generates appropriate tags
9. Saves output to /tmp/blog-post-draft.md

### Step 2: Publish to Ghost (ghost-publisher)

Agent Actions:
1. Reads markdown file
2. Extracts title, excerpt, tags, status
3. Validates all code blocks have language identifiers
4. Validates all links are absolute URLs
5. Searches Ghost for duplicate posts by title
6. If duplicate found -> Asks user: Update or rename?
7. If no duplicate -> Creates draft post via Ghost MCP
8. Verifies post was created successfully
9. Reports Ghost Admin URL for review

## Key Guidelines

### Belgian Direct Writing Style

Characteristics:
- Fact-based, lead with concrete information
- No fluff: Cut "delve", "realm", "landscape", "perhaps"
- Active voice: "Swift 6 adds X" not "Swift 6 introduces capabilities"
- Specific examples: Show code, don't just describe
- Honest assessment: Acknowledge trade-offs

### Code Block Formatting (CRITICAL)

Always use triple backticks with language identifier.

Supported languages: swift, javascript, typescript, python, bash, json, yaml, sql, html, css, rust, go, java, kotlin

Ghost uses PrismJS for syntax highlighting.

### Link Format (CRITICAL)

All links must be absolute URLs starting with https://

### Duplicate Prevention

ghost-publisher ALWAYS checks for duplicates before creating posts.

## Resources Incorporated

### Ghost Documentation
- Ghost Markdown Guide: https://ghost.org/help/using-markdown/
- Ghost Markdown Reference: https://www.markdownguide.org/tools/ghost/
- Ghost Admin API: https://ghost.org/docs/admin-api/
- PrismJS Languages: https://prismjs.com/#supported-languages

### Ghost MCP
- Ghost MCP GitHub: https://github.com/MFYDev/ghost-mcp
- Ghost MCP NPM: https://www.npmjs.com/package/@fanyangmeng/ghost-mcp
- Ghost MCP Blog: https://fanyangmeng.blog/introducing-ghost-mcp-a-model-context-protocol-server-for-ghost-cms/
- MD2Ghost Project: https://github.com/MirisWisdom/MD2Ghost

### Claude Code Best Practices
- Subagent Docs: https://docs.claude.com/en/docs/claude-code/sub-agents
- Prompt Engineering: https://docs.claude.com/en/docs/build-with-claude/prompt-engineering/claude-4-best-practices
- Long-Context Sonnet: https://ki-ecke.com/insights/claude-sonnet-4-1m-token-guide-how-to-process-codebases/
- Subagent Best Practices: https://www.pubnub.com/blog/best-practices-for-claude-code-sub-agents/
- Hooks Guide: https://www.arsturn.com/blog/a-beginners-guide-to-using-subagents-and-hooks-in-claude-code

## Agent Files

blog-content-writer.md: 15KB, 464 lines
- Comprehensive writing guidelines
- Belgian direct style examples
- Ghost markdown compatibility reference
- Content structure templates
- Quality assurance checklists
- Link verification protocol
- Integration with ghost-publisher

ghost-publisher.md: ~20KB
- Ghost MCP tool reference
- Duplicate detection workflow
- Format validation checklist
- Publishing workflow (5 phases)
- Error handling guide
- Ghost Admin URLs
- Integration with blog-content-writer

## Summary

You now have a complete blogging pipeline:

1. Create content -> blog-content-writer agent
   - Transforms raw content to Ghost-ready markdown
   - Enforces Belgian direct writing style
   - Validates format, links, code blocks
   - Uses sonnet-1m for large context

2. Publish to Ghost -> ghost-publisher agent
   - Detects duplicates before creating
   - Validates markdown compatibility
   - Posts via Ghost MCP
   - Reports admin URLs

Both agents are globally available from any repo and cross-reference each other for seamless workflow.

Created: 2025-10-08
Location: ~/.claude/agents/
Status: Ready to use
