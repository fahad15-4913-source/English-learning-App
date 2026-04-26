import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:confetti/confetti.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../providers/learning_provider.dart';
import '../providers/progress_provider.dart';
import '../widgets/exercise_widgets.dart';
import '../widgets/scene_3d_widget.dart';

class LessonScreen extends StatefulWidget {
  final Lesson lesson;
  const LessonScreen({super.key, required this.lesson});

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen>
    with TickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _slideController;
  bool _showFeedback = false;
  bool _isCorrect = false;
  String _feedbackMessage = '';

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 2),
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LearningProvider>(
      builder: (context, learning, _) {
        if (learning.isLessonComplete) {
          return _buildCompletionScreen(learning);
        }
        return Scaffold(
          body: Stack(
            children: [
              SafeArea(
                child: Column(
                  children: [
                    // Top bar with progress
                    _buildTopBar(learning),

                    // Exercise content
                    Expanded(
                      child: _buildExerciseContent(learning),
                    ),

                    // Feedback & Continue
                    if (_showFeedback) _buildFeedbackBar(),
                  ],
                ),
              ),

              // Confetti
              Align(
                alignment: Alignment.topCenter,
                child: ConfettiWidget(
                  confettiController: _confettiController,
                  blastDirectionality: BlastDirectionality.explosive,
                  numberOfParticles: 20,
                  maxBlastForce: 20,
                  colors: const [
                    AppTheme.accentGreen,
                    AppTheme.accentCyan,
                    AppTheme.primaryBlue,
                    AppTheme.accentOrange,
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTopBar(LearningProvider learning) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => _showExitDialog(),
          ),
          Expanded(
            child: LinearPercentIndicator(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              lineHeight: 10,
              percent: learning.lessonProgress.clamp(0.0, 1.0),
              backgroundColor: Colors.grey.withOpacity(0.2),
              progressColor: AppTheme.accentGreen,
              barRadius: const Radius.circular(5),
              animation: true,
              animationDuration: 300,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.accentOrange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.favorite, color: AppTheme.accentOrange, size: 16),
                const SizedBox(width: 4),
                Text(
                  '${learning.correctAnswers}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.accentOrange,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseContent(LearningProvider learning) {
    final step = learning.currentStep;
    if (step == null) return const SizedBox();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step type indicator
          _buildStepTypeChip(step.type),
          const SizedBox(height: 16),

          // Instruction
          Text(
            step.instruction,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 24),

          // Exercise widget based on type
          _buildExerciseWidget(step, learning),
        ],
      ),
    );
  }

  Widget _buildStepTypeChip(StepType type) {
    final typeInfo = _getStepTypeInfo(type);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: typeInfo['color'] as Color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(typeInfo['icon'] as IconData, size: 14, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            typeInfo['label'] as String,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getStepTypeInfo(StepType type) {
    switch (type) {
      case StepType.info:
        return {'label': 'Learn', 'icon': Icons.lightbulb, 'color': AppTheme.primaryBlue};
      case StepType.multipleChoice:
        return {'label': 'Choose', 'icon': Icons.check_circle, 'color': AppTheme.secondaryPurple};
      case StepType.fillBlank:
        return {'label': 'Fill In', 'icon': Icons.edit, 'color': AppTheme.accentGreen};
      case StepType.matchPairs:
        return {'label': 'Match', 'icon': Icons.compare_arrows, 'color': AppTheme.accentOrange};
      case StepType.arrangeWords:
        return {'label': 'Arrange', 'icon': Icons.sort, 'color': AppTheme.accentCyan};
      case StepType.speakAndCheck:
        return {'label': 'Speak', 'icon': Icons.mic, 'color': AppTheme.accentPink};
      case StepType.listenAndChoose:
        return {'label': 'Listen', 'icon': Icons.headphones, 'color': AppTheme.accentOrange};
      case StepType.typeSentence:
        return {'label': 'Type', 'icon': Icons.keyboard, 'color': AppTheme.primaryBlue};
      case StepType.flashcard:
        return {'label': 'Flashcard', 'icon': Icons.style, 'color': AppTheme.secondaryPurple};
      case StepType.conversation3D:
        return {'label': '3D Scene', 'icon': Icons.view_in_ar, 'color': AppTheme.accentCyan};
    }
  }

  Widget _buildExerciseWidget(LessonStep step, LearningProvider learning) {
    switch (step.type) {
      case StepType.info:
        return InfoExercise(
          content: step.content ?? '',
          onContinue: () => _handleContinue(learning),
        );

      case StepType.multipleChoice:
        return MultipleChoiceExercise(
          options: step.options ?? [],
          correctAnswer: step.correctAnswer ?? '',
          onAnswer: (isCorrect) => _handleAnswer(isCorrect, step, learning),
          disabled: _showFeedback,
        );

      case StepType.fillBlank:
        return FillBlankExercise(
          correctAnswer: step.correctAnswer ?? '',
          hint: step.hint,
          onAnswer: (isCorrect) => _handleAnswer(isCorrect, step, learning),
          disabled: _showFeedback,
        );

      case StepType.matchPairs:
        return MatchPairsExercise(
          pairs: step.matchPairs ?? {},
          onComplete: (isCorrect) => _handleAnswer(isCorrect, step, learning),
        );

      case StepType.arrangeWords:
        return ArrangeWordsExercise(
          correctOrder: step.correctOrder ?? [],
          onAnswer: (isCorrect) => _handleAnswer(isCorrect, step, learning),
        );

      case StepType.speakAndCheck:
        return SpeakExercise(
          targetWord: step.content ?? step.correctAnswer ?? '',
          onAnswer: (isCorrect) => _handleAnswer(isCorrect, step, learning),
        );

      case StepType.conversation3D:
        return Scene3DWidget(
          sceneType: step.content ?? 'DEFAULT',
          onComplete: () => _handleContinue(learning),
        );

      default:
        return InfoExercise(
          content: step.content ?? 'Exercise coming soon!',
          onContinue: () => _handleContinue(learning),
        );
    }
  }

  void _handleAnswer(bool isCorrect, LessonStep step, LearningProvider learning) {
    setState(() {
      _showFeedback = true;
      _isCorrect = isCorrect;
      _feedbackMessage = isCorrect
          ? _getCorrectMessage()
          : step.explanation ?? 'The correct answer was: ${step.correctAnswer}';
    });

    if (isCorrect) {
      learning.answerCorrect();
      _confettiController.play();
    } else {
      learning.answerIncorrect();
    }
  }

  String _getCorrectMessage() {
    final messages = [
      'Excellent! 🌟',
      'Perfect! 🎯',
      'Amazing! 🔥',
      'Well done! ✨',
      'Brilliant! 💪',
      'You got it! 🏆',
    ];
    return messages[Random().nextInt(messages.length)];
  }

  void _handleContinue(LearningProvider learning) {
    setState(() {
      _showFeedback = false;
    });
    learning.nextStep();
  }

  Widget _buildFeedbackBar() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _isCorrect
            ? AppTheme.accentGreen.withOpacity(0.1)
            : AppTheme.errorRed.withOpacity(0.1),
        border: Border(
          top: BorderSide(
            color: _isCorrect ? AppTheme.accentGreen : AppTheme.errorRed,
            width: 2,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                _isCorrect ? Icons.check_circle : Icons.cancel,
                color: _isCorrect ? AppTheme.accentGreen : AppTheme.errorRed,
              ),
              const SizedBox(width: 8),
              Text(
                _isCorrect ? 'Correct!' : 'Not quite right',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _isCorrect ? AppTheme.accentGreen : AppTheme.errorRed,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            _feedbackMessage,
            style: TextStyle(
              color: _isCorrect
                  ? AppTheme.accentGreen.withOpacity(0.8)
                  : AppTheme.errorRed.withOpacity(0.8),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _handleContinue(
                context.read<LearningProvider>(),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    _isCorrect ? AppTheme.accentGreen : AppTheme.errorRed,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Continue',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ────────────────────────────────────────────
  // Completion Screen
  // ────────────────────────────────────────────
  Widget _buildCompletionScreen(LearningProvider learning) {
    final accuracy = learning.accuracy;
    final stars = accuracy >= 0.9 ? 3 : (accuracy >= 0.7 ? 2 : 1);

    // Award XP
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProgressProvider>().completeLesson(
            widget.lesson.id,
            learning.earnedXP,
            widget.lesson.category.name,
          );
    });

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1E1B4B), Color(0xFF312E81)],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // Stars
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (i) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(
                      i < stars ? Icons.star : Icons.star_border,
                      size: i == 1 ? 72 : 56,
                      color: i < stars
                          ? AppTheme.accentOrange
                          : Colors.white.withOpacity(0.3),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 24),

              const Text(
                'Lesson Complete!',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.lesson.title,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),

              const SizedBox(height: 40),

              // Stats
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildCompletionStat(
                    'XP Earned',
                    '+${learning.earnedXP}',
                    Icons.bolt,
                    AppTheme.accentOrange,
                  ),
                  _buildCompletionStat(
                    'Accuracy',
                    '${(accuracy * 100).toInt()}%',
                    Icons.target,
                    AppTheme.accentGreen,
                  ),
                  _buildCompletionStat(
                    'Correct',
                    '${learning.correctAnswers}/${learning.totalAnswered}',
                    Icons.check_circle,
                    AppTheme.accentCyan,
                  ),
                ],
              ),

              const Spacer(),

              // Buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          learning.resetLesson();
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.accentGreen,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Continue Learning',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () {
                        learning.startLesson(widget.lesson);
                      },
                      child: Text(
                        'Practice Again',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompletionStat(
      String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withOpacity(0.15),
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Leave Lesson?'),
        content: const Text('Your progress in this lesson will be lost.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Stay'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<LearningProvider>().resetLesson();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorRed,
            ),
            child: const Text('Leave', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
