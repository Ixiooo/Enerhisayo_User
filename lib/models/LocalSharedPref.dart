import 'package:shared_preferences/shared_preferences.dart';


class LocalSharedPreferences{
  
  static SharedPreferences? _preferences;
  
  static const _id='id';
  static const _emailKey='email';
  static const _firstName='firstName';
  static const _lastName='lastName';
  static const _age='age';
  static const _gender='gender';
  static const _height='height';
  static const _weight='weight';
  static const _bmi='bmi';
  static const _subscription='subscription';
  static const _day='day';
  static const _week='week';
  static const _category='category';
  static const _dayStatus='dayStatus';
  static const _workoutStatus='workoutStatus';
  static const _dailyWarmupStatus='dailyWarmupStatus';
  static const _profileUpdateStatus='profileUpdateStatus';
  static const _newAccount='newAccount';

  static Future init() async =>
    _preferences = await SharedPreferences.getInstance();

  // Setters

  // Strings
  static Future setID(String id) async =>
    await _preferences!.setString(_id, id);

  static Future setEmail(String email) async =>
    await _preferences!.setString(_emailKey, email);

  static Future setFirstName(String firstName) async =>
    await _preferences!.setString(_firstName, firstName);

  static Future setLastName(String lastName) async =>
    await _preferences!.setString(_lastName, lastName);

  static Future setGender(String gender) async =>
    await _preferences!.setString(_gender, gender);

  static Future setCategory(String category) async =>
    await _preferences!.setString(_category, category);

  // Double
  static Future setAge(double age) async =>
    await _preferences!.setDouble(_age, age);
  
  static Future setHeight(double height) async =>
    await _preferences!.setDouble(_height, height);

  static Future setWeight(double weight) async =>
    await _preferences!.setDouble(_weight, weight);

  static Future setBmi(double bmi) async =>
    await _preferences!.setDouble(_bmi, bmi);

  static Future setSubscription(double subscription) async =>
    await _preferences!.setDouble(_subscription, subscription);

  // Int
  static Future setDay(int day) async =>
    await _preferences!.setInt(_day, day);

  static Future setWeek(int week) async =>
    await _preferences!.setInt(_week, week);

  // Boolean
  static Future setDayStatus(bool dayStatus) async =>
    await _preferences!.setBool(_dayStatus, dayStatus);

  static Future setWorkoutStatus(bool workoutStatus) async =>
    await _preferences!.setBool(_workoutStatus, workoutStatus);

  static Future setDailyWarmupStatus(bool dailyWarmupStatus) async =>
    await _preferences!.setBool(_dailyWarmupStatus, dailyWarmupStatus);

  static Future setProfileUpdateStatus(bool profileUpdateStatus) async =>
    await _preferences!.setBool(_profileUpdateStatus, profileUpdateStatus);

  static Future setNewAccount(bool newAccount) async =>
    await _preferences!.setBool(_newAccount, newAccount);

  // Getters
  
  // String
  static String getEmail() => _preferences!.getString(_emailKey) ?? 'Error';

  static String getId() => _preferences!.getString(_id) ?? 'Error';

  static String getCategory() => _preferences!.getString(_category) ?? 'Error';

  static String getFirstName() => _preferences!.getString(_firstName) ?? 'Error';

  static String getLastName() => _preferences!.getString(_lastName) ?? 'Error';
  
  static String getGender() => _preferences!.getString(_gender) ?? 'Error';

  //Double
  static double getBMI() => _preferences!.getDouble(_bmi) ?? 0;

  static double getSubscription() => _preferences!.getDouble(_subscription) ?? 1;
  
  static double getAge() => _preferences!.getDouble(_age) ?? 1;

  static double getHeight() => _preferences!.getDouble(_height) ?? 1;

  static double getWeight() => _preferences!.getDouble(_weight) ?? 1;
  
  // Int
  static int getDay() => _preferences!.getInt(_day) ?? 1;
  
  static int getWeek() => _preferences!.getInt(_week) ?? 1;

  // Boolean

  static bool getDayStatus() => _preferences!.getBool(_dayStatus) ?? false;

  static bool getWorkoutStatus() => _preferences!.getBool(_workoutStatus) ?? false;

  static bool getDailyWarmupStatus() => _preferences!.getBool(_dailyWarmupStatus) ?? false;
  
  static bool getProfileUpdateStatus() => _preferences!.getBool(_profileUpdateStatus) ?? false;

  static bool getNewAccount() => _preferences!.getBool(_newAccount) ?? false;


  // Functions
  static Future deleteEmail() async => await _preferences!.remove(_emailKey);

  static Future deleteAll() async => await _preferences!.clear();


}