import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/firebase_service.dart';

class LearningProvider extends ChangeNotifier {
  List<Lesson> _allLessons = [];
  Lesson? _currentLesson;
  int _currentStepIndex = 0;
  int _correctAnswers = 0;
  int _totalAnswered = 0;
  bool _isLessonComplete = false;
  int _earnedXP = 0;
  List<VocabWord> _reviewWords = [];

  List<Lesson> get allLessons => _allLessons;
  Lesson? get currentLesson => _currentLesson;
  int get currentStepIndex => _currentStepIndex;
  LessonStep? get currentStep =>
      _currentLesson != null && _currentStepIndex < _currentLesson!.steps.length
          ? _currentLesson!.steps[_currentStepIndex]
          : null;
  int get correctAnswers => _correctAnswers;
  int get totalAnswered => _totalAnswered;
  bool get isLessonComplete => _isLessonComplete;
  int get earnedXP => _earnedXP;
  double get accuracy => _totalAnswered > 0 ? _correctAnswers / _totalAnswered : 0;
  int get stepsRemaining =>
      _currentLesson != null ? _currentLesson!.steps.length - _currentStepIndex : 0;
  double get lessonProgress => _currentLesson != null
      ? _currentStepIndex / _currentLesson!.steps.length
      : 0;
  List<VocabWord> get reviewWords => _reviewWords;

  // ── Load Lessons ──
  void loadDemoLessons() {
    // Uses the demo lessons from FirebaseService
    _allLessons = _getBuiltInLessons();
    notifyListeners();
  }

  List<Lesson> getLessonsByCategory(LessonCategory category) {
    return _allLessons.where((l) => l.category == category).toList();
  }

  List<Lesson> getLessonsByDifficulty(DifficultyLevel difficulty) {
    return _allLessons.where((l) => l.difficulty == difficulty).toList();
  }

  // ── Lesson Flow ──
  void startLesson(Lesson lesson) {
    _currentLesson = lesson;
    _currentStepIndex = 0;
    _correctAnswers = 0;
    _totalAnswered = 0;
    _isLessonComplete = false;
    _earnedXP = 0;
    notifyListeners();
  }

  void answerCorrect() {
    _correctAnswers++;
    _totalAnswered++;
    _earnedXP += 5;
    notifyListeners();
  }

  void answerIncorrect() {
    _totalAnswered++;
    notifyListeners();
  }

  bool nextStep() {
    if (_currentLesson == null) return false;
    if (_currentStepIndex < _currentLesson!.steps.length - 1) {
      _currentStepIndex++;
      notifyListeners();
      return true;
    } else {
      _isLessonComplete = true;
      _earnedXP += _currentLesson!.xpReward;
      // Bonus for perfect score
      if (_correctAnswers == _totalAnswered && _totalAnswered > 0) {
        _earnedXP += 10;
      }
      notifyListeners();
      return false;
    }
  }

  void resetLesson() {
    _currentLesson = null;
    _currentStepIndex = 0;
    _correctAnswers = 0;
    _totalAnswered = 0;
    _isLessonComplete = false;
    _earnedXP = 0;
    notifyListeners();
  }

