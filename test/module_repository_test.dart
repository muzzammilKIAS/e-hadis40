import 'package:e_hadis40/core/curriculum/app_curriculum_structure.dart';
import 'package:e_hadis40/data/repositories/module_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Repository menyediakan 8 modul dan 42 nombor hadis', () {
    const repository = ModuleRepository();
    expect(repository.modules.length, 8);
    expect(repository.modules.first.startHadith, 1);
    expect(repository.modules.last.endHadith, 42);
  });

  test('Struktur kurikulum: 42 hadis, 8 modul', () {
    expect(AppCurriculumStructure.totalHadiths, 42);
    expect(AppCurriculumStructure.totalModules, 8);
  });

  test('Setiap modul mempunyai count yang betul', () {
    final modules = const ModuleRepository().modules;
    final counts = <int, int>{};
    for (final m in modules) {
      counts[m.number] = m.hadithNumbers.length;
    }
    expect(counts[1], 5);
    expect(counts[2], 5);
    expect(counts[3], 5);
    expect(counts[4], 5);
    expect(counts[5], 5);
    expect(counts[6], 5);
    expect(counts[7], 6);
    expect(counts[8], 6);
  });

  test('Mapping hadis ke module betul', () {
    expect(AppCurriculumStructure.moduleIdFor(5), 'module_01');
    expect(AppCurriculumStructure.moduleIdFor(6), 'module_02');
    expect(AppCurriculumStructure.moduleIdFor(10), 'module_02');
    expect(AppCurriculumStructure.moduleIdFor(11), 'module_03');
    expect(AppCurriculumStructure.moduleIdFor(30), 'module_06');
    expect(AppCurriculumStructure.moduleIdFor(31), 'module_07');
    expect(AppCurriculumStructure.moduleIdFor(36), 'module_07');
    expect(AppCurriculumStructure.moduleIdFor(37), 'module_08');
    expect(AppCurriculumStructure.moduleIdFor(42), 'module_08');
  });
}
