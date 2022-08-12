class UserData{

  String id;
  final String email;
  final String firstName;
  final String lastName;
  final String gender;
  final String category;
  final double age;
  final double height;
  final double weight;
  final double bmi;
  final num subscription;

  UserData({
      this.id = '',
      this.email = '',
      this.firstName = '',
      this.lastName = '',
      this.age = 0,
      this.gender = '',
      this.category = '',
      this.height = 0,
      this.weight = 0,
      this.bmi = 0,
      this.subscription = 0,
  });

  Map<String, dynamic> toJson() =>{
    'id': id,
    'email': email,
    'firstName': firstName,
    'lastName': lastName,
    'age': age,
    'gender': gender,
    'category': category,
    'height': height,
    'weight': weight,
    'bmi': bmi,
    'subscription': subscription
  };

  static UserData fromJson(Map<String, dynamic> json) => UserData(
    id: json['id'],
    email: json['email'],
    firstName: json['firstName'],
    lastName: json['lastName'],
    age: json['age'],
    gender: json['gender'],
    category: json['category'],
    height: json['height'],
    weight: json['weight'],
    bmi: json['bmi'],
    subscription: json['subscription']
  );

}