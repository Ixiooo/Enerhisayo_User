class UserProgress{

  String id;
  String user_id;
  final int day;
  final int week;

  UserProgress({
      this.id = '',
      this.user_id = '',
      this.day = 0,
      this.week = 0,
  });

  Map<String, dynamic> toJson() =>{
    'id': id,
    'user_id': user_id,
    'day': day,
    'week': week,
  };

  static UserProgress fromJson(Map<String, dynamic> json) => UserProgress(
    id: json['id'],
    user_id: json['user_id'],
    day: json['day'] as int,
    week: json['week'] as int,
  );

}