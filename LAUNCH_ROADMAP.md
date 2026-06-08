# BOLOO AI — Launch Roadmap
**Goal:** 100 paying users × ৳1,999 = ৳199,900 revenue within 90 days  
**Strategy:** Fix only what blocks payment. Ship fast. Sell manually first. Automate later.

---

## The Only Number That Matters

```
Week 2:   First build on a real Android phone
Week 3:   First paying user
Week 5:   10 paying users
Week 9:   50 paying users
Week 13:  100 paying users
```

Everything in this roadmap serves one of those milestones or it doesn't belong here.

---

## Phase 1 — Make It Shippable (Days 1–10)

Fix the exact issues from PROJECT_AUDIT.md that block payment. Nothing else.

### Day 1 — Make It Compile
**One task, ~2 hours**

Download five font files from Google Fonts and drop them in `assets/fonts/`:
- Plus Jakarta Sans: Regular, Medium, SemiBold, Bold
- DM Mono: Medium

The app will not build without this. Do it first.

**Also on Day 1:** Update the price in `paywall_screen.dart` from ৳2,999 to ৳1,999. The lower price removes friction for the first 100 users. You can raise it after product-market fit is confirmed.

### Days 2–4 — Fix the Three Critical Logic Bugs

These are the bugs where the product lies to the user. Ship them broken and you will get support messages and refunds.

**Bug 1: Subscription gate missing** (`router.dart:46–57`)  
Users can skip the paywall entirely. Add two checks to the redirect: if `onboarding_completed` is false → go to `/onboarding`; if no active subscription → go to `/paywall`. This is the most important fix — without it you cannot collect payment reliably.

**Bug 2: Maya never knows what day it is** (`conversation_provider.dart:109`)  
`day: null` is always passed to Maya. Change it to pass `convo.journeyDay`. Without this fix, every session feels identical regardless of where the user is in the programme. Users will notice on Day 3.

**Bug 3: Journey completion never recorded** (`conversation_provider.dart` — `endSession()`)  
Call `journeyService.markDayCompleted(journeyDay)` inside `endSession()`. Without this, the journey map shows Day 1 forever. Users will think the app is broken.

**Also in this window:**
- Fix the stream subscription leak in `voice_session_screen.dart` (~30 min). This causes crashes after 4–5 sessions. Your first users will hit it.
- Fix the webhook timing attack in `zinnipay-webhook/index.ts` (~30 min). Replace `!==` with `timingSafeEqual`. This protects every future payment.

### Days 5–7 — Build the Android APK

The iOS submission process takes 1–3 days of Apple review. Android is 3–7 days. Start Android first. Get a real APK on a real phone before doing anything else.

What's needed to generate the first APK:
1. Run `flutter create . --project-name boloo_ai` on the existing codebase to generate the missing Android Gradle files and iOS Xcode project (it fills in the gaps without overwriting existing Dart code).
2. Wire `--dart-define` secrets into the build command with real Supabase + Zinnipay credentials.
3. `flutter build apk --release --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...`

**First test:** Install on a physical Android device. Tap through sign-up → onboarding → paywall → pay with bKash sandbox → dashboard → start a session → end session → view scorecard. Fix every crash you encounter before moving to the next phase.

### Days 8–10 — Provision Supabase Production

1. Create a Supabase project (Pro plan — free tier has rate limits that will cause failures under real load).
2. Run all three migrations in order: `001_initial_schema.sql`, `002_rls_policies.sql`, `003_curriculum_seed.sql`.
3. Deploy all four Edge Functions: `maya-conversation`, `score-session`, `initiate-payment`, `zinnipay-webhook`.
4. Set all secrets in the Supabase dashboard: `GEMINI_API_KEY`, `SUPABASE_SERVICE_ROLE_KEY`, `ZINNIPAY_SECRET_KEY`, `ZINNIPAY_MERCHANT_ID`.
5. Register the webhook URL with Zinnipay: `https://<project-ref>.supabase.co/functions/v1/zinnipay-webhook`.
6. Run one complete end-to-end test with real bKash credentials (Zinnipay sandbox). Verify the `subscriptions` table row is created and `user_profiles.journey_start_date` is set.

**Do not skip the end-to-end payment test.** This is the revenue path. Test it before any user sees the app.

---

## Phase 2 — Validate With 5 Real Users (Days 11–17)

Before paying for any ads or posting publicly, put the APK in the hands of 5 people you personally know who match the target user: job seekers, freelancers, or recent graduates who need English for their career.

Give them free access. Tell them to use it for 3 days and tell you everything that frustrates them.

**The only thing you're measuring:**
- Can they complete a session without the app crashing?
- Does the scorecard feel meaningful or arbitrary?
- Did they understand what to do next without you explaining?

**What to fix based on feedback:**
Only fix things that caused confusion or crashes. Do not add features. Do not redesign. You are looking for show-stoppers only.

**Also in this window:**
- Add Privacy Policy and Terms of Service links to the Settings screen. Link to a hosted Google Doc or simple webpage. App Store will reject without this.
- Submit to Google Play (takes 3–7 days to review). Target Android first — faster review, larger Bangladesh market share, direct APK distribution possible as fallback.
- Submit to Apple App Store (takes 1–3 days).

