# Cricket Scoring App - Current Status

## ✅ What's Working

### 1. Authentication
- User registration with email/password
- Login/logout functionality
- Password reset
- User documents created in Firestore

### 2. Teams Management
- Create teams (name, city, color)
- View teams from Firestore
- Real-time updates
- Team stats tracking

### 3. Player Management (User-based)
- Users can complete player profile (jersey #, role, batting/bowling style)
- Add users as players to teams
- View team rosters
- Remove players from teams

### 4. Match Management
- Create matches with team selection
- Set overs, ground, date
- Match status (upcoming, live, completed)
- Toss and match start

### 5. Live Scoring
- Select striker, non-striker, bowler
- Record runs (0-7)
- Record extras (wide, no-ball, bye, leg-bye)
- Record wickets
- Auto-swap batsmen on odd runs
- Undo last ball
- Ball-by-ball tracking

## 🔧 How to Use

### Step 1: Register Users
1. Sign up with email/password
2. Go to Profile → Complete Player Profile
3. Fill in jersey number, role, batting/bowling style

### Step 2: Create Teams
1. Go to Teams tab
2. Tap + button
3. Enter team name and city
4. Select team color

### Step 3: Add Players to Teams
1. Go to Teams tab
2. Tap the people icon on a team card
3. Tap "Add Player"
4. Select users who have completed their player profile
5. Users with ✓ can be added, users with ⚠️ need to complete profile first

### Step 4: Create Match
1. Go to Matches tab
2. Tap "New Match"
3. Select both teams
4. Set overs, ground, date
5. Create match

### Step 5: Start Scoring
1. Tap on match from list
2. Tap "Start Match"
3. Select toss winner and decision
4. Select striker, non-striker, and bowler
5. Start recording balls!

## 📊 Data Structure

```
users/
  {userId}/
    - name, email, role
    - jerseyNumber, playerRole, battingStyle, bowlingStyle

teams/
  {teamId}/
    - name, city, color, stats
    players/
      {userId}/
        - playerId, name, role, jerseyNumber, isCaptain, isWicketKeeper

matches/
  {matchId}/
    - teamA, teamB, overs, ground, date, status
    innings/
      {inningsNumber}/
        - runs, wickets, overs, extras
    balls/
      {ballId}/
        - batsmanId, bowlerId, runs, isWicket, extras
```

## 🔒 Firestore Rules

Current rules allow:
- Any authenticated user to read all data
- Users to create/update their own profile
- Any authenticated user to create teams, matches, and record balls

## ⚠️ Important Notes

1. **Users must complete player profile** before being added to teams
2. **Deploy Firestore rules** to Firebase Console for permissions to work
3. **Real-time updates** - All data syncs automatically
4. **No test data** - All data comes from Firestore

## 🐛 Troubleshooting

### "No users available" when adding players
- Make sure users have registered
- Check that users completed their player profile
- Verify Firestore rules are deployed

### "Permission denied" errors
- Deploy the updated firestore.rules to Firebase Console
- Make sure user is logged in

### "Profile setup required" message
- Click "Refresh" button
- Log out and log back in
- Check Firebase Console to see if user document exists

## 🚀 Next Steps

- Add batting/bowling statistics calculation
- Add player performance dashboard
- Add match summary and scorecard
- Add over completion handling
- Add innings completion
- Add match result calculation
- Add team standings and rankings
