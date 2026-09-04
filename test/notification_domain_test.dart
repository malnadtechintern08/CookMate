import 'package:flutter_test/flutter_test.dart';
import 'package:cookmate/features/notifications/domain/entities/notification_item.dart';
import 'package:cookmate/features/notifications/data/models/notification_model.dart';

void main() {
  group('Notification Domain & Model Tests', () {
    test('NotificationType.fromString correctly parses all supported types', () {
      expect(NotificationType.fromString('new_recipe'), NotificationType.newRecipe);
      expect(NotificationType.fromString('recipe_updated'), NotificationType.recipeUpdated);
      expect(NotificationType.fromString('admin_announcement'), NotificationType.adminAnnouncement);
      expect(NotificationType.fromString('new_feature'), NotificationType.newFeature);
      expect(NotificationType.fromString('recipe_approved'), NotificationType.recipeApproved);
      expect(NotificationType.fromString('recipe_rejected'), NotificationType.recipeRejected);
      expect(NotificationType.fromString('changes_requested'), NotificationType.changesRequested);
      expect(NotificationType.fromString('promotion'), NotificationType.promotion);
      expect(NotificationType.fromString('system'), NotificationType.system);
      expect(NotificationType.fromString('general'), NotificationType.general);
      expect(NotificationType.fromString(null), NotificationType.general);
      expect(NotificationType.fromString('unknown_type'), NotificationType.general);
    });

    test('NotificationModel parses JSON correctly with action_label and all_except_user', () {
      final json = {
        'id': 42,
        'title': 'New Recipe Added 🍲',
        'message': 'Chicken Ghee Roast is now available.',
        'type': 'new_recipe',
        'target_type': 'all_except_user',
        'related_type': 'recipe',
        'related_id': 'rec_chicken_ghee_roast',
        'image': 'assets/images/recipes/chicken_ghee_roast.jpg',
        'action_label': 'Tap to Explore',
        'is_read': 0,
        'read_at': null,
        'created_at': '2026-09-04T10:00:00.000Z',
      };

      final model = NotificationModel.fromJson(json);

      expect(model.id, 42);
      expect(model.title, 'New Recipe Added 🍲');
      expect(model.message, 'Chicken Ghee Roast is now available.');
      expect(model.type, NotificationType.newRecipe);
      expect(model.targetType, 'all_except_user');
      expect(model.relatedType, 'recipe');
      expect(model.relatedId, 'rec_chicken_ghee_roast');
      expect(model.actionLabel, 'Tap to Explore');
      expect(model.isRead, false);
      expect(model.readAt, isNull);
      expect(model.createdAt.year, 2026);

      final outJson = model.toJson();
      expect(outJson['action_label'], 'Tap to Explore');
      expect(outJson['target_type'], 'all_except_user');
    });

    test('NotificationModel copyWith updates fields without mutating others', () {
      final model = NotificationModel(
        id: 1,
        title: 'Original Title',
        message: 'Original Message',
        type: NotificationType.general,
        isRead: false,
        createdAt: DateTime(2026, 9, 4, 10, 0),
      );

      final readTime = DateTime(2026, 9, 4, 10, 30);
      final updated = model.copyWith(isRead: true, readAt: readTime);

      expect(updated.id, 1);
      expect(updated.title, 'Original Title');
      expect(updated.isRead, true);
      expect(updated.readAt, readTime);
    });

    test('NotificationModel.timeAgoFormatted outputs readable relative timestamps', () {
      final now = DateTime.now();

      final justNow = NotificationModel(
        id: 1,
        title: 'T',
        message: 'M',
        type: NotificationType.general,
        createdAt: now.subtract(const Duration(seconds: 20)),
      );
      expect(justNow.timeAgoFormatted, 'Just now');

      final fiveMinAgo = NotificationModel(
        id: 2,
        title: 'T',
        message: 'M',
        type: NotificationType.general,
        createdAt: now.subtract(const Duration(minutes: 5)),
      );
      expect(fiveMinAgo.timeAgoFormatted, '5 min ago');

      final twoHoursAgo = NotificationModel(
        id: 3,
        title: 'T',
        message: 'M',
        type: NotificationType.general,
        createdAt: now.subtract(const Duration(hours: 2)),
      );
      expect(twoHoursAgo.timeAgoFormatted, '2 hours ago');

      final yesterday = NotificationModel(
        id: 4,
        title: 'T',
        message: 'M',
        type: NotificationType.general,
        createdAt: now.subtract(const Duration(days: 1, hours: 2)),
      );
      expect(yesterday.timeAgoFormatted, 'Yesterday');
    });

    test('Badge counter formatting handles > 99 correctly', () {
      String formatBadge(int count) => count > 99 ? '99+' : count.toString();

      expect(formatBadge(1), '1');
      expect(formatBadge(5), '5');
      expect(formatBadge(99), '99');
      expect(formatBadge(100), '99+');
      expect(formatBadge(999), '99+');
    });
  });
}
