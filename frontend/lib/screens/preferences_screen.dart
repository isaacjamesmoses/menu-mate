import 'package:flutter/material.dart';
import '../models/menu_item.dart';
import '../services/api_service.dart';
import '../theme/colors.dart';
import 'results_screen.dart';

class PreferencesScreen extends StatefulWidget {
  final List<MenuItem> menuItems;

  const PreferencesScreen({super.key, required this.menuItems});

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();
  
  bool _isLoading = false;

  // Form states
  int _peopleCount = 2; // Default
  final TextEditingController _budgetController = TextEditingController();
  final TextEditingController _preferredFoodsController = TextEditingController();
  final TextEditingController _avoidFoodsController = TextEditingController();

  // Dietary Toggles
  final Map<String, bool> _dietaryToggles = {
    'vegetarian': false,
    'vegan': false,
    'halal': false,
    'spicy': false,
    'non_spicy': false,
  };

  @override
  void dispose() {
    _budgetController.dispose();
    _preferredFoodsController.dispose();
    _avoidFoodsController.dispose();
    super.dispose();
  }

  Future<void> _submitPreferences() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);

    try {
      final double budget = double.parse(_budgetController.text);
      
      final preferencesData = {
        'people_count': _peopleCount,
        'budget': budget,
        'preferred_foods': _preferredFoodsController.text,
        'foods_to_avoid': _avoidFoodsController.text,
        'dietary_toggles': _dietaryToggles,
      };
      
      final response = await _apiService.recommendMeal(
        menuItems: widget.menuItems,
        peopleCount: _peopleCount,
        budget: budget,
        preferredFoods: _preferredFoodsController.text,
        foodsToAvoid: _avoidFoodsController.text,
        dietaryToggles: _dietaryToggles,
      );

      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ResultsScreen(
              rawResponse: response,
              preferencesData: preferencesData,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your Preferences')),
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Group Size', style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: 8),
                    SegmentedButton<int>(
                      segments: const [
                        ButtonSegment(value: 2, label: Text('2 People')),
                        ButtonSegment(value: 4, label: Text('4 People')),
                        ButtonSegment(value: 5, label: Text('5 People')),
                      ],
                      selected: {_peopleCount},
                      onSelectionChanged: (Set<int> newSelection) {
                        setState(() {
                          _peopleCount = newSelection.first;
                        });
                      },
                    ),
                    const SizedBox(height: 24),
                    
                    Text('Total Budget', style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _budgetController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Max Budget',
                        prefixText: '\$ ',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Budget is required';
                        if (double.tryParse(value) == null || double.parse(value) <= 0) {
                          return 'Enter a valid positive number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    
                    Text('Food Preferences', style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _preferredFoodsController,
                      decoration: const InputDecoration(
                        labelText: 'Preferred Foods (e.g. pasta, cheese)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _avoidFoodsController,
                      decoration: const InputDecoration(
                        labelText: 'Foods to Avoid (e.g. nuts, shellfish)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    Text('Dietary Restrictions', style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 4.0,
                      children: _dietaryToggles.keys.map((key) {
                        final displayName = key.replaceAll('_', '-').toUpperCase();
                        return FilterChip(
                          label: Text(displayName),
                          selected: _dietaryToggles[key]!,
                          onSelected: (bool selected) {
                            setState(() {
                              _dietaryToggles[key] = selected;
                            });
                          },
                          selectedColor: AppColors.primaryLight,
                          checkmarkColor: AppColors.primaryDark,
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 48),

                    ElevatedButton(
                      onPressed: _isLoading ? null : _submitPreferences,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Generate Meal Plan'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.4),
              child: const Center(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Designing infinite variations...'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
