#!/bin/bash

echo "🚀 Deploying Genuity AI Backend to Vercel..."
echo ""
echo "This will:"
echo "1. Install Vercel CLI (if needed)"
echo "2. Deploy your backend"
echo "3. Set up environment variables"
echo ""
read -p "Press Enter to continue..."

# Check if vercel is installed
if ! command -v vercel &> /dev/null; then
    echo "📦 Installing Vercel CLI..."
    npm install -g vercel
fi

# Deploy
echo ""
echo "🚀 Starting deployment..."
echo "⚠️  When prompted, answer:"
echo "   - Set up and deploy? → y"
echo "   - Which scope? → (your account)"
echo "   - Link to existing project? → n"
echo "   - Project name? → genuity-ai-backend"
echo "   - Directory? → ./ (just press Enter)"
echo "   - Override settings? → n"
echo ""
read -p "Ready? Press Enter to deploy..."

vercel

echo ""
echo "✅ Deployment started!"
echo ""
echo "NOW run this command to add your API key:"
echo ""
echo "   vercel env add OPENAI_API_KEY"
echo ""
echo "When it asks:"
echo "1. Paste your sk-proj-... key"
echo "2. Choose: Production"
echo ""
echo "Then run: vercel --prod"
echo ""

