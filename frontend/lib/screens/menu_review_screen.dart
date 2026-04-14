import 'package:flutter/material.dart';
import '../models/menu_item.dart';
import '../theme/colors.dart';
import '../widgets/editable_menu_item_card.dart';
import 'preferences_screen.dart';

class MenuReviewScreen extends StatefulWidget {
  final List<MenuItem> initialItems;

  const MenuReviewScreen({super.key, required this.initialItems});

  @override
  State<MenuReviewScreen> createState() => _MenuReviewScreenState();
}

class _MenuReviewScreenState extends State<MenuReviewScreen> {
  late List<MenuItem> _items;

  @override
  void initState() {
    super.initState();
    _items = List.from(widget.initialItems);
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  void _updateItem(int index, MenuItem updatedItem) {
    _items[index] = updatedItem;
  }

  void _addNewItem() {
    setState(() {
      _items.add(
        MenuItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: '',
          price: 0.0,
          category: 'Uncategorized',
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Menu'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: _addNewItem,
            tooltip: 'Add new item manually',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Edit any incorrect details or add missing items before we create your meal plan.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _items.isEmpty
                  ? Center(
                      child: Text(
                        'No items found. Tap + to add one.',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppColors.textHint,
                            ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _items.length,
                      itemBuilder: (context, index) {
                        return EditableMenuItemCard(
                          key: ValueKey(_items[index].id),
                          item: _items[index],
                          onDelete: () => _removeItem(index),
                          onChanged: (updated) => _updateItem(index, updated),
                        );
                      },
                    ),
            ),
            Container(
              padding: const EdgeInsets.all(24.0),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  OutlinedButton.icon(
                    onPressed: _addNewItem,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Missing Item'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      if (_items.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please add at least one item.'),
                            backgroundColor: AppColors.error,
                          ),
                        );
                        return;
                      }
                      // Navigate to PreferencesScreen with the _items
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => PreferencesScreen(menuItems: _items),
                        ),
                      );
                    },
                    child: const Text('Continue to Preferences'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
