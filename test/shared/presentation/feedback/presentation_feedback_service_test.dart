import 'dart:async';

import 'package:flutter_starter_app/shared/presentation/feedback/presentation_feedback_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PresentationFeedbackService', () {
    test(
      'runs concurrent loading actions without skipping later actions',
      () async {
        var showCount = 0;
        var hideCount = 0;
        final firstRelease = Completer<void>();
        final secondRelease = Completer<void>();
        final started = <int>[];
        final service = PresentationFeedbackService(
          showLoadingHandler: ({allowClick = false, crossPage = true}) {
            showCount += 1;
          },
          hideLoadingHandler: () {
            hideCount += 1;
          },
        );

        final first = service.runWithLoading(() async {
          started.add(1);
          await firstRelease.future;
        });
        await Future<void>.delayed(Duration.zero);

        final second = service.runWithLoading(() async {
          started.add(2);
          await secondRelease.future;
        });
        await Future<void>.delayed(Duration.zero);

        expect(started, <int>[1, 2]);
        expect(showCount, 1);
        expect(hideCount, 0);
        expect(service.isShowingLoading, isTrue);

        secondRelease.complete();
        await Future<void>.delayed(Duration.zero);

        expect(hideCount, 0);
        expect(service.isShowingLoading, isTrue);

        firstRelease.complete();
        await Future.wait(<Future<void>>[first, second]);

        expect(hideCount, 1);
        expect(service.isShowingLoading, isFalse);
      },
    );

    test('hides loading, emits hint, and rethrows errors by default', () async {
      var hideCount = 0;
      final hints = <String>[];
      final service = PresentationFeedbackService(
        showLoadingHandler: ({allowClick = false, crossPage = true}) {},
        hideLoadingHandler: () {
          hideCount += 1;
        },
        showHintHandler: hints.add,
      );

      await expectLater(
        service.runWithLoading(() async {
          throw StateError('failed');
        }),
        throwsA(isA<StateError>()),
      );

      expect(hideCount, 1);
      expect(hints.single, contains('failed'));
      expect(service.isShowingLoading, isFalse);
    });

    test('can explicitly swallow errors after emitting hint', () async {
      final hints = <String>[];
      final service = PresentationFeedbackService(showHintHandler: hints.add);

      await service.runWithLoading(() async {
        throw StateError('failed');
      }, rethrowError: false);

      expect(hints.single, contains('failed'));
      expect(service.isShowingLoading, isFalse);
    });
  });
}
