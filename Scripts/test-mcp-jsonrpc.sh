#!/bin/bash
# Tech Conference MCP - JSON-RPC Testing Script
# Tests the MCP server using `swift run` with JSON-RPC protocol (NOT installed binary)
# This ensures we're always testing the latest source code

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test counters
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# Helper functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[✅ PASS]${NC} $1"
    ((PASSED_TESTS++))
    ((TOTAL_TESTS++))
}

log_error() {
    echo -e "${RED}[❌ FAIL]${NC} $1"
    ((FAILED_TESTS++))
    ((TOTAL_TESTS++))
}

log_test() {
    echo -e "${YELLOW}[TEST]${NC} $1"
}

# Function to send JSON-RPC request
send_jsonrpc() {
    local request="$1"
    local description="$2"

    log_test "$description"

    # Send request via swift run (uses latest source code, NOT installed binary)
    local response=$(echo "$request" | xcrun swift run tech-conf-mcp 2>/dev/null | tail -1)

    # Check if response is valid JSON
    if echo "$response" | jq . >/dev/null 2>&1; then
        # Check for JSON-RPC error
        if echo "$response" | jq -e '.error' >/dev/null 2>&1; then
            local error_message=$(echo "$response" | jq -r '.error.message')
            log_error "$description - Error: $error_message"
            return 1
        else
            log_success "$description"
            return 0
        fi
    else
        log_error "$description - Invalid JSON response"
        return 1
    fi
}

# Print header
echo "╔══════════════════════════════════════════════════════════════════╗"
echo "║        Tech Conference MCP - JSON-RPC Test Suite                ║"
echo "║        Testing with: xcrun swift run tech-conf-mcp              ║"
echo "╚══════════════════════════════════════════════════════════════════╝"
echo ""

log_info "⚠️  CRITICAL: This tests the CURRENT SOURCE CODE, not the installed binary"
log_info "Use Scripts/release.sh to install the latest version"
echo ""

# Test 1: Initialize MCP server (tools/list)
send_jsonrpc \
    '{"jsonrpc":"2.0","id":1,"method":"tools/list"}' \
    "Test 1: List available MCP tools"

# Test 2: list_sessions (all sessions)
send_jsonrpc \
    '{"jsonrpc":"2.0","id":2,"method":"tools/call","params":{"name":"list_sessions","arguments":{}}}' \
    "Test 2: List all conference sessions"

# Test 3: list_sessions with filters (track filter)
send_jsonrpc \
    '{"jsonrpc":"2.0","id":3,"method":"tools/call","params":{"name":"list_sessions","arguments":{"track":"Server-Side Swift"}}}' \
    "Test 3: List sessions by track (Server-Side Swift)"

# Test 4: search_sessions
send_jsonrpc \
    '{"jsonrpc":"2.0","id":4,"method":"tools/call","params":{"name":"search_sessions","arguments":{"query":"Swift"}}}' \
    "Test 4: Search sessions for 'Swift'"

# Test 5: get_speaker
send_jsonrpc \
    '{"jsonrpc":"2.0","id":5,"method":"tools/call","params":{"name":"get_speaker","arguments":{"speakerName":"Adam Fowler"}}}' \
    "Test 5: Get speaker details (Adam Fowler)"

# Test 6: get_speaker (another speaker)
send_jsonrpc \
    '{"jsonrpc":"2.0","id":6,"method":"tools/call","params":{"name":"get_speaker","arguments":{"speakerName":"Tim Condon"}}}' \
    "Test 6: Get speaker details (Tim Condon)"

# Test 7: get_schedule (with date)
send_jsonrpc \
    '{"jsonrpc":"2.0","id":7,"method":"tools/call","params":{"name":"get_schedule","arguments":{"date":"2025-10-15"}}}' \
    "Test 7: Get schedule for specific date"

# Test 8: find_room
send_jsonrpc \
    '{"jsonrpc":"2.0","id":8,"method":"tools/call","params":{"name":"find_room","arguments":{"venueName":"Main Hall"}}}' \
    "Test 8: Find room/venue information"

# Test 9: get_session_details (requires session ID - this may fail without real data)
send_jsonrpc \
    '{"jsonrpc":"2.0","id":9,"method":"tools/call","params":{"name":"get_session_details","arguments":{"sessionId":"session-001"}}}' \
    "Test 9: Get session details by ID"

# Test 10: list_sessions with difficulty filter
send_jsonrpc \
    '{"jsonrpc":"2.0","id":10,"method":"tools/call","params":{"name":"list_sessions","arguments":{"difficultyLevel":"intermediate"}}}' \
    "Test 10: List intermediate difficulty sessions"

# Test 11: list_sessions with format filter
send_jsonrpc \
    '{"jsonrpc":"2.0","id":11,"method":"tools/call","params":{"name":"list_sessions","arguments":{"format":"workshop"}}}' \
    "Test 11: List workshop format sessions"

# Test 12: search_sessions with specific term
send_jsonrpc \
    '{"jsonrpc":"2.0","id":12,"method":"tools/call","params":{"name":"search_sessions","arguments":{"query":"concurrency"}}}' \
    "Test 12: Search sessions for 'concurrency'"

echo ""
echo "╔══════════════════════════════════════════════════════════════════╗"
echo "║                       Test Results Summary                       ║"
echo "╚══════════════════════════════════════════════════════════════════╝"
echo ""
echo "Total Tests:  $TOTAL_TESTS"
echo "✅ Passed:    $PASSED_TESTS"
echo "❌ Failed:    $FAILED_TESTS"
echo ""

if [ $FAILED_TESTS -eq 0 ]; then
    echo -e "${GREEN}🎉 All tests passed!${NC}"
    echo ""
    log_info "The MCP server is working correctly with JSON-RPC protocol"
    log_info "Ready to install with: ./Scripts/release.sh"
    exit 0
else
    echo -e "${RED}❌ Some tests failed${NC}"
    echo ""
    log_info "Check the error messages above for details"
    log_info "The server may need fixes before release"
    exit 1
fi
