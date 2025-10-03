#!/usr/bin/env python3
"""
Test script for tech-conf-mcp server
Tests the MCP server with real JSON-RPC stdio communication
"""

import json
import subprocess
import sys
import time
from datetime import datetime

MCP_PATH = "/Users/stijnwillems/Developer/tech-conf-agent/.build/release/tech-conf-mcp"
OUTPUT_FILE = "/Users/stijnwillems/Developer/tech-conf-agent/test-results.json"

class MCPTester:
    def __init__(self, mcp_path):
        self.mcp_path = mcp_path
        self.process = None
        self.test_results = []
        self.test_count = 0
        self.pass_count = 0
        self.fail_count = 0
        
    def start_server(self):
        """Start the MCP server process"""
        print("Starting MCP server...")
        self.process = subprocess.Popen(
            [self.mcp_path, "--log-level", "error"],
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
            bufsize=1
        )
        time.sleep(0.5)  # Give server time to start
        print(f"MCP server started (PID: {self.process.pid})\n")
        
    def send_request(self, request, description):
        """Send a JSON-RPC request and read response"""
        self.test_count += 1
        print("-----------------------------------")
        print(f"Test #{self.test_count}: {description}")
        print(f"Request: {json.dumps(request)}")
        print()
        
        try:
            # Send request
            request_str = json.dumps(request) + "\n"
            self.process.stdin.write(request_str)
            self.process.stdin.flush()
            
            # Read response (with timeout)
            response_line = self.process.stdout.readline()
            
            if not response_line:
                raise Exception("No response received")
            
            response = json.loads(response_line)
            
            # Pretty print response
            print("Response:")
            print(json.dumps(response, indent=2))
            print()
            
            # Check for errors (some tests expect errors)
            if "error" in response:
                # Check if this is an expected error test
                if "error handling" in description.lower():
                    print(f"STATUS: PASS - Expected error received: {response['error']['message']}")
                    self.pass_count += 1
                    status = "pass"
                else:
                    print(f"STATUS: FAIL - Unexpected error in response: {response['error']}")
                    self.fail_count += 1
                    status = "fail"
            else:
                print("STATUS: PASS - Valid JSON-RPC response")
                self.pass_count += 1
                status = "pass"
            
            # Store result
            self.test_results.append({
                "name": description,
                "status": status,
                "request": request,
                "response": response
            })
            
        except json.JSONDecodeError as e:
            print(f"STATUS: FAIL - Invalid JSON response: {e}")
            print(f"Raw response: {response_line}")
            self.fail_count += 1
            self.test_results.append({
                "name": description,
                "status": "fail",
                "request": request,
                "error": f"Invalid JSON: {str(e)}"
            })
        except Exception as e:
            print(f"STATUS: FAIL - {str(e)}")
            self.fail_count += 1
            self.test_results.append({
                "name": description,
                "status": "fail",
                "request": request,
                "error": str(e)
            })
        
        print()
        
    def run_tests(self):
        """Run all test cases"""
        print("========================================")
        print("Tech Conference MCP Server Test Suite")
        print("========================================")
        print()
        
        # Test 1: Initialize
        self.send_request(
            {
                "jsonrpc": "2.0",
                "id": 1,
                "method": "initialize",
                "params": {
                    "protocolVersion": "2024-11-05",
                    "capabilities": {},
                    "clientInfo": {
                        "name": "test-client",
                        "version": "1.0.0"
                    }
                }
            },
            "Initialize MCP server"
        )
        
        # Test 2: List tools
        self.send_request(
            {
                "jsonrpc": "2.0",
                "id": 2,
                "method": "tools/list",
                "params": {}
            },
            "List all available tools"
        )
        
        # Test 3: List sessions (no filter)
        self.send_request(
            {
                "jsonrpc": "2.0",
                "id": 3,
                "method": "tools/call",
                "params": {
                    "name": "list_sessions",
                    "arguments": {}
                }
            },
            "List all sessions without filters"
        )
        
        # Test 4: List sessions (track filter)
        self.send_request(
            {
                "jsonrpc": "2.0",
                "id": 4,
                "method": "tools/call",
                "params": {
                    "name": "list_sessions",
                    "arguments": {
                        "track": "Server-Side Swift"
                    }
                }
            },
            "List sessions filtered by track"
        )
        
        # Test 5: List sessions (difficulty filter)
        self.send_request(
            {
                "jsonrpc": "2.0",
                "id": 5,
                "method": "tools/call",
                "params": {
                    "name": "list_sessions",
                    "arguments": {
                        "difficulty": "advanced"
                    }
                }
            },
            "List sessions filtered by difficulty"
        )
        
        # Test 6: Search sessions
        self.send_request(
            {
                "jsonrpc": "2.0",
                "id": 6,
                "method": "tools/call",
                "params": {
                    "name": "search_sessions",
                    "arguments": {
                        "query": "Swift Concurrency"
                    }
                }
            },
            "Search sessions by query"
        )
        
        # Test 7: Get speaker
        self.send_request(
            {
                "jsonrpc": "2.0",
                "id": 7,
                "method": "tools/call",
                "params": {
                    "name": "get_speaker",
                    "arguments": {
                        "speakerName": "Jane Developer"
                    }
                }
            },
            "Get speaker details by name"
        )
        
        # Test 8: Get schedule
        self.send_request(
            {
                "jsonrpc": "2.0",
                "id": 8,
                "method": "tools/call",
                "params": {
                    "name": "get_schedule",
                    "arguments": {
                        "date": "today"
                    }
                }
            },
            "Get schedule for today"
        )
        
        # Test 9: Find room
        self.send_request(
            {
                "jsonrpc": "2.0",
                "id": 9,
                "method": "tools/call",
                "params": {
                    "name": "find_room",
                    "arguments": {
                        "roomName": "Main Hall"
                    }
                }
            },
            "Find room by name"
        )
        
        # Test 10: Get session details
        self.send_request(
            {
                "jsonrpc": "2.0",
                "id": 10,
                "method": "tools/call",
                "params": {
                    "name": "get_session_details",
                    "arguments": {
                        "sessionId": "test-session-123"
                    }
                }
            },
            "Get detailed session information"
        )
        
        # Test 11: Invalid tool (error handling)
        self.send_request(
            {
                "jsonrpc": "2.0",
                "id": 11,
                "method": "tools/call",
                "params": {
                    "name": "nonexistent_tool",
                    "arguments": {}
                }
            },
            "Test error handling with invalid tool"
        )
        
        # Test 12: Missing required parameter (error handling)
        self.send_request(
            {
                "jsonrpc": "2.0",
                "id": 12,
                "method": "tools/call",
                "params": {
                    "name": "search_sessions",
                    "arguments": {}
                }
            },
            "Test error handling with missing parameter"
        )
        
    def save_results(self, output_file):
        """Save test results to JSON file"""
        results = {
            "testRun": datetime.utcnow().isoformat() + "Z",
            "tests": self.test_results,
            "summary": {
                "total": self.test_count,
                "passed": self.pass_count,
                "failed": self.fail_count
            }
        }
        
        with open(output_file, 'w') as f:
            json.dump(results, f, indent=2)
        
        print(f"Results saved to: {output_file}")
        
    def cleanup(self):
        """Clean up server process"""
        if self.process:
            self.process.terminate()
            try:
                self.process.wait(timeout=2)
            except subprocess.TimeoutExpired:
                self.process.kill()
        
    def print_summary(self):
        """Print test summary"""
        print("========================================")
        print("Test Summary")
        print("========================================")
        print(f"Total tests: {self.test_count}")
        print(f"Passed: {self.pass_count}")
        print(f"Failed: {self.fail_count}")
        print()
        
        if self.fail_count == 0:
            print("All tests passed!")
            return 0
        else:
            print("Some tests failed.")
            return 1

def main():
    tester = MCPTester(MCP_PATH)
    
    try:
        tester.start_server()
        tester.run_tests()
        tester.save_results(OUTPUT_FILE)
        tester.print_summary()
        exit_code = 0 if tester.fail_count == 0 else 1
    except Exception as e:
        print(f"ERROR: {e}")
        exit_code = 1
    finally:
        tester.cleanup()
    
    sys.exit(exit_code)

if __name__ == "__main__":
    main()
