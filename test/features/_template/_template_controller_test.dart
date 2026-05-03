import 'package:cute_pixel/features/_template/_template_api.dart';
import 'package:cute_pixel/features/_template/_template_controller.dart';
import 'package:cute_pixel/features/_template/_template_models.dart';
import 'package:cute_pixel/shared/widgets/view_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockTemplateApi extends Mock implements TemplateApi {}

void main() {
  group('TemplateController', () {
    late _MockTemplateApi api;
    late TemplateController controller;

    setUp(() {
      api = _MockTemplateApi();
      controller = TemplateController(api);
    });

    tearDown(() {
      controller.dispose();
    });

    test('load() emits Data on success', () async {
      const items = [TemplateItem(id: 'tpl-1', name: 'First')];
      when(() => api.fetchItems()).thenAnswer((_) async => items);

      await controller.load();

      final state = controller.state.value;
      expect(state, isA<Data<List<TemplateItem>>>());
      expect((state as Data<List<TemplateItem>>).data, items);
    });
  });
}
