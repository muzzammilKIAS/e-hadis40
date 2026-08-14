import '../models/learning_module.dart';
import '../../core/curriculum/app_curriculum_structure.dart';

class ModuleRepository {
  const ModuleRepository();

  List<LearningModule> get modules => AppCurriculumStructure.modules;
}
