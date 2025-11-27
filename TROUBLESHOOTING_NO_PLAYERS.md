# Troubleshooting: No Players in Match Creation

## Problem
Players show in Teams screen but not in Playing XI screen during match creation.

## Root Cause
Players are added to one team, but you're selecting a different team in match creation.

## Solution

### Step 1: Identify the Team IDs

From your screenshot, the teams are:
- **Team 1 ("first")**: `MNVBWAPz7Ej90LIef2Ev`
- **Team 2 ("second")**: `uBNAOyBHlkhDzEikPK0z`

### Step 2: Check Firebase Console

1. Go to Firebase Console → Firestore Database
2. Navigate to `teams` collection
3. Find these exact team IDs
4. Check their `players` subcollection

### Step 3: Add Players to These Teams

**Option A: Using the App**

1. Go to **Teams** tab in the app
2. Find the team named **"first"**
3. Open it
4. Tap **"Add Player"** button
5. Select at least 2 users
6. Repeat for team **"second"**

**Option B: Firebase Console (Manual)**

For each team:
1. Go to `teams/{teamId}/players`
2. Add documents with player data:

```
Document ID: [user's UID]

Fields:
playerId: [user's UID]
name: [player name]
role: batsman
jerseyNumber: 1
isCaptain: false
isWicketKeeper: false
addedAt: [server timestamp]
```

### Step 4: Verify

1. Go back to match creation
2. Select the same teams
3. Players should now appear!

## Common Mistakes

❌ **Adding players to wrong team**
- You add players to "Team A"
- But select "Team B" in match creation

❌ **Multiple teams with same name**
- You have 2 teams named "India"
- Players in one, but selecting the other

❌ **Wrong Firestore path**
- Players in `users` collection ✗
- Should be in `teams/{teamId}/players` ✓

## Quick Check

Run this in your browser console on Firebase:
```javascript
// Check if players exist
db.collection('teams')
  .doc('MNVBWAPz7Ej90LIef2Ev')
  .collection('players')
  .get()
  .then(snap => console.log('Team 1 players:', snap.size));

db.collection('teams')
  .doc('uBNAOyBHlkhDzEikPK0z')
  .collection('players')
  .get()
  .then(snap => console.log('Team 2 players:', snap.size));
```

## Prevention

Always:
1. Create teams first
2. Add players to those teams
3. Use the SAME teams in match creation
4. Check team names match exactly

## Still Not Working?

Check console logs for:
```
teamPlayersProvider: Fetching players for team: [teamId]
teamPlayersProvider: Got X players for team [teamId]
```

If it says "Got 0 players", the subcollection is empty!