---

## Phase 3 — First 20 Paying Users (Days 18–30)

This phase is almost entirely sales, not engineering. The goal is ৳1,999 × 20 = ৳39,980 in your bank account.

### How to sell manually before marketing

Do not run ads yet. Ads require a feedback loop (click → install → pay) that you cannot optimise until you know users can complete that loop without help. Instead, sell directly:

**Channel 1: Your personal network**  
Message every person in your contacts who is a freelancer, job seeker, or corporate professional. Not a mass blast — individual messages. "আমি একটা English practice app বানিয়েছি, তুমি কি ৩ দিন try করতে চাও?" Offer the first 20 users ৳1,999 (keep this price — they are paying, not beta testing). Your goal is 5 paying users from personal network.

**Channel 2: Targeted Facebook groups**  
Post in:
- Freelancer groups (Bangladeshi Freelancers, Upwork Bangladesh, Fiverr Bangladesh)
- Job seeker groups (BCS preparation, corporate job hunting)
- University alumni groups

Post format: short demo video (screen record a session on your phone) + one sentence about the outcome ("Maya helped me practice my Upwork interview pitch for 30 days"). No price in the post — tell people to DM you. Convert over WhatsApp. Aim for 10 paying users from this channel.

**Channel 3: LinkedIn**  
Post a before/after story about someone who used it (real or illustrative). Tag relevant Bangladesh tech and HR communities. Aim for 5 paying users.

**At 20 paying users, you have evidence the funnel works.** Only then move to Phase 4.

---

## Phase 4 — Scale to 100 (Days 31–90)

### The numbers

```
Day 30:   20 users (manual sales)
Day 45:   40 users (+20 via referral + targeted content)
Day 60:   65 users (+25 via first small ad spend)
Day 75:   85 users (+20 via second ad push)
Day 90:  100 users (+15 via referral and organic)
```

Average needed: ~1.3 new paying users per day after Day 30.

### What drives acquisition at this scale

**Referral** — Add a simple referral offer: existing users get ৳300 cashback (via bKash) for each friend who pays. 100 users trying to refer even one person each generates meaningful pipeline. This requires adding a referral code field to `user_profiles` and a manual payout process (you can handle this manually at first — you will have fewer than 50 referrals total). **Do not build referral tracking in the app right now.** Handle it via a Google Form and manual bKash transfers.

**Testimonials** — After each user completes Day 7 (first milestone), WhatsApp them and ask for a voice note or short video. One genuine 30-second video of a freelancer saying "আমার Upwork client এখন আমার English নিয়ে কোনো comment করে না" is worth more than any ad.

**Content** — Post one short video per week on Facebook and LinkedIn. Each video is a single tip Maya gives during a session (e.g., "How to answer 'Tell me about yourself' in under 60 seconds"). End every video with the app download link. No production budget needed — screen record + your voiceover.

**Paid ads (after Day 45 only)**  
Start small: ৳500/day on Facebook targeting:
- Age 22–35, Bangladesh
- Interests: freelancing, Upwork, Fiverr, job interview, IELTS
- Lookalike audience from your first 20 users' phone numbers

The ad creative is your best testimonial video. Do not write ad copy — use the user's own words.

---

## What NOT to Do in 90 Days

These will consume time without moving the user number.

| Temptation | Why to skip it |
|------------|----------------|
| Build iOS before you have 10 paying Android users | Apple review is slower, Bangladesh is ~85% Android |
| Add pronunciation scoring / phoneme engine | Audit explicitly excluded it; users haven't asked for it |
| Build a referral tracking system in the app | Handle manually until 200 users |
| Add more curriculum days beyond Day 30 | No user will reach Day 30 in 90 days |
| Redesign the UI | The design is already production quality |
| Push notifications | Increases app complexity, requires additional permissions |
| Web version | Doubles your QA surface, no user demand established |
| Social login beyond Google | bKash phone number is your best auth for Bangladesh users |
| In-app chat support | Use WhatsApp until you have 200 users |

---

## Revenue Checkpoint

| Milestone | Users | Revenue | Calendar target |
|-----------|-------|---------|-----------------|
| First payment | 1 | ৳1,999 | Day 22 |
| Proof it works | 10 | ৳19,990 | Day 30 |
| Referral kicks in | 20 | ৳39,980 | Day 35 |
| Break-even on infra costs | ~30 | ৳59,970 | Day 45 |
| Ads justify themselves | 50 | ৳99,950 | Day 60 |
| **Goal** | **100** | **৳199,900** | **Day 90** |

Supabase Pro: ~$25/month. Gemini API: ~$10–30/month at this scale. Zinnipay: ~2% per transaction. Total monthly cost at 100 users: under ৳10,000. The unit economics work from user 6 onwards.

---

## The Honest Constraint

The technical work is 10 days. The hard part is convincing 100 strangers to pay ৳1,999 for a new app from an unknown brand. The roadmap above front-loads manual sales and trust-building because that is the actual bottleneck — not the code.

Every day spent adding features is a day not spent talking to a potential user. The app is good enough to charge for right now, once the five audit blockers are fixed.
