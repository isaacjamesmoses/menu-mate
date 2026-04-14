import 'package:flutter/material.dart';
import '../models/menu_item.dart';
import '../theme/colors.dart';

class EditableMenuItemCard extends StatefulWidget {
  final MenuItem item;
  final VoidCallback onDelete;
  final ValueChanged<MenuItem> onChanged;

  const EditableMenuItemCard({
    super.key,
    required this.item,
    required this.onDelete,
    required this.onChanged,
  });

  @override
  State<EditableMenuItemCard> createState() => _EditableMenuItemCardState();
}

class _EditableMenuItemCardState extends State<EditableMenuItemCard> {
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late String _selectedCategory;

  final List<String> _categories = ['Main', 'Side', 'Starter', 'Drink', 'Dessert', 'Uncategorized'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item.name);
    _priceController = TextEditingController(text: widget.item.price.toStringAsFixed(2));
    _selectedCategory = _categories.contains(widget.item.category) 
        ? widget.item.category 
        : 'Uncategorized';

    _nameController.addListener(_notifyChange);
    _priceController.addListener(_notifyChange);
  }

  @override
  void dispose() {
    _nameController.removeListener(_notifyChange);
    _priceController.removeListener(_notifyChange);
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _notifyChange() {
    final newPrice = double.tryParse(_priceController.text) ?? widget.item.price;
    final updatedItem = MenuItem(
      id: widget.item.id,
      name: _nameController.text,
      price: newPrice,
      category: _selectedCategory,
    );
    widget.onChanged(updatedItem);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Dish Name',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _priceController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Price',
                      prefixText: '\$ ',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: AppColors.error),
                  onPressed: widget.onDelete,
                  tooltip: 'Delete Item',
                ),
              ],
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              items: _categories.map((cat) {
                return DropdownMenuItem(
                  value: cat,
                  child: Text(cat),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _selectedCategory = val;
                  });
                  _notifyChange();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
