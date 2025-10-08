<img src="https://r2cdn.perplexity.ai/pplx-full-logo-primary-dark%402x.png" style="height:64px;margin-right:32px"/>

# I use ghost for blog posts with an mcp but it is not clear for claude code how to post a markdown blog post with the correct formatting. Can you give instructions and links for him?

To publish a Markdown blog post with correct formatting to Ghost using Claude Code (via an MCP workflow), follow these step-by-step instructions. Ghost supports Markdown natively in its editor but Markdown content must be converted to HTML before publishing by API.

### Step-by-Step Instructions

1. **Write Your Post in Markdown**
Draft your blog post locally using Markdown. Use standard Markdown syntax such as headings (`#H1`), bold (`**bold**`), italics (`*italic*`), lists, links, images, code blocks, and footnotes. Check the full syntax Ghost supports for best compatibility, noting that nested tables and lists are limited.[^1][^2]
2. **Convert Markdown to HTML**
The Ghost Admin API expects post bodies to be submitted in HTML, not raw Markdown. Use a conversion library like [`marked`](https://www.npmjs.com/package/marked) (Node.js), or Pandoc for batch conversion as shown in this script.[^3][^4]
Example Node.js:

```js
const marked = require('marked');
const html = marked(yourMarkdownString);
```

3. **Prepare Post Metadata**
Set up post metadata like title, tags, author, and publish date as needed. You can automate this using Claude Code with a `claude.md` configuration file for context ingestion.[^5][^6]
4. **Publish via Ghost Admin API**
Use the Ghost Admin API’s `posts` endpoint to publish your content programmatically. The most straightforward method is a POST/body structure:

```json
{
  "posts": [
    {
      "title": "My Post Title",
      "html": "<h1>Header</h1><p>Body text...</p>",
      "tags": ["Tech", "Claude"]
    }
  ]
}
```

Authenticate using an Admin API key. Refer to [Markdown to Ghost CMS GitHub project](https://github.com/MirisWisdom/MD2Ghost), which provides an automated script for bulk publishing Markdown files to Ghost via API, converting Markdown files to HTML automatically.[^3]
    - Project: https://github.com/MirisWisdom/MD2Ghost
    - Ghost API Docs: https://ghost.org/docs/admin-api/
5. **Claude Code Integration**
In Claude Code, you can trigger these automated publishing flows through MCP commands or direct shell/Node scripts. Configure Claude’s context with a relevant `.claude.md` file and use custom slash-commands, as documented in resources like “Awesome Claude Code”.[^6][^5]
6. **Formatting Best Practices**
    - Use Markdown cards in the Ghost editor when editing manually.[^7]
    - For automated publishing, always check post appearance after conversion—inline styling or HTML nuance might be needed for tables or complex elements.[^8]
    - Ghost supports a live preview and has built-in SEO tools and scheduling options in its editor.[^2]

### Helpful Resources \& Links

- **Ghost Markdown Reference:**
https://www.markdownguide.org/tools/ghost/[^1]
- **Ghost Markdown Guide:**
https://ghost.org/help/using-markdown/[^7]
- **Ghost Admin API Docs:**
https://ghost.org/docs/admin-api/[^3]
- **Bulk Markdown Upload Script:**
https://github.com/MirisWisdom/MD2Ghost[^3]
- **Claude Code “claude.md” Context and Workflow Tips:**
https://apidog.com/blog/claude-md/[^5]
- **Claude Code Resource List:**
https://github.com/hesreallyhim/awesome-claude-code[^6]


### Summary Table: Markdown Workflow for Ghost

| Step | Tool/Resource | Notes |
| :-- | :-- | :-- |
| Write in Markdown | Any editor, Claude Code | Use supported syntax[^1][^2] |
| Convert to HTML | marked, Pandoc, Claude Code, script | Ghost API needs HTML[^4][^3] |
| Publish via API | Ghost Admin API, MD2Ghost script | Automated or manual[^3][^9] |
| Formatting checks | Ghost editor preview | Especially for tables \& lists[^8][^7] |
| Claude automation | MCP, claude.md commands | Seamless integration[^5][^6][^10] |

For advanced Claude Code workflows, use configuration files and custom slash-commands, and automate conversions with Node scripts or CLI tools integrated into your MCP pipeline. Always verify published post appearance in Ghost after API-based upload for best formatting.
<span style="display:none">[^11][^12][^13][^14][^15][^16][^17][^18][^19][^20]</span>

<div align="center">⁂</div>

[^1]: https://www.markdownguide.org/tools/ghost/

[^2]: https://www.thememyblog.com/blog/ghost-cms-koenig-markdown-editor/

[^3]: https://github.com/MirisWisdom/MD2Ghost

[^4]: https://community.n8n.io/t/create-a-post-with-image-in-ghost/5878

[^5]: https://apidog.com/blog/claude-md/

[^6]: https://github.com/hesreallyhim/awesome-claude-code

[^7]: https://ghost.org/help/using-markdown/

[^8]: https://stackoverflow.com/questions/32147570/ghost-edit-markdown-output

[^9]: https://www.datawithjavi.com/building-a-ghost-cms-mcp-server/

[^10]: https://www.paulmduvall.com/claude-code-advanced-tips-using-commands-configuration-and-hooks/

[^11]: https://forum.ghost.org/t/posting-code-in-posts/54451

[^12]: https://www.reddit.com/r/ClaudeAI/comments/1hygpqh/trouble_with_markdown_links/

[^13]: https://dev.to/canro91/you-dont-need-markdown-to-blog-but-it-makes-it-easier-5255

[^14]: https://www.youtube.com/watch?v=Mp756uv9mkc

[^15]: https://www.devas.life/how-to-automate-development-journaling-with-claude-code/

[^16]: https://draft.dev/learn/using-ghost-as-a-headless-cms

[^17]: https://forum.ghost.org/t/how-to-write-ghost-posts-in-markdown-and-track-via-git/17836

[^18]: https://forum.ghost.org/t/best-way-to-migrate-markdown-to-ghost/44349

[^19]: https://forum.ghost.org/t/the-ultimate-guide-to-writing-publishing-with-markdown/42

[^20]: https://www.ichi.co.uk/blog/migrating-from-ghost-to-nextjs/converting-a-ghost-blog-to-nextjs-and-mdx-using-ai-and-javascript

