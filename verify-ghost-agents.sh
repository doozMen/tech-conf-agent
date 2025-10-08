#!/bin/bash
# Verify Ghost blogging agents are correctly installed

echo "=== Ghost Blogging Agents Verification ==="
echo ""

# Check agent files
echo "1. Checking agent files..."
if [ -f "$HOME/.claude/agents/blog-content-writer.md" ]; then
    echo "   ✅ blog-content-writer.md found ($(ls -lh "$HOME/.claude/agents/blog-content-writer.md" | awk '{print $5}'))"
else
    echo "   ❌ blog-content-writer.md NOT FOUND"
fi

if [ -f "$HOME/.claude/agents/ghost-publisher.md" ]; then
    echo "   ✅ ghost-publisher.md found ($(ls -lh "$HOME/.claude/agents/ghost-publisher.md" | awk '{print $5}'))"
else
    echo "   ❌ ghost-publisher.md NOT FOUND"
fi

echo ""

# Check frontmatter
echo "2. Checking frontmatter..."
echo ""
echo "   blog-content-writer:"
head -6 "$HOME/.claude/agents/blog-content-writer.md" | grep -E "^(name|description|model|tools):" | sed 's/^/      /'

echo ""
echo "   ghost-publisher:"
head -7 "$HOME/.claude/agents/ghost-publisher.md" | grep -E "^(name|description|model|tools|mcp):" | sed 's/^/      /'

echo ""

# Check Ghost MCP connection (if Claude CLI available)
echo "3. Checking Ghost MCP connection..."
if command -v claude &> /dev/null; then
    if claude mcp list 2>/dev/null | grep -q "ghost"; then
        echo "   ✅ Ghost MCP connected"
    else
        echo "   ⚠️  Ghost MCP not found in MCP list"
        echo "      Run: claude mcp add ghost npx ghost-mcp"
    fi
else
    echo "   ⚠️  Claude CLI not available (this is optional)"
fi

echo ""

# Summary
echo "=== Summary ==="
echo ""
echo "Agent files:"
echo "  - blog-content-writer.md: $HOME/.claude/agents/blog-content-writer.md"
echo "  - ghost-publisher.md: $HOME/.claude/agents/ghost-publisher.md"
echo ""
echo "Documentation:"
echo "  - GHOST-AGENTS-SUMMARY.md: Quick overview"
echo "  - GHOST-AGENTS-QUICK-REFERENCE.md: Usage reference"
echo "  - GHOST-AGENTS-FEATURES.md: Comprehensive features"
echo ""
echo "Usage:"
echo "  1. Create content: claude agent blog-content-writer \"Create post from docs/notes.md\""
echo "  2. Publish to Ghost: claude agent ghost-publisher \"Publish /tmp/blog-post-draft.md\""
echo ""
echo "Ghost Admin: https://doozmen-stijn-willems.ghost.io/ghost/#/dashboard"
echo ""
