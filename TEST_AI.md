# 🧪 Test Your AI Integration

## ✅ Build Status: SUCCESS!

Your app compiled successfully with real AI integration!

---

## 🚀 How to Run & Test

### 1. Open in Xcode
```bash
open /Users/michaeloni/GenuityAI/GenuityAI.xcodeproj
```

### 2. Select Simulator
- Click the device selector at the top (near the play button)
- Choose any iPhone simulator (e.g., iPhone 17, iPhone 17 Pro)

### 3. Run the App
- Press `Cmd + R` or click the ▶️ Play button
- Wait for simulator to launch (~10-20 seconds)

---

## 💬 Test Conversations

Try these messages to see the AI in action:

### Test 1: Positive Mood
**You:** "I'm feeling amazing today! Just got a promotion at work and celebrated with friends!"

**Expected:**
- AI responds empathetically about your promotion
- Asks a thoughtful follow-up question
- Automatically detects: Mood=5, Activities=[Work, Social]

### Test 2: Stressed Mood
**You:** "I've been really stressed lately. Work deadlines are piling up and I'm not sleeping well."

**Expected:**
- AI shows empathy for your stress
- Asks about patterns or coping strategies
- Automatically detects: Mood=2, Activities=[Work, Sleep]

### Test 3: Neutral Day
**You:** "Just a normal day. Did some reading and went for a walk."

**Expected:**
- AI asks engaging follow-up
- Automatically detects: Mood=3, Activities=[Reading, Outdoor]

### Test 4: Anxious
**You:** "Feeling anxious about an upcoming presentation. My heart won't stop racing."

**Expected:**
- Supportive, calming response
- Question about triggers or support
- Automatically detects: Mood=2, Activities=[Work]

---

## 🔍 What to Look For

### ✅ Signs It's Working:
1. **Natural responses** - Not just keyword matches
2. **Context awareness** - AI references your previous messages
3. **Varied responses** - Different replies to similar moods
4. **Smooth conversation** - Feels like talking to a person
5. **Automatic entries** - Check History tab for saved moods

### ❌ If It's Not Working:
1. **"⚠️ OpenAI API key not configured"**
   - Check Config.swift has your real API key
   - Rebuild the project (Cmd + B)

2. **"API Error (401)"**
   - Your API key is invalid
   - Get a new one from https://platform.openai.com/api-keys

3. **"Network error"**
   - Check internet connection
   - Check OpenAI status: https://status.openai.com/

4. **Fallback mode activates**
   - You'll see "Using fallback mode"
   - Responses become generic/keyword-based
   - This means the AI call failed but app still works

---

## 📊 Check Your Results

### In the Chat Tab:
- AI responses should be contextual and varied
- Conversation flows naturally
- No generic template responses

### In the History Tab:
- New entries appear automatically
- Mood scores are accurate
- Activities are intelligently extracted

### In the Insights Tab:
- Charts update with new data
- AI insights become more personalized over time

---

## 💰 Monitor Your Usage

Check your OpenAI usage at:
https://platform.openai.com/usage

**Expected costs:**
- Each conversation: ~$0.001-0.003
- 100 test conversations: ~$0.20-0.30

Very affordable! 🎉

---

## 🎯 Compare: AI vs Simulated

To see the difference, try the same message twice:

**With AI (Current):**
> "Feeling stressed about work"
- Natural, empathetic response
- Asks specific follow-up
- Contextual understanding

**Simulated Mode (Old):**
> "Feeling stressed about work"  
- Generic: "I understand. Stress can be overwhelming..."
- Same response every time
- No context or personalization

The difference should be obvious! 🚀

---

## 🐛 Common Issues

### Simulator Crashes
- Restart simulator: Device → Restart
- Clean build: Cmd + Shift + K, then Cmd + B

### Keyboard Not Showing
- Click the chat input field
- If still not showing: I/O → Keyboard → Toggle Software Keyboard

### App Won't Build
- Check terminal output for errors
- Make sure Config.swift is in the Services folder

---

## 🎉 Next Steps

Once AI is working:

1. **Test different moods** - Try happy, sad, anxious, excited, tired
2. **Multi-turn conversations** - Have 5-10 message exchanges
3. **Check conversation memory** - Reference something you said earlier
4. **Review insights** - See how data accumulates in Insights tab
5. **Monitor API costs** - Check OpenAI dashboard

---

## 🔄 Disable AI (Fallback Mode)

To test without AI (or if you run out of credits):

In `Config.swift`:
```swift
static let openAIAPIKey = ""  // Empty string
```

The app will automatically use simulated responses as fallback!

---

**Ready to test? Open Xcode and press `Cmd + R`!** 🚀

Any issues? Check the logs in Xcode's console (bottom panel).

