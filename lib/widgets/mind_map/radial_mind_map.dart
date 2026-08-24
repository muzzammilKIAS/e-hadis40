import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../data/models/hadith.dart';
import '../../screens/hadith_screen.dart';
import '../../services/app_controller.dart';
import '../dashboard/dashboard_activity_tile.dart';
import '../dashboard/glass_surface.dart';
import '../dashboard/islamic_atmosphere.dart';

/// Satu cabang dalam peta minda — kumpulan hadis di bawah satu label
/// (tema/nilai fokus, ATAU nama perawi, dsb.). Warna aksen dan senarai
/// hadis disediakan oleh pemanggil (skrin domain-khusus); widget ini
/// hanya bertanggungjawab untuk lukisan radial + interaksi kembang.
class MindMapCluster {
  const MindMapCluster({
    required this.label,
    required this.accent,
    required this.hadiths,
    this.subtitle,
  });

  final String label;

  /// Info tambahan pendek dipaparkan dalam kad kembang (cth. gelaran
  /// perawi) — pilihan, boleh biarkan null untuk peta minda ikut tema.
  final String? subtitle;
  final Color accent;
  final List<Hadith> hadiths;
}

/// Halaman peta minda radial kongsi — digunakan oleh skrin "ikut tema"
/// (`MindMapScreen`) dan "ikut perawi" (`NarratorMindMapScreen`). Menerima
/// senarai cabang yang telah disusun (label + warna + hadis) dan
/// mengendalikan semua lukisan/geometri/interaksi (zum, pan, kembang,
/// navigasi ke `HadithScreen`) secara generik — supaya logik kelompok
/// (ikut tema vs ikut perawi) kekal berasingan daripada logik lukisan.
class RadialMindMapPage extends StatefulWidget {
  const RadialMindMapPage({
    required this.title,
    required this.hint,
    required this.centerLabel,
    required this.centerSubLabel,
    required this.clusters,
    super.key,
  });

  final String title;
  final String hint;
  final String centerLabel;
  final String centerSubLabel;
  final List<MindMapCluster> clusters;

  @override
  State<RadialMindMapPage> createState() => _RadialMindMapPageState();
}

class _RadialMindMapPageState extends State<RadialMindMapPage> {
  static const double _canvasSize = 4000;
  static const double _centerNodeSize = 156;

  /// Jejari gelang cabang mengembang mengikut bilangan cabang — dengan
  /// bilangan cabang yang lebih ramai (cth. 22 perawi berbanding 13 tema),
  /// gelang lebih kecil menjadikan cabang terlalu rapat sehingga kad
  /// kembang bertindih dengan label cabang jiran. `62px` ialah anggaran
  /// lebar minimum selesa setiap cabang di sekeliling gelang.
  double get _clusterRingRadius =>
      math.max(820.0, widget.clusters.length * 62.0);

  final TransformationController _transformController =
      TransformationController();
  final Set<String> _expanded = <String>{};
  bool _centered = false;

  @override
  void dispose() {
    _transformController.dispose();
    super.dispose();
  }

