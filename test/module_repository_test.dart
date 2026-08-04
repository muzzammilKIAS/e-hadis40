import 'package:e_hadis40/data/repositories/module_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Repository menyediakan 8 modul dan 40 nombor hadis', () {
    const repository = ModuleRepository();
    expect(repository.modules.length, 8);
    expect(repository.modules.first.startHadith, 1);
    expect(repository.modules.last.endHadith, 40);
  });
}
