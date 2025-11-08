#!/bin/bash

# Quick Fix for EC2 Docker Build Issue
# Run this on your EC2 instance to fix the numpy version problem

echo "🔧 PhishGuard AI - Quick Docker Build Fix"
echo "=========================================="

cd /home/ubuntu/PhishGuard-AI

# Pull latest fixes from GitHub
echo "📥 Pulling latest fixes from GitHub..."
git pull origin main

# Clean up failed containers and images
echo "🧹 Cleaning up failed Docker build..."
sudo docker-compose down
sudo docker system prune -f

# Remove problematic images
echo "🗑️ Removing old images..."
sudo docker rmi $(sudo docker images -q --filter "dangling=true") 2>/dev/null || echo "No dangling images to remove"

# Check if we have the flexibility requirements file
if [ -f "requirements_flexible.txt" ]; then
    echo "✅ Using flexible requirements file"
    cp requirements_flexible.txt requirements_deploy.txt
fi

# Build with no cache to force fresh download of compatible packages
echo "🔨 Building with fixed requirements..."
sudo docker-compose build --no-cache

# Start the service
echo "🚀 Starting PhishGuard AI..."
sudo docker-compose up -d

echo ""
echo "✅ Build fix completed!"
echo ""

# Check status
echo "📦 Container Status:"
sudo docker-compose ps

echo ""
echo "🌐 Your dashboard should now be available at:"
echo "   http://$(curl -s http://checkip.amazonaws.com):8080"
echo ""
echo "🔍 To verify the fix worked:"
echo "   curl -I http://localhost:8080/health"