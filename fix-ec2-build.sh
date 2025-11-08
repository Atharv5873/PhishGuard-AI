#!/bin/bash

# Quick Fix for EC2 Docker Build and Import Issues
# Run this on your EC2 instance to fix both numpy and import problems

echo "🔧 PhishGuard AI - Complete Docker Fix"
echo "======================================"

cd /home/ubuntu/PhishGuard-AI || exit 1

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

# Force remove the phishguard image to rebuild completely
echo "🔄 Removing existing PhishGuard images for clean rebuild..."
sudo docker rmi phishguard-ai-phishguard-ai 2>/dev/null || echo "Image not found"
sudo docker rmi $(sudo docker images | grep phishguard | awk '{print $3}') 2>/dev/null || echo "No PhishGuard images found"

# Build with no cache to force fresh download of compatible packages
echo "🔨 Building with all fixes applied..."
sudo docker-compose build --no-cache

# Start the service
echo "🚀 Starting PhishGuard AI..."
sudo docker-compose up -d

echo ""
echo "✅ Complete fix applied!"
echo ""

# Wait a moment for container to start
sleep 5

# Check status
echo "📦 Container Status:"
sudo docker-compose ps

echo ""
echo "🔍 Container Logs (checking for errors):"
sudo docker-compose logs --tail=10 phishguard-ai

echo ""
echo "🌐 Testing connectivity:"
echo "   Health check: curl -I http://localhost:8080/health"
curl -I http://localhost:8080/health 2>/dev/null || echo "   Service starting up..."

echo ""
echo "🎯 Your dashboard should now be available at:"
echo "   http://$(curl -s http://checkip.amazonaws.com):8080"
echo ""
echo "⚡ If container is still starting, wait 30 seconds and check:"
echo "   sudo docker-compose logs -f phishguard-ai"