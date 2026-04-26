import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';

class VocabularyScreen extends StatefulWidget {
  const VocabularyScreen({super.key});

  @override
  State<VocabularyScreen> createState() => _VocabularyScreenState();
}

class _VocabularyScreenState extends State<VocabularyScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _flipController;
  bool _isFlipped = false;
  int _currentIndex = 0;

  final List<VocabWord> _words = [
    VocabWord(word: 'Serendipity', phonetic: '/ˌser.ənˈdɪp.ɪ.ti/',
      definition: 'The occurrence of events by chance in a happy way.',
      exampleSentence: 'Finding that book was pure serendipity.',
      partOfSpeech: 'noun', synonyms: ['luck', 'fortune', 'chance'], masteryLevel: 3),
    VocabWord(word: 'Ephemeral', phonetic: '/ɪˈfem.ər.əl/',
      definition: 'Lasting for a very short time.',
      exampleSentence: 'The beauty of cherry blossoms is ephemeral.',
      partOfSpeech: 'adjective', synonyms: ['fleeting', 'transient'], masteryLevel: 1),
    VocabWord(word: 'Eloquent', phonetic: '/ˈel.ə.kwənt/',
      definition: 'Fluent or persuasive in speaking or writing.',
      exampleSentence: 'She gave an eloquent speech at the ceremony.',
      partOfSpeech: 'adjective', synonyms: ['articulate', 'fluent'], masteryLevel: 2),
    VocabWord(word: 'Ubiquitous', phonetic: '/juːˈbɪk.wɪ.təs/',
      definition: 'Present, appearing, or found everywhere.',
      exampleSentence: 'Smartphones have become ubiquitous in modern life.',
      partOfSpeech: 'adjective', synonyms: ['omnipresent', 'universal'], masteryLevel: 0),
    VocabWord(word: 'Resilient', phonetic: '/rɪˈzɪl.i.ənt/',
      definition: 'Able to recover quickly from difficulties.',
      exampleSentence: 'Children are remarkably resilient.',
      partOfSpeech: 'adjective', synonyms: ['tough', 'strong', 'adaptable'], masteryLevel: 4),
    VocabWord(word: 'Ambiguous', phonetic: '/æmˈbɪɡ.ju.əs/',
      definition: 'Open to more than one interpretation.',
      exampleSentence: 'The ending of the movie was intentionally ambiguous.',
      partOfSpeech: 'adjective', synonyms: ['vague', 'unclear'], masteryLevel: 1),
  ];

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vocabulary'),
        automaticallyImplyLeading: false,
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: AppTheme.accentGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${_words.length} words',
              style: const TextStyle(
                color: AppTheme.accentGreen,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Mastery filter
          _buildMasteryFilter(),

          // Flashcard
          Expanded(
            child: GestureDetector(
              onTap: _flipCard,
              onHorizontalDragEnd: (details) {
                if (details.primaryVelocity != null) {
                  if (details.primaryVelocity! < 0) _nextCard();
                  if (details.primaryVelocity! > 0) _prevCard();
                }
              },
              child: _buildFlashcard(),
            ),
          ),

          // Controls
          _buildControls(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildMasteryFilter() {
    return SizedBox(
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _buildFilterChip('All', true),
          _buildFilterChip('New', false),
          _buildFilterChip('Learning', false),
          _buildFilterChip('Review', false),
          _buildFilterChip('Mastered', false),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool selected) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) {},
        selectedColor: AppTheme.primaryBlue.withOpacity(0.15),
        checkmarkColor: AppTheme.primaryBlue,
        labelStyle: TextStyle(
          color: selected ? AppTheme.primaryBlue : null,
          fontWeight: selected ? FontWeight.bold : null,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  Widget _buildFlashcard() {
    final word = _words[_currentIndex];
    return AnimatedBuilder(
      animation: _flipController,
      builder: (_, __) {
        final angle = _flipController.value * pi;
        final isFront = angle < pi / 2;

        return Padding(
          padding: const EdgeInsets.all(24),
          child: Transform(
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(angle),
            alignment: Alignment.center,
            child: isFront
                ? _buildCardFront(word)
                : Transform(
                    transform: Matrix4.identity()..rotateY(pi),
                    alignment: Alignment.center,
                    child: _buildCardBack(word),
                  ),
          ),
        );
      },
    );
  }

  Widget _buildCardFront(VocabWord word) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4338CA), Color(0xFF6366F1)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withOpacity(0.3),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Mastery dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (i) {
              return Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i < word.masteryLevel
                      ? AppTheme.accentGreen
                      : Colors.white.withOpacity(0.3),
                ),
              );
            }),
          ),
          const SizedBox(height: 20),

          // Part of speech
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              word.partOfSpeech,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Word
          Text(
            word.word,
            style: const TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),

          // Phonetic
          Text(
            word.phonetic,
            style: TextStyle(
              fontSize: 18,
              color: Colors.white.withOpacity(0.7),
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 8),

          // Speaker icon
          IconButton(
            onPressed: () {
              // TODO: TTS
            },
            icon: const Icon(Icons.volume_up_rounded, color: Colors.white70),
          ),

          const SizedBox(height: 30),
          Text(
            'Tap to flip',
            style: TextStyle(
              color: Colors.white.withOpacity(0.4),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardBack(VocabWord word) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(
          color: AppTheme.primaryBlue.withOpacity(0.2),
          width: 2,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Definition',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryBlue,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            word.definition,
            style: const TextStyle(fontSize: 20, height: 1.4),
          ),
          const SizedBox(height: 24),
          const Text(
            'Example',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.accentGreen,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '"${word.exampleSentence}"',
            style: TextStyle(
              fontSize: 16,
              fontStyle: FontStyle.italic,
              color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.8),
              height: 1.4,
            ),
          ),
          if (word.synonyms.isNotEmpty) ...[
            const SizedBox(height: 24),
            const Text(
              'Synonyms',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.secondaryPurple,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: word.synonyms.map((s) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.secondaryPurple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    s,
                    style: const TextStyle(
                      color: AppTheme.secondaryPurple,
                      fontSize: 13,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Hard
          _buildControlButton(
            icon: Icons.close,
            color: AppTheme.errorRed,
            label: 'Hard',
            onTap: () => _rateAndNext(1),
          ),
          // Good
          _buildControlButton(
            icon: Icons.check,
            color: AppTheme.accentOrange,
            label: 'Good',
            onTap: () => _rateAndNext(3),
          ),
          // Easy
          _buildControlButton(
            icon: Icons.star,
            color: AppTheme.accentGreen,
            label: 'Easy',
            onTap: () => _rateAndNext(5),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.1),
              border: Border.all(color: color.withOpacity(0.3), width: 2),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
        ),
        const SizedBox(height: 6),
        Text(label, style: TextStyle(fontSize: 12, color: color)),
      ],
    );
  }

  void _flipCard() {
    if (_isFlipped) {
      _flipController.reverse();
    } else {
      _flipController.forward();
    }
    _isFlipped = !_isFlipped;
  }

  void _nextCard() {
    if (_isFlipped) {
      _flipController.reverse();
      _isFlipped = false;
    }
    setState(() {
      _currentIndex = (_currentIndex + 1) % _words.length;
    });
  }

  void _prevCard() {
    if (_isFlipped) {
      _flipController.reverse();
      _isFlipped = false;
    }
    setState(() {
      _currentIndex = (_currentIndex - 1 + _words.length) % _words.length;
    });
  }

  void _rateAndNext(int rating) {
    setState(() {
      _words[_currentIndex].masteryLevel =
          (_words[_currentIndex].masteryLevel + (rating > 2 ? 1 : -1))
              .clamp(0, 5);
    });
    _nextCard();
  }
}
