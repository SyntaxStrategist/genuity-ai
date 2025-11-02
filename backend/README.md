# Genuity AI Backend

Secure API proxy for OpenAI (keeps your API key safe on server, not in app).

---

## 🚀 Deploy to Vercel (5 Minutes)

### Step 1: Install Vercel CLI
```bash
npm install -g vercel
```

### Step 2: Deploy
```bash
cd /Users/michaeloni/GenuityAI/backend
vercel
```

Follow prompts:
- **Set up and deploy?** → YES
- **Which scope?** → Your account
- **Link to existing project?** → NO
- **Project name?** → genuity-ai-backend
- **Directory?** → ./ (current)
- **Override settings?** → NO

### Step 3: Add API Key to Vercel
```bash
vercel env add OPENAI_API_KEY
```

Paste your OpenAI key when prompted.
Choose: **Production**

### Step 4: Redeploy
```bash
vercel --prod
```

### Step 5: Copy Your URL
```
✅ Deployed to: https://genuity-ai-backend.vercel.app
```

**Copy this URL** - you'll need it for the iOS app!

---

## 🧪 Test Locally First

### Install dependencies:
```bash
npm install
```

### Create .env file:
```bash
echo "OPENAI_API_KEY=sk-proj-your-key-here" > .env
```

### Run server:
```bash
npm run dev
```

### Test it:
```bash
curl -X POST http://localhost:3000/api/chat \
  -H "Content-Type: application/json" \
  -d '{
    "messages": [
      {"role": "system", "content": "You are a helpful assistant"},
      {"role": "user", "content": "Hello!"}
    ]
  }'
```

Should return:
```json
{
  "message": "Hi! How can I help you today?",
  "usage": {...}
}
```

---

## 🔒 Security Features

✅ **Rate Limiting**: 30 requests per 15 min per IP (prevents abuse)
✅ **CORS Enabled**: Only your app can call it (configure later)
✅ **API Key on Server**: Never exposed to clients
✅ **HTTPS Automatic**: Vercel provides SSL
✅ **No Logging**: Doesn't store user messages

---

## 💰 Costs

**Vercel**: FREE (up to 100GB bandwidth/month)
**OpenAI**: ~$0.001 per chat message (dirt cheap with gpt-4o-mini)

**Example**:
- 1,000 users
- 10 messages/user/month
- 10,000 total messages
- Cost: ~$10/month

**Scales beautifully.**

---

## 🔧 After Deployment

Once deployed, you'll update your iOS app to call:
```
https://YOUR-APP.vercel.app/api/chat
```

Instead of OpenAI directly.

**I'll update the iOS app for you once you have the Vercel URL.**

---

## ⚡ Quick Commands

```bash
# Deploy to Vercel
vercel --prod

# View logs
vercel logs

# View environment variables
vercel env ls

# Remove deployment
vercel rm genuity-ai-backend
```

---

Ready to deploy? Just run the commands above! 🚀

