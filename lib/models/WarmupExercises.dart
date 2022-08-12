class WarmupExercises{

  String id;
  final String exerciseName;
  final int count;
  final int durationSecs;
  final int restSecs;
  final int repCount;

  WarmupExercises({
      this.id = '',
      this.exerciseName = '',
      this.count = 0,
      this.durationSecs = 0,
      this.restSecs = 0,
      this.repCount = 0,
  });

  Map<String, dynamic> toJson() =>{
    'id': id,
    'exerciseName': exerciseName,
    'count': count,
    'durationSecs': durationSecs,
    'restSecs': restSecs,
    'repCount': repCount
  };

  static WarmupExercises fromJson(Map<String, dynamic> json) => WarmupExercises(
    id: json['id'],
    exerciseName: json['exerciseName'],
    count: json['count'] as int,
    durationSecs: json['durationSecs'] as int,
    restSecs: json['restSecs'] as int,
    repCount: json['repCount'] as int
  );

}