  /// Pusatkan lukisan besar (2200×2200) di tengah viewport pada muatan
  /// pertama sahaja — tanpa ini, `InteractiveViewer` bermula terpaku di
  /// sudut kiri-atas kanvas (nod tengah tidak kelihatan langsung).
  void _centerViewport(Size viewport) {
    if (_centered) return;
    _centered = true;
    final dx = (viewport.width - _canvasSize) / 2;
    final dy = (viewport.height - _canvasSize) / 2;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _transformController.value = Matrix4.identity()
        ..translateByDouble(dx, dy, 0, 1);
    });
  }

  List<_PositionedCluster> _layoutClusters() {
    const center = Offset(_canvasSize / 2, _canvasSize / 2);
    final total = widget.clusters.length;
    return [
      for (var i = 0; i < total; i++)
        _PositionedCluster(
          cluster: widget.clusters[i],
          position: center +
              Offset.fromDirection(
                -math.pi / 2 + (2 * math.pi * i / total),
                _clusterRingRadius,
              ),
          angle: -math.pi / 2 + (2 * math.pi * i / total),
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final controller = context.watch<AppController>();
    final clusters = _layoutClusters();

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        foregroundColor: scheme.onSurface,
        iconTheme: IconThemeData(color: scheme.onSurface),
        titleTextStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: scheme.onSurface,
            ),
        title: Text(widget.title),
      ),
      body: IslamicAtmosphere(
        intensity: 0.6,
        child: Column(
          children: [
            SizedBox(
              height: kToolbarHeight + MediaQuery.of(context).padding.top,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded,
                      size: 16, color: scheme.onSurfaceVariant),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.hint,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  _centerViewport(
                    Size(constraints.maxWidth, constraints.maxHeight),
                  );
                  return ClipRect(
                    child: InteractiveViewer(
                      transformationController: _transformController,
                      constrained: false,
                      minScale: 0.32,
                      maxScale: 2.2,
                      boundaryMargin: const EdgeInsets.all(400),
                      child: SizedBox(
                        width: _canvasSize,
                        height: _canvasSize,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Positioned.fill(
                              child: CustomPaint(
                                painter: _ConnectorPainter(
                                  clusters: clusters,
                                  expanded: _expanded,
                                  lineColor: scheme.primary,
                                  dark: scheme.brightness == Brightness.dark,
                                ),
                              ),
                            ),
                            ..._buildClusterWidgets(
                                clusters, controller, scheme),
                            Positioned(
                              left: _canvasSize / 2 - _centerNodeSize / 2,
                              top: _canvasSize / 2 - _centerNodeSize / 2,
                              width: _centerNodeSize,
                              height: _centerNodeSize,
                              child: _CenterNodeContent(
                                label: widget.centerLabel,
                                subLabel: widget.centerSubLabel,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildClusterWidgets(
    List<_PositionedCluster> clusters,
    AppController controller,
    ColorScheme scheme,
  ) {
    final widgets = <Widget>[];
    for (final positioned in clusters) {
      final cluster = positioned.cluster;
      final nodeRadius = _clusterNodeRadius(cluster.hadiths.length);
      final expanded = _expanded.contains(cluster.label);

      widgets.add(
        Positioned(
          left: positioned.position.dx - nodeRadius,
          top: positioned.position.dy - nodeRadius,
          width: nodeRadius * 2,
          height: nodeRadius * 2,
          child: _ClusterCircle(
            cluster: cluster,
            radius: nodeRadius,
            expanded: expanded,
            onTap: () => setState(() {
              if (expanded) {
                _expanded.remove(cluster.label);
              } else {
                _expanded.add(cluster.label);
              }
            }),
          ),
        ),
      );

      widgets.add(
        Positioned(
          left: positioned.position.dx - 74,
          top: positioned.position.dy + nodeRadius + 6,
          width: 148,
          child: Text(
            cluster.label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 12.5,
              color: scheme.onSurface,
            ),
          ),
        ),
      );

      if (expanded) {
        final anchor = _expandAnchor(positioned, nodeRadius);
        widgets.add(
          Positioned(
            left: anchor.left,
            top: anchor.top,
            width: _ExpandAnchor.cardWidth,
            child: _ClusterExpandCard(cluster: cluster, controller: controller),
          ),
        );
      }
    }
    return widgets;
  }

  static double _clusterNodeRadius(int hadithCount) =>
      26.0 + math.min(hadithCount, 9) * 2.6;

  /// Kad kembang dianjak keluar sepanjang arah RADIAL cabang itu sendiri
  /// (bukan semata mendatar kiri/kanan) — dengan banyak cabang berketat di
  /// sekeliling gelang (cth. 22 perawi), anjakan mendatar tulen menyebabkan
  /// kad bertindih dengan label cabang jiran yang bersebelahan menegak.
  /// Menyusuri arah cabang sendiri mengekalkan kad dalam "petak" ruang
  /// kosong milik cabang itu di luar gelang.
  static _ExpandAnchor _expandAnchor(
    _PositionedCluster positioned,
    double nodeRadius,
  ) {
    final dirX = math.cos(positioned.angle);
    final dirY = math.sin(positioned.angle);
    final pointRight = dirX >= 0;
    final outward = nodeRadius + 44;
    final baseX = positioned.position.dx + dirX * outward;
    final baseY = positioned.position.dy + dirY * outward;
    final left = pointRight ? baseX : baseX - _ExpandAnchor.cardWidth;
    final top = (baseY - 90).clamp(40.0, _canvasSize - 420).toDouble();
    return _ExpandAnchor(left: left, top: top, pointRight: pointRight);
  }
}

class _PositionedCluster {
  const _PositionedCluster({
    required this.cluster,
    required this.position,
    required this.angle,
  });

  final MindMapCluster cluster;
  final Offset position;
  final double angle;
}

class _ExpandAnchor {
  const _ExpandAnchor({
    required this.left,
    required this.top,
    required this.pointRight,
  });

  static const double cardWidth = 264;

  final double left;
  final double top;
  final bool pointRight;
}

class _CenterNodeContent extends StatelessWidget {
  const _CenterNodeContent({required this.label, required this.subLabel});

  final String label;
  final String subLabel;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final dark = scheme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: dark
              ? [AppColors.deepEmerald, const Color(0xFF15654C)]
              : [AppColors.primary, AppColors.secondary],
        ),
        border: Border.all(
          color: AppColors.goldAccent.withValues(alpha: 0.55),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.deepEmerald.withValues(alpha: dark ? 0.5 : 0.3),
            blurRadius: 26,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.auto_awesome_rounded,
              color: AppColors.softGold, size: 26),
          const SizedBox(height: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
          ),
          Text(
            subLabel,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.82),
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ClusterCircle extends StatelessWidget {
  const _ClusterCircle({
    required this.cluster,
    required this.radius,
    required this.expanded,
    required this.onTap,
  });

  final MindMapCluster cluster;
  final double radius;
  final bool expanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final dark = scheme.brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                cluster.accent.withValues(alpha: dark ? 0.42 : 0.38),
                cluster.accent.withValues(alpha: dark ? 0.22 : 0.2),
              ],
            ),
            border: Border.all(
              color: cluster.accent.withValues(alpha: expanded ? 0.95 : 0.55),
              width: expanded ? 2.4 : 1.6,
            ),
            boxShadow: expanded
                ? [
                    BoxShadow(
                      color: cluster.accent.withValues(alpha: 0.35),
                      blurRadius: 18,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          // Warna aksen cabang (termasuk pink) diwarnakan pada BULATAN
          // (latar/sempadan di atas) — bukan pada nombor teks di sini,
          // supaya bilangan hadis kekal mudah dibaca tanpa mengira warna
          // cabang.
          child: Text(
            '${cluster.hadiths.length}',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: radius >= 38 ? 18 : 15,
              color: dark ? Colors.white : scheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}

class _ClusterExpandCard extends StatelessWidget {
  const _ClusterExpandCard({required this.cluster, required this.controller});

  final MindMapCluster cluster;
  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return GlassSurface(
      padding: const EdgeInsets.all(14),
      radius: 18,
      accent: cluster.accent.withValues(alpha: 0.5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: cluster.accent,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  cluster.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13.5,
                  ),
                ),
              ),
            ],
          ),
          if (cluster.subtitle != null && cluster.subtitle!.isNotEmpty) ...[
            const SizedBox(height: 2),
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Text(
                cluster.subtitle!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11.5,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
          const SizedBox(height: 10),
          for (var i = 0; i < cluster.hadiths.length; i++) ...[
            if (i > 0) const SizedBox(height: 6),
            DashboardActivityTile(
              dense: true,
              icon: controller.isCompleted(cluster.hadiths[i].id)
                  ? Icons.check_circle_rounded
                  : Icons.auto_stories_rounded,
              leadingLabel: cluster.hadiths[i].displayNumber,
              title: cluster.hadiths[i].title,
              accent: cluster.accent,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => HadithScreen(hadith: cluster.hadiths[i]),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Melukis garisan lengkung nod-tengah → setiap cabang, dan
/// cabang → kad kembang (bila dibuka). Lengkung (bukan garis lurus)
/// sengaja digunakan untuk rasa "organik" mengikut gaya lukisan peta
/// minda tulisan tangan.
class _ConnectorPainter extends CustomPainter {
  const _ConnectorPainter({
    required this.clusters,
    required this.expanded,
    required this.lineColor,
    required this.dark,
  });

  final List<_PositionedCluster> clusters;
  final Set<String> expanded;
  final Color lineColor;
  final bool dark;

  static const _center = Offset(
    _RadialMindMapPageState._canvasSize / 2,
    _RadialMindMapPageState._canvasSize / 2,
  );

  @override
  void paint(Canvas canvas, Size size) {
    final trunkPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..color = lineColor.withValues(alpha: dark ? 0.4 : 0.32);

    for (final positioned in clusters) {
      final mid = Offset.lerp(_center, positioned.position, 0.5)!;
      final normal = Offset(
        -(positioned.position.dy - _center.dy),
        positioned.position.dx - _center.dx,
      );
      final normalLength = normal.distance == 0 ? 1.0 : normal.distance;
      final control = mid + (normal / normalLength) * 46;

      final path = Path()
        ..moveTo(_center.dx, _center.dy)
        ..quadraticBezierTo(
          control.dx,
          control.dy,
          positioned.position.dx,
          positioned.position.dy,
        );
      canvas.drawPath(path, trunkPaint);

      if (expanded.contains(positioned.cluster.label)) {
        final nodeRadius = _RadialMindMapPageState._clusterNodeRadius(
          positioned.cluster.hadiths.length,
        );
        final anchor =
            _RadialMindMapPageState._expandAnchor(positioned, nodeRadius);
        final target = Offset(
          anchor.pointRight
              ? anchor.left
              : anchor.left + _ExpandAnchor.cardWidth,
          anchor.top + 40,
        );
        final branchPaint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.8
          ..strokeCap = StrokeCap.round
          ..color = positioned.cluster.accent.withValues(alpha: 0.6);
        canvas.drawLine(positioned.position, target, branchPaint);
      }
    }
  }

  @override
  bool shouldRepaint(_ConnectorPainter old) =>
      old.clusters != clusters ||
      old.expanded != expanded ||
      old.lineColor != lineColor ||
      old.dark != dark;
}
