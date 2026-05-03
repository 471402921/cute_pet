import 'package:cute_pixel/features/_template/_template_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TemplateItem', () {
    test('toJson then fromJson is round-trip stable', () {
      const original = TemplateItem(
        id: 'tpl-1',
        name: 'First',
        status: TemplateStatus.inactive,
      );
      final json = original.toJson();
      final restored = TemplateItem.fromJson(json);
      expect(restored, equals(original));
    });

    test('JSON encodes status enum as string name', () {
      const item = TemplateItem(id: 'tpl-1', name: 'First');
      expect(item.toJson()['status'], 'active');
    });
  });
}
