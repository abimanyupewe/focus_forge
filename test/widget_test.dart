import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focus_forge/features/schedule/presentation/pages/dashboard_page.dart';
import 'package:focus_forge/features/schedule/presentation/view_models/dashboard_view_model.dart';

class MockDashboardNotifier extends DashboardNotifier {
  @override
  DashboardState build() {
    return DashboardState(
      isLoading: false,
      schedules: const [],
      dailyDurations: const {},
      streakDays: 0,
    );
  }
}

void main() {
  testWidgets('FocusForgeApp basic loading smoke test', (WidgetTester tester) async {
    // Merender DashboardPage dengan provider yang telah di-override secara sinkron
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          dashboardViewModelProvider.overrideWith(() => MockDashboardNotifier()),
        ],
        child: const MaterialApp(
          home: DashboardPage(),
        ),
      ),
    );

    // Pump frame untuk menyelesaikan semua animasi finit
    await tester.pumpAndSettle();

    // Memverifikasi teks 'FocusForge' berhasil dirender di AppBar/Header awal
    expect(find.text('FocusForge'), findsOneWidget);
  });
}
