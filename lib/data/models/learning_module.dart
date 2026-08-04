class LearningModule {
  const LearningModule({
    required this.id,
    required this.number,
    required this.startHadith,
    required this.endHadith,
  });

  final String id;
  final int number;
  final int startHadith;
  final int endHadith;

  String get title => 'Modul $number';
  String get rangeLabel => 'Hadis $startHadith–$endHadith';

  List<int> get hadithNumbers => List<int>.generate(
      endHadith - startHadith + 1, (index) => startHadith + index);
}
