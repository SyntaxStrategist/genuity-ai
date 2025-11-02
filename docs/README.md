# Genuity AI Landing Page

Beautiful, compliant landing page for Genuity AI mental health app.

## 🚀 How to Deploy to GitHub Pages

### Step 1: Push to GitHub
```bash
cd /Users/michaeloni/GenuityAI
git add docs/
git commit -m "Add landing page"
git push origin main
```

### Step 2: Enable GitHub Pages
1. Go to your GitHub repo: `https://github.com/SyntaxStrategist/genuity-ai`
2. Click **Settings** (top right)
3. Scroll to **Pages** (left sidebar)
4. Under **Source**, select:
   - Branch: `main`
   - Folder: `/docs`
5. Click **Save**
6. Wait 2-3 minutes

### Step 3: Your Site is Live! 🎉
Your site will be at: `https://syntaxstrategist.github.io/genuity-ai`

---

## 📸 Add Screenshots

Before going live, add your app screenshots:

1. Take screenshots in Xcode Simulator (Cmd + S)
2. Save them as:
   - `screenshot-1.png` (Chat view)
   - `screenshot-2.png` (Insights)
   - `screenshot-3.png` (Predictions)
   - `screenshot-4.png` (Results)
3. Put them in `docs/images/` folder
4. Update `index.html` to use them

---

## 🎨 Customization

### Change Colors
Edit `docs/style.css` and modify:
```css
:root {
    --purple: #8B5CF6;  /* Your brand color */
}
```

### Update Links
Replace `https://apps.apple.com` with your actual App Store link once approved.

### Custom Domain (Optional)
1. Buy domain (e.g., genuityai.com)
2. Add CNAME file to docs folder:
   ```
   echo "genuityai.com" > docs/CNAME
   ```
3. Configure DNS at your domain registrar
4. GitHub guides: https://docs.github.com/pages/custom-domains

---

## ✅ What's Included

- **index.html** - Main landing page
- **privacy.html** - Full privacy policy (compliant)
- **terms.html** - Terms of service (compliant)
- **style.css** - Beautiful styling matching your app
- All legal disclaimers for mental health apps

---

## 🚨 Before Launch Checklist

- [ ] Add real app screenshots
- [ ] Update email: `hello@genuityai.com` with your real email
- [ ] Update App Store links (currently placeholder)
- [ ] Review privacy policy (update jurisdiction if needed)
- [ ] Review terms of service (update jurisdiction if needed)
- [ ] Test on mobile (responsive design)
- [ ] Test all links work
- [ ] Spell check everything

---

## 🔧 Local Testing

To test locally before deploying:

```bash
# Option 1: Python
cd docs
python3 -m http.server 8000
# Visit: http://localhost:8000

# Option 2: PHP
php -S localhost:8000

# Option 3: npx
npx serve docs
```

---

## 📱 Update App Settings

Once live, update your app:

1. Open `GenuityAI/Views/SettingsView.swift`
2. Find line with `Link(destination: URL(string: "https://genuity.app")!)`
3. Replace with your actual URL: `https://YOUR_USERNAME.github.io/GenuityAI`
4. Rebuild app

---

## 🎯 What Makes This Landing Page Great

✅ **Legally Compliant**
- Medical disclaimer prominent
- Crisis resources visible
- Privacy policy comprehensive
- Terms of service complete

✅ **Privacy-Focused**
- Emphasizes local-only processing
- No tracking or analytics
- Transparent about data handling

✅ **Conversion Optimized**
- Clear value proposition
- Benefits explained simply
- Multiple CTAs
- Social proof ready

✅ **Mobile-First**
- Responsive design
- Fast loading
- Touch-friendly buttons

✅ **Accessible**
- Semantic HTML
- Screen reader friendly
- Keyboard navigable
- High contrast

---

Need help? Open an issue on GitHub!

