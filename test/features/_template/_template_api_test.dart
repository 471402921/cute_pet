import 'package:cute_pixel/features/_template/_template_api.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TemplateApi (mock)', () {
    test('returns at least one item', () async {
      final items = await TemplateApi().fetchItems();
      expect(items, isNotEmpty);
    });
  });
}
