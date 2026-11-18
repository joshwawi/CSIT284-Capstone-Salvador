import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:capstone_salvador/main.dart';

void main() {
  testWidgets('shows teacher feedback screen and average', (tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Student Feedback'), findsOneWidget);
    expect(find.text('Teacher Evaluation'), findsOneWidget);
    expect(find.text('Dr. Ana Reyes'), findsOneWidget);
    expect(find.text('4.6'), findsOneWidget);
    expect(find.text('10 responses'), findsOneWidget);
  });

  testWidgets('requires a rating and updates average after submission', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MyApp());

    await tester.ensureVisible(find.byKey(const Key('submit-feedback')));
    await tester.tap(find.byKey(const Key('submit-feedback')));
    await tester.pump();
    expect(find.text('Please select a star rating'), findsOneWidget);

    await tester.tap(find.byKey(const Key('rating-5')));
    await tester.pump();
    expect(find.text('5 out of 5'), findsOneWidget);

    await tester.ensureVisible(find.byKey(const Key('submit-feedback')));
    await tester.tap(find.byKey(const Key('submit-feedback')));
    await tester.pump();

    expect(find.text('4.6'), findsOneWidget);
    expect(find.text('11 responses'), findsOneWidget);
    expect(find.text('Select 1 to 5 stars'), findsOneWidget);
  });

  testWidgets('navigates to rating summary with ten dummy teachers', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.text('Ratings'));
    await tester.pumpAndSettle();

    expect(find.text('Rating Summary'), findsOneWidget);
    expect(find.text('All Teacher Ratings'), findsOneWidget);
    expect(find.text('10 teachers'), findsOneWidget);
    expect(find.text('Dr. Ana Reyes'), findsOneWidget);
  });
}
