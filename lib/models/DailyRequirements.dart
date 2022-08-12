class DailyRequirements{
  final String id;
  final String category;
  final int day;
  final int week;
  final int requiredMins;
  final int minExercises;

  DailyRequirements({
      this.id = '',
      this.category = '',
      this.day = 0,
      this.week = 0,
      this.requiredMins = 0,
      this.minExercises = 0
  });

  Map<String, dynamic> toJson() =>{
    'id': id,
    'category': category,
    'day': day,
    'week': week,
    'requiredMins': requiredMins,
    'minExercises': minExercises
  };

  static DailyRequirements fromJson(Map<String, dynamic> json) => DailyRequirements(
    id: json['id'] ?? '',
    category: json['category'] ?? '',
    day: json['day'] ?? 0,
    week: json['week'] ?? 0,
    requiredMins: json['requiredMins'] ?? 0,
    minExercises: json['minExercises'] ?? 0
  );

}