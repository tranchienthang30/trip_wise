import 'package:flutter/material.dart';
import '../services/sample_service.dart';
import '../widgets/item_card.dart';

class ItemsScreen extends StatelessWidget {
  const ItemsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final items = SampleService.fetchItems();

    return Scaffold(
      appBar: AppBar(title: const Text('Items')),
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) => ItemCard(item: items[index]),
      ),
    );
  }
}
