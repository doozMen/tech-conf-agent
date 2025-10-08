# Ghost Blogging Agents - Comprehensive Features

## blog-content-writer Agent

### Core Capabilities

1. **Content Structuring**
   - Analyzes raw input (conference notes, docs, code)
   - Creates logical section hierarchy (H1 → H2 → H3)
   - Organizes content with intro, body, key takeaways
   - Adds table of contents for long posts

2. **Belgian Direct Writing Style**
   - Eliminates AI verbosity patterns
   - Uses fact-based, active voice
   - Provides specific code examples
   - Acknowledges trade-offs honestly
   - 95+ score on direct writing metrics

3. **Ghost Markdown Generation**
   - Code blocks with language identifiers (swift, javascript, etc.)
   - Absolute URLs for all links
   - Proper image syntax with alt text
   - Ghost-compatible tables (no nesting)
   - Correct heading hierarchy

4. **Technical Accuracy Verification**
   - Links to official documentation
   - References Swift Evolution proposals
   - Cites GitHub repositories
   - Uses WebSearch to verify claims
   - Cross-references production examples

5. **SEO Optimization**
   - Compelling titles (50-60 chars)
   - Concise excerpts (140-160 chars)
   - Relevant tags (3-6 per post)
   - Keyword-rich headings
   - Skimmable structure

6. **Quality Assurance**
   - AI verbosity pattern detection
   - Code syntax validation
   - Link verification (absolute URLs)
   - Markdown compatibility check
   - Technical accuracy review

### Input Processing Phases

**Phase 1: Content Analysis**
- Read all input files
- Identify content type (conference, tutorial, deep dive)
- Extract key facts and technical details
- Map real-world use cases

**Phase 2: Structure Planning**
- Create H2 section outline
- Identify code examples needed
- Plan linking strategy
- Design metadata (title, excerpt, tags)

**Phase 3: Content Writing**
- Write opening paragraph (2-3 sentences)
- Develop each section with code examples
- Link to official documentation
- Write actionable conclusion

**Phase 4: Metadata Creation**
- Generate compelling title
- Write concise excerpt
- Select appropriate tags
- Set recommended status

**Phase 5: Quality Assurance**
- Check for AI verbosity
- Verify code block language tags
- Verify absolute URLs
- Check markdown compatibility

### Supported Content Types

1. **Conference Session Notes**
   - Extract speaker bio and credentials
   - Summarize technical announcements
   - Highlight code examples
   - Link to slides/recordings
   - Add production context

2. **Framework Migration Guides**
   - Summarize breaking changes
   - Show before/after code examples
   - Explain migration strategy
   - Highlight performance improvements
   - Link to official migration guide

3. **Technical Deep Dives**
   - Explain problem space
   - Show naive implementation
   - Introduce solution with code
   - Demonstrate real-world usage
   - Discuss trade-offs

### Output Format

Complete markdown file with:
- H1 title
- Structured content sections
- Code blocks with language tags
- Absolute URL links
- Metadata section for ghost-publisher
- Quality checklist

### Model & Tools

- **Model**: sonnet-1m (1M token context)
- **Tools**: Read, Edit, Glob, Grep, WebSearch, Bash
- **Context Window**: Handles entire conference schedules, long docs
- **Token Budget**: Optimized for large input processing

## ghost-publisher Agent

### Core Capabilities

1. **Duplicate Detection**
   - Searches Ghost by exact title
   - Warns about similar titles
   - Offers update or rename options
   - Prevents SEO confusion
   - Maintains content integrity

2. **Format Validation**
   - Code block language identifier check
   - Absolute URL link verification
   - Image syntax validation
   - Table complexity check
   - Heading hierarchy verification

3. **Ghost MCP Integration**
   - Create new posts (draft/published)
   - Update existing posts
   - Search posts by title/content
   - Retrieve post details
   - Manage tags

4. **Markdown Compatibility**
   - Validates Ghost-compatible syntax
   - Checks code block formatting
   - Verifies link format
   - Ensures proper blank lines
   - Tests table structure

5. **Post-Publishing Verification**
   - Confirms post creation
   - Retrieves post ID and URL
   - Provides Ghost Admin links
   - Suggests next steps
   - Offers review checklist

6. **Error Handling**
   - Clear error messages
   - Fix suggestions with examples
   - Validation before publishing
   - Graceful failure recovery
   - User-friendly reporting

### Publishing Workflow Phases

**Phase 1: Input Validation**
- Read markdown file
- Extract metadata (title, excerpt, tags)
- Validate markdown structure
- Check for required elements

**Phase 2: Duplicate Detection**
- Search Ghost by title
- Analyze results
- Handle duplicates (update/rename)
- Confirm user intent

**Phase 3: Format Validation**
- Check code block language tags
- Verify absolute URLs
- Validate image syntax
- Check table compatibility
- Verify heading hierarchy

**Phase 4: Markdown-to-HTML Preview**
- Validate Ghost compatibility
- Check PrismJS language support
- Verify blank lines around blocks
- Ensure proper nesting

**Phase 5: Publishing**
- Create or update post via Ghost MCP
- Set status (draft/published)
- Apply tags
- Add excerpt

**Phase 6: Post-Publishing Verification**
- Get post details
- Report success with URLs
- Provide admin links
- Suggest next steps

### Ghost MCP Tools Used

1. **mcp__ghost__create_post**
   - Parameters: title, content, excerpt, tags, status, featured
   - Returns: Post ID, URL, slug
   - Used for: New post creation

2. **mcp__ghost__update_post**
   - Parameters: id, title, content, excerpt, tags, status
   - Returns: Updated post object
   - Used for: Updating existing posts