  // ── Built-in Lessons ──
  List<Lesson> _getBuiltInLessons() {
    return [
      Lesson(
        id: 'vocab_greetings',
        title: 'Greetings & Introductions',
        description: 'Learn essential greeting phrases.',
        category: LessonCategory.vocabulary,
        difficulty: DifficultyLevel.beginner,
        iconEmoji: '👋',
        xpReward: 25,
        estimatedMinutes: 8,
        tags: ['greetings', 'basics'],
        steps: [
          LessonStep(id: 's1', type: StepType.info, instruction: 'Welcome!',
            content: 'Let\'s learn common English greetings:\n\n• Hello / Hi / Hey\n• Good morning / afternoon / evening\n• How are you?\n• Nice to meet you!'),
          LessonStep(id: 's2', type: StepType.multipleChoice,
            instruction: 'Which greeting is most formal?',
            options: ['Hey!', 'What\'s up?', 'Good evening', 'Yo!'],
            correctAnswer: 'Good evening',
            explanation: '"Good evening" is formal. "Hey" and "What\'s up" are casual.'),
          LessonStep(id: 's3', type: StepType.fillBlank,
            instruction: 'Complete: "Nice to ___ you!"',
            correctAnswer: 'meet', hint: 'Encounter someone for the first time.'),
          LessonStep(id: 's4', type: StepType.arrangeWords,
            instruction: 'Put the words in order:',
            correctOrder: ['How', 'are', 'you', 'doing', 'today', '?']),
          LessonStep(id: 's5', type: StepType.matchPairs,
            instruction: 'Match each greeting with its response:',
            matchPairs: {'How are you?': 'I\'m fine, thanks!',
              'Nice to meet you': 'Nice to meet you too',
              'Good morning': 'Good morning!',
              'What\'s your name?': 'My name is...'}),
        ],
      ),
      Lesson(
        id: 'grammar_present',
        title: 'Present Simple Tense',
        description: 'Master the present simple tense.',
        category: LessonCategory.grammar,
        difficulty: DifficultyLevel.beginner,
        iconEmoji: '📝',
        xpReward: 30,
        estimatedMinutes: 12,
        tags: ['grammar', 'tenses'],
        steps: [
          LessonStep(id: 's1', type: StepType.info, instruction: 'Present Simple',
            content: 'We use Present Simple for:\n\n1. Daily routines: "I wake up at 7 AM"\n2. Facts: "The sun rises in the east"\n3. Habits: "She drinks coffee every morning"\n\nRemember: Add -s/-es for he/she/it!'),
          LessonStep(id: 's2', type: StepType.multipleChoice,
            instruction: 'Choose the correct sentence:',
            options: ['She go to school.', 'She goes to school.',
              'She going to school.', 'She goed to school.'],
            correctAnswer: 'She goes to school.',
            explanation: 'With "she", add -es to "go" → "goes".'),
          LessonStep(id: 's3', type: StepType.fillBlank,
            instruction: 'He ___ (play) football every weekend.',
            correctAnswer: 'plays', hint: 'Add -s for he/she/it!'),
          LessonStep(id: 's4', type: StepType.arrangeWords,
            instruction: 'Arrange the words:',
            correctOrder: ['They', 'usually', 'eat', 'lunch', 'at', 'noon']),
        ],
      ),
      Lesson(
        id: 'pronunciation_vowels',
        title: 'English Vowel Sounds',
        description: 'Practice the five main vowel sounds.',
        category: LessonCategory.pronunciation,
        difficulty: DifficultyLevel.beginner,
        iconEmoji: '🗣️',
        xpReward: 25,
        estimatedMinutes: 10,
        tags: ['pronunciation', 'vowels'],
        steps: [
          LessonStep(id: 's1', type: StepType.info, instruction: 'Vowel Sounds',
            content: 'English has 5 vowel letters: A, E, I, O, U\nBut over 15 vowel SOUNDS!\n\nShort vowels:\n• /æ/ as in "cat"\n• /ɛ/ as in "bed"\n• /ɪ/ as in "sit"\n• /ɒ/ as in "hot"\n• /ʌ/ as in "cup"'),
          LessonStep(id: 's2', type: StepType.multipleChoice,
            instruction: 'Same vowel sound as "cat"?',
            options: ['cake', 'bat', 'car', 'coat'],
            correctAnswer: 'bat',
            explanation: 'Both "cat" and "bat" have the short /æ/ sound.'),
          LessonStep(id: 's3', type: StepType.speakAndCheck,
            instruction: 'Say this word clearly:',
            content: 'BEAUTIFUL', correctAnswer: 'beautiful'),
        ],
      ),
      Lesson(
        id: 'vocab_food',
        title: 'Food & Restaurant',
        description: 'Vocabulary for ordering food and dining out.',
        category: LessonCategory.vocabulary,
        difficulty: DifficultyLevel.elementary,
        iconEmoji: '🍕',
        xpReward: 25,
        estimatedMinutes: 10,
        tags: ['food', 'restaurant'],
        steps: [
          LessonStep(id: 's1', type: StepType.info, instruction: 'At the Restaurant',
            content: 'Key phrases:\n\n• "A table for two, please."\n• "Could I see the menu?"\n• "I\'d like to order..."\n• "The check, please."\n• "Can I have some water?"'),
          LessonStep(id: 's2', type: StepType.matchPairs,
            instruction: 'Match food to category:',
            matchPairs: {'Steak': 'Main Course', 'Salad': 'Appetizer',
              'Ice cream': 'Dessert', 'Coffee': 'Beverage'}),
          LessonStep(id: 's3', type: StepType.fillBlank,
            instruction: 'Could I ___ the menu, please?',
            correctAnswer: 'see', hint: 'To look at something'),
        ],
      ),
      Lesson(
        id: 'grammar_past',
        title: 'Past Simple Tense',
        description: 'Talk about completed actions in the past.',
        category: LessonCategory.grammar,
        difficulty: DifficultyLevel.elementary,
        iconEmoji: '⏪',
        xpReward: 30,
        estimatedMinutes: 12,
        tags: ['grammar', 'tenses', 'past'],
        steps: [
          LessonStep(id: 's1', type: StepType.info, instruction: 'Past Simple',
            content: 'Past Simple for completed actions:\n\n• Regular: add -ed (walked, played)\n• Irregular: special forms (went, ate, saw)\n\nExamples:\n"I visited Paris last summer."\n"She ate pizza for dinner."'),
          LessonStep(id: 's2', type: StepType.multipleChoice,
            instruction: 'Past tense of "go"?',
            options: ['goed', 'went', 'gone', 'going'],
            correctAnswer: 'went',
            explanation: '"Go" is irregular. Past form is "went".'),
          LessonStep(id: 's3', type: StepType.fillBlank,
            instruction: 'Yesterday, I ___ (eat) breakfast at 8 AM.',
            correctAnswer: 'ate', hint: '"Eat" is irregular.'),
        ],
      ),
      Lesson(
        id: 'conversation_travel',
        title: 'Travel Conversations',
        description: 'Essential phrases for traveling in English.',
        category: LessonCategory.conversation,
        difficulty: DifficultyLevel.intermediate,
        iconEmoji: '✈️',
        xpReward: 35,
        estimatedMinutes: 15,
        tags: ['travel', 'conversation', 'practical'],
        steps: [
          LessonStep(id: 's1', type: StepType.info, instruction: 'Travel English',
            content: 'Essential travel phrases:\n\n• "Where is the nearest...?"\n• "How much does this cost?"\n• "Can you help me, please?"\n• "I\'d like to book a room."\n• "What time does the train leave?"'),
          LessonStep(id: 's2', type: StepType.conversation3D,
            instruction: 'Practice at the airport!',
            content: 'AIRPORT_SCENE'),
          LessonStep(id: 's3', type: StepType.multipleChoice,
            instruction: 'At the hotel, you say:',
            options: ['I want room now.', 'Give me a room.',
              'I\'d like to check in, please.', 'Room. Now.'],
            correctAnswer: 'I\'d like to check in, please.',
            explanation: 'Polite language is important in English!'),
          LessonStep(id: 's4', type: StepType.arrangeWords,
            instruction: 'Form the question:',
            correctOrder: ['Where', 'is', 'the', 'nearest', 'train', 'station', '?']),
        ],
      ),
    ];
  }
}
