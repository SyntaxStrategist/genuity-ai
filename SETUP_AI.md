# 🤖 Adding AI to Genuity AI

## Quick Setup Guide

### Step 1: Get Your OpenAI API Key

1. Go to https://platform.openai.com/
2. Sign up or log in
3. Go to **API Keys** section
4. Click **"Create new secret key"**
5. Copy the key (starts with `sk-...`)

**Cost:** ~$0.002 per conversation with GPT-4o-mini (very cheap!)

### Step 2: Add API Key to Config

1. Open `GenuityAI/Services/Config.swift`
2. Replace `YOUR_API_KEY_HERE` with your actual key:

```swift
static let openAIAPIKey = "sk-proj-xxxxxxxxxxxxx"
```

3. Save the file

### Step 3: Build and Run

1. Press `Cmd + B` to build
2. Press `Cmd + R` to run
3. Start chatting! The AI will now respond with real intelligence 🧠

---

## 🔧 Configuration Options

### Choose Your Model

In `Config.swift`, you can change the model:

```swift
// Cheaper & faster (recommended for development)
static let openAIModel = "gpt-4o-mini"  // ~$0.15 per 1M tokens

// Smarter & more empathetic (recommended for production)
static let openAIModel = "gpt-4o"       // ~$5 per 1M tokens
```

### Customize the AI Personality

Edit `Config.systemPrompt` to change how the AI responds:

```swift
static let systemPrompt = """
You are Genuity AI, an empathetic mental health companion...
"""
```

---

## 🔐 Security Best Practices

### ⚠️ IMPORTANT: Keep Your API Key Secret!

**Never commit your API key to Git!**

I've created a `.gitignore` file, but to be extra safe:

#### Option 1: Use Environment Variables (Recommended)

Instead of hardcoding, use Xcode environment variables:
1. Edit Scheme → Run → Arguments → Environment Variables
2. Add: `OPENAI_API_KEY` = `your_key_here`
3. Update Config.swift:

```swift
static let openAIAPIKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"] ?? ""
```

#### Option 2: Use a Config File (Git-Ignored)

Create `Secrets.swift` (add to .gitignore):

```swift
enum Secrets {
    static let openAIKey = "sk-proj-xxxxx"
}
```

Then in Config.swift:
```swift
static let openAIAPIKey = Secrets.openAIKey
```

---

## 🧪 Testing the AI

### Test Messages to Try:

1. **Positive mood:**
   - "I'm feeling amazing today! Just got a promotion at work!"

2. **Negative mood:**
   - "I'm feeling really down. Work has been stressful and I can't sleep."

3. **Neutral mood:**
   - "Just had a normal day, nothing special."

The AI should:
- Respond empathetically
- Ask thoughtful follow-up questions
- Automatically detect mood score (1-5)
- Extract activities from your message

---

## 🐛 Troubleshooting

### "⚠️ OpenAI API key not configured"
- Make sure you replaced `YOUR_API_KEY_HERE` in Config.swift
- Check that the key starts with `sk-`

### "API Error (401): Unauthorized"
- Your API key is invalid or expired
- Get a new key from OpenAI

### "API Error (429): Rate limit exceeded"
- You've hit OpenAI's rate limit
- Wait a few seconds and try again
- Upgrade your OpenAI plan for higher limits

### "Network error"
- Check your internet connection
- Make sure the app has network permissions
- Check if OpenAI API is down: https://status.openai.com/

### Fallback Mode
If the AI fails, the app automatically falls back to the simulated keyword-based responses. You'll see "Using fallback mode" in the chat.

---

## 💰 Cost Estimation

### GPT-4o-mini (Recommended)
- Input: $0.15 per 1M tokens
- Output: $0.60 per 1M tokens
- **Average per conversation:** ~$0.001 - $0.003
- **1000 conversations:** ~$2-3

### GPT-4o
- Input: $2.50 per 1M tokens
- Output: $10.00 per 1M tokens
- **Average per conversation:** ~$0.02 - $0.05
- **1000 conversations:** ~$30-50

For a mood tracking app, **GPT-4o-mini is perfect** and extremely cost-effective.

---

## 🔮 Next Steps

Once AI is working, you can:

1. **Add streaming responses** - Show AI typing in real-time
2. **Improve mood extraction** - Use function calling for structured data
3. **Generate smarter insights** - Use AI to analyze mood patterns
4. **Add voice input** - Transcribe with Whisper API
5. **Local AI option** - Run models on-device for privacy

---

## 🎯 Alternative AI Services

### Anthropic Claude
- Better for therapeutic conversations
- Longer context window (200K tokens)
- Similar pricing to GPT-4o

### Google Gemini
- Free tier available
- Multimodal (can analyze images)
- Good for budget projects

### On-Device AI
- Apple CoreML / MLX
- 100% private, no API costs
- Requires larger app size

Let me know if you want to integrate any of these instead!

---

**Questions? Issues? Let me know!** 🚀

