# Player Management & Live Scoring Guide

## Features Added

### 1. Player Management
- **Add Players**: Create players with name, jersey number, role, batting/bowling style
- **Team Players**: Add players to teams from the Teams screen
- **Player Roles**: Batsman, Bowler, All-rounder, Wicket Keeper
- **Captain & WK Badges**: Visual indicators for team roles

### 2. Live Scoring with Player Selection
- **Striker & Non-Striker**: Select batting players before scoring
- **Bowler Selection**: Choose the current bowler
- **Auto Swap**: Batsmen automatically swap on odd runs (1, 3, 5, 7)
- **Manual Swap**: Button to manually swap striker/non-striker
- **Wicket Handling**: Striker is cleared after wicket to select new batsman

### 3. Stats Tracking
- All balls are recorded with:
  - Batsman ID (striker)
  - Bowler ID
  - Runs scored
  - Extras (wide, no-ball, bye, leg-bye)
  - Wickets

## How to Use

### Step 1: Add Players
1. Go to **Teams** tab
2. Tap the **people icon** on any team card
3. Tap **+ Add Player**
4. Either:
   - Select existing player from list
   - Tap **New** to create a new player

### Step 2: Create a Match
1. Go to **Matches** tab
2. Tap **+ New Match**
3. Select teams, overs, ground, date
4. Tap **Create Match**

### Step 3: Start Match
1. Tap on the match from the list
2. Tap **Start Match**
3. Select toss winner and decision (Bat/Bowl)
4. Match status changes to **Live**

### Step 4: Live Scoring
1. **Select Players**:
   - Tap "Select Player" for Striker
   - Tap "Select Player" for Non-Striker
   - Tap "Select Player" for Bowler

2. **Record Balls**:
   - Tap run buttons (0-7) to record runs
   - Batsmen auto-swap on odd runs
   - Use swap button (⇄) to manually swap

3. **Record Extras**:
   - Tap Wide, No Ball, Bye, or Leg Bye
   - Extra runs are added automatically

4. **Record Wickets**:
   - Tap **WICKET** button
   - Striker is cleared
   - Select new batsman to continue

5. **Undo**:
   - Tap undo button (↶) in app bar to reverse last ball

## Data Structure

### Firestore Collections
```
players/
  {playerId}/
    - name, role, jerseyNumber, battingStyle, bowlingStyle

teams/
  {teamId}/
    players/
      {playerId}/
        - playerId, name, role, jerseyNumber, isCaptain, isWicketKeeper

matches/
  {matchId}/
    innings/
      {inningsNumber}/
        - runs, wickets, overs, extras
    
    balls/
      {ballId}/
        - batsmanId, bowlerId, runs, isWide, isNoBall, isWicket, etc.
```

## Next Steps
- Add batting/bowling stats calculation
- Show player stats in match
- Add wicket type selection dialog
- Add runs dialog for extras (e.g., 2 wides, 4 byes)
- Add over completion handling
- Add innings completion
- Add match result calculation
