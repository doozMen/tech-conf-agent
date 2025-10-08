# Ghost Agents Quick Reference

## Agent Files Created

1. **blog-content-writer.md** (15KB, 464 lines)
   - Location: ~/.claude/agents/blog-content-writer.md
   - Model: sonnet-1m
   - Purpose: Transform raw content into Ghost-ready blog posts

2. **ghost-publisher.md** (19KB, 662 lines)
   - Location: ~/.claude/agents/ghost-publisher.md
   - Model: sonnet
   - Purpose: Publish to Ghost with validation and duplicate detection

## Quick Usage

### Create Blog Post

```bash
# From any repo
claude agent blog-content-writer "Create blog post from docs/my-notes.md"
```

Output: /tmp/blog-post-draft.md

### Publish to Ghost

```bash
# From any repo
claude agent ghost-publisher "Publish /tmp/blog-post-draft.md as draft"
```

Output: Ghost draft post with admin URL

## Critical Formatting Rules

### Code Blocks
- MUST have language identifier
- Use triple backticks with language: ```swift

### Links
- MUST be absolute URLs (https://...)
- NO relative paths (/docs/page)

### Images
- MUST use absolute URLs
- Format: ![Alt text](https://example.com/image.jpg)

## Belgian Direct Writing Style

❌ Avoid:
- "delve", "realm", "landscape", "perhaps", "elevate", "journey"
- Passive voice
- Abstract descriptions

✅ Use:
- Fact-based statements
- Active voice
- Specific code examples
- Honest trade-off assessment

## Duplicate Prevention

ghost-publisher ALWAYS:
1. Searches Ghost by title first
2. If found -> Asks: Update or rename?
3. If not found -> Creates new post

## Ghost MCP Tools

Available via ghost-publisher:
- mcp__ghost__create_post
- mcp__ghost__update_post
- mcp__ghost__search_posts
- mcp__ghost__get_post
- mcp__ghost__list_tags

## Ghost Admin URLs

Base: https://doozmen-stijn-willems.ghost.io
Dashboard: /ghost/#/dashboard
Posts: /ghost/#/posts
Editor: /ghost/#/editor/post/[ID]

## Verify Setup

```bash
# Check agents exist
ls -la ~/.claude/agents/blog-*.md

# Check Ghost MCP connected
claude mcp list | grep ghost
```

## Example Workflow

1. Have conference notes in docs/conference-2025.md
2. Invoke: claude agent blog-content-writer "Create post from docs/conference-2025.md"
3. Review: /tmp/blog-post-draft.md
4. Invoke: claude agent ghost-publisher "Publish /tmp/blog-post-draft.md"
5. Review in Ghost Admin at provided URL
6. Publish when ready

## Troubleshooting

**Issue**: Code blocks not highlighting
**Fix**: Add language identifier after triple backticks

**Issue**: Links broken
**Fix**: Make all URLs absolute (start with https://)

**Issue**: Duplicate posts
**Fix**: ghost-publisher should prevent this automatically

**Issue**: Ghost MCP not connected
**Fix**: Check claude_desktop_config.json has ghost MCP configured

## Resources

All documentation links embedded in agents:
- Ghost Markdown Guide
- Ghost Admin API Docs
- Ghost MCP GitHub
- Claude Subagent Best Practices
- PrismJS Language Support

## Agent Cross-References

blog-content-writer mentions ghost-publisher in:
- Output format section
- Handoff protocol
- Metadata structure

ghost-publisher mentions blog-content-writer in:
- Expected input format
- Integration section
- Workflow description

Both agents work seamlessly together for complete blogging pipeline.
