import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

// ─────────────────────────────────────────────
// Info Exercise (Read & Learn)
// ─────────────────────────────────────────────
class InfoExercise extends StatelessWidget {
  final String content;
  final VoidCallback onContinue;

  const InfoExercise({
    super.key,
    required this.content,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppTheme.primaryBlue.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppTheme.primaryBlue.withOpacity(0.15),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.lightbulb_outline,
                      color: AppTheme.primaryBlue,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Learn',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                content,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: onContinue,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              'Got it! Continue',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Multiple Choice Exercise
// ─────────────────────────────────────────────
class MultipleChoiceExercise extends StatefulWidget {
  final List<String> options;
  final String correctAnswer;
  final Function(bool) onAnswer;
  final bool disabled;

  const MultipleChoiceExercise({
    super.key,
    required this.options,
    required this.correctAnswer,
    required this.onAnswer,
    this.disabled = false,
  });

  @override
  State<MultipleChoiceExercise> createState() => _MultipleChoiceExerciseState();
}

class _MultipleChoiceExerciseState extends State<MultipleChoiceExercise> {
  String? _selectedOption;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: widget.options.map((option) {
        final isSelected = _selectedOption == option;
        final isCorrect = option == widget.correctAnswer;
        final showResult = _selectedOption != null;

        Color? bgColor;
        Color? borderColor;
        IconData? trailingIcon;

        if (showResult && isSelected && isCorrect) {
          bgColor = AppTheme.accentGreen.withOpacity(0.1);
          borderColor = AppTheme.accentGreen;
          trailingIcon = Icons.check_circle;
        } else if (showResult && isSelected && !isCorrect) {
          bgColor = AppTheme.errorRed.withOpacity(0.1);
          borderColor = AppTheme.errorRed;
          trailingIcon = Icons.cancel;
        } else if (showResult && isCorrect) {
          bgColor = AppTheme.accentGreen.withOpacity(0.05);
          borderColor = AppTheme.accentGreen.withOpacity(0.3);
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GestureDetector(
            onTap: widget.disabled || _selectedOption != null
                ? null
                : () {
                    setState(() => _selectedOption = option);
                    widget.onAnswer(option == widget.correctAnswer);
                  },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: bgColor ?? Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: borderColor ??
                      (isSelected
                          ? AppTheme.primaryBlue
                          : Colors.grey.withOpacity(0.2)),
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: (borderColor ?? AppTheme.primaryBlue)
                              .withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected
                          ? (borderColor ?? AppTheme.primaryBlue)
                          : Colors.grey.withOpacity(0.15),
                    ),
                    child: Center(
                      child: isSelected
                          ? const Icon(Icons.check, color: Colors.white, size: 16)
                          : null,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      option,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                  if (trailingIcon != null)
                    Icon(
                      trailingIcon,
                      color: borderColor,
                      size: 22,
                    ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─────────────────────────────────────────────
// Fill in the Blank Exercise
// ─────────────────────────────────────────────
class FillBlankExercise extends StatefulWidget {
  final String correctAnswer;
  final String? hint;
  final Function(bool) onAnswer;
  final bool disabled;

  const FillBlankExercise({
    super.key,
    required this.correctAnswer,
    this.hint,
    required this.onAnswer,
    this.disabled = false,
  });

  @override
  State<FillBlankExercise> createState() => _FillBlankExerciseState();
}

class _FillBlankExerciseState extends State<FillBlankExercise> {
  final _controller = TextEditingController();
  bool _submitted = false;
  bool _showHint = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Input field
        TextField(
          controller: _controller,
          enabled: !_submitted && !widget.disabled,
          autofocus: true,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _checkAnswer(),
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            hintText: 'Type your answer...',
            filled: true,
            fillColor: Theme.of(context).inputDecorationTheme.fillColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppTheme.primaryBlue, width: 2),
            ),
            contentPadding: const EdgeInsets.all(20),
            suffixIcon: !_submitted
                ? IconButton(
                    icon: const Icon(Icons.send_rounded, color: AppTheme.primaryBlue),
                    onPressed: _checkAnswer,
                  )
                : null,
          ),
        ),

        // Hint
        if (widget.hint != null && !_submitted) ...[
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => setState(() => _showHint = true),
            child: Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  size: 16,
                  color: AppTheme.accentOrange.withOpacity(0.7),
                ),
                const SizedBox(width: 6),
                Text(
                  _showHint ? widget.hint! : 'Tap for a hint',
                  style: TextStyle(
                    color: AppTheme.accentOrange.withOpacity(0.7),
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],

        if (!_submitted && !widget.disabled) ...[
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _checkAnswer,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentGreen,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Check Answer',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  void _checkAnswer() {
    if (_controller.text.trim().isEmpty) return;
    setState(() => _submitted = true);
    final isCorrect = _controller.text.trim().toLowerCase() ==
        widget.correctAnswer.toLowerCase();
    widget.onAnswer(isCorrect);
  }
}

// ─────────────────────────────────────────────
// Match Pairs Exercise
// ─────────────────────────────────────────────
class MatchPairsExercise extends StatefulWidget {
  final Map<String, String> pairs;
  final Function(bool) onComplete;

  const MatchPairsExercise({
    super.key,
    required this.pairs,
    required this.onComplete,
  });

  @override
  State<MatchPairsExercise> createState() => _MatchPairsExerciseState();
}

class _MatchPairsExerciseState extends State<MatchPairsExercise> {
  String? _selectedLeft;
  final Map<String, String> _matched = {};
  final Set<String> _wrongPairs = {};
  late List<String> _leftItems;
  late List<String> _rightItems;

  @override
  void initState() {
    super.initState();
    _leftItems = widget.pairs.keys.toList()..shuffle();
    _rightItems = widget.pairs.values.toList()..shuffle();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left column
        Expanded(
          child: Column(
            children: _leftItems.map((item) {
              final isMatched = _matched.containsKey(item);
              final isSelected = _selectedLeft == item;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: GestureDetector(
                  onTap: isMatched
                      ? null
                      : () => setState(() => _selectedLeft = item),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isMatched
                          ? AppTheme.accentGreen.withOpacity(0.1)
                          : isSelected
                              ? AppTheme.primaryBlue.withOpacity(0.1)
                              : Theme.of(context).cardTheme.color,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isMatched
                            ? AppTheme.accentGreen
                            : isSelected
                                ? AppTheme.primaryBlue
                                : Colors.grey.withOpacity(0.2),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Text(
                      item,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isMatched ? AppTheme.accentGreen : null,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        const SizedBox(width: 12),

        // Right column
        Expanded(
          child: Column(
            children: _rightItems.map((item) {
              final isMatched = _matched.containsValue(item);
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: GestureDetector(
                  onTap: isMatched || _selectedLeft == null
                      ? null
                      : () => _tryMatch(item),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isMatched
                          ? AppTheme.accentGreen.withOpacity(0.1)
                          : _selectedLeft != null
                              ? AppTheme.secondaryPurple.withOpacity(0.05)
                              : Theme.of(context).cardTheme.color,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isMatched
                            ? AppTheme.accentGreen
                            : Colors.grey.withOpacity(0.2),
                      ),
                    ),
                    child: Text(
                      item,
                      style: TextStyle(
                        fontSize: 14,
                        color: isMatched ? AppTheme.accentGreen : null,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  void _tryMatch(String rightItem) {
    if (_selectedLeft == null) return;
    final correctMatch = widget.pairs[_selectedLeft];
    if (correctMatch == rightItem) {
      setState(() {
        _matched[_selectedLeft!] = rightItem;
        _selectedLeft = null;
      });
      if (_matched.length == widget.pairs.length) {
        widget.onComplete(true);
      }
    } else {
      setState(() {
        _wrongPairs.add('${_selectedLeft}_$rightItem');
        _selectedLeft = null;
      });
    }
  }
}

// ─────────────────────────────────────────────
// Arrange Words Exercise
// ─────────────────────────────────────────────
class ArrangeWordsExercise extends StatefulWidget {
  final List<String> correctOrder;
  final Function(bool) onAnswer;

  const ArrangeWordsExercise({
    super.key,
    required this.correctOrder,
    required this.onAnswer,
  });

  @override
  State<ArrangeWordsExercise> createState() => _ArrangeWordsExerciseState();
}

class _ArrangeWordsExerciseState extends State<ArrangeWordsExercise> {
  late List<String> _availableWords;
  final List<String> _selectedWords = [];
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    _availableWords = List.from(widget.correctOrder)..shuffle();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Selected words (answer area)
        Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 60),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).inputDecorationTheme.fillColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _submitted
                  ? (_checkAnswer()
                      ? AppTheme.accentGreen
                      : AppTheme.errorRed)
                  : Colors.grey.withOpacity(0.2),
              width: _submitted ? 2 : 1,
            ),
          ),
          child: _selectedWords.isEmpty
              ? Text(
                  'Tap words to build the sentence',
                  style: TextStyle(
                    color: Colors.grey.withOpacity(0.5),
                    fontStyle: FontStyle.italic,
                  ),
                )
              : Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _selectedWords.asMap().entries.map((entry) {
                    return GestureDetector(
                      onTap: _submitted
                          ? null
                          : () {
                              setState(() {
                                _availableWords.add(_selectedWords[entry.key]);
                                _selectedWords.removeAt(entry.key);
                              });
                            },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryBlue,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          entry.value,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
        ),

        const SizedBox(height: 20),

        // Available words
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _availableWords.map((word) {
            return GestureDetector(
              onTap: _submitted
                  ? null
                  : () {
                      setState(() {
                        _selectedWords.add(word);
                        _availableWords.remove(word);
                      });
                    },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardTheme.color,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.withOpacity(0.3)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  word,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 24),

        // Check button
        if (!_submitted && _availableWords.isEmpty)
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () {
                setState(() => _submitted = true);
                widget.onAnswer(_checkAnswer());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentGreen,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Check',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }

  bool _checkAnswer() {
    if (_selectedWords.length != widget.correctOrder.length) return false;
    for (int i = 0; i < _selectedWords.length; i++) {
      if (_selectedWords[i] != widget.correctOrder[i]) return false;
    }
    return true;
  }
}

// ─────────────────────────────────────────────
// Speak Exercise
// ─────────────────────────────────────────────
class SpeakExercise extends StatefulWidget {
  final String targetWord;
  final Function(bool) onAnswer;

  const SpeakExercise({
    super.key,
    required this.targetWord,
    required this.onAnswer,
  });

  @override
  State<SpeakExercise> createState() => _SpeakExerciseState();
}

class _SpeakExerciseState extends State<SpeakExercise>
    with SingleTickerProviderStateMixin {
  bool _isListening = false;
  String _recognizedText = '';
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Target word display
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF4338CA), Color(0xFF6366F1)],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              const Icon(Icons.volume_up, color: Colors.white70, size: 28),
              const SizedBox(height: 12),
              Text(
                widget.targetWord,
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),

        const SizedBox(height: 32),

        // Mic button
        GestureDetector(
          onTap: _toggleListening,
          child: AnimatedBuilder(
            animation: _pulseController,
            builder: (_, __) {
              final scale = _isListening
                  ? 1.0 + sin(_pulseController.value * pi * 2) * 0.1
                  : 1.0;
              return Transform.scale(
                scale: scale,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isListening
                        ? AppTheme.errorRed
                        : AppTheme.accentGreen,
                    boxShadow: [
                      BoxShadow(
                        color: (_isListening
                                ? AppTheme.errorRed
                                : AppTheme.accentGreen)
                            .withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Icon(
                    _isListening ? Icons.stop : Icons.mic,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 16),
        Text(
          _isListening ? 'Listening...' : 'Tap to speak',
          style: TextStyle(
            color: Colors.grey[500],
            fontSize: 14,
          ),
        ),

        // Recognized text
        if (_recognizedText.isNotEmpty) ...[
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.accentGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: AppTheme.accentGreen),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'You said: "$_recognizedText"',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],

        // Skip button
        const SizedBox(height: 20),
        TextButton(
          onPressed: () => widget.onAnswer(true),
          child: Text(
            'Skip (microphone not available)',
            style: TextStyle(color: Colors.grey[400], fontSize: 13),
          ),
        ),
      ],
    );
  }

  void _toggleListening() {
    setState(() {
      _isListening = !_isListening;
      if (_isListening) {
        _pulseController.repeat();
        // Simulate recognition after 2s
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted && _isListening) {
            setState(() {
              _isListening = false;
              _recognizedText = widget.targetWord.toLowerCase();
              _pulseController.stop();
            });
            widget.onAnswer(true);
          }
        });
      } else {
        _pulseController.stop();
      }
    });
  }
}
