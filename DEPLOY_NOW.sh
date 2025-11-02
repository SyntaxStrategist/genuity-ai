#!/bin/bash

# 🚀 Deploy Genuity AI Landing Page to GitHub Pages
# Run this script to deploy in one command!

echo "🚀 Deploying Genuity AI to GitHub Pages..."
echo ""

# Check if in correct directory
if [ ! -d "docs" ]; then
    echo "❌ Error: docs folder not found. Are you in the GenuityAI directory?"
    exit 1
fi

# Check if git is initialized
if [ ! -d ".git" ]; then
    echo "❌ Error: Not a git repository. Initialize git first:"
    echo "   git init"
    echo "   git remote add origin https://github.com/SyntaxStrategist/genuity-ai.git"
    exit 1
fi

echo "📦 Adding docs folder to git..."
git add docs/

echo "💾 Committing changes..."
git commit -m "Add landing page for Genuity AI" || {
    echo "⚠️  No changes to commit (already committed?)"
}

echo "🌐 Pushing to GitHub..."
git push origin main || {
    echo ""
    echo "⚠️  Push failed. You may need to:"
    echo "   1. Set up your GitHub remote:"
    echo "      git remote add origin https://github.com/SyntaxStrategist/genuity-ai.git"
    echo ""
    echo "   2. Or if remote exists, try:"
    echo "      git push -u origin main"
    exit 1
}

echo ""
echo "✅ Deployment complete!"
echo ""
echo "📝 Next steps:"
echo "   1. Go to: https://github.com/SyntaxStrategist/genuity-ai"
echo "   2. Click: Settings → Pages"
echo "   3. Set Source: main branch, /docs folder"
echo "   4. Click Save"
echo "   5. Wait 2-3 minutes"
echo ""
echo "🌐 Your site will be live at:"
echo "   https://syntaxstrategist.github.io/genuity-ai"
echo ""
echo "🎉 Done!"

