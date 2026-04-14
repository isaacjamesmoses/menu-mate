import 'package:flutter/material.dart';
import '../models/meal_plan.dart';
import '../theme/colors.dart';
import '../services/api_service.dart';

class ResultsScreen extends StatefulWidget {
  final Map<String, dynamic> rawResponse;
  final Map<String, dynamic> preferencesData;

  const ResultsScreen({
    super.key,
    required this.rawResponse,
    required this.preferencesData,
  });

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  final ApiService _apiService = ApiService();
  late MealPlan bestPlan;
  late MealPlan alternative1;
  late MealPlan alternative2;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    bestPlan = MealPlan.fromJson(widget.rawResponse['best_plan']);
    alternative1 = MealPlan.fromJson(widget.rawResponse['alternative_plan_1']);
    alternative2 = MealPlan.fromJson(widget.rawResponse['alternative_plan_2']);
  }

  Future<void> _savePlan(MealPlan planToSave) async {
    setState(() => _isSaving = true);
    
    // Quick serialization helper since MealPlan currently misses a toJson method 
    // for clean upload, but we can extract it back from rawResponse.
    Map<String, dynamic> planDataToUpload;
    
    if (planToSave.planId == bestPlan.planId) {
       planDataToUpload = widget.rawResponse['best_plan'];
    } else if (planToSave.planId == alternative1.planId) {
       planDataToUpload = widget.rawResponse['alternative_plan_1'];
    } else {
       planDataToUpload = widget.rawResponse['alternative_plan_2'];
    }

    try {
      await _apiService.savePlan(
        planData: planDataToUpload,
        preferencesData: widget.preferencesData,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Plan Saved successfully!')),
        );
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save plan: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Widget _buildPlanCard(BuildContext context, MealPlan plan, String title, bool isHero) {
    return Card(
      margin: const EdgeInsets.only(bottom: 24),
      elevation: isHero ? 4 : 0,
      color: isHero ? AppColors.primaryLight : AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: isHero ? BorderSide.none : const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: isHero ? AppColors.primaryDark : AppColors.textPrimary,
                    fontSize: isHero ? 24 : 20,
                  ),
                ),
                Text(
                  '\$${plan.totalCost.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppColors.primaryDark,
                    fontWeight: FontWeight.w800,
                    fontSize: isHero ? 24 : 20,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '\$${plan.costPerPerson.toStringAsFixed(2)} per person',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isHero ? AppColors.primaryDark.withOpacity(0.8) : AppColors.textSecondary,
              ),
              textAlign: TextAlign.right,
            ),
            const SizedBox(height: 16),
            Text(
              plan.explanation,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            Text(
              'Included Dishes',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...plan.dishes.map((dish) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_outline, size: 16, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(dish.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                  ),
                  Text('\$${dish.price.toStringAsFixed(2)}'),
                ],
              ),
            )),
            if (!isHero) ...[
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: _isSaving ? null : () => _savePlan(plan),
                child: const Text('Save This Alternative'),
              ),
            ]
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Meal Plans'),
        automaticallyImplyLeading: false, 
      ),
      body: SafeArea(
        child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                _buildPlanCard(context, bestPlan, 'The MenuMate Choice', true),
                
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Text(
                    'Other Great Alternatives',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
                
                _buildPlanCard(context, alternative1, 'Alternative 1', false),
                _buildPlanCard(context, alternative2, 'Alternative 2', false),
                
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isSaving ? null : () => _savePlan(bestPlan),
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                  child: const Text('Save The MenuMate Plan'),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: _isSaving ? null : () {
                    Navigator.of(context).pop(); 
                  },
                  child: const Text('Try Again (Edit Constraints)'),
                ),
                const SizedBox(height: 48),
              ],
            ),
            if (_isSaving)
              Container(
                color: Colors.black.withOpacity(0.4),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
