import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';

class FirebaseService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ── Auth ──
  static User? get currentUser => _auth.currentUser;
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  static Future<UserCredential> signUp(String email, String password, String name) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await credential.user?.updateDisplayName(name);

    // Create user document in Firestore
    await _firestore.collection('users').doc(credential.user!.uid).set(
      UserModel(
        uid: credential.user!.uid,
        email: email,
        displayName: name,
        createdAt: DateTime.now(),
        lastActive: DateTime.now(),
      ).toMap(),
    );
    return credential;
  }

  static Future<UserCredential> signIn(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  static Future<void> signOut() async => await _auth.signOut();

  static Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // ── User Data ──
  static Future<UserModel?> getUserData(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists) return UserModel.fromFirestore(doc);
    return null;
  }

  static Future<void> updateUserData(String uid, Map<String, dynamic> data) async {
    await _firestore.collection('users').doc(uid).update(data);
  }

  static Future<void> addXP(String uid, int amount) async {
    await _firestore.collection('users').doc(uid).update({
      'xp': FieldValue.increment(amount),
      'lastActive': Timestamp.now(),
    });
  }

  static Future<void> completeLesson(String uid, String lessonId, int xp) async {
    await _firestore.collection('users').doc(uid).update({
      'completedLessons': FieldValue.arrayUnion([lessonId]),
      'xp': FieldValue.increment(xp),
      'lastActive': Timestamp.now(),
    });
  }

  // ── Lessons ──
  static Stream<List<Lesson>> getLessons({LessonCategory? category}) {
    Query<Map<String, dynamic>> query = _firestore.collection('lessons');
    if (category != null) {
      query = query.where('category', isEqualTo: category.index);
    }
    return query.snapshots().map(
      (snap) => snap.docs.map((doc) => Lesson.fromFirestore(doc)).toList(),
    );
  }

  static Future<Lesson?> getLesson(String id) async {
    final doc = await _firestore.collection('lessons').doc(id).get();
    if (doc.exists) return Lesson.fromFirestore(doc);
    return null;
  }

  // ── Leaderboard ──
  static Stream<List<UserModel>> getLeaderboard({int limit = 20}) {
    return _firestore
        .collection('users')
        .orderBy('xp', descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (snap) => snap.docs.map((doc) => UserModel.fromFirestore(doc)).toList(),
        );
  }

  // ── Vocab ──
  static Future<void> saveVocabProgress(
      String uid, String wordId, int mastery) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('vocabulary')
        .doc(wordId)
        .set({'masteryLevel': mastery, 'lastReviewed': Timestamp.now()});
  }

  // ── Daily Streak ──
  static Future<int> updateStreak(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    final data = doc.data();
    if (data == null) return 0;

    final lastActive = (data['lastActive'] as Timestamp?)?.toDate();
    final now = DateTime.now();
    int streak = data['streak'] ?? 0;

    if (lastActive != null) {
      final diff = now.difference(lastActive).inDays;
      if (diff == 1) {
        streak++;
      } else if (diff > 1) {
        streak = 1;
      }
    } else {
      streak = 1;
    }

    await _firestore.collection('users').doc(uid).update({
      'streak': streak,
      'lastActive': Timestamp.now(),
    });

    return streak;
  }

  // ── Seed Demo Lessons ──
  static Future<void> seedDemoLessons() async {
    final lessons = _getDemoLessons();
    final batch = _firestore.batch();
    for (final lesson in lessons) {
      batch.set(
        _firestore.collection('lessons').doc(lesson.id),
        lesson.toMap(),
      );
    }
    await batch.commit();
  }

  static List<Lesson> _getDemoLessons() {
    return [
      Lesson(
        id: 'vocab_greetings',
        title: 'Greetings & Introductions',
        description: 'Learn essential greeting phrases and how to introduce yourself.',
        category: LessonCategory.vocabulary,
        difficulty: DifficultyLevel.beginner,
        iconEmoji: '👋',
        xpReward: 25,
        estimatedMinutes: 8,
        tags: ['greetings', 'basics', 'social'],
        steps: [
          LessonStep(
            id: 's1',
            type: StepType.info,
            instruction: 'Welcome! Let\'s learn common English greetings.',
            content: 'In English, there are many ways to say hello. The most common ones are:\n\n• Hello\n• Hi\n• Hey\n• Good morning / afternoon / evening\n• How are you?\n• Nice to meet you!',
          ),
          LessonStep(
            id: 's2',
            type: StepType.multipleChoice,
            instruction: 'Which greeting is most formal?',
            options: ['Hey!', 'What\'s up?', 'Good evening', 'Yo!'],
            correctAnswer: 'Good evening',
            explanation: '"Good evening" is the most formal. "Hey" and "What\'s up" are casual.',
          ),
          LessonStep(
            id: 's3',
            type: StepType.fillBlank,
            instruction: 'Complete: "Nice to ___ you!"',
            correctAnswer: 'meet',
            hint: 'This word means to encounter someone for the first time.',
          ),
          LessonStep(
            id: 's4',
            type: StepType.arrangeWords,
            instruction: 'Put the words in order to form a sentence:',
            correctOrder: ['How', 'are', 'you', 'doing', 'today', '?'],
          ),
          LessonStep(
            id: 's5',
            type: StepType.matchPairs,
            instruction: 'Match each greeting with its response:',
            matchPairs: {
              'How are you?': 'I\'m fine, thanks!',
              'Nice to meet you': 'Nice to meet you too',
              'Good morning': 'Good morning!',
              'What\'s your name?': 'My name is...',
            },
          ),
        ],
      ),
      Lesson(
        id: 'grammar_present_simple',
        title: 'Present Simple Tense',
        description: 'Master the present simple tense for daily routines and facts.',
        category: LessonCategory.grammar,
        difficulty: DifficultyLevel.beginner,
        iconEmoji: '📝',
        xpReward: 30,
        estimatedMinutes: 12,
        tags: ['grammar', 'tenses', 'basics'],
        steps: [
          LessonStep(
            id: 's1',
            type: StepType.info,
            instruction: 'The Present Simple Tense',
            content: 'We use the Present Simple for:\n\n1. Daily routines: "I wake up at 7 AM"\n2. Facts: "The sun rises in the east"\n3. Habits: "She drinks coffee every morning"\n\nRemember: Add -s/-es for he/she/it!',
          ),
          LessonStep(
            id: 's2',
            type: StepType.multipleChoice,
            instruction: 'Choose the correct sentence:',
            options: [
              'She go to school.',
              'She goes to school.',
              'She going to school.',
              'She goed to school.',
            ],
            correctAnswer: 'She goes to school.',
            explanation: 'With "she" (third person singular), we add -es to "go" → "goes".',
          ),
          LessonStep(
            id: 's3',
            type: StepType.fillBlank,
            instruction: 'He ___ (play) football every weekend.',
            correctAnswer: 'plays',
            hint: 'Remember to add -s for he/she/it!',
          ),
          LessonStep(
            id: 's4',
            type: StepType.typeSentence,
            instruction: 'Write a sentence about your morning routine using Present Simple:',
            correctAnswer: '', // Open-ended, AI-checked
          ),
          LessonStep(
            id: 's5',
            type: StepType.arrangeWords,
            instruction: 'Arrange the words:',
            correctOrder: ['They', 'usually', 'eat', 'lunch', 'at', 'noon'],
          ),
        ],
      ),
      Lesson(
        id: 'pronunciation_vowels',
        title: 'English Vowel Sounds',
        description: 'Practice the five main vowel sounds in English.',
        category: LessonCategory.pronunciation,
        difficulty: DifficultyLevel.beginner,
        iconEmoji: '🗣️',
        xpReward: 25,
        estimatedMinutes: 10,
        tags: ['pronunciation', 'vowels', 'speaking'],
        steps: [
          LessonStep(
            id: 's1',
            type: StepType.info,
            instruction: 'English Vowel Sounds',
            content: 'English has 5 vowel letters: A, E, I, O, U\nBut over 15 vowel SOUNDS!\n\nLet\'s start with the short vowels:\n• /æ/ as in "cat"\n• /ɛ/ as in "bed"\n• /ɪ/ as in "sit"\n• /ɒ/ as in "hot"\n• /ʌ/ as in "cup"',
          ),
          LessonStep(
            id: 's2',
            type: StepType.multipleChoice,
            instruction: 'Which word has the same vowel sound as "cat"?',
            options: ['cake', 'bat', 'car', 'coat'],
            correctAnswer: 'bat',
            explanation: 'Both "cat" and "bat" have the short /æ/ sound.',
          ),
          LessonStep(
            id: 's3',
            type: StepType.speakAndCheck,
            instruction: 'Say this word clearly:',
            content: 'BEAUTIFUL',
            correctAnswer: 'beautiful',
          ),
        ],
      ),
      Lesson(
        id: 'vocab_food',
        title: 'Food & Restaurant',
        description: 'Learn vocabulary for ordering food and dining out.',
        category: LessonCategory.vocabulary,
        difficulty: DifficultyLevel.elementary,
        iconEmoji: '🍕',
        xpReward: 25,
        estimatedMinutes: 10,
        tags: ['food', 'restaurant', 'daily life'],
        steps: [
          LessonStep(
            id: 's1',
            type: StepType.info,
            instruction: 'At the Restaurant',
            content: 'Key phrases for dining:\n\n• "A table for two, please."\n• "Could I see the menu?"\n• "I\'d like to order..."\n• "The check/bill, please."\n• "Can I have some water?"',
          ),
          LessonStep(
            id: 's2',
            type: StepType.matchPairs,
            instruction: 'Match the food to its category:',
            matchPairs: {
              'Steak': 'Main Course',
              'Salad': 'Appetizer',
              'Ice cream': 'Dessert',
              'Coffee': 'Beverage',
            },
          ),
          LessonStep(
            id: 's3',
            type: StepType.conversation3D,
            instruction: 'Practice ordering at a restaurant in 3D!',
            content: 'RESTAURANT_SCENE',
          ),
        ],
      ),
      Lesson(
        id: 'grammar_past_simple',
        title: 'Past Simple Tense',
        description: 'Learn to talk about completed actions in the past.',
        category: LessonCategory.grammar,
        difficulty: DifficultyLevel.elementary,
        iconEmoji: '⏪',
        xpReward: 30,
        estimatedMinutes: 12,
        tags: ['grammar', 'tenses', 'past'],
        steps: [
          LessonStep(
            id: 's1',
            type: StepType.info,
            instruction: 'Past Simple Tense',
            content: 'We use Past Simple for completed actions:\n\n• Regular verbs: add -ed (walked, played)\n• Irregular verbs: special forms (went, ate, saw)\n\nExamples:\n"I visited Paris last summer."\n"She ate pizza for dinner."',
          ),
          LessonStep(
            id: 's2',
            type: StepType.multipleChoice,
            instruction: 'What is the past tense of "go"?',
            options: ['goed', 'went', 'gone', 'going'],
            correctAnswer: 'went',
            explanation: '"Go" is an irregular verb. Its past form is "went".',
          ),
          LessonStep(
            id: 's3',
            type: StepType.fillBlank,
            instruction: 'Yesterday, I ___ (eat) breakfast at 8 AM.',
            correctAnswer: 'ate',
            hint: '"Eat" is an irregular verb.',
          ),
        ],
      ),
      Lesson(
        id: 'listening_daily',
        title: 'Daily Conversations',
        description: 'Practice listening to everyday English conversations.',
        category: LessonCategory.listening,
        difficulty: DifficultyLevel.beginner,
        iconEmoji: '👂',
        xpReward: 25,
        estimatedMinutes: 8,
        tags: ['listening', 'daily life', 'comprehension'],
        steps: [
          LessonStep(
            id: 's1',
            type: StepType.info,
            instruction: 'Listening Practice',
            content: 'Good listening skills are essential!\n\nTips:\n• Focus on key words\n• Don\'t try to understand every word\n• Listen for context clues\n• Pay attention to tone and intonation',
          ),
          LessonStep(
            id: 's2',
            type: StepType.listenAndChoose,
            instruction: 'Listen and select what you hear:',
            content: 'I would like a cup of coffee, please.',
            options: [
              'I would like a cup of coffee, please.',
              'I would like a cup of tea, please.',
              'I would like a glass of coffee, please.',
            ],
            correctAnswer: 'I would like a cup of coffee, please.',
          ),
        ],
      ),
    ];
  }
}
