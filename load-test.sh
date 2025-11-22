#!/bin/bash

# Simple load testing script for the Book Catalog API

echo "🚀 Starting load test for Book Catalog API..."

BASE_URL="http://localhost:8080"
CONCURRENT_REQUESTS=10
TOTAL_REQUESTS=100

# Function to make a POST request
make_post_request() {
    local id=$1
    curl -s -X POST "$BASE_URL/books" \
        -H 'Content-Type: application/json' \
        -d "{\"title\":\"Load Test Book $id\",\"author\":\"Test Author $id\"}" \
        > /dev/null
    echo "POST request $id completed"
}

# Function to make a GET request
make_get_request() {
    local id=$1
    curl -s "$BASE_URL/books" > /dev/null
    echo "GET request $id completed"
}

echo "📊 Testing GET requests..."
start_time=$(date +%s)

# Run concurrent GET requests
for i in $(seq 1 $TOTAL_REQUESTS); do
    make_get_request $i &
    if [ $((i % CONCURRENT_REQUESTS)) -eq 0 ]; then
        wait  # Wait for current batch to complete
    fi
done
wait  # Wait for remaining requests

end_time=$(date +%s)
duration=$((end_time - start_time))
echo "✅ GET requests completed in ${duration} seconds"

echo "📝 Testing POST requests..."
start_time=$(date +%s)

# Run concurrent POST requests
for i in $(seq 1 50); do
    make_post_request $i &
    if [ $((i % CONCURRENT_REQUESTS)) -eq 0 ]; then
        wait  # Wait for current batch to complete
    fi
done
wait  # Wait for remaining requests

end_time=$(date +%s)
duration=$((end_time - start_time))
echo "✅ POST requests completed in ${duration} seconds"

echo "📋 Final book count:"
curl -s "$BASE_URL/books" | jq '. | length' || echo "jq not installed, raw response:"
curl -s "$BASE_URL/books"

echo "🎉 Load testing completed!"