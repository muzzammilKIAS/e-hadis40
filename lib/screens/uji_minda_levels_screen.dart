// ignore_for_file: deprecated_member_use
import 'dart:convert';
import 'dart:html' as html;

import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../widgets/dashboard/glass_surface.dart';
import '../widgets/dashboard/islamic_atmosphere.dart';
import '../widgets/dashboard/xplorasi_minda_title.dart';
import 'uji_minda_screen.dart';

/// Senarai 4 level "X-plorasi Minda" — setiap level memainkan ~10 hadis
/// daripada jumlah 41 (lihat `activeIndices` dalam `web/uji_minda/index.html`).
/// Level 1 sentiasa terbuka; level seterusnya terkunci sehingga level
/// sebelumnya selesai. Status selesai disimpan oleh game itu sendiri dalam
/// `localStorage` (kunci `ehadis40-xplorasi-level-done`, satu tatasusunan
/// nombor level) — sama-origin dengan app induk, jadi terus boleh dibaca di
/// sini tanpa perlu saluran komunikasi lain.
class UjiMindaLevelsScreen extends StatefulWidget {
  const UjiMindaLevelsScreen({super.key});

  static const _progressKey = 'ehadis40-xplorasi-level-done';
  static const totalLevels = 4;
  static const questionsPerLevel = 10;

  @override
  State<UjiMindaLevelsScreen> createState() => _UjiMindaLevelsScreenState();
}

class _UjiMindaLevelsScreenState extends State<UjiMindaLevelsScreen> {
  Set<int> _done = {};

  @override
  void initState() {
    super.initState();
    _readProgress();
  }

  void _readProgress() {
    final raw = html.window.localStorage[UjiMindaLevelsScreen._progressKey];
    if (raw == null) {
      setState(() => _done = {});
      return;
    }
    try {
      final list = (jsonDecode(raw) as List).cast<num>();
      setState(() => _done = list.map((n) => n.toInt()).toSet());
    } catch (_) {
      setState(() => _done = {});
    }
  }

  Future<void> _openLevel(int level) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => UjiMindaScreen(level: level),
      ),
    );
    if (!mounted) return;
    _readProgress();
  }

  (int, int) _rangeFor(int level) {
    final start = (level - 1) * UjiMindaLevelsScreen.questionsPerLevel + 1;
    final end = level == UjiMindaLevelsScreen.totalLevels
        ? 41
        : level * UjiMindaLevelsScreen.questionsPerLevel;
    return (start, end);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        title: XplorasiMindaTitle(
          textColor: scheme.onSurface,
          xBoxColor: AppColors.gold,
          xIconColor: scheme.brightness == Brightness.dark
              ? scheme.surface
              : Colors.white,
          fontSize: 18,
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // 700px sepadan dengan ambang `panelColumns`/`inlineSearch`
            // dalam `DashboardLayout` supaya tablet/desktop bertukar susun
            // atur pada titik yang sama merata-rata app.
            final columns = constraints.maxWidth >= 700 ? 2 : 1;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pilih Level',
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Selesaikan satu level untuk membuka level seterusnya. '
                        'Setiap level mengandungi ${UjiMindaLevelsScreen.questionsPerLevel} soalan.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(height: 20),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: UjiMindaLevelsScreen.totalLevels,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columns,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: columns == 2 ? 2.6 : 2.9,
                        ),
                        itemBuilder: (context, i) {
                          final level = i + 1;
                          final unlocked =
                              level == 1 || _done.contains(level - 1);
                          final completed = _done.contains(level);
                          final (start, end) = _rangeFor(level);
                          return _LevelTile(
                            level: level,
                            hadithRange: 'Hadis $start – $end',
                            unlocked: unlocked,
                            completed: completed,
                            onTap: unlocked ? () => _openLevel(level) : null,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _LevelTile extends StatefulWidget {
  const _LevelTile({
    required this.level,
    required this.hadithRange,
    required this.unlocked,
    required this.completed,
    required this.onTap,
  });

  final int level;
  final String hadithRange;
  final bool unlocked;
  final bool completed;
  final VoidCallback? onTap;

  @override
  State<_LevelTile> createState() => _LevelTileState();
}

class _LevelTileState extends State<_LevelTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final dark = scheme.brightness == Brightness.dark;
    final accent = widget.completed ? scheme.primary : AppColors.gold;

    return MouseRegion(
      cursor: widget.unlocked
          ? SystemMouseCursors.click
          : SystemMouseCursors.forbidden,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedOpacity(
        opacity: widget.unlocked ? 1 : 0.55,
        duration: const Duration(milliseconds: 180),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          transform: Matrix4.translationValues(
            0,
            _hovered && widget.unlocked ? -3 : 0,
            0,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _hovered && widget.unlocked
                  ? accent.withValues(alpha: 0.75)
                  : scheme.outlineVariant.withValues(alpha: dark ? 0.6 : 1),
              width: _hovered && widget.unlocked ? 1.4 : 1,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              Positioned.fill(
                child: IslamicCardPattern(color: accent, seed: widget.level),
              ),
              GlassSurface(
                padding: const EdgeInsets.all(16),
                child: Material(
                  type: MaterialType.transparency,
                  child: InkWell(
                    onTap: widget.onTap,
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: accent.withValues(alpha: dark ? 0.24 : 0.14),
                            border: Border.all(
                                color: accent.withValues(alpha: 0.4)),
                          ),
                          child: widget.unlocked
                              ? Text(
                                  '${widget.level}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 20,
                                    color: accent,
                                  ),
                                )
                              : Icon(Icons.lock_rounded,
                                  size: 20, color: accent),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Level ${widget.level}',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                widget.unlocked
                                    ? widget.hadithRange
                                    : 'Selesaikan Level ${widget.level - 1} dahulu',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(color: scheme.onSurfaceVariant),
                              ),
                            ],
                          ),
                        ),
                        if (widget.completed)
                          Icon(Icons.check_circle_rounded,
                              color: scheme.primary, size: 22)
                        else if (widget.unlocked)
                          Icon(Icons.arrow_forward_rounded,
                              color: accent, size: 18),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
