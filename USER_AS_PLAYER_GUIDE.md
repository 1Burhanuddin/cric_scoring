# User as Player System - Complete Guide

## Overview
The system now uses **authenticated users** as players instead of creating separate player records. Any user who signs up can complete their player profile and be added to teams.

## How It Works

### 1. User Registration
- Users sign up with email/password through the app
- User profile is created in `users/{userId}` collection
- Initially, users have NO player profile

### 2. Complete Player Profile
Users need to complete their player profile to be added to teams:

**Profile Fields:**
- **Jersey Number** (1-99): Their shirt number
- **Player Role**: Batsman, Bowler, All-rounder, or Wicket Keeper
- **Batting Style**: Right Hand or Left Hand
- **Bowling Style** (Optional): Fast, Medium, or Spin variations

**How to Complete:**
1. Navigate to Profile screen
2. Tap "Update Player Profile"
3. Fill in all required fields
4. Save profile

### 3. Adding Players to Teams
Team managers can add users to their teams:

1. Go to **Teams** tab
2. Tap the **people icon** on any team card
3. Tap **+ Add Player**
4. Select from list of registered users
5. Users with ✓ (green check) have complete player profiles
6. Users with ⚠️ (orange warning) need to complete their profile first

### 4. Live Scoring with Real Users
During match scoring:
- Select striker/non-striker from team players
- Select bowler from bowling team
- All stats are tracked against real user accounts
- Users can see their own batting/bowling stats

## Data Structure

### Users Collection
```
users/
  {userId}/
    - name: "John Doe"
    - email: "john@example.com"
    - role: "viewer" | "scorer" | "admin"
    - jerseyNumber: 10
    - playerRole: "batsman" | "bowler" | "allrounder" | "wicketkeeper"
    - battingStyle: "right-hand" | "left-hand"
    - bowlingStyle: "right-arm-fast" | "left-arm-spin" | etc.
```

### Team Players (Subcollection)
```
teams/
  {teamId}/
    players/
      {userId}/
        - playerId: userId
        - name: "John Doe"
        - role: "batsman"
        - jerseyNumber: 10
        - isCaptain: false
        - isWicketKeeper: false
```

### Match Balls (With User IDs)
```
matches/
  {matchId}/
    balls/
      {ballId}/
        - batsmanId: userId (striker)
        - bowlerId: userId
        - runs: 4
        - isWicket: false
```

## Benefits

1. **Single Source of Truth**: User data is centralized
2. **Real Stats**: Stats are tied to actual user accounts
3. **Easy Management**: No duplicate player records
4. **User Engagement**: Users can track their own performance
5. **Authentication**: Only registered users can play

## User Flow

### For Players:
1. Sign up → 2. Complete player profile → 3. Get added to team → 4. Play matches

### For Team Managers:
1. Create team → 2. Add registered users as players → 3. Create matches → 4. Start scoring

### For Scorers:
1. Open match → 2. Select players from team rosters → 3. Record balls → 4. Stats auto-tracked

## Next Steps

- Add player stats dashboard (batting/bowling averages)
- Add user profile screen showing their teams and stats
- Add notifications when added to a team
- Add player search/filter in team selection
- Add player availability status
