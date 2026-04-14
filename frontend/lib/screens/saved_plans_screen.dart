import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/colors.dart';
import '../models/meal_plan.dart';

class SavedPlansScreen extends StatefulWidget {
  const SavedPlansScreen({super.key});

  @override
  State<SavedPlansScreen> createState() => _SavedPlansScreenState();
}

class _SavedPlansScreenState extends State<SavedPlansScreen> {
  final ApiService _apiService = ApiService();
  List<dynamic> _savedPlans = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadPlans();
  }

  Future<void> _loadPlans() async {
    try {
      final plans = await _apiService.getSavedPlans();
      setState(() {
        _savedPlans = plans;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Plans'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Text('Failed to load plans.\n$_errorMessage', 
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.error),
        ),
      );
    }

    if (_savedPlans.isEmpty) {
      return Center(
        child: Text('No saved plans yet.', 
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppColors.textHint),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _savedPlans.length,
      itemBuilder: (context, index) {
        final planData = _savedPlans[index];
        final mealPlan = MealPlan.fromJson(planData['plan']);
        final dateStr = planData['created_at'].toString();
        final displayDate = DateTime.tryParse(dateStr)?.toLocal().toString().split('.')[0] ?? dateStr;

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Saved on $displayDate', style: Theme.of(context).textTheme.bodySmall),
                    Text('\$${mealPlan.totalCost.toStringAsFixed(2)}', 
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...mealPlan.dishes.map((dish) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2.0),
                  child: Row(
                    children: [
                      const Icon(Icons.restaurant, size: 14, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text(dish.name),
                    ],
                  ),
                )),
              ],
            ),
          ),
        );
      },
    );
  }
}
