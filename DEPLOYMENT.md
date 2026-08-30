# 🚀 Deployment Guide: 365 Potential Tracker (Web & Mobile Phone)

This guide walks you through deploying the **Web Version** (on Vercel / Netlify) and using/installing the **Mobile App Version** on your phone (Android & iOS) with **100% real user data**.

---

## 1. Web Deployment (Vercel)

The repository includes [`vercel.json`](./vercel.json) ready for instant Single-Page Application deployment.

### Steps to Deploy on Vercel:
1. Push your repository to **GitHub**.
2. Go to **[Vercel Dashboard](https://vercel.com/)** $\rightarrow$ Click **Add New Project** $\rightarrow$ **Import Git Repository**.
3. **Configure Project**:
   - **Framework Preset**: `Other`
   - **Root Directory**: `./` (or `web` for static PWA)
4. Click **Deploy**.
5. Your web app will be live at `https://your-project.vercel.app`!

---

## 2. Mobile App on Your Phone (Android & iOS)

### 📲 Option A: Install as Progressive Web App (PWA) — Instant & No App Store Needed (Recommended)
Once deployed on Vercel (or when opened on your local network/browser):

* **On Android (Chrome / Brave / Edge)**:
  1. Open your deployed URL (`https://your-project.vercel.app`).
  2. Tap the **three dots menu (⋮)** in the top right $\rightarrow$ Tap **"Add to Home screen"** or **"Install app"**.
  3. An app icon named **365 Potential** will appear on your phone home screen. It opens full screen with zero browser bars like a native app!

* **On iPhone / iPad (Safari)**:
  1. Open the URL in Safari.
  2. Tap the **Share button** (square with upward arrow at bottom) $\rightarrow$ Tap **"Add to Home Screen"**.
  3. Tap **Add**. The app is now installed on your iOS home screen!

---

### 📱 Option B: Build Native Android APK (Flutter)

If you have the Flutter SDK installed on your computer and want a `.apk` file:

```bash
# 1. Get dependencies
flutter pub get

# 2. Build Release APK (with Supabase keys injected)
flutter build apk --release \
  --dart-define=SUPABASE_URL=https://your-project.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your-anon-key
```

* The compiled installer `.apk` will be generated at:
  `build/app/outputs/flutter-apk/app-release.apk`
* Transfer this file to your Android phone via USB/WhatsApp/Drive and tap to install!

---

## 3. Real Supabase Database Setup

To store your real data securely in PostgreSQL with multi-device sync:

1. Create a free project at **[Supabase.com](https://supabase.com)**.
2. Go to **SQL Editor** $\rightarrow$ Run the script in [`supabase/migrations/20260829_init_schema.sql`](./supabase/migrations/20260829_init_schema.sql).
3. Copy your **Project URL** and **Anon Key** from **Project Settings $\rightarrow$ API**.
4. All real logs, habits, and user accounts will automatically synchronize across all your devices!
