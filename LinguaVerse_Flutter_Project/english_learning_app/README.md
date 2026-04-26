# 🌍 LinguaVerse — Interactive English Learning Platform

An interactive, automated English learning app built with **Flutter + Firebase**, featuring **3D visualization**, gamification, speech recognition, and adaptive learning.

---

## ✨ Features

### 🎓 Learning Modules
- **Vocabulary** — Flashcards with spaced repetition, mastery tracking, synonyms/antonyms
- **Grammar** — Interactive exercises (fill-blank, arrange words, multiple choice)
- **Pronunciation** — Speech-to-text practice with real-time feedback
- **Listening** — Audio comprehension exercises
- **Reading** — Passage comprehension with quizzes
- **Conversation** — 3D scene-based dialogue practice

### 🎮 3D Visualization
- **Interactive 3D scenes** — Restaurant, Airport, City environments
- **Drag-to-look** gesture controls with perspective rendering
- **Animated characters** with floating/bouncing effects
- **Custom Canvas painters** with perspective grids, lighting, and parallax

### 🏆 Gamification
- **XP & Levels** — Earn experience points, level up from Beginner to Master
- **Daily Streaks** — Track consecutive learning days
- **Gems** — Virtual currency for unlocking content
- **Achievements** — Unlock badges for milestones
- **Leaderboard** — Compete with other learners globally

### 🔥 Firebase Integration
- **Authentication** — Email/password sign-up/sign-in
- **Cloud Firestore** — Lessons, user progress, vocabulary, leaderboard
- **Firebase Storage** — Audio files, lesson images
- **Analytics** — Track user engagement and learning patterns

### 📱 UI/UX
- **Material 3** with custom theming (Poppins + Inter fonts)
- **Light & Dark mode** toggle
- **Smooth animations** — Page transitions, confetti, pulsing buttons
- **Responsive layout** — Works on phones and tablets

---

## 📁 Project Structure

```
english_learning_app/
├── lib/
│   ├── main.dart                    # App entry point, Firebase init
│   ├── firebase_options.dart        # Firebase configuration
│   ├── theme/
│   │   └── app_theme.dart           # Light/Dark themes, gradients, colors
│   ├── models/
│   │   └── models.dart              # UserModel, Lesson, VocabWord, etc.
│   ├── services/
│   │   ├── firebase_service.dart    # Auth, Firestore CRUD, seeding
│   │   └── speech_service.dart      # TTS, STT, sound effects
│   ├── providers/
│   │   ├── auth_provider.dart       # Authentication state
│   │   ├── learning_provider.dart   # Lesson flow, progress
│   │   ├── progress_provider.dart   # XP, streaks, stats
│   │   └── theme_provider.dart      # Dark/Light mode
│   ├── screens/
│   │   ├── splash_screen.dart       # Animated splash with 3D globe
│   │   ├── onboarding_screen.dart   # 3-page feature introduction
│   │   ├── auth_screen.dart         # Sign in / Sign up / Demo mode
│   │   ├── home_screen.dart         # Dashboard with bottom nav
│   │   ├── lesson_screen.dart       # Interactive lesson flow
│   │   ├── vocabulary_screen.dart   # 3D flip flashcards
│   │   ├── progress_screen.dart     # Charts, skill breakdown
│   │   └── profile_screen.dart      # Settings, achievements
│   └── widgets/
│       ├── category_card.dart       # Category, Streak, LessonCard
│       ├── exercise_widgets.dart    # All exercise types
│       ├── scene_3d_widget.dart     # 3D environment painter
│       ├── streak_widget.dart       # Streak display
│       └── lesson_card.dart         # Lesson card
├── android/app/build.gradle         # Android config with Firebase
├── firestore.rules                  # Firestore security rules
├── pubspec.yaml                     # Dependencies
└── README.md
```

---

## 🚀 Setup Instructions

