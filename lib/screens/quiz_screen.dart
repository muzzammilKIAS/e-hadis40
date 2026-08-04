import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/utils/responsive.dart';
import '../data/models/hadith.dart';
import '../services/app_controller.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({required this.hadith, super.key});

  final Hadith hadith;

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late final List<int?> _answers;
  int _currentIndex = 0;
  bool _submitted = false;
  int _score = 0;

  @override
  void initState() {
    super.initState();
    _answers = List<int?>.filled(widget.hadith.quiz.length, null);
  }

  @override
  Widget build(BuildContext context) {
    final questions = widget.hadith.quiz;
    if (questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Kuiz')),
        body: const Center(child: Text('Kuiz belum tersedia.')),
      );
    }

    return Scaffold(
      appBar:
          AppBar(title: Text('Kuiz · Hadis ${widget.hadith.displayNumber}')),
      body: SingleChildScrollView(
        padding: Responsive.pagePadding(context),
        child: Responsive.constrainedPage(
          child: _submitted
              ? _ResultView(
                  hadith: widget.hadith,
                  answers: _answers,
                  score: _score,
                  onRetry: _reset,
                )
              : _QuestionView(
                  question: questions[_currentIndex],
                  currentIndex: _currentIndex,
                  total: questions.length,
                  selectedAnswer: _answers[_currentIndex],
                  onSelect: (value) =>
                      setState(() => _answers[_currentIndex] = value),
                  onPrevious: _currentIndex == 0
                      ? null
                      : () => setState(() => _currentIndex--),
                  onNext: _currentIndex == questions.length - 1
                      ? null
                      : () => setState(() => _currentIndex++),
                  onSubmit: _submit,
                  isLast: _currentIndex == questions.length - 1,
                ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final unanswered = _answers.where((answer) => answer == null).length;
    if (unanswered > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Masih ada $unanswered soalan yang belum dijawab.')),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hantar jawapan?'),
        content:
            const Text('Anda masih boleh menyemak jawapan sebelum menghantar.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Semak Lagi')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Hantar')),
        ],
      ),
    );
    if (confirmed != true) return;

    var correct = 0;
    for (var index = 0; index < widget.hadith.quiz.length; index++) {
      if (_answers[index] == widget.hadith.quiz[index].correctAnswerIndex) {
        correct++;
      }
    }
    final score = ((correct / widget.hadith.quiz.length) * 100).round();
    await context.read<AppController>().saveQuizScore(widget.hadith.id, score);
    if (!mounted) return;
    setState(() {
      _score = score;
      _submitted = true;
    });
  }

  void _reset() {
    setState(() {
      for (var index = 0; index < _answers.length; index++) {
        _answers[index] = null;
      }
      _currentIndex = 0;
      _submitted = false;
      _score = 0;
    });
  }
}

class _QuestionView extends StatelessWidget {
  const _QuestionView({
    required this.question,
    required this.currentIndex,
    required this.total,
    required this.selectedAnswer,
    required this.onSelect,
    required this.onPrevious,
    required this.onNext,
    required this.onSubmit,
    required this.isLast,
  });

  final QuizQuestion question;
  final int currentIndex;
  final int total;
  final int? selectedAnswer;
  final ValueChanged<int> onSelect;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final VoidCallback onSubmit;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Soalan ${currentIndex + 1} daripada $total'),
                const Spacer(),
                Text('${(((currentIndex + 1) / total) * 100).round()}%'),
              ],
            ),
            const SizedBox(height: 10),
            LinearProgressIndicator(
                value: (currentIndex + 1) / total, minHeight: 8),
            const SizedBox(height: 28),
            Text(question.question,
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 22),
            for (var index = 0; index < question.options.length; index++) ...[
              _OptionTile(
                label: String.fromCharCode(65 + index),
                text: question.options[index],
                selected: selectedAnswer == index,
                onTap: () => onSelect(index),
              ),
              const SizedBox(height: 12),
            ],
            const SizedBox(height: 18),
            Divider(color: scheme.outlineVariant),
            const SizedBox(height: 12),
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: onPrevious,
                  icon: const Icon(Icons.arrow_back_rounded),
                  label: const Text('Sebelumnya'),
                ),
                const Spacer(),
                if (!isLast)
                  FilledButton.icon(
                    onPressed: onNext,
                    icon: const Icon(Icons.arrow_forward_rounded),
                    label: const Text('Seterusnya'),
                  )
                else
                  FilledButton.icon(
                    onPressed: onSubmit,
                    icon: const Icon(Icons.send_rounded),
                    label: const Text('Hantar Jawapan'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.label,
    required this.text,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String text;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? scheme.primaryContainer : scheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? scheme.primary : scheme.outlineVariant,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor:
                  selected ? scheme.primary : scheme.surfaceContainerHighest,
              foregroundColor:
                  selected ? scheme.onPrimary : scheme.onSurfaceVariant,
              child: Text(label),
            ),
            const SizedBox(width: 14),
            Expanded(
                child:
                    Text(text, style: Theme.of(context).textTheme.bodyLarge)),
            if (selected)
              Icon(Icons.check_circle_rounded, color: scheme.primary),
          ],
        ),
      ),
    );
  }
}

class _ResultView extends StatelessWidget {
  const _ResultView({
    required this.hadith,
    required this.answers,
    required this.score,
    required this.onRetry,
  });

  final Hadith hadith;
  final List<int?> answers;
  final int score;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final passed = score >= hadith.passingScorePercent;
    final scheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Card(
          color: passed
              ? scheme.primaryContainer.withValues(alpha: 0.55)
              : scheme.secondaryContainer.withValues(alpha: 0.55),
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              children: [
                Icon(
                  passed
                      ? Icons.workspace_premium_rounded
                      : Icons.menu_book_rounded,
                  size: 64,
                  color: passed ? scheme.primary : scheme.secondary,
                ),
                const SizedBox(height: 16),
                Text('$score%',
                    style: Theme.of(context).textTheme.displaySmall),
                const SizedBox(height: 8),
                Text(
                  passed
                      ? 'Tahniah, anda lulus.'
                      : 'Belum mencapai tahap kelulusan.',
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  passed
                      ? 'Teruskan menghayati dan mengamalkan pengajaran hadis.'
                      : 'Baca semula huraian dan pengajaran, kemudian cuba lagi.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Cuba Semula'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Align(
          alignment: Alignment.centerLeft,
          child: Text('Semakan Jawapan',
              style: Theme.of(context).textTheme.headlineSmall),
        ),
        const SizedBox(height: 12),
        for (var index = 0; index < hadith.quiz.length; index++) ...[
          _ReviewCard(
            number: index + 1,
            question: hadith.quiz[index],
            selected: answers[index],
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard(
      {required this.number, required this.question, required this.selected});

  final int number;
  final QuizQuestion question;
  final int? selected;

  @override
  Widget build(BuildContext context) {
    final correct = selected == question.correctAnswerIndex;
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  correct ? Icons.check_circle_rounded : Icons.cancel_rounded,
                  color: correct ? scheme.primary : scheme.error,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text('$number. ${question.question}',
                      style: Theme.of(context).textTheme.titleMedium),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
                'Jawapan anda: ${selected == null ? 'Tiada' : question.options[selected!]}'),
            const SizedBox(height: 5),
            Text(
                'Jawapan betul: ${question.options[question.correctAnswerIndex]}'),
            const SizedBox(height: 10),
            Text(question.explanation,
                style: TextStyle(color: scheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}
