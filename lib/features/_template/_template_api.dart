import 'package:cute_pixel/features/_template/_template_models.dart';

class TemplateApi {
  Future<List<TemplateItem>> fetchItems() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return const [
      TemplateItem(id: 'tpl-1', name: 'First Item'),
      TemplateItem(
        id: 'tpl-2',
        name: 'Second Item',
        status: TemplateStatus.inactive,
      ),
    ];
  }
}
