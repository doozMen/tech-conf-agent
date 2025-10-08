<img src="https://r2cdn.perplexity.ai/pplx-full-logo-primary-dark%402x.png" style="height:64px;margin-right:32px"/>

# Explain how to format code blocks correctly in Ghost blog posts

Code blocks in Ghost blog posts are formatted using standard Markdown fenced code blocks: three backticks (```) before and after the code. For syntax highlighting, specify the language right after the opening backticks. Ghost’s editor and published posts will automatically apply the correct formatting and color when a language is provided[web:21][web:25].

### Formatting Code Blocks

- To create a code block:

```
```javascript
function greet() {
    console.log("Hello, world!");
}
```

```
```

- Change `javascript` to the appropriate language—like `python`, `bash`, `json`, `html`, etc.—for highlighting[web:21][web:25].
- Code blocks can be added anywhere in the post; just ensure there are blank lines before and after the block for clean separation.
- For inline code (single word or phrase), use single backticks:

```
`let x = 10;`
```


### Syntax Highlighting Setup

- Ghost uses PrismJS for client-side syntax highlighting. For extra effects, inject Prism’s CSS/JS into your Ghost site via the Code Injection section under Settings.
- Once Prism is enabled, all code blocks marked with language identifiers will display with colors and style[web:21][web:25][web:27].


### Common Issues

- Avoid using single backticks for multi-line code (these are for inline code).
- Make sure not to paste code into “rich text” mode—always use the Markdown editor or markdown cards.
- Indentation matters only for preserving whitespace; fences are always preferred for technical posts[web:21][web:26].

This method ensures all code snippets are readable, well-formatted, and have syntax highlighting in Ghost blog posts[web:21][web:25][web:27].
<span style="display:none">[^1][^10][^2][^3][^4][^5][^6][^7][^8][^9]</span>

<div align="center">⁂</div>

[^1]: https://ghost.org/tutorials/code-snippets-in-ghost/

[^2]: https://forum.ghost.org/t/code-blocks-improvements/24253

[^3]: https://www.meziantou.net/show-code-blocks-on-your-blog.htm

[^4]: https://www.youtube.com/watch?v=Mp756uv9mkc

[^5]: https://www.reddit.com/r/aws/comments/xxyzh7/psa_how_to_insert_properly_formatted_code_blocks/

[^6]: https://www.youtube.com/watch?v=2X4PtfL1HKg

[^7]: https://meta.stackoverflow.com/questions/251361/how-do-i-format-my-code-blocks

[^8]: https://cyanbyfuchsia.wordpress.com/2014/01/02/add-code-syntax-highlighting-to-your-ghost-blogging-site/

[^9]: https://community.zapier.com/how-do-i-3/from-ghost-to-medium-scripts-not-formatted-as-code-snippet-11572

[^10]: https://www.markdownguide.org/tools/ghost/

