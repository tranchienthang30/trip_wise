import '../models/item.dart';

class SampleService {
  static List<Item> fetchItems() {
    return List.generate(
      8,
      (i) => Item(
        id: i + 1,
        title: 'Item ${i + 1}',
        description: 'Description for item ${i + 1}',
      ),
    );
  }
}
