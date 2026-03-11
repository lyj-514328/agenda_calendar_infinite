import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agenda_calendar_infinite/agenda_calendar_infinite.dart';

void main() {
  group('CalendarEvent', () {
    test('should create CalendarEvent with required properties', () {
      final start = DateTime(2024, 1, 1);
      final end = DateTime(2024, 1, 2);
      final event = CalendarEvent(
        id: '1',
        title: 'Test Event',
        startDate: start,
        endDate: end,
      );

      expect(event.id, '1');
      expect(event.title, 'Test Event');
      expect(event.startDate, start);
      expect(event.endDate, end);
      expect(event.color, Colors.blue);
      expect(event.data, isNull);
    });

    test('should accept custom color and data', () {
      final start = DateTime(2024, 1, 1);
      final end = DateTime(2024, 1, 2);
      final event = CalendarEvent(
        id: '2',
        title: 'Custom Event',
        startDate: start,
        endDate: end,
        color: Colors.red,
        data: {'key': 'value'},
      );

      expect(event.color, Colors.red);
      expect(event.data, {'key': 'value'});
    });
  });

  group('VerticalCalendar', () {
    testWidgets('should build without errors', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VerticalCalendar(
              selectedDay: DateTime(2024, 1, 15),
              onDaySelected: (selected, focused) {},
            ),
          ),
        ),
      );

      expect(find.byType(VerticalCalendar), findsOneWidget);
    });

    testWidgets('should display month header', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VerticalCalendar(
              selectedDay: DateTime(2024, 1, 15),
              onDaySelected: (selected, focused) {},
            ),
          ),
        ),
      );

      expect(find.text('2024年1月'), findsOneWidget);
    });

    testWidgets('should display week days', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VerticalCalendar(
              selectedDay: DateTime(2024, 1, 15),
              onDaySelected: (selected, focused) {},
            ),
          ),
        ),
      );

      expect(find.text('一'), findsWidgets);
      expect(find.text('二'), findsWidgets);
      expect(find.text('三'), findsWidgets);
      expect(find.text('四'), findsWidgets);
      expect(find.text('五'), findsWidgets);
      expect(find.text('六'), findsWidgets);
      expect(find.text('日'), findsWidgets);
    });
  });
}
