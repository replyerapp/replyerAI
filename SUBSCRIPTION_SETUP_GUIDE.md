# ReplyerAI Subscription Setup Guide

A complete beginner's guide to setting up in-app purchases with App Store Connect and RevenueCat.

---

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Part 1: App Store Connect Setup](#part-1-app-store-connect-setup)
3. [Part 2: RevenueCat Dashboard Setup](#part-2-revenuecat-dashboard-setup)
4. [Part 3: Testing Your Subscriptions](#part-3-testing-your-subscriptions)
5. [Part 4: Going Live](#part-4-going-live)
6. [Troubleshooting](#troubleshooting)

---

## Prerequisites

Before you start, make sure you have:

- ✅ An Apple Developer Account ($99/year) - https://developer.apple.com
- ✅ Your app's Bundle ID (yours is: `eckc.replyerAI`)
- ✅ A RevenueCat account (free) - https://www.revenuecat.com
- ✅ Your RevenueCat API Key (you have: `test_jpKNvGjjymPrTNKOqTNXvkZhQsX`)
- ✅ Xcode with your app ready to build

---

## Part 1: App Store Connect Setup

### Step 1.1: Log into App Store Connect

1. Go to https://appstoreconnect.apple.com
2. Sign in with your Apple Developer account

### Step 1.2: Create Your App (if not already created)

1. Click **"My Apps"**
2. Click the **"+"** button → **"New App"**
3. Fill in:
   - **Platform**: iOS
   - **Name**: ReplyerAI
   - **Primary Language**: English (or your preferred)
   - **Bundle ID**: Select `eckc.replyerAI`
   - **SKU**: `replyerAI` (unique identifier, can be anything)
4. Click **"Create"**

### Step 1.3: Create a Subscription Group

Subscription groups allow users to upgrade/downgrade between plans.

1. In your app, go to the **"Subscriptions"** tab (left sidebar under "Features")
2. Click **"+"** next to "Subscription Groups"
3. **Reference Name**: `ReplyerAI Pro`
4. Click **"Create"**

### Step 1.4: Create Subscription Products

Now create each subscription inside the group:

#### Monthly Subscription

1. Click on your "ReplyerAI Pro" subscription group
2. Click **"+"** next to "Subscriptions"
3. Fill in:
   - **Reference Name**: `Monthly`
   - **Product ID**: `monthly` ⚠️ IMPORTANT: Must match exactly!
4. Click **"Create"**
5. Now configure the subscription:
   - **Subscription Duration**: 1 Month
   - **Subscription Prices**: Click "Add Subscription Price"
     - Select your base country
     - Enter price (e.g., $4.99)
     - Click "Next" → "Confirm"
   - **App Store Localization**: Click "+" 
     - **Display Name**: `Monthly`
     - **Description**: `Unlimited AI reply generations every month`
6. Click **"Save"**

#### 6-Month Subscription

1. Click **"+"** next to "Subscriptions" again
2. Fill in:
   - **Reference Name**: `Six Month`
   - **Product ID**: `six_month` ⚠️ IMPORTANT: Must match exactly!
3. Click **"Create"**
4. Configure:
   - **Subscription Duration**: 6 Months
   - **Subscription Prices**: (e.g., $19.99 - save vs monthly)
   - **App Store Localization**:
     - **Display Name**: `6 Months`
     - **Description**: `Save 33% with our 6-month plan`
5. Click **"Save"**

#### Yearly Subscription

1. Click **"+"** next to "Subscriptions"
2. Fill in:
   - **Reference Name**: `Yearly`
   - **Product ID**: `yearly` ⚠️ IMPORTANT: Must match exactly!
3. Click **"Create"**
4. Configure:
   - **Subscription Duration**: 1 Year
   - **Subscription Prices**: (e.g., $29.99 - best value)
   - **App Store Localization**:
     - **Display Name**: `Yearly`
     - **Description**: `Best value! Save 50% with yearly`
5. Click **"Save"**

### Step 1.5: Create Lifetime Purchase (Non-Consumable)

Lifetime is different - it's a one-time purchase, not a subscription.

1. Go to **"In-App Purchases"** tab (left sidebar, under "Features")
2. Click **"+"** button
3. Select **"Non-Consumable"**
4. Fill in:
   - **Reference Name**: `Lifetime`
   - **Product ID**: `lifetime` ⚠️ IMPORTANT: Must match exactly!
5. Click **"Create"**
6. Configure:
   - **Price**: Click "Add Pricing" (e.g., $79.99)
   - **App Store Localization**: Click "+"
     - **Display Name**: `Lifetime`
     - **Description**: `One-time purchase. Unlimited forever!`
7. Click **"Save"**

### Step 1.6: App Store Connect Shared Secret

RevenueCat needs this to verify purchases.

1. Go to your app in App Store Connect
2. Click **"App Information"** (left sidebar under "General")
3. Scroll down to **"App-Specific Shared Secret"**
4. Click **"Manage"**
5. Click **"Generate"** if you don't have one
6. **Copy this secret** - you'll need it for RevenueCat!

### Step 1.7: Create Sandbox Test Accounts

To test purchases without real money:

1. Go to **"Users and Access"** (top menu)
2. Click **"Sandbox"** tab
3. Click **"+"** to add a tester
4. Fill in:
   - **First Name**: Test
   - **Last Name**: User
   - **Email**: Use a NEW email (not your real one!) like `test@youremaildomain.com`
   - **Password**: Create a password
   - **Country**: Your country
5. Click **"Invite"**

⚠️ **IMPORTANT**: Use a completely new email that's never been used with Apple!

---

## Part 2: RevenueCat Dashboard Setup

### Step 2.1: Create a RevenueCat Project

1. Go to https://app.revenuecat.com
2. Click **"+ New Project"**
3. **Project Name**: `ReplyerAI`
4. Click **"Create Project"**

### Step 2.2: Add Your iOS App

1. In your project, click **"Apps"** (left sidebar)
2. Click **"+ New App"**
3. Select **"App Store"** (Apple icon)
4. Fill in:
   - **App Name**: `ReplyerAI`
   - **Bundle ID**: `eckc.replyerAI`
   - **App Store Connect App-Specific Shared Secret**: Paste the secret from Step 1.6
5. Click **"Save Changes"**

### Step 2.3: Get Your API Keys

1. Go to **"API Keys"** (left sidebar under Project Settings)
2. You'll see two keys:
   - **Public API Key** (starts with `appl_`): Use this in your app ✅
   - **Secret API Key**: Never put this in your app! ❌
3. You already have: `test_jpKNvGjjymPrTNKOqTNXvkZhQsX`

### Step 2.4: Import Products from App Store Connect

1. Go to **"Products"** (left sidebar)
2. Click **"+ New"**
3. Select **"Import Products"**
4. RevenueCat will automatically find your products from App Store Connect
5. Select all 4 products:
   - ☑️ `monthly`
   - ☑️ `six_month`
   - ☑️ `yearly`
   - ☑️ `lifetime`
6. Click **"Import"**

If auto-import doesn't work, add manually:
1. Click **"+ New"**
2. **App**: Select your iOS app
3. **Identifier**: Enter product ID (e.g., `monthly`)
4. Click **"Add"**
5. Repeat for all 4 products

### Step 2.5: Create an Entitlement

Entitlements define what users get access to.

1. Go to **"Entitlements"** (left sidebar)
2. Click **"+ New"**
3. **Identifier**: `replyerAI Pro` ⚠️ IMPORTANT: Must match exactly what's in your code!
4. Click **"Add"**
5. Now attach products to this entitlement:
   - Click on **"replyerAI Pro"** entitlement
   - Click **"Attach"**
   - Select all 4 products:
     - ☑️ `monthly`
     - ☑️ `six_month`
     - ☑️ `yearly`
     - ☑️ `lifetime`
   - Click **"Add"**

### Step 2.6: Create an Offering

Offerings define which products to show users.

1. Go to **"Offerings"** (left sidebar)
2. You should see a **"default"** offering already created
3. Click on **"default"**
4. Add packages:
   - Click **"+ New Package"**
   - **Identifier**: Select `$rc_monthly` (built-in identifier)
   - **Product**: Select `monthly`
   - Click **"Add"**
5. Repeat for other packages:
   - `$rc_six_month` → `six_month`
   - `$rc_annual` → `yearly`
   - `$rc_lifetime` → `lifetime`

### Step 2.7: Configure Your Paywall (Optional but Recommended)

RevenueCat can generate beautiful paywalls automatically!

1. Go to **"Paywalls"** (left sidebar)
2. Click **"+ New Paywall"**
3. Choose a template (e.g., "Sphynx", "Minimal", etc.)
4. Customize:
   - **Header**: "Unlock ReplyerAI Pro"
   - **Subheader**: "Unlimited AI-powered message replies"
   - **Features list**:
     - ✨ Unlimited generations
     - 🔍 Decode hidden meanings
     - ✍️ Match your writing style
   - **Call to action**: "Start Free Trial" or "Subscribe Now"
5. Click **"Save"**
6. Go to **"Offerings"** → **"default"**
7. Under **"Paywall"**, select your new paywall
8. Click **"Save"**

---

## Part 3: Testing Your Subscriptions

### Step 3.1: Configure Sandbox on Your iPhone

1. On your iPhone, go to **Settings**
2. Scroll down and tap **"App Store"**
3. Scroll down to **"Sandbox Account"**
4. Tap **"Sign In"** (or sign out of existing)
5. Sign in with the sandbox account you created in Step 1.7

### Step 3.2: Build and Run on Device

1. Open Xcode
2. Connect your iPhone
3. Select your iPhone as the build target
4. Press **Cmd+R** to build and run

### Step 3.3: Test the Purchase Flow

1. Open the app
2. Tap **"Upgrade"** to show the paywall
3. Select a subscription
4. Complete the purchase with your sandbox account
5. The purchase should complete instantly (sandbox is fast!)

### Step 3.4: Verify in RevenueCat Dashboard

1. Go to RevenueCat Dashboard
2. Click **"Customers"** (left sidebar)
3. You should see your test user
4. Click on them to see their subscription status

### Sandbox Subscription Durations

In sandbox, subscriptions renew much faster for testing:

| Real Duration | Sandbox Duration |
|---------------|------------------|
| 1 Week        | 3 minutes        |
| 1 Month       | 5 minutes        |
| 2 Months      | 10 minutes       |
| 3 Months      | 15 minutes       |
| 6 Months      | 30 minutes       |
| 1 Year        | 1 hour           |

---

## Part 4: Going Live

### Before Submitting to App Store

1. **Test thoroughly** with sandbox accounts
2. **Replace test API key** with production key (if using different keys)
3. **Set log level to `.error`** in production (already done in code)
4. **Submit products for review** in App Store Connect:
   - Each product needs a screenshot
   - Review Information must be filled out

### Submitting Your App

1. In App Store Connect, go to your app
2. Create a new version
3. Fill in all required metadata
4. Under **"In-App Purchases"**, select your products
5. Submit for review

---

## Troubleshooting

### "No products available"

- Make sure product IDs match EXACTLY (case-sensitive)
- Products must be in "Ready to Submit" or "Approved" status
- Wait 15-30 minutes after creating products
- Check that your Bundle ID matches

### "Purchase failed"

- Make sure you're signed into sandbox account on device
- Don't use your real Apple ID for testing
- Check RevenueCat dashboard for error details

### "Entitlement not active after purchase"

- Verify entitlement ID matches: `replyerAI Pro`
- Check that products are attached to the entitlement
- Look at RevenueCat logs in Xcode console

### "Paywall not showing"

- Make sure you have an offering set as "default"
- Check that packages are added to the offering
- Verify API key is correct in `Secrets.swift`

### Debug Tips

1. **Check Xcode Console**: RevenueCat logs helpful info
2. **RevenueCat Dashboard → Customers**: See real-time purchase data
3. **RevenueCat Dashboard → Overview**: Check for errors

---

## Quick Reference

### Product IDs (Must Match Exactly!)

| Product | ID | Type |
|---------|-----|------|
| Monthly | `monthly` | Auto-renewable subscription |
| 6 Month | `six_month` | Auto-renewable subscription |
| Yearly | `yearly` | Auto-renewable subscription |
| Lifetime | `lifetime` | Non-consumable |

### Entitlement ID

```
replyerAI Pro
```

### Your RevenueCat API Key

```
test_jpKNvGjjymPrTNKOqTNXvkZhQsX
```

### Code Locations

| File | Purpose |
|------|---------|
| `Secrets.swift` | API keys |
| `SubscriptionService.swift` | All RevenueCat logic |
| `ContentView.swift` | Paywall presentation |
| `replyerAIApp.swift` | SDK initialization |

---

## Need Help?

- **RevenueCat Docs**: https://www.revenuecat.com/docs
- **RevenueCat Discord**: https://discord.gg/revenuecat
- **Apple Developer Forums**: https://developer.apple.com/forums/
- **App Store Connect Help**: https://developer.apple.com/help/app-store-connect/

---

Good luck with your app! 🚀

