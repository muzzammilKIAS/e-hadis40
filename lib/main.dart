import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'data/repositories/hadith_repository.dart';
import 'data/repositories/module_repository.dart';
import 'data/repositories/narrator_repository.dart';
import 'services/app_controller.dart';
import 'services/global_audio_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final controller = AppController();
  await controller.initialize();
  final hadithRepository = await HadithRepository.load();

  final narratorRepository = await NarratorRepository.load();

  final audioController = GlobalHadithAudioController();
  audioController.init(hadithRepository.availableHadiths);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AppController>.value(value: controller),
        Provider<HadithRepository>.value(value: hadithRepository),
        Provider<NarratorRepository>.value(value: narratorRepository),
        Provider<ModuleRepository>(create: _createModuleRepository),
        ChangeNotifierProvider<GlobalHadithAudioController>.value(
          value: audioController,
        ),
      ],
      child: const EHadis40App(),
    ),
  );
}

ModuleRepository _createModuleRepository(BuildContext context) {
  return const ModuleRepository();
}
