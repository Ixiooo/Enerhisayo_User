class DailyExercises{

  String id;
  final String exerciseName;
  final String category;
  final int day;
  final int week;
  final int count;
  final int repCount;
  final int durationSecs;
  final int restSecs;

  DailyExercises({
      this.id = '',
      this.exerciseName = '',
      this.category = '',
      this.day = 0,
      this.week = 0,
      this.count = 0,
      this.repCount = 0,
      this.durationSecs = 0,
      this.restSecs = 0
  });

  Map<String, dynamic> toJson() =>{
    'id': id,
    'exerciseName': exerciseName,
    'category': category,
    'day': day,
    'week': week,
    'count': count,
    'repCount': repCount,
    'durationSecs': durationSecs,
    'restSecs': restSecs
  };

  static DailyExercises fromJson(Map<String, dynamic> json) => DailyExercises(
    id: json['id'],
    exerciseName: json['exerciseName'],
    category: json['category'],
    day: json['day'],
    week: json['week'],
    count: json['count'],
    repCount: json['repCount'],
    durationSecs: json['durationSecs'],
    restSecs: json['restSecs']
  );

}