<img src="https://r2cdn.perplexity.ai/pplx-full-logo-primary-dark%402x.png" style="height:64px;margin-right:32px"/>

# Show how to add language tags to code blocks for better readability

To enhance readability with syntax highlighting, always add a language tag after the opening triple backticks in your Markdown code blocks when publishing to Ghost.

### Example Code Block with Language Tag

For a Python example:

```
```

def hello():
print("Hello, world!")

```
```

This produces a colorized block specifically for Python code in Ghost’s editor and on the published page.[^1][^2][^3]

### Steps for Adding Language Tags

- Start with three backticks (```) on a new line.
- Immediately type the language name (such as `python`, `javascript`, `bash`, or `html`).
- Insert your code, then close the block with three backticks on a new line.
- Supported language tags include:
    - `javascript`
    - `python`
    - `html`
    - `json`
    - `shell` or `bash`
    - Many others per PrismJS and Ghost’s markdown support[web:21][web:7].


### Why Use Language Tags?

- Tags trigger syntax highlighting for better readability[web:21][web:7].
- Highlighted code blocks help distinguish commands, scripting, and configs at a glance[web:25].


### Code Block Formatting Table

| Language | Markdown Example | Syntax Highlighted? |
| :-- | :-- | :-- |
| Python | \`\`\`python ... \`\`\` | Yes[web:21][web:25] |
| JavaScript | \`\`\`javascript ... \`\`\` | Yes[web:21][web:25] |
| HTML | \`\`\`html ... \`\`\` | Yes[web:21] |
| Bash | \`\`\`bash ... \`\`\` | Yes[web:7] |
| None | \`\`\` ... \`\`\` (no tag) | No syntax highlighting |

Adding the appropriate language tag to the opening line of your code blocks will automatically give you better readability, clear colors, and semantic distinction in Ghost blog posts[web:21][web:25][web:7].

<div align="center">⁂</div>

[^1]: https://ghost.org/tutorials/code-snippets-in-ghost/

[^2]: https://www.youtube.com/watch?v=2X4PtfL1HKg

[^3]: https://www.markdownguide.org/tools/ghost/

