# 🚀 Quick Start - Add AI in 3 Steps

## Step 1️⃣: Add Config.swift to Xcode

The file is created, but you need to add it to your Xcode project:

1. Open `GenuityAI.xcodeproj` in Xcode
2. Right-click on the **Services** folder
3. Select **"Add Files to GenuityAI..."**
4. Navigate to and select `GenuityAI/Services/Config.swift`
5. Make sure **"Copy items if needed"** is checked
6. Click **Add**

## Step 2️⃣: Get Your API Key

1. Visit: https://platform.openai.com/api-keys
2. Click **"Create new secret key"**
3. Copy the key (looks like `sk-proj-abc123...`)

## Step 3️⃣: Add Key to Config.swift

Open `Config.swift` and replace the placeholder:

```swift
static let openAIAPIKey = 
```

## ✅ You're Done!

Press `Cmd + R` to run and start chatting with real AI!

---

## 🎯 What Changed?

### Before (Simulated AI):
- Keyword matching ("happy" → generic response)
- No real intelligence
- Limited responses

### After (Real AI):
- ✅ Natural conversations with GPT-4o-mini
- ✅ Contextual, empathetic responses
- ✅ Remembers conversation history
- ✅ Smart mood & activity extraction
- ✅ Automatic fallback if API fails

---

## 💡 Test It Out

Try saying:
> "I'm feeling stressed about work. I've been working late every night and barely sleeping."

The AI will:
1. Respond empathetically
2. Ask a thoughtful follow-up question
3. Automatically extract mood score: **2** (negative)
4. Detect activities: **Work, Sleep**
5. Save to your history

---

## 💰 Cost

With GPT-4o-mini:
- **$0.001-0.003 per conversation**
- **~$2-3 for 1000 conversations**

Extremely affordable! 🎉

---

## ⚠️ Security Note

**NEVER commit your API key to Git!**

Your `.gitignore` is already configured to protect `Config.swift`.

For production apps, use environment variables (see `SETUP_AI.md` for details).

---

Need help? Check `SETUP_AI.md` for troubleshooting and advanced options!

