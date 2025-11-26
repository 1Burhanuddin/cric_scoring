# Cric Scoring App 🏏

A CricHeroes-style cricket scoring and management app built using Flutter and Firebase. Features include player profiles, teams, tournaments, matches, live scoring, and detailed statistics.

## 📌 Project Overview

This is a comprehensive cricket management application that allows users to:
- Create and manage teams and players
- Organize tournaments
- Score matches live with ball-by-ball updates
- View detailed statistics and leaderboards
- Track player and team performance

## 🎨 Design Philosophy

- **Compact UI**: 10-15% smaller components for efficient space usage
- **Material 3**: Modern design with consistent theming
- **Responsive**: Adapts to different screen sizes
- **Clean**: Minimal padding, subtle shadows, and clear typography

## 🧱 Project Structure Roadmap

### ✅ PHASE 1 — UI & Navigation (COMPLETED)

Design all screens before integrating Firebase.

**Completed Components:**
- ✅ App Theme (compact style with Material 3)
- ✅ Splash Screen
- ✅ Bottom Navigation (5 tabs: Home, Matches, Players, Teams, Tournaments)
- ✅ Home Screen with Quick Actions
- ✅ Player Profile UI (with tabs: Overview, Batting, Bowling, Activity)
- ✅ Player Profile Overview Screen (enhanced version)
- ✅ Players List Screen
- ✅ Teams UI (List & Details with tabs)
- ✅ Team Details Overview Screen (Players, Matches, Stats tabs)
- ✅ Matches List & Details UI (with tabs: Summary, Scorecard, Squads, Overs)
- ✅ Tournament UI (List & Details)
- ✅ Tournament Details Overview Screen (Matches, Teams, Points Table, Stats tabs)
- ✅ Stats & Leaderboards UI
- ✅ Navigation Setup for all screens

**UI Features:**
- Compact sizing (10-12px padding)
- Small icons (12-14px)
- Minimal card elevation
- Responsive scrollable layouts
- Color-coded status indicators
- Material 3 tab navigation
- Gradient headers

👉 **UI is fully ready for backend integration.**

---

### 🔄 PHASE 2 — Firebase Initialization (NEXT)

After UI screens are completed:

**Tasks:**
- [ ] Setup Firebase in Flutter
  - Add Firebase dependencies to `pubspec.yaml`
  - Configure Firebase for Android
  - Configure Firebase for iOS (if needed)
- [ ] Configure Firebase Authentication
- [ ] Setup Firestore Database
- [ ] Setup Firebase Storage (for images)
- [ ] Create test/mock data
- [ ] Plan database collection structure

**Planned Collections:**
```
users/
  - uid
  - name
  - email
  - role (admin/scorer/viewer)
  - photoUrl
  - createdAt

teams/
  - teamId
  - name
  - city
  - logoUrl
  - players[]
  - stats{}
  - createdAt

players/
  - playerId
  - name
  - role
  - battingStyle
  - bowlingStyle
  - age
  - city
  - photoUrl
  - stats{}
  - teamId

tournaments/
  - tournamentId
  - name
  - location
  - format
  - overs
  - ballType
  - teams[]
  - matches[]
  - status
  - startDate
  - endDate

matches/
  - matchId
  - tournamentId
  - teamA
  - teamB
  - venue
  - date
  - status
  - tossWinner
  - innings[]
  - result

innings/
  - inningId
  - matchId
  - battingTeam
  - bowlingTeam
  - overs[]
  - score
  - wickets

overs/
  - overId
  - inningId
  - overNumber
  - bowler
  - balls[]
```

---

### 🔐 PHASE 3 — Authentication Module

Implement role-based user system:

**Tasks:**
- [ ] Signup / Login UI
- [ ] Email password authentication
- [ ] Forgot password flow
- [ ] Admin / Scorer / Viewer roles
- [ ] User profile basics in Firestore
- [ ] Role-based access control
- [ ] Session management

**User Roles:**
- **Admin**: Full access (create/edit/delete)
- **Scorer**: Can score matches and update data
- **Viewer**: Read-only access

---

### 👥 PHASE 4 — Team & Player Management

Admin functions:

**Tasks:**
- [ ] Create Team
- [ ] Add/Edit Players
- [ ] Upload team logo & player photos
- [ ] Validate roles (Batsman/Bowler/All-Rounder/WK)
- [ ] Delete team/player
- [ ] Search and filter

**Frontend displays:**
- [ ] Player list (with real data)
- [ ] Team list (with real data)
- [ ] Team details (with real data)
- [ ] Player profile (with real data)

---

### 🏏 PHASE 5 — Match Creation

Once teams exist:

**Tasks:**
- [ ] Create new match
- [ ] Select two teams
- [ ] Match format (10/20/30/50 overs)
- [ ] Choose playing XI
- [ ] Toss & selection
- [ ] Match status: Upcoming / Live
- [ ] Edit match details
- [ ] Delete match

---

### ⚡ PHASE 6 — Live Scoring Engine

The largest module:

**Tasks:**
- [ ] Ball-by-ball updates
- [ ] Runs, extras, wickets
- [ ] Bowler/Striker/Non-striker selection
- [ ] Over completion logic
- [ ] Real-time updates via Firestore streams
- [ ] Auto syncing UI
- [ ] Undo last ball
- [ ] End innings
- [ ] Declare result
- [ ] Player of the match selection

