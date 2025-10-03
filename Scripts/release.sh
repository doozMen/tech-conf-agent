#!/bin/bash
# Tech Conference MCP Release Script

set -e

echo "🚀 Tech Conference MCP Release Script"
echo "======================================"

# Remove existing installation if present
if [ -f "$HOME/.swiftpm/bin/tech-conf-mcp" ]; then
    echo "Removing existing tech-conf-mcp installation..."
    rm -f "$HOME/.swiftpm/bin/tech-conf-mcp"
fi

# Install using experimental-install with xcrun (builds automatically in release mode)
echo "Installing Tech Conference MCP to ~/.swiftpm/bin..."
xcrun swift package experimental-install --product tech-conf-mcp

# Verify installation
echo "Verifying installation..."
if command -v tech-conf-mcp &> /dev/null; then
    echo "✅ tech-conf-mcp installed successfully"
    tech-conf-mcp --version
else
    echo "❌ Installation failed"
    exit 1
fi

# Extract version from TechConfMCP.swift to keep it synchronized
VERSION=$(grep 'version:' Sources/TechConfMCP/TechConfMCP.swift | sed 's/.*version: "\(.*\)".*/\1/')

# Create updated MCP configuration example with absolute paths
cat > tech-conf-mcp-config.json << 'EOF'
{
  "mcpServers": {
    "tech-conf": {
      "command": "/Users/$USER/.swiftpm/bin/tech-conf-mcp",
      "args": ["--log-level", "info"],
      "env": {
        "PATH": "$HOME/.swiftpm/bin:/usr/local/bin:/usr/bin:/bin"
      }
    }
  }
}
EOF

# Replace $USER with actual username
sed -i '' "s/\$USER/$USER/g" tech-conf-mcp-config.json

echo ""
echo "✅ Release complete!"
echo ""
echo "📋 Next steps:"
echo "1. Add this configuration to your Claude Desktop MCP settings:"
echo "   Location: ~/Library/Application Support/Claude/claude_desktop_config.json"
echo ""
echo "   Or manually merge the configuration:"
echo ""
cat tech-conf-mcp-config.json
echo ""
echo "2. Restart Claude Desktop to load the MCP server"
echo "3. Test with natural language queries like:"
echo "   - 'List all conference sessions'"
echo "   - 'Find sessions about Swift concurrency'"
echo "   - 'Show me Adam Fowler's speaker profile'"
echo ""
echo "🎯 You now have 6 MCP tools available for conference navigation (v${VERSION})!"
echo ""
echo "📚 Documentation:"
echo "   - README.md - Project overview"
echo "   - USAGE.md - Tool reference and examples"
echo "   - INSTALLATION.md - Detailed setup guide"