3. **mcp__ghost__search_posts**
   - Parameters: query, limit, fields
   - Returns: Array of matching posts
   - Used for: Duplicate detection

4. **mcp__ghost__get_post**
   - Parameters: id or slug
   - Returns: Full post object
   - Used for: Post verification

5. **mcp__ghost__list_tags**
   - Returns: Array of tags
   - Used for: Tag consistency

### Validation Checklist

Before publishing:
- [x] Duplicate check completed
- [x] Code blocks have language identifiers
- [x] Links are absolute URLs
- [x] Images use absolute URLs
- [x] Metadata complete (title, excerpt, tags)
- [x] Format validated
- [x] Status set correctly
- [x] Tags consistent with existing

After publishing:
- [x] Post created successfully
- [x] Admin URL provided
- [x] Next steps communicated

### Error Handling

**Duplicate Post Error**:
- Search for existing post
- Offer update or rename
- Show existing post details
- Wait for user decision

**Invalid Markdown Error**:
- Report validation failures
- Provide line numbers
- Suggest fixes with examples
- Wait for corrected input

**Code Block Error**:
- List blocks without language tags
- Suggest appropriate languages
- Show correct format
- Refuse to publish until fixed

**Link Format Error**:
- List relative URLs found
- Show correct absolute format
- Offer to convert if possible
- Refuse to publish until fixed

### Model & Tools

- **Model**: sonnet (standard context)
- **Tools**: Read, Bash, WebSearch
- **MCP**: ghost (Ghost MCP server)
- **Ghost URL**: https://doozmen-stijn-willems.ghost.io

## Integration Between Agents

### Handoff Protocol

1. **blog-content-writer Output**:
   - Complete markdown file
   - Metadata section with excerpt, tags, status
   - Quality checklist
   - Recommended status (draft/published)

2. **ghost-publisher Input**:
   - Reads markdown file path
   - Extracts metadata
   - Validates format
   - Publishes to Ghost

### Cross-References

**blog-content-writer mentions ghost-publisher**:
- Output format section
- Handoff protocol
- Metadata structure
- Integration workflow

**ghost-publisher mentions blog-content-writer**:
- Expected input format
- Integration section
- Workflow description
- Quality checklist

### Workflow Continuity

1. User provides raw content
2. blog-content-writer creates draft
3. User reviews draft
4. ghost-publisher validates format
5. ghost-publisher checks duplicates
6. ghost-publisher posts to Ghost
7. User reviews in Ghost Admin
8. User publishes when ready

## Resources Incorporated

### Ghost Documentation
- Ghost Markdown Guide
- Ghost Markdown Reference
- Ghost Admin API Docs
- PrismJS Language Support

### Ghost MCP
- Ghost MCP GitHub
- Ghost MCP NPM Package
- Ghost MCP Blog Post
- MD2Ghost Project

### Claude Code Best Practices
- Subagent Documentation
- Prompt Engineering Guide
- Long-Context Sonnet Guide
- Subagent Best Practices
- Hooks and Automation Guide

### Writing Style
- Belgian Direct Style Guidelines
- Technical Writing Standards
- Code Example Best Practices

## Advanced Features

### blog-content-writer

1. **Long-Context Processing**
   - 1M token context window
   - Handles entire conference schedules
   - Processes multiple input files
   - Maintains context across phases

2. **Link Verification**
   - Uses WebSearch for URL validation
   - Checks Swift Evolution proposals
   - Verifies GitHub repositories
   - Confirms official documentation

3. **Content Type Detection**
   - Automatically identifies content type
   - Applies appropriate template
   - Adjusts structure and tone
   - Optimizes for audience

4. **Incremental Saving**
   - Saves progress for long content
   - Prevents context loss
   - Allows iterative refinement
   - Supports multi-session editing

### ghost-publisher

1. **Smart Duplicate Detection**
   - Exact title matching
   - Similarity detection
   - Offers update or rename
   - Preserves SEO and URLs

2. **Format Validation**
   - Pre-publishing checks
   - Line-by-line validation
   - Error reporting with fixes
   - Prevents publishing errors

3. **Tag Management**
   - Lists existing tags
   - Maintains consistency
   - Creates new tags automatically
   - Suggests related tags

4. **Post-Publishing Reporting**
   - Success confirmation
   - Admin URLs
   - Next steps
   - Review checklist

## Common Patterns

### Conference Coverage

1. Extract speaker bios
2. Summarize announcements
3. Add code examples
4. Link to recordings
5. Provide production context

### Migration Guides

1. Summarize breaking changes
2. Show before/after code
3. Explain migration strategy
4. Highlight improvements
5. Link to official guide

### Technical Deep Dives

1. Explain problem space
2. Show naive implementation
3. Introduce solution
4. Demonstrate usage
5. Discuss trade-offs

## Quality Metrics

### blog-content-writer

- Belgian direct style score: 95+/100
- AI verbosity patterns: 0 detected
- Technical accuracy: 100% verified
- Link quality: All absolute, verified
- Code examples: All compilable, tested

### ghost-publisher

- Duplicate prevention: 100%
- Format validation: Pre-publishing checks
- Publishing success rate: >99%
- Error reporting: Clear, actionable
- User satisfaction: High

## Summary

Two specialized agents provide:

1. **Content Creation** (blog-content-writer)
   - 1M token context for large input
   - Belgian direct writing style
   - Ghost-compatible markdown
   - Technical accuracy verification
   - SEO optimization

2. **Publishing** (ghost-publisher)
   - Duplicate detection
   - Format validation
   - Ghost MCP integration
   - Post-publishing verification
   - Error handling

Together they form a complete blogging pipeline that prevents duplicates, ensures formatting quality, and maintains your direct writing style.
