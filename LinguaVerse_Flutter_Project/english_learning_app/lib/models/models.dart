import 'package:cloud_firestore/cloud_firestore.dart';

// ─────────────────────────────────────────────
// User Model
// ─────────────────────────────────────────────
class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final String avatarUrl;
  final int level;
  final int xp;
  final int streak;
  final int gems;
  final List<String> completedLessons;
  final List<String> achievements;
  final DateTime createdAt;
  final DateTime lastActive;
  final UserSettings settings;

  UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    this.avatarUrl = '',
    this.level = 1,
    this.xp = 0,
    this.streak = 0,
    this.gems = 50,
    this.completedLessons = const [],
    this.achievements = const [],
    required this.createdAt,
    required this.lastActive,
    UserSettings? settings,
  }) : settings = settings ?? UserSettings();

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? 'Learner',
      avatarUrl: data['avatarUrl'] ?? '',
      level: data['level'] ?? 1,
      xp: data['xp'] ?? 0,
      streak: data['streak'] ?? 0,
      gems: data['gems'] ?? 50,
      completedLessons: List<String>.from(data['completedLessons'] ?? []),
      achievements: List<String>.from(data['achievements'] ?? []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastActive: (data['lastActive'] as Timestamp?)?.toDate() ?? DateTime.now(),
      settings: data['settings'] != null
          ? UserSettings.fromMap(data['settings'])
          : UserSettings(),
    );
  }

  Map<String, dynamic> toMap() => {
        'email': email,
        'displayName': displayName,
        'avatarUrl': avatarUrl,
        'level': level,
        'xp': xp,
        'streak': streak,
        'gems': gems,
        'completedLessons': completedLessons,
        'achievements': achievements,
        'createdAt': Timestamp.fromDate(createdAt),
        'lastActive': Timestamp.fromDate(lastActive),
        'settings': settings.toMap(),
      };

  int get xpToNextLevel => level * 100;
  double get levelProgress => xp / xpToNextLevel;
}

class UserSettings {
  final bool darkMode;
  final bool soundEnabled;
  final bool notificationsEnabled;
  final String dailyGoal; // 'easy', 'medium', 'hard', 'intense'
  final String nativeLanguage;

  UserSettings({
    this.darkMode = false,
    this.soundEnabled = true,
    this.notificationsEnabled = true,
    this.dailyGoal = 'medium',
    this.nativeLanguage = 'auto',
  });

  factory UserSettings.fromMap(Map<String, dynamic> map) => UserSettings(
        darkMode: map['darkMode'] ?? false,
        soundEnabled: map['soundEnabled'] ?? true,
        notificationsEnabled: map['notificationsEnabled'] ?? true,
        dailyGoal: map['dailyGoal'] ?? 'medium',
        nativeLanguage: map['nativeLanguage'] ?? 'auto',
      );

  Map<String, dynamic> toMap() => {
        'darkMode': darkMode,
        'soundEnabled': soundEnabled,
        'notificationsEnabled': notificationsEnabled,
        'dailyGoal': dailyGoal,
        'nativeLanguage': nativeLanguage,
      };
}

// ─────────────────────────────────────────────
// Lesson Model
// ─────────────────────────────────────────────
enum LessonCategory {
  vocabulary,
  grammar,
  pronunciation,
  listening,
  reading,
  writing,
  conversation,
}

enum DifficultyLevel {
  beginner,
  elementary,
  intermediate,
  upperIntermediate,
  advanced,
}

class Lesson {
  final String id;
  final String title;
  final String description;
  final LessonCategory category;
  final DifficultyLevel difficulty;
  final String iconEmoji;
  final List<LessonStep> steps;
  final int xpReward;
  final int estimatedMinutes;
  final List<String> tags;
  final String? prerequisiteLessonId;

  Lesson({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.difficulty,
    required this.iconEmoji,
    required this.steps,
    this.xpReward = 20,
    this.estimatedMinutes = 10,
    this.tags = const [],
    this.prerequisiteLessonId,
  });

  factory Lesson.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Lesson(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      category: LessonCategory.values[data['category'] ?? 0],
      difficulty: DifficultyLevel.values[data['difficulty'] ?? 0],
      iconEmoji: data['iconEmoji'] ?? '📚',
      steps: (data['steps'] as List?)
              ?.map((s) => LessonStep.fromMap(s))
              .toList() ??
          [],
      xpReward: data['xpReward'] ?? 20,
      estimatedMinutes: data['estimatedMinutes'] ?? 10,
      tags: List<String>.from(data['tags'] ?? []),
      prerequisiteLessonId: data['prerequisiteLessonId'],
    );
  }

  Map<String, dynamic> toMap() => {
        'title': title,
        'description': description,
        'category': category.index,
        'difficulty': difficulty.index,
        'iconEmoji': iconEmoji,
        'steps': steps.map((s) => s.toMap()).toList(),
        'xpReward': xpReward,
        'estimatedMinutes': estimatedMinutes,
        'tags': tags,
        'prerequisiteLessonId': prerequisiteLessonId,
      };
}

