# FinFlow — Supabase Setup Guide

## What You Need
- A free Supabase account → https://supabase.com
- A text editor (or just Notepad)

---

## Step 1 — Create a Supabase Project

1. Go to https://supabase.com and sign up (free)
2. Click **"New Project"**
3. Fill in:
   - **Name:** FinFlow (or anything you like)
   - **Database Password:** Save this somewhere safe
   - **Region:** Southeast Asia (Singapore) — closest to PH
4. Click **Create new project** and wait ~1 minute

---

## Step 2 — Run the Database Schema

1. In your Supabase dashboard, click **SQL Editor** in the left sidebar
2. Click **"New query"**
3. Open the file `sql/schema.sql` from this package
4. Copy ALL its contents and paste into the SQL Editor
5. Click **Run** (green button)
6. You should see "Success. No rows returned"

This creates all your tables:
- `profiles` — your user profile
- `income` — income records
- `expenses` — expense records
- `schedule` — recurring payments/income
- `budgets` — monthly budget limits
- `goals` — savings goals

---

## Step 3 — Get Your API Keys

1. In Supabase dashboard, click **Project Settings** (gear icon, bottom left)
2. Click **API** in the settings menu
3. You need two values:
   - **Project URL** — looks like `https://abcdefgh.supabase.co`
   - **anon public key** — a long string starting with `eyJ...`

---

## Step 4 — Add Your Keys to the App

1. Open `index.html` in a text editor
2. Find these two lines near the top of the `<script>` section:

```javascript
const SUPABASE_URL  = 'YOUR_SUPABASE_URL';
const SUPABASE_ANON = 'YOUR_SUPABASE_ANON_KEY';
```

3. Replace the placeholder values with your actual keys:

```javascript
const SUPABASE_URL  = 'https://abcdefgh.supabase.co';
const SUPABASE_ANON = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...';
```

4. Save the file

---

## Step 5 — Enable Email Confirmations (Optional)

By default, Supabase requires email confirmation on signup.

**To disable it (easier for personal use):**
1. Go to **Authentication** → **Providers** → **Email**
2. Toggle OFF "Confirm email"
3. Save

---

## Step 6 — Open the App

Simply open `index.html` in your web browser (Chrome, Firefox, Edge).

> **For best results**, serve it via a local server:
> - If you have VS Code: install "Live Server" extension → right-click index.html → Open with Live Server
> - Or run: `npx serve .` in the project folder

---

## Step 7 — Deploy Online (Optional)

To access FinFlow from anywhere (phone, other devices):

### Option A — Netlify (Free, Easiest)
1. Go to https://netlify.com
2. Drag the entire `finflow` folder onto the Netlify dashboard
3. Done! You get a live URL like `https://your-finflow.netlify.app`

### Option B — GitHub Pages
1. Push this folder to a GitHub repository
2. Go to repo Settings → Pages → Deploy from branch (main)
3. Your app is live at `https://yourusername.github.io/finflow`

### Option C — Vercel (Premium, Best for Analytics)
1. Install Vercel CLI: `npm i -g vercel`
2. Run `vercel` in this folder
3. Follow the CLI prompts (hit Enter for defaults)
4. Or simply connect your GitHub repo to **[vercel.com](https://vercel.com)**

---

## Features Included

| Feature | Description |
|---------|-------------|
| 🔐 Auth | Email/password login, secure per-user data |
| 💰 Income | Track income by source & category |
| 📤 Expenses | Log spending with categories & filters |
| ⏰ Schedule | Recurring payments/income, mark as paid |
| 📊 Budget | Set monthly limits, live progress bars |
| 🎯 Goals | Savings goals with progress tracking |
| 📈 Reports | Charts, monthly summaries, savings rate |
| ☁️ Cloud | All data synced to Supabase, access anywhere |

---

## Security Notes

- Each user can ONLY see their own data (Row Level Security is enabled)
- Passwords are hashed by Supabase — never stored in plain text
- Your `anon` key is safe to expose in frontend code — it has no admin access
- Never share your `service_role` key (different from anon key)

---

## Troubleshooting

**"Failed to fetch" or network errors:**
→ Double-check your SUPABASE_URL and SUPABASE_ANON values

**Can't sign up / login:**
→ Make sure you ran the schema.sql first
→ Check Authentication → Users in Supabase to see if user was created

**Data not saving:**
→ Open browser DevTools (F12) → Console → look for error messages
→ Make sure RLS policies were created (check sql/schema.sql ran fully)

---

*FinFlow — Personal Finance Tracker*
*Built with Supabase + Vanilla JS*
