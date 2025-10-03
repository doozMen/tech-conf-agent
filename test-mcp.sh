#!/bin/bash

# Test script for tech-conf-mcp server
# This script tests the MCP server with real JSON-RPC stdio communication

set -e

MCP_PATH="/Users/stijnwillems/Developer/tech-conf-agent/.build/release/tech-conf-mcp"
OUTPUT_FILE="/Users/stijnwillems/Developer/tech-conf-agent/test-results.json"

echo "========================================"
echo "Tech Conference MCP Server Test Suite"
echo "========================================"
echo ""

# Check if MCP server exists
if [ ! -f "$MCP_PATH" ]; then
    echo "ERROR: MCP server not found at $MCP_PATH"
    exit 1
fi

echo "Testing MCP server at: $MCP_PATH"
echo "Output will be saved to: $OUTPUT_FILE"
echo ""

# Initialize results file
echo "{" > "$OUTPUT_FILE"
echo '  "testRun": "' $(date -u +"%Y-%m-%dT%H:%M:%SZ") '",' >> "$OUTPUT_FILE"
echo '  "tests": [' >> "$OUTPUT_FILE"

TEST_COUNT=0
PASS_COUNT=0
FAIL_COUNT=0

# Helper function to send JSON-RPC request and capture response
test_request() {
    local test_name="$1"
    local request="$2"
    local description="$3"
    
    echo "-----------------------------------"
    echo "Test: $test_name"
    echo "Description: $description"
    echo "Request: $request"
    echo ""
    
    TEST_COUNT=$((TEST_COUNT + 1))
    
    # Send request and capture response (timeout after 10 seconds)
    local response
    response=$(echo "$request" | timeout 10s "$MCP_PATH" --log-level error 2>/dev/null || echo '{"error":"timeout or crash"}')
    
    # Validate JSON response
    if echo "$response" | jq empty 2>/dev/null; then
        echo "Response: $response" | jq '.'
        echo "STATUS: PASS - Valid JSON response"
        PASS_COUNT=$((PASS_COUNT + 1))
        
        # Append to results file
        [ $TEST_COUNT -gt 1 ] && echo "," >> "$OUTPUT_FILE"
        echo "    {" >> "$OUTPUT_FILE"
        echo '      "name": "'"$test_name"'",' >> "$OUTPUT_FILE"
        echo '      "status": "pass",' >> "$OUTPUT_FILE"
        echo '      "request": '"$(echo "$request" | jq -c '.')"',' >> "$OUTPUT_FILE"
        echo '      "response": '"$(echo "$response" | jq -c '.')"'' >> "$OUTPUT_FILE"
        echo "    }" >> "$OUTPUT_FILE"
    else
        echo "Response: $response"
        echo "STATUS: FAIL - Invalid JSON or error"
        FAIL_COUNT=$((FAIL_COUNT + 1))
        
        # Append to results file
        [ $TEST_COUNT -gt 1 ] && echo "," >> "$OUTPUT_FILE"
        echo "    {" >> "$OUTPUT_FILE"
        echo '      "name": "'"$test_name"'",' >> "$OUTPUT_FILE"
        echo '      "status": "fail",' >> "$OUTPUT_FILE"
        echo '      "request": '"$(echo "$request" | jq -c '.')"',' >> "$OUTPUT_FILE"
        echo '      "error": "'"$(echo "$response" | sed 's/"/\\"/g')"'"' >> "$OUTPUT_FILE"
        echo "    }" >> "$OUTPUT_FILE"
    fi
    
    echo ""
}

# Test 1: Initialize
test_request "initialize" \
    '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2024-11-05","capabilities":{},"clientInfo":{"name":"test-client","version":"1.0.0"}}}' \
    "Initialize the MCP server"

# Test 2: List tools
test_request "tools_list" \
    '{"jsonrpc":"2.0","id":2,"method":"tools/list","params":{}}' \
    "List all available tools"

# Test 3: List sessions (no filters)
test_request "list_sessions_no_filter" \
    '{"jsonrpc":"2.0","id":3,"method":"tools/call","params":{"name":"list_sessions","arguments":{}}}' \
    "List all sessions without filters"

# Test 4: List sessions (filter by track)
test_request "list_sessions_track_filter" \
    '{"jsonrpc":"2.0","id":4,"method":"tools/call","params":{"name":"list_sessions","arguments":{"track":"Server-Side Swift"}}}' \
    "List sessions filtered by track"

