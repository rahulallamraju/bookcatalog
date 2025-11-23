#!/bin/bash

# Comprehensive testing script for Book Catalog API

BASE_URL="http://localhost:8080"
echo "🧪 Comprehensive Book Catalog API Testing"
echo "========================================"

# Check if server is running
check_server() {
    echo "🔍 Checking if server is running..."
    if curl -s "$BASE_URL/books" > /dev/null; then
        echo "✅ Server is running"
        return 0
    else
        echo "❌ Server is not running. Please start it with: mvn spring-boot:run"
        return 1
    fi
}

# Test basic functionality
test_basic_crud() {
    echo -e "\n📚 Testing Basic CRUD Operations"
    echo "--------------------------------"
    
    echo "1. GET all books (initial state):"
    curl -s "$BASE_URL/books" | jq . || curl -s "$BASE_URL/books"
    
    echo -e "\n2. POST new book:"
    curl -X POST "$BASE_URL/books" \
        -H 'Content-Type: application/json' \
        -d '{"title":"Test Driven Development","author":"Kent Beck"}' | jq . || curl -s "$BASE_URL/books"
    
    echo -e "\n3. GET all books (after adding):"
    curl -s "$BASE_URL/books" | jq . || curl -s "$BASE_URL/books"
}

# Test edge cases
test_edge_cases() {
    echo -e "\n🧩 Testing Edge Cases"
    echo "--------------------"
    
    echo "1. Empty title and author:"
    curl -X POST "$BASE_URL/books" \
        -H 'Content-Type: application/json' \
        -d '{"title":"","author":""}' -w "\nStatus: %{http_code}\n"
    
    echo -e "\n2. Missing fields:"
    curl -X POST "$BASE_URL/books" \
        -H 'Content-Type: application/json' \
        -d '{"title":"Only Title"}' -w "\nStatus: %{http_code}\n"
    
    echo -e "\n3. Extra fields:"
    curl -X POST "$BASE_URL/books" \
        -H 'Content-Type: application/json' \
        -d '{"title":"Book with ISBN","author":"Test Author","isbn":"123-456","year":2023}' -w "\nStatus: %{http_code}\n"
}

# Test invalid requests
test_invalid_requests() {
    echo -e "\n❌ Testing Invalid Requests"
    echo "---------------------------"
    
    echo "1. Malformed JSON:"
    curl -X POST "$BASE_URL/books" \
        -H 'Content-Type: application/json' \
        -d '{"title":"Broken JSON","author"}' -w "\nStatus: %{http_code}\n" 2>/dev/null
    
    echo -e "\n2. Wrong HTTP method:"
    curl -X DELETE "$BASE_URL/books" -w "\nStatus: %{http_code}\n" 2>/dev/null
    
    echo -e "\n3. Non-existent endpoint:"
    curl "$BASE_URL/nonexistent" -w "\nStatus: %{http_code}\n" 2>/dev/null
}

# Test actuator endpoints (if enabled)
test_actuator() {
    echo -e "\n🩺 Testing Actuator Endpoints"
    echo "-----------------------------"
    
    echo "1. Health check:"
    curl -s "$BASE_URL/actuator/health" | jq . || curl -s "$BASE_URL/actuator/health"
    
    echo -e "\n2. Application info:"
    curl -s "$BASE_URL/actuator/info" | jq . || curl -s "$BASE_URL/actuator/info"
    
    echo -e "\n3. Metrics (sample):"
    curl -s "$BASE_URL/actuator/metrics" | jq '.names[0:5]' || curl -s "$BASE_URL/actuator/metrics"
}

# Performance test
test_performance() {
    echo -e "\n⚡ Quick Performance Test"
    echo "------------------------"
    
    echo "Adding 10 books rapidly:"
    start_time=$(date +%s)
    for i in {1..10}; do
        curl -s -X POST "$BASE_URL/books" \
            -H 'Content-Type: application/json' \
            -d "{\"title\":\"Performance Book $i\",\"author\":\"Speed Test Author\"}" > /dev/null &
    done
    wait
    end_time=$(date +%s)
    duration=$((end_time - start_time))
    
    echo "✅ Added 10 books in ${duration} second(s)"
    
    echo "Current book count:"
    curl -s "$BASE_URL/books" | jq '. | length' || echo "Install jq for better output formatting"
}

# Main execution
main() {
    if check_server; then
        test_basic_crud
        test_edge_cases
        test_invalid_requests
        test_actuator
        test_performance
        
        echo -e "\n🎉 Testing completed!"
        echo "📊 Final book count:"
        curl -s "$BASE_URL/books" | jq '. | length' || curl -s "$BASE_URL/books" | grep -o '{"title"' | wc -l
    fi
}

main