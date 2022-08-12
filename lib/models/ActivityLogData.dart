class ActivityLogData{

  String id;
  String user_id;
  final String title;
  final String content;
  final DateTime? createdAt;

  ActivityLogData({
      this.id = '',
      this.user_id = '',
      this.title = '',
      this.content = '',
      this.createdAt,
  });

  Map<String, dynamic> toJson() =>{
    'id': id,
    'title': title,
    'user_id': user_id,
    'content': content,
    'createdAt': createdAt,
  };

  static ActivityLogData fromJson(Map<String, dynamic> json) => ActivityLogData(
    id: json['id'],
    title: json['title'],
    user_id: json['user_id'],
    content: json['content'],
    createdAt: json['createdAt']?.toDate()
  );
}