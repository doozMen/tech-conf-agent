#!/bin/bash
# Tech Conference MCP Version Bump Script
# Usage: ./Scripts/bump-version.sh [new-version]
# Example: ./Scripts/bump-version.sh 1.1.0

set -e

if [ $# -eq 0 ]; then
    echo "❌ Error: Version number required"
    echo "Usage: $0 [new-version]"
    echo "Example: $0 1.1.0"
    exit 1
fi

NEW_VERSION="$1"
OLD_VERSION=$(grep 'version:' Sources/TechConfMCP/TechConfMCP.swift | sed 's/.*version: "\(.*\)".*/\1/')

echo "🔄 Tech Conference MCP Version Bump"
echo "===================================="
echo "Old version: $OLD_VERSION"
echo "New version: $NEW_VERSION"
echo ""

# Confirm before proceeding
read -p "Continue with version bump? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Version bump cancelled"
    exit 1
fi

echo "📝 Updating version references..."

# Update TechConfMCP.swift version
echo "  - Sources/TechConfMCP/TechConfMCP.swift"
sed -i '' "s/version: \"$OLD_VERSION\"/version: \"$NEW_VERSION\"/" Sources/TechConfMCP/TechConfMCP.swift

# Update CLAUDE.md version reference
if [ -f "CLAUDE.md" ]; then
    echo "  - CLAUDE.md"
    sed -i '' "s/v$OLD_VERSION/v$NEW_VERSION/g" CLAUDE.md
fi

# Update README.md version badges if present
if grep -q "$OLD_VERSION" README.md 2>/dev/null; then
    echo "  - README.md"
    sed -i '' "s/$OLD_VERSION/$NEW_VERSION/g" README.md
fi

# Update or create CHANGELOG.md
if [ ! -f "CHANGELOG.md" ]; then
    echo "  - Creating CHANGELOG.md"
    cat > CHANGELOG.md << EOF
# Changelog

All notable changes to Tech Conference MCP will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [$NEW_VERSION] - $(date +%Y-%m-%d)

### Added
- [Add your changes here]

### Changed
- [Add your changes here]

### Fixed
- [Add your changes here]

EOF
else
    echo "  - Updating CHANGELOG.md"
    # Create temporary file with new version section
    cat > /tmp/new_changelog_section << EOF
## [$NEW_VERSION] - $(date +%Y-%m-%d)

### Added
- [Add your changes here]

### Changed
- [Add your changes here]

### Fixed
- [Add your changes here]

EOF

    # Create new changelog by inserting new section at the top (after header)
    awk -v new_section="$(cat /tmp/new_changelog_section)" '
    NR==1,/^## \[/ {
        if (/^## \[/) {
            print new_section;
            print;
            found=1;
            next;
        }
        print;
        next;
    }
    { print }
    END { if (!found) print new_section }
    ' CHANGELOG.md > /tmp/updated_changelog.md

    # Replace original with updated version
    mv /tmp/updated_changelog.md CHANGELOG.md
    rm /tmp/new_changelog_section
fi

echo ""
echo "✅ Version bump complete!"
echo ""
echo "📋 Next steps:"
echo "1. Update the CHANGELOG.md with your actual changes"
echo "2. Review the changes:"
echo "   git diff"
echo "3. Commit the version bump:"
echo "   git add -A"
echo "   git commit -m \"chore: bump version to $NEW_VERSION\""
echo "4. Create a git tag:"
echo "   git tag v$NEW_VERSION"
echo "5. Push to remote:"
echo "   git push && git push --tags"
echo ""
echo "🎯 Files updated:"
echo "  - Sources/TechConfMCP/TechConfMCP.swift (version: $NEW_VERSION)"
if [ -f "CLAUDE.md" ]; then
    echo "  - CLAUDE.md (v$NEW_VERSION references)"
fi
if grep -q "$NEW_VERSION" README.md 2>/dev/null; then
    echo "  - README.md (version $NEW_VERSION)"
fi
echo "  - CHANGELOG.md (new section added)"
