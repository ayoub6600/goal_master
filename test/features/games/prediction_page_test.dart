import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:goal_master/core/errors/failure.dart';
import 'package:goal_master/features/games/data/prediction_repo.dart';
import 'package:goal_master/features/games/presentation/prediction/prediction_page.dart';

class _Repo implements PredictionRepo {
  final sent = <(int, int, int)>[];

  PredictionMatch _match(int id, Duration from, {Score? mine}) {
    final now = DateTime.now();
    return PredictionMatch(
        id: id, home: 'الأهلي', away: 'الاتحاد', competition: 'الدوري الليبي', kickoff: now.add(from),
        open: from > Duration.zero, locksAt: now.add(from), status: 'scheduled', result: null, mine: mine,
        points: null, exact: false);
  }

  @override
  Future<Either<Failure, PredictionBoard>> board() async => right(PredictionBoard(
        enabled: true, verified: true, exactPoints: 3, resultPoints: 1, prizes: const [100, 50, 25],
        upcoming: [_match(1, const Duration(hours: 3)), _match(2, const Duration(minutes: -5), mine: (home: 1, away: 1))],
        recent: const [],
        week: const PredictionTable(start: '2026-11-16', end: '2026-11-22', awarded: false, leaders: [], myRank: null, myPoints: 0),
        lastWeek: const PredictionTable(start: '2026-11-09', end: '2026-11-15', awarded: false, leaders: [], myRank: null, myPoints: 0),
      ));

  @override
  Future<Either<Failure, PredictionMatch>> predict(int matchId, int home, int away) async {
    sent.add((matchId, home, away));
    return right(_match(matchId, const Duration(hours: 3), mine: (home: home, away: away)));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets('pick a score and save it; a started match is locked', (tester) async {
    tester.view.physicalSize = const Size(440 * 3, 1400 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final repo = _Repo();

    await tester.pumpWidget(MaterialApp(
      builder: (context, child) => Directionality(textDirection: TextDirection.rtl, child: child!),
      home: PredictionPage(repo: repo),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Home +2, away +1 on the open match (the first card's arrows).
    final ups = find.byIcon(Icons.keyboard_arrow_up_rounded);
    for (final i in [0, 0, 1]) {
      await tester.tap(ups.at(i));
      await tester.pump();
    }
    await tester.tap(find.text('احفظ توقعك'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(repo.sent, [(1, 2, 1)]);
    expect(find.text('تم حفظ توقعك'), findsOneWidget);
    expect(find.textContaining('انطلقت المباراة — توقعك 1 : 1'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });
}
