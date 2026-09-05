import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cookmate/features/rating/services/rating_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('RatingService Unit Tests', () {
    late RatingService ratingService;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      ratingService = RatingService(prefs: prefs);
      ratingService.resetSessionState();
    });

    test('Initial state: no actions, not responded, should not show popup', () async {
      expect(await ratingService.hasResponded(), isFalse);
      expect(await ratingService.hasRated(), isFalse);
      expect(await ratingService.shouldShowAutomaticRatingPopup(), isFalse);
    });

    test('Increments meaningful action count correctly', () async {
      expect(await ratingService.recordMeaningfulAction(), 1);
      expect(await ratingService.recordMeaningfulAction(), 2);
      expect(await ratingService.recordMeaningfulAction(), 3);

      // Now threshold (3) is met
      expect(await ratingService.shouldShowAutomaticRatingPopup(actionThreshold: 3), isTrue);
    });

    test('Does not show popup if action threshold is not reached', () async {
      await ratingService.recordMeaningfulAction();
      await ratingService.recordMeaningfulAction();

      // Only 2 actions, threshold is 3
      expect(await ratingService.shouldShowAutomaticRatingPopup(actionThreshold: 3), isFalse);
    });

    test('Enforces cooldown period when popup was recently shown', () async {
      for (int i = 0; i < 3; i++) {
        await ratingService.recordMeaningfulAction();
      }
      expect(await ratingService.shouldShowAutomaticRatingPopup(), isTrue);

      // Record popup shown now
      await ratingService.recordPopupShown();

      // Immediately after, should be on cooldown and marked shown this session
      expect(ratingService.popupShownThisSession, isTrue);
      expect(await ratingService.shouldShowAutomaticRatingPopup(cooldownDays: 7), isFalse);
    });

    test('Never shows automatic popup once user submits a 4 or 5 star rating', () async {
      for (int i = 0; i < 5; i++) {
        await ratingService.recordMeaningfulAction();
      }
      expect(await ratingService.shouldShowAutomaticRatingPopup(), isTrue);

      // User rates 5 stars
      await ratingService.recordRatingSubmitted(5);

      expect(await ratingService.hasResponded(), isTrue);
      expect(await ratingService.hasRated(), isTrue);
      // Even in a new session and with threshold met, user already rated so should never show again
      ratingService.resetSessionState();
      expect(await ratingService.shouldShowAutomaticRatingPopup(), isFalse);
      expect(await ratingService.canShowAutomaticPopup(ignoreSession: true), isFalse);
    });

    test('Session throttling prevents showing popup twice in the same session', () async {
      // Show once in session
      await ratingService.recordPopupShown();
      expect(ratingService.popupShownThisSession, isTrue);

      // Second check in same session must return false
      expect(await ratingService.canShowAutomaticPopup(), isFalse);

      // After new session begins (resetSessionState) and cooldown cleared
      ratingService.resetSessionState();
      expect(ratingService.popupShownThisSession, isFalse);
    });

    test('Dialog collision guard prevents opening when another dialog is active', () async {
      ratingService.isDialogShowing = true;
      expect(await ratingService.canShowAutomaticPopup(ignoreSession: true), isFalse);

      ratingService.isDialogShowing = false;
      expect(await ratingService.canShowAutomaticPopup(ignoreSession: true), isTrue);
    });

    test('Dismissal records last shown timestamp and marks shown this session', () async {
      for (int i = 0; i < 3; i++) {
        await ratingService.recordMeaningfulAction();
      }

      await ratingService.recordDismissed();
      expect(await ratingService.hasResponded(), isFalse);
      expect(ratingService.popupShownThisSession, isTrue);
      expect(await ratingService.shouldShowAutomaticRatingPopup(cooldownDays: 7), isFalse);
    });

    test('Reset clears all rating storage and session state', () async {
      await ratingService.recordMeaningfulAction();
      await ratingService.recordRatingSubmitted(5);
      expect(await ratingService.hasResponded(), isTrue);

      await ratingService.resetRatingState();
      expect(await ratingService.hasResponded(), isFalse);
      expect(await ratingService.hasRated(), isFalse);
      expect(ratingService.popupShownThisSession, isFalse);
      expect(await ratingService.shouldShowAutomaticRatingPopup(), isFalse);
    });
  });
}
