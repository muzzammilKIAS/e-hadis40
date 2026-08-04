import 'package:flutter/material.dart';

import '../core/constants/app_constants.dart';
import '../data/models/hadith.dart';

class ProjectorScreen extends StatefulWidget {
  const ProjectorScreen({required this.hadith, super.key});

  final Hadith hadith;

  @override
  State<ProjectorScreen> createState() => _ProjectorScreenState();
}

class _ProjectorScreenState extends State<ProjectorScreen> {
  late final PageController _pageController;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hadith = widget.hadith;
    final pages = <_ProjectorPageData>[
      _ProjectorPageData(
        title: 'Hadis ${hadith.displayNumber} · ${hadith.title}',
        subtitle: hadith.theme,
        arabic: hadith.arabicText,
      ),
      _ProjectorPageData(
          title: 'Maksud Hadis', paragraphs: [hadith.translationMalay]),
      _ProjectorPageData(
          title: 'Huraian Hadis', paragraphs: hadith.explanations),
      _ProjectorPageData(title: 'Pengajaran', paragraphs: hadith.lessons),
      _ProjectorPageData(title: 'Penghayatan', paragraphs: hadith.appreciation),
      _ProjectorPageData(title: 'Fokus Nilai', paragraphs: hadith.focusValues),
      _ProjectorPageData(
          title: 'Soalan Refleksi', paragraphs: hadith.reflectionQuestions),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mod Projektor'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(child: Text('${_index + 1}/${pages.length}')),
          ),
        ],
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: pages.length,
        onPageChanged: (value) => setState(() => _index = value),
        itemBuilder: (context, index) => _ProjectorPage(data: pages[index]),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              OutlinedButton.icon(
                onPressed: _index == 0 ? null : () => _goTo(_index - 1),
                icon: const Icon(Icons.arrow_back_rounded),
                label: const Text('Sebelumnya'),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: LinearProgressIndicator(
                  value: (_index + 1) / pages.length,
                  minHeight: 8,
                ),
              ),
              const SizedBox(width: 16),
              FilledButton.icon(
                onPressed:
                    _index == pages.length - 1 ? null : () => _goTo(_index + 1),
                icon: const Icon(Icons.arrow_forward_rounded),
                label: const Text('Seterusnya'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _goTo(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }
}

class _ProjectorPageData {
  const _ProjectorPageData({
    required this.title,
    this.subtitle,
    this.arabic,
    this.paragraphs = const [],
  });

  final String title;
  final String? subtitle;
  final String? arabic;
  final List<String> paragraphs;
}

class _ProjectorPage extends StatelessWidget {
  const _ProjectorPage({required this.data});

  final _ProjectorPageData data;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(42),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            children: [
              Text(
                data.title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displaySmall,
              ),
              if (data.subtitle != null) ...[
                const SizedBox(height: 12),
                Text(
                  data.subtitle!,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: scheme.primary,
                      ),
                ),
              ],
              const SizedBox(height: 36),
              if (data.arabic != null)
                Directionality(
                  textDirection: TextDirection.rtl,
                  child: SelectableText(
                    data.arabic!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: AppConstants.arabicFontFamily,
                      fontFamilyFallback: AppConstants.arabicFontFallback,
                      fontSize: 46,
                      height: 2,
                    ),
                  ),
                ),
              if (data.paragraphs.isNotEmpty)
                Column(
                  children: [
                    for (var index = 0; index < data.paragraphs.length; index++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 22),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 18,
                              child: Text('${index + 1}'),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                data.paragraphs[index],
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(
                                      height: 1.55,
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
