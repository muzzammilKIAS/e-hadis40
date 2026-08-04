import '../models/learning_module.dart';

class ModuleRepository {
  const ModuleRepository();

  List<LearningModule> get modules => List<LearningModule>.generate(8, (index) {
        final number = index + 1;
        final start = index * 5 + 1;
        return LearningModule(
          id: 'module_${number.toString().padLeft(2, '0')}',
          number: number,
          startHadith: start,
          endHadith: start + 4,
        );
      });
}
