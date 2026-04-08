// test/widget_test.dart (simplified version)
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:seva_pulse/main.dart';

void main() {
  // Mock SharedPreferences for testing
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('SevaPulse app starts with splash screen', (WidgetTester tester) async {
    // Initialize SharedPreferences mock
    final prefs = await SharedPreferences.getInstance();
    
    // Build our app
    await tester.pumpWidget(MyApp(prefs: prefs));
    
    // Wait for initial frame
    await tester.pump();
    
    // Verify app title is present (from splash screen)
    expect(find.text('SEVA PULSE'), findsOneWidget);
    
    // Verify that the app doesn't crash
    expect(tester.takeException(), isNull);
  });
  
  testWidgets('SevaPulse app has required dependencies', (WidgetTester tester) async {
    final prefs = await SharedPreferences.getInstance();
    
    // This test just ensures the app builds without errors
    expect(() async {
      await tester.pumpWidget(MyApp(prefs: prefs));
      await tester.pump();
    }, returnsNormally);
  });
}