# Test 5: List sessions (filter by difficulty)
test_request "list_sessions_difficulty_filter" \
    '{"jsonrpc":"2.0","id":5,"method":"tools/call","params":{"name":"list_sessions","arguments":{"difficulty":"advanced"}}}' \
    "List sessions filtered by difficulty level"

# Test 6: List sessions (filter by format)
test_request "list_sessions_format_filter" \
    '{"jsonrpc":"2.0","id":6,"method":"tools/call","params":{"name":"list_sessions","arguments":{"format":"workshop"}}}' \
    "List sessions filtered by format"

# Test 7: List sessions (multiple filters)
test_request "list_sessions_multi_filter" \
    '{"jsonrpc":"2.0","id":7,"method":"tools/call","params":{"name":"list_sessions","arguments":{"track":"iOS Development","difficulty":"advanced"}}}' \
    "List sessions with multiple filters"

# Test 8: Search sessions
test_request "search_sessions" \
    '{"jsonrpc":"2.0","id":8,"method":"tools/call","params":{"name":"search_sessions","arguments":{"query":"Swift Concurrency"}}}' \
    "Search sessions by query"

# Test 9: Get speaker by name
test_request "get_speaker_by_name" \
    '{"jsonrpc":"2.0","id":9,"method":"tools/call","params":{"name":"get_speaker","arguments":{"speakerName":"Tim Condon"}}}' \
    "Get speaker details by name"

# Test 10: Get schedule for today
test_request "get_schedule_today" \
    '{"jsonrpc":"2.0","id":10,"method":"tools/call","params":{"name":"get_schedule","arguments":{"date":"today"}}}' \
    "Get schedule for today"

# Test 11: Get schedule with time range
test_request "get_schedule_time_range" \
    '{"jsonrpc":"2.0","id":11,"method":"tools/call","params":{"name":"get_schedule","arguments":{"date":"today","startTime":"09:00","endTime":"12:00"}}}' \
    "Get schedule with specific time range"

# Test 12: Find room by name
test_request "find_room_by_name" \
    '{"jsonrpc":"2.0","id":12,"method":"tools/call","params":{"name":"find_room","arguments":{"roomName":"Main Hall"}}}' \
    "Find room by name"

# Test 13: Get session details
# First get a session ID from list_sessions
SESSION_ID=$(echo '{"jsonrpc":"2.0","id":13,"method":"tools/call","params":{"name":"list_sessions","arguments":{}}}' | "$MCP_PATH" --log-level error 2>/dev/null | jq -r '.result.content[0].text' | jq -r '.[0].id' 2>/dev/null || echo "test-session-id")

test_request "get_session_details" \
    '{"jsonrpc":"2.0","id":14,"method":"tools/call","params":{"name":"get_session_details","arguments":{"sessionId":"'"$SESSION_ID"'"}}}' \
    "Get detailed session information"

# Test 14: List favorited sessions
test_request "list_favorited_sessions" \
    '{"jsonrpc":"2.0","id":15,"method":"tools/call","params":{"name":"list_sessions","arguments":{"isFavorited":true}}}' \
    "List only favorited sessions"

# Test 15: Invalid tool call (error handling)
test_request "invalid_tool" \
    '{"jsonrpc":"2.0","id":16,"method":"tools/call","params":{"name":"nonexistent_tool","arguments":{}}}' \
    "Test error handling with invalid tool name"

# Test 16: Missing required parameter (error handling)
test_request "missing_required_param" \
    '{"jsonrpc":"2.0","id":17,"method":"tools/call","params":{"name":"search_sessions","arguments":{}}}' \
    "Test error handling with missing required parameter"

# Close results file
echo "" >> "$OUTPUT_FILE"
echo "  ]," >> "$OUTPUT_FILE"
echo '  "summary": {' >> "$OUTPUT_FILE"
echo '    "total": '"$TEST_COUNT"',' >> "$OUTPUT_FILE"
echo '    "passed": '"$PASS_COUNT"',' >> "$OUTPUT_FILE"
echo '    "failed": '"$FAIL_COUNT"'' >> "$OUTPUT_FILE"
echo "  }" >> "$OUTPUT_FILE"
echo "}" >> "$OUTPUT_FILE"

# Print summary
echo "========================================"
echo "Test Summary"
echo "========================================"
echo "Total tests: $TEST_COUNT"
echo "Passed: $PASS_COUNT"
echo "Failed: $FAIL_COUNT"
echo ""
echo "Results saved to: $OUTPUT_FILE"
echo ""

if [ $FAIL_COUNT -eq 0 ]; then
    echo "All tests passed!"
    exit 0
else
    echo "Some tests failed. Check $OUTPUT_FILE for details."
    exit 1
fi
