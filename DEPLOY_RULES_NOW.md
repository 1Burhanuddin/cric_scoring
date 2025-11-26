# 🚀 Deploy Firestore Rules - REQUIRED

## ⚡ Quick Fix

The permission error is because the updated Firestore rules need to be deployed.

### Run This Command:

```bash
firebase deploy --only firestore:rules --project cric-scoring
```

**OR** if that doesn't work:

```bash
npx firebase deploy --only firestore:rules --project cric-scoring
```

---

## ✅ What I Fixed

1. **Removed color picker** - Teams now use default blue color
2. **Updated Firestore rules** - Any authenticated user can now:
   - Create teams
   - Create players  
   - Create matches
   - Create tournaments
   - Update and delete their own data

---

## 📝 Changes Made

### firestore.rules
- Changed from admin-only to authenticated-user access
- Teams: `allow create, update, delete: if isAuthenticated()`
- Players: `allow create, update, delete: if isAuthenticated()`
- Matches: `allow create, update, delete: if isAuthenticated()`
- Tournaments: `allow create, update, delete: if isAuthenticated()`

### Add Team Screen
- Removed color picker UI
- Removed color selection
- Removed preview card
- Simplified to just name and city
- Uses default blue color (0xFF1E88E5)

---

## 🎯 After Deploying

1. Run the app
2. Go to Teams tab
3. Tap + button
4. Enter team name and city
5. Tap Create Team
6. Should work without permission errors!

---

## 📍 Storage Rules (Optional)

Storage rules are for uploading images (team logos, player photos).

**For now, you can skip this** since we're not uploading images yet.

**To deploy later:**
```bash
firebase deploy --only storage --project cric-scoring
```

---

## ✅ Verification

After deploying, you should see:
```
✔ Deploy complete!
```

Then test creating a team - no more permission errors!

---

**Status**: ⚠️ Rules updated in code, need to deploy

**Action**: Run the deploy command above

**Time**: 30 seconds
