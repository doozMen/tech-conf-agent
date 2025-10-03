# Security Policy

## Supported Versions

The following versions of Tech Conference MCP Server are currently supported with security updates:

| Version | Supported          |
| ------- | ------------------ |
| 1.x.x   | :white_check_mark: |
| < 1.0   | :x:                |

## Reporting a Vulnerability

We take the security of Tech Conference MCP Server seriously. If you discover a security vulnerability, please follow these steps:

### 1. Do Not Disclose Publicly

Please **do not** create a public GitHub issue for security vulnerabilities. This helps protect users while we work on a fix.

### 2. Report via GitHub Security Advisories

The preferred method for reporting vulnerabilities is through GitHub's Security Advisory feature:

1. Navigate to the repository's **Security** tab
2. Click **Report a vulnerability**
3. Fill out the advisory form with details

### 3. Alternative Reporting Method

If you cannot use GitHub Security Advisories, please email the project maintainers with:

- **Subject**: "Security Vulnerability Report - Tech Conference MCP"
- **Details**: Description of the vulnerability, steps to reproduce, and potential impact

### What to Include in Your Report

A good security report should include:

- **Type of vulnerability** (e.g., SQL injection, authentication bypass, data exposure)
- **Affected component(s)** (e.g., database queries, MCP tool handlers, data sync)
- **Steps to reproduce** the vulnerability
- **Potential impact** (e.g., data breach, unauthorized access, denial of service)
- **Suggested fix** (if you have one)
- **Your contact information** for follow-up questions

### Example Report

```
Type: SQL Injection
Component: ConferenceQueries.searchSessions()
Swift Version: 6.2
Platform: macOS 15.0

Description:
The searchSessions() method may be vulnerable to SQL injection when
user-provided search queries are not properly sanitized.

Steps to Reproduce:
1. Call search_sessions tool with query: "'; DROP TABLE session; --"
2. Observe database behavior

Impact:
Potential for unauthorized database manipulation or data exfiltration.

Suggested Fix:
Use parameterized queries with StatementArguments for all user inputs.
```

## Response Timeline

- **Initial Response**: Within 48 hours of receiving your report
- **Triage**: Within 1 week, we will confirm the vulnerability and assess severity
- **Fix Development**: Depends on severity (critical: 1-2 weeks, high: 2-4 weeks)
- **Disclosure**: Coordinated disclosure after fix is released

## Security Update Process

1. **Assessment**: Evaluate severity using CVSS scoring
2. **Development**: Create a fix in a private branch
3. **Testing**: Comprehensive testing of the security patch
4. **Release**: Publish patched version to GitHub and notify users
5. **Advisory**: Publish security advisory with details and mitigation steps

## Security Best Practices for Users

### Database Security

- **File Permissions**: Ensure your conference database has appropriate file permissions:
  ```bash
  chmod 600 ~/.tech-conf-mcp/conferences.db
  ```

- **Backup**: Regularly backup your conference data:
  ```bash
  cp ~/.tech-conf-mcp/conferences.db ~/.tech-conf-mcp/backups/conferences-$(date +%Y%m%d).db
  ```

### Configuration Security

- **Local Settings**: Never commit `.claude/settings.local.json` to version control
- **API Keys**: If adding external sync features, use environment variables for API keys
- **File Paths**: Use absolute paths and avoid exposing sensitive directory structures

### Running the Server

- **Minimal Permissions**: Run the MCP server with minimal required permissions
- **Logging**: Review logs regularly for suspicious activity:
  ```bash
  tech-conf-mcp --log-level info 2>&1 | tee tech-conf.log
  ```

- **Updates**: Keep the server updated to the latest version:
  ```bash
  swift package update
  swift package experimental-install
  ```

## Known Security Considerations

### Current Limitations

1. **Local-Only Data**: Currently, all data is stored locally in SQLite. No remote sync is implemented.
2. **No Authentication**: The MCP server assumes trusted communication with Claude Desktop via stdio.
3. **No Input Validation**: User queries are passed through with minimal sanitization (mitigated by parameterized queries).

### Future Security Enhancements

- [ ] Input validation and sanitization for all tool parameters
- [ ] Rate limiting for tool calls to prevent abuse
- [ ] Audit logging for all database operations
- [ ] Encrypted database storage option
- [ ] OAuth integration for external data sync (TechConfSync module)

## Vulnerability Disclosure Policy

Once a security issue is resolved:

1. **Fixed Version**: We release a patched version immediately
2. **Security Advisory**: Publish details in GitHub Security Advisories
3. **Credit**: Security researchers who report vulnerabilities responsibly will be credited (if desired)
4. **Notification**: Users are notified via GitHub releases and README updates

## Questions?

If you have questions about this security policy, please open a GitHub issue with the label `security-question` (for non-sensitive questions) or contact the maintainers directly.

---

**Last Updated**: 2025-10-03
**Policy Version**: 1.0