### Prerequisites
- Flutter SDK 3.2+ installed
- Android Studio with Flutter/Dart plugins
- A Firebase project

### Step 1: Clone & Install
```bash
# Create Flutter project (if starting fresh)
flutter create english_learning_app
# Then replace lib/ and other files with this project's files

# Or simply copy all files into your project directory
cd english_learning_app
flutter pub get
```

### Step 2: Firebase Setup
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project (or use existing)
3. Add an **Android app**:
   - Package name: `com.linguaverse.english_learning_app`
   - Download `google-services.json`
   - Place it in `android/app/`
4. Enable **Authentication** → Email/Password
5. Create **Cloud Firestore** database
6. Deploy security rules from `firestore.rules`

#### Auto-configure with FlutterFire CLI (recommended):
```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase (auto-generates firebase_options.dart)
flutterfire configure
```

#### Manual configuration:
Edit `lib/firebase_options.dart` and replace all `YOUR_*` placeholders with values from Firebase Console → Project Settings.

### Step 3: Update main.dart for Firebase Options
```dart
// In main.dart, update Firebase.initializeApp:
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
```
Add this import:
```dart
import 'firebase_options.dart';
```

### Step 4: Android Configuration
Ensure `android/app/build.gradle` has:
- `minSdk 23`
- `multiDexEnabled true`
- Google Services plugin applied

Ensure `android/build.gradle` (root) has:
```gradle
buildscript {
    dependencies {
        classpath 'com.google.gms:google-services:4.4.0'
    }
}
```

### Step 5: Run
```bash
# Connect device or start emulator
flutter run

# For release build
flutter build apk --release
```

---

## 🎮 Demo Mode

The app includes a **Demo Mode** button on the login screen that lets you explore all features without creating a Firebase account. Demo mode:
- Pre-loads 6 built-in lessons across categories
- Initializes sample progress data (Level 4, 7-day streak)
- Enables all vocabulary flashcards
- Shows mock weekly activity charts

---

## 📝 Exercise Types

| Type | Description | Widget |
|------|-------------|--------|
| 📖 Info | Read & learn content cards | `InfoExercise` |
| ✅ Multiple Choice | Select correct answer from options | `MultipleChoiceExercise` |
| ✏️ Fill Blank | Type the missing word | `FillBlankExercise` |
| 🔗 Match Pairs | Connect related items | `MatchPairsExercise` |
| 🔤 Arrange Words | Drag words into correct sentence order | `ArrangeWordsExercise` |
| 🎤 Speak | Pronounce word with speech recognition | `SpeakExercise` |
| 🎮 3D Scene | Interactive conversation in 3D environment | `Scene3DWidget` |

---

## 🎨 3D Visualization Details

The 3D scenes use **CustomPainter** with manual perspective projection:

- **Perspective floor grids** with vanishing point lines
- **3D furniture rendering** (tables, chairs, counters) with depth shading
- **Animated elements**: candle flames, floating characters, bouncing effects
- **Interactive rotation**: Pan gesture to look around the scene
- **Scene types**: Restaurant (evening dining), Airport (check-in counter), City (street navigation)

The vocabulary flashcards also use **3D flip animation** with `Matrix4.rotateY()` for a realistic card-turning effect.

---

## 🔧 Key Dependencies

| Package | Purpose |
|---------|---------|
| `firebase_core` | Firebase initialization |
| `firebase_auth` | User authentication |
| `cloud_firestore` | Database for lessons & progress |
| `provider` | State management |
| `flutter_tts` | Text-to-speech for pronunciation |
| `speech_to_text` | Speech recognition for speaking exercises |
| `fl_chart` | Weekly activity bar charts |
| `percent_indicator` | Progress bars and circular indicators |
| `confetti` | Celebration effects on correct answers |
| `vector_math` | 3D math operations |
| `google_fonts` | Poppins & Inter typography |

---

## 📄 License

MIT License — Free for personal and commercial use.