// ─────────────────────────────────────────────
// Lesson Step Types
// ─────────────────────────────────────────────
enum StepType {
  info,
  multipleChoice,
  fillBlank,
  matchPairs,
  listenAndChoose,
  speakAndCheck,
  arrangeWords,
  typeSentence,
  flashcard,
  conversation3D,
}

class LessonStep {
  final String id;
  final StepType type;
  final String instruction;
  final String? content;
  final String? audioUrl;
  final String? imageUrl;
  final List<String>? options;
  final String? correctAnswer;
  final List<String>? correctOrder;
  final Map<String, String>? matchPairs;
  final String? hint;
  final String? explanation;

  LessonStep({
    required this.id,
    required this.type,
    required this.instruction,
    this.content,
    this.audioUrl,
    this.imageUrl,
    this.options,
    this.correctAnswer,
    this.correctOrder,
    this.matchPairs,
    this.hint,
    this.explanation,
  });

  factory LessonStep.fromMap(Map<String, dynamic> map) => LessonStep(
        id: map['id'] ?? '',
        type: StepType.values[map['type'] ?? 0],
        instruction: map['instruction'] ?? '',
        content: map['content'],
        audioUrl: map['audioUrl'],
        imageUrl: map['imageUrl'],
        options: map['options'] != null ? List<String>.from(map['options']) : null,
        correctAnswer: map['correctAnswer'],
        correctOrder:
            map['correctOrder'] != null ? List<String>.from(map['correctOrder']) : null,
        matchPairs: map['matchPairs'] != null
            ? Map<String, String>.from(map['matchPairs'])
            : null,
        hint: map['hint'],
        explanation: map['explanation'],
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'type': type.index,
        'instruction': instruction,
        'content': content,
        'audioUrl': audioUrl,
        'imageUrl': imageUrl,
        'options': options,
        'correctAnswer': correctAnswer,
        'correctOrder': correctOrder,
        'matchPairs': matchPairs,
        'hint': hint,
        'explanation': explanation,
      };
}

// ─────────────────────────────────────────────
// Achievement Model
// ─────────────────────────────────────────────
class Achievement {
  final String id;
  final String title;
  final String description;
  final String iconEmoji;
  final int xpReward;
  final bool unlocked;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.iconEmoji,
    this.xpReward = 50,
    this.unlocked = false,
  });
}

// ─────────────────────────────────────────────
// Word / Vocabulary Model
// ─────────────────────────────────────────────
class VocabWord {
  final String word;
  final String phonetic;
  final String definition;
  final String exampleSentence;
  final String partOfSpeech;
  final String? audioUrl;
  final String? imageUrl;
  final List<String> synonyms;
  final List<String> antonyms;
  int masteryLevel; // 0-5 (spaced repetition)

  VocabWord({
    required this.word,
    required this.phonetic,
    required this.definition,
    required this.exampleSentence,
    required this.partOfSpeech,
    this.audioUrl,
    this.imageUrl,
    this.synonyms = const [],
    this.antonyms = const [],
    this.masteryLevel = 0,
  });

  factory VocabWord.fromMap(Map<String, dynamic> map) => VocabWord(
        word: map['word'] ?? '',
        phonetic: map['phonetic'] ?? '',
        definition: map['definition'] ?? '',
        exampleSentence: map['exampleSentence'] ?? '',
        partOfSpeech: map['partOfSpeech'] ?? '',
        audioUrl: map['audioUrl'],
        imageUrl: map['imageUrl'],
        synonyms: List<String>.from(map['synonyms'] ?? []),
        antonyms: List<String>.from(map['antonyms'] ?? []),
        masteryLevel: map['masteryLevel'] ?? 0,
      );

  Map<String, dynamic> toMap() => {
        'word': word,
        'phonetic': phonetic,
        'definition': definition,
        'exampleSentence': exampleSentence,
        'partOfSpeech': partOfSpeech,
        'audioUrl': audioUrl,
        'imageUrl': imageUrl,
        'synonyms': synonyms,
        'antonyms': antonyms,
        'masteryLevel': masteryLevel,
      };
}

// ─────────────────────────────────────────────
// Learning Path Model
// ─────────────────────────────────────────────
class LearningPath {
  final String id;
  final String name;
  final String description;
  final List<String> lessonIds;
  final String badgeEmoji;
  final DifficultyLevel difficulty;

  LearningPath({
    required this.id,
    required this.name,
    required this.description,
    required this.lessonIds,
    required this.badgeEmoji,
    required this.difficulty,
  });
}
