import 'menu_item.dart';

class MealPlan {
  final String planId;
  final List<MenuItem> dishes;
  final double totalCost;
  final double costPerPerson;
  final String explanation;

  MealPlan({
    required this.planId,
    required this.dishes,
    required this.totalCost,
    required this.costPerPerson,
    required this.explanation,
  });

  factory MealPlan.fromJson(Map<String, dynamic> json) {
    return MealPlan(
      planId: json['plan_id'] ?? '',
      dishes: (json['dishes'] as List<dynamic>?)
              ?.map((e) => MenuItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      totalCost: (json['total_cost'] ?? 0.0).toDouble(),
      costPerPerson: (json['cost_per_person'] ?? 0.0).toDouble(),
      explanation: json['explanation'] ?? '',
    );
  }
}