**Scoring Features:**
- Runs: 0, 1, 2, 3, 4, 6
- Extras: Wide, No Ball, Bye, Leg Bye
- Wickets: Bowled, Caught, LBW, Run Out, Stumped, etc.
- Strike rotation
- Bowler change
- Partnership tracking
- Fall of wickets

---

### 🏆 PHASE 7 — Tournament Logic

After match flow works:

**Tasks:**
- [ ] Create tournament
- [ ] Add teams
- [ ] Add matches
- [ ] Auto points table
- [ ] Auto NRR calculation
- [ ] Leaderboards
- [ ] Player & team stats aggregation
- [ ] Tournament winner
- [ ] Awards (Orange Cap, Purple Cap, etc.)

**Tournament Features:**
- League format
- Knockout format
- Mixed format
- Points calculation
- Net Run Rate (NRR)
- Top scorers/wicket-takers

---

### 🚀 PHASE 8 — Polishing & Deployment

Final:

**Tasks:**
- [ ] UI polish
- [ ] Testing (unit, widget, integration)
- [ ] Performance optimizations
- [ ] Bug fixes
- [ ] Error handling
- [ ] Loading states
- [ ] Offline support
- [ ] Push notifications
- [ ] Analytics
- [ ] Publish to Play Store (optional)

---

## 🛠️ Tech Stack

- **Frontend**: Flutter (Dart)
- **Backend**: Firebase
  - Authentication
  - Firestore Database
  - Storage
  - Cloud Functions (optional)
- **State Management**: Provider / Riverpod (TBD)
- **Design**: Material 3

---

## 📱 Screens Overview

### Main Navigation (Bottom Nav Bar)
1. **Home** - Quick actions, upcoming matches, recent matches
2. **Matches** - Live, upcoming, and completed matches
3. **Players** - Player list and profiles
4. **Teams** - Team list and details
5. **Tournaments** - Tournament list and details

### Detailed Screens
- **Player Profile Overview** - Stats, batting, bowling, activity
- **Team Details Overview** - Players, matches, stats
- **Match Details** - Summary, scorecard, squads, overs
- **Tournament Details** - Matches, teams, points table, stats
- **Live Scoring** - Ball-by-ball scoring interface (TBD)

---

## 🎨 Theme Configuration

The app uses a compact Material 3 theme with:
- **Primary Color**: Blue (#1E88E5)
- **Secondary Color**: Green (#43A047)
- **Background**: Light Grey (#F8F9FA)
- **Font Sizes**: Reduced by 10-15%
- **Padding**: Compact (10-12px)
- **Card Radius**: 16px
- **Icon Sizes**: 12-20px

---

## 📦 Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.2
  
  # Firebase (to be added in Phase 2)
  # firebase_core: ^latest
  # firebase_auth: ^latest
  # cloud_firestore: ^latest
  # firebase_storage: ^latest
  
  # State Management (TBD)
  # provider: ^latest
  # or riverpod: ^latest
  
  # Image Handling (TBD)
  # image_picker: ^latest
  # cached_network_image: ^latest
```

---

## 🚦 Getting Started

### Prerequisites
- Flutter SDK (3.2.3 or higher)
- Dart SDK
- Android Studio / VS Code
- Firebase account (for Phase 2+)

### Installation

1. Clone the repository
```bash
git clone <repository-url>
cd cric_scoring
```

2. Install dependencies
```bash
flutter pub get
```

3. Run the app
```bash
flutter run
```

---

## 📝 Current Status

**Phase 1 (UI & Navigation)**: ✅ COMPLETED

All UI screens are designed and ready. The app has:
- Complete navigation structure
- All major screens implemented
- Compact, modern design
- Static placeholder data
- Ready for Firebase integration

**Next Step**: Begin Phase 2 - Firebase Initialization

---

## 🤝 Contributing

This is a learning/portfolio project. Contributions, issues, and feature requests are welcome!

---

## 📄 License

This project is for educational purposes.

---

## 👨‍💻 Developer Notes

### Code Organization
```
lib/
├── main.dart
├── theme/
│   └── app_theme.dart
└── screens/
    ├── splash_screen.dart
    ├── main_navigation.dart
    ├── home_screen.dart
    ├── matches_screen.dart
    ├── matches_list_screen.dart
    ├── match_details_screen.dart
    ├── players_screen.dart
    ├── player_profile_screen.dart
    ├── player_profile_overview_screen.dart
    ├── teams_screen.dart
    ├── team_details_screen.dart
    ├── teams_list_screen.dart
    ├── team_details_overview_screen.dart
    ├── tournaments_screen.dart
    ├── tournament_details_screen.dart
    ├── tournament_list_screen.dart
    └── tournament_details_overview_screen.dart
```

### Design Patterns
- **Stateless Widgets**: Used for static UI components
- **Material 3**: Modern design system
- **Responsive Design**: Adapts to different screen sizes
- **Reusable Components**: Card builders, stat widgets, etc.

---

## 📸 Screenshots

(To be added after Phase 1 completion)

---

## 🎯 Future Enhancements

- Dark mode support
- Multiple language support
- Advanced analytics
- Video highlights integration
- Social sharing
- Commentary feature
- Ball tracking visualization
- Player comparison tool

---

**Last Updated**: December 2024  
**Current Phase**: Phase 1 ✅ Complete | Phase 2 🔄 Next
