#!/bin/bash

# Interactive test script for tech-conf-mcp server
# This script sends multiple JSON-RPC requests through a persistent stdio connection

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

# Start the MCP server in the background
mkfifo /tmp/mcp_input 2>/dev/null || true
mkfifo /tmp/mcp_output 2>/dev/null || true

# Clean up on exit
cleanup() {
    rm -f /tmp/mcp_input /tmp/mcp_output
    [ ! -z "$MCP_PID" ] && kill $MCP_PID 2>/dev/null
}
trap cleanup EXIT

# Start server
"$MCP_PATH" --log-level error < /tmp/mcp_input > /tmp/mcp_output 2>&1 &
MCP_PID=$!

# Give server time to start
sleep 1

# Check if server is running
if ! kill -0 $MCP_PID 2>/dev/null; then
    echo "ERROR: MCP server failed to start"
    exit 1
fi

echo "MCP server started (PID: $MCP_PID)"
echo ""

# Function to send request and read response
send_request() {
    local request="$1"
    local description="$2"
    
    echo "-----------------------------------"
    echo "Test: $description"
    echo "Request: $request"
    echo ""
    
    # Send request
    echo "$request" > /tmp/mcp_input
    
    # Read response (with timeout)
    local response
    response=$(timeout 5s head -n 1 /tmp/mcp_output 2>/dev/null || echo '{"error":"timeout"}')
    
    echo "Response: $response"
    echo ""
    
    # Validate response
    if echo "$response" | jq empty 2>/dev/null; then
        echo "STATUS: PASS - Valid JSON"
        echo "$response" | jq '.'
    else
        echo "STATUS: FAIL - Invalid JSON or error"
    fi
    echo ""
}

# Run tests
send_request \
    '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2024-11-05","capabilities":{},"clientInfo":{"name":"test-client","version":"1.0.0"}}}' \
    "Initialize MCP server"

send_request \
    '{"jsonrpc":"2.0","id":2,"method":"tools/list","params":{}}' \
    "List available tools"

send_request \
    '{"jsonrpc":"2.0","id":3,"method":"tools/call","params":{"name":"list_sessions","arguments":{}}}' \
    "List all sessions"

send_request \
    '{"jsonrpc":"2.0","id":4,"method":"tools/call","params":{"name":"search_sessions","arguments":{"query":"Swift"}}}' \
    "Search sessions for 'Swift'"

echo "========================================"
echo "Tests completed"
echo "========================================"
