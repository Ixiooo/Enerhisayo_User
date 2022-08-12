class Exercise{

  String id;
  final String exerciseName;
  final String videoUrl;

  Exercise({
      this.id = '',
      this.exerciseName = '',
      this.videoUrl = '',
  });

  Map<String, dynamic> toJson() =>{
    'id': id,
    'exerciseName': exerciseName,
    'videoUrl': videoUrl
  };

  static Exercise fromJson(Map<String, dynamic> json) => Exercise(
    id: json['id'],
    exerciseName: json['exerciseName'],
    videoUrl: json['videoUrl'] ?? ''
  );

}