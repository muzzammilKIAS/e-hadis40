import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Anatomi Sunnah H31-H42', () {
    test('H31-H42 wujud dan guna sumber tempatan', () {
      for (var n = 31; n <= 42; n++) {
        final file = File('web/anatomi_sunnah/hadith_$n.html');
        expect(file.existsSync(), true,
            reason: 'web/anatomi_sunnah/hadith_$n.html mesti wujud');
        final content = file.readAsStringSync();
        expect(content.contains('./lib/three.min.js'), true,
            reason: 'H$n mesti guna three.min.js tempatan');
        expect(content.contains('./lib/gsap.min.js'), true,
            reason: 'H$n mesti guna gsap.min.js tempatan');
        expect(content.contains('cdn.tailwindcss.com'), false,
            reason: 'H$n tidak boleh guna CDN Tailwind');
        expect(content.contains('cdnjs.cloudflare.com'), false,
            reason: 'H$n tidak boleh guna CDN cloudflare');
        expect(content.contains('fonts.googleapis.com'), false,
            reason: 'H$n tidak boleh guna Google Fonts CDN');
        expect(content.contains('anatomi-back-btn'), true,
            reason: 'H$n mesti ada butang kembali');
        expect(content.contains('max-w-2xl'), false,
            reason:
                'H$n header kotak hadis mesti guna max-w-xl (sama seperti H1-H30), bukan max-w-2xl');
        expect(content.contains('max-w-xl'), true,
            reason: 'H$n header kotak hadis mesti guna max-w-xl');
        expect(
            content.contains(
                '<div class="glass-panel p-6 rounded-3xl max-w-sm ml-auto text-right">'),
            false,
            reason: 'H$n panel butang mesti text-left (sama seperti H1-H30)');
        expect(RegExp(r'@media \(max-width: 1024px\)').hasMatch(content), true,
            reason: 'H$n mesti ada responsive tablet block');
        expect(RegExp(r'@media \(max-width: 640px\)').hasMatch(content), true,
            reason: 'H$n mesti ada responsive phone block');
      }
    });

    test('Tiada mojibake biasa (Ã, Â, â€) dalam H31-H42', () {
      for (var n = 31; n <= 42; n++) {
        final content =
            File('web/anatomi_sunnah/hadith_$n.html').readAsStringSync();
        expect(content.contains('Ã'), false, reason: 'H$n ada mojibake Ã');
        expect(content.contains('â€'), false, reason: 'H$n ada mojibake â€');
        expect(content.contains('â¢'), false, reason: 'H$n ada mojibake bullet');
      }
    });

    test('Badge setiap fail memaparkan nombor hadis yang betul', () {
      for (var n = 31; n <= 42; n++) {
        final content =
            File('web/anatomi_sunnah/hadith_$n.html').readAsStringSync();
        expect(content.contains('Hadis $n</span>') ||
                content.contains('Hadis $n (Penutup)</span>'),
            true,
            reason: 'H$n mesti memaparkan badge "Hadis $n" yang betul '
                '(bukan salinan daripada hadis lain)');
      }
    });

    test('AnatomiSunnahScreen.availableHadithSet merangkumi H31-H42', () {
      final source =
          File('lib/screens/anatomi_sunnah_screen.dart').readAsStringSync();
      expect(source.contains('31, 32, 33, 34, 35, 36, 37, 38, 39, 40,'), true,
          reason: 'Hadis 31-40 mesti tersenarai dalam availableHadithSet');
      expect(source.contains('41, 42,'), true,
          reason: 'Hadis 41-42 mesti tersenarai dalam availableHadithSet');
    });
  });
}
