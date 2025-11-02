# 🚀 Deploy Your Landing Page

Your landing page is ready! Here's how to make it live in 3 minutes.

---

## ✅ What You Have

```
docs/
├── index.html          ✅ Main landing page (beautiful!)
├── privacy.html        ✅ Privacy policy (compliant)
├── terms.html          ✅ Terms of service (compliant)
├── style.css           ✅ Styling (matches your app)
├── images/             ✅ Folder for screenshots
└── README.md           ✅ Documentation
```

---

## 🌐 Step 1: Push to GitHub

```bash
cd /Users/michaeloni/GenuityAI
git add docs/
git commit -m "Add landing page for Genuity AI"
git push origin main
```

*(If you haven't set up git yet, do that first!)*

---

## 📦 Step 2: Enable GitHub Pages

1. Go to: `https://github.com/YOUR_USERNAME/GenuityAI`
2. Click **Settings** tab (top right)
3. Scroll down left sidebar → Click **Pages**
4. Under **Build and deployment**:
   - **Source**: Deploy from a branch
   - **Branch**: `main`
   - **Folder**: `/docs`
   - Click **Save**

5. Wait 2-3 minutes for deployment

---

## 🎉 Step 3: Your Site is LIVE!

Your URL will be:
```
https://YOUR_USERNAME.github.io/GenuityAI
```

**Example**: If your GitHub username is `michaeloni`, your site is:
```
https://michaeloni.github.io/GenuityAI
```

---

## 📸 Step 4: Add Screenshots (Optional but Recommended)

1. **Take screenshots in Xcode**:
   - Run app in simulator
   - Press `Cmd + S` to save screenshot
   - Take 4-5 screenshots:
     - Chat view
     - Insights with patterns
     - Predictions view
     - Results/effectiveness
     - Settings (optional)

2. **Add to website**:
   ```bash
   # Save screenshots to docs/images/
   mv ~/Desktop/screenshot1.png docs/images/chat.png
   mv ~/Desktop/screenshot2.png docs/images/insights.png
   # etc...
   ```

3. **Update HTML** (optional):
   - Edit `docs/index.html`
   - Add screenshot section with `<img src="images/chat.png">`

---

## 🔧 Step 5: Update App Settings

Replace placeholder URL in your app:

1. Open `GenuityAI/Views/SettingsView.swift`
2. Find line 272: `URL(string: "https://YOUR_USERNAME.github.io/GenuityAI")`
3. Replace `YOUR_USERNAME` with your actual GitHub username
4. Save and rebuild app

**Example**:
```swift
Link(destination: URL(string: "https://michaeloni.github.io/GenuityAI")!) {
```

---

## 🎨 Customization (Optional)

### Change Email
Replace `hello@genuityai.com` with your real email in:
- `docs/index.html` (footer)
- `docs/privacy.html` (bottom)
- `docs/terms.html` (bottom)

### Custom Domain (Optional)
If you buy a domain like `genuityai.com`:

1. Create CNAME file:
   ```bash
   echo "genuityai.com" > docs/CNAME
   git add docs/CNAME
   git commit -m "Add custom domain"
   git push
   ```

2. Configure DNS at your domain registrar:
   - Type: `CNAME`
   - Name: `www` or `@`
   - Value: `YOUR_USERNAME.github.io`

3. Wait for DNS propagation (5-60 minutes)

---

## ✅ Pre-Launch Checklist

Before sharing your website publicly:

- [ ] Screenshots added to `docs/images/`
- [ ] Email updated (replace `hello@genuityai.com`)
- [ ] App Store link updated (when available)
- [ ] Test on mobile browser
- [ ] Check all links work
- [ ] Spell check content
- [ ] Privacy policy reviewed
- [ ] Terms of service reviewed
- [ ] Crisis resources phone numbers correct for your country

---

## 🧪 Test Locally First

Before deploying, test it locally:

```bash
cd docs
python3 -m http.server 8000
```

Then visit: `http://localhost:8000`

---

## 📱 What People Will See

✅ **Professional landing page**
- Hero section with clear value prop
- Feature highlights (Predict, Prevent, Prove)
- Privacy emphasis (100% local)
- How it works timeline
- Crisis resources
- Legal compliance (privacy + terms)

✅ **Mobile-optimized**
- Looks great on iPhone
- Fast loading
- Touch-friendly buttons

✅ **Trustworthy**
- Medical disclaimers prominent
- Privacy-first messaging
- Crisis resources visible
- Complete legal documentation

---

## 🎯 Next Steps

1. **Deploy now** → Follow Step 1-3 above
2. **Add screenshots** → Makes it 10x better
3. **Share the link** → On Twitter, ProductHunt, etc.
4. **Update app** → Replace placeholder URL

---

## 🆘 Troubleshooting

**Site not loading?**
- Wait 3-5 minutes after enabling Pages
- Check GitHub Pages settings are correct
- Try incognito/private browsing

**404 error?**
- Make sure branch is `main` (not `master`)
- Make sure folder is `/docs` (not root)
- Check files are actually in `docs/` folder

**Styling broken?**
- Check `style.css` is in same folder as HTML files
- Make sure file names are lowercase

---

## 💬 Need Help?

Open an issue on GitHub or contact support.

---

**Your landing page is ready to go! 🚀**

Push to GitHub → Enable Pages → Share your link!

