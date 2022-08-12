import 'package:enerhisayo/api/notification_api.dart';
import 'package:enerhisayo/main.dart';
import 'package:enerhisayo/models/UserProgress.dart';
import 'package:enerhisayo/screens/profile/profile_home.dart';
import 'package:enerhisayo/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/size_helpers.dart';
import '../../models/UserData.dart';
import '../../models/LocalSharedPref.dart';
import 'package:enerhisayo/screens/workout/workout_page.dart';
import 'package:enerhisayo/screens/home/home_page.dart';

class MyHomePage extends StatefulWidget {
  static const routeName = '/admin_home';

  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final user = FirebaseAuth.instance.currentUser!;
  
  //Pages Navigation
  int currentIndex = 0;
  List<Widget> _pages = [];
  List<String> _notifBody = [
    'Life has its ups and downs, we call them squats. Get up! Let\'s Exercise',
    'When you feel like quitting, think about why you started',
    'Unless you puke, faint or die, keep going! - Jillian Michaels. Magiging physically fit ka rin tiwala lang!',
    'If not now, when? Aba\'y ho! Bangon diyan at mag exercise na!',
    'Every step is progress, no matter how small.',
    'The clock is ticking. Are you becoming the person you want to be?',
    'Sore? Tired? Out of breath? Good... it\'s working.'
  ];

  //Variable Declarations
  String _currentEmail = '';
  String _id = '', _email = '', _firstName = '', _lastName = '', _gender = '', _category = '';
  double _height = 0, _weight = 0, _bmi = 0, _age=0, _subscription=0;
  int _day=0,_week=0, _totalDuration = 0;
  bool localIsSet = false;
  DateTime? currentBackPressTime;

  //Get Data from Database and set to Local SharedPrefs
  void _getdata() async {
    final data = FirebaseFirestore.instance.collection('users').where('email', isEqualTo: user.email);
    final snapshot = await data.get();

    UserData userModel = UserData.fromJson(snapshot.docs[0].data());
    _id = userModel.id;
    _email = userModel.email;
    _firstName = userModel.firstName;
    _lastName = userModel.lastName;
    _gender = userModel.gender;
    _category = userModel.category;
    _age =  userModel.age;
    _height = userModel.height;
    _weight = userModel.weight;
    _bmi = userModel.bmi;
    _subscription = userModel.subscription.toDouble();

    // Check if User is Newly Registered
    if(LocalSharedPreferences.getNewAccount()){
      _day =1;
      _week = 1;
      await LocalSharedPreferences.setNewAccount(false);
    }else{
      final progressData = FirebaseFirestore.instance.collection('userProgress').where('user_id', isEqualTo: _id);
      final progressDataSnapshot = await progressData.get();
      UserProgress userProgress = UserProgress.fromJson(progressDataSnapshot.docs[0].data());
      _day = userProgress.day;
      _week = userProgress.week;
    }

    await LocalSharedPreferences.setID(_id);
    await LocalSharedPreferences.setEmail(_email);
    await LocalSharedPreferences.setFirstName(_firstName);
    await LocalSharedPreferences.setLastName(_lastName);
    await LocalSharedPreferences.setAge(_age);
    await LocalSharedPreferences.setGender(_gender);
    await LocalSharedPreferences.setHeight(_height);
    await LocalSharedPreferences.setWeight(_weight);
    await LocalSharedPreferences.setBmi(_bmi);
    await LocalSharedPreferences.setSubscription(_subscription);
    await LocalSharedPreferences.setDay(_day);
    await LocalSharedPreferences.setWeek(_week);
    await LocalSharedPreferences.setCategory(_category);

    await LocalSharedPreferences.setDayStatus(false);
    await LocalSharedPreferences.setWorkoutStatus(false);
    await LocalSharedPreferences.setDailyWarmupStatus(false);
    await LocalSharedPreferences.setProfileUpdateStatus(false);


    setState(() {
      localIsSet = true;
    });
  }

  // Refresh Workout Page
  void _refreshWorkoutPage(){
    setState(() {
    _subscription = LocalSharedPreferences.getSubscription();
    _day = LocalSharedPreferences.getDay();
    _week = LocalSharedPreferences.getWeek();
      
    });
  }

  // Navigate to Workout Page when Workout Menu Item is Clicked
  void _setIndexToWorkout(){
    setState(() {
      currentIndex = 1;
    });
  }

  // Navigate to Profile Page when Workout Menu Item is Clicked
  void _setIndexToActivityLog(){
    setState(() {
      currentIndex = 2;
    });
  }

  // Ask the User to Tap Back Button Twice to Exit the Application
  Future<bool> onWillPop() {
      DateTime now = DateTime.now();
      if (currentBackPressTime == null || 
          now.difference(currentBackPressTime!) > Duration(seconds: 2)) {
        currentBackPressTime = now;
        Utils.showToast("Press Again to Exit Application");
        return Future.value(false);
      }
      return Future.value(true);
    }
  
  // Log out of Application
  void logout()async{
    try{
      await LocalSharedPreferences.deleteAll();
      await FirebaseAuth.instance.signOut();
    }catch(e)
    {
      print(e.toString());
    }
  }

  // Initialize the pages of the Home Screen and Get the Data of Current User
  @override
  void initState() {
    super.initState();
    
    NotificationApi.init(initScheduled: true);

    NotificationApi.showScheduledNotification(
      title: 'Enerhisayo',
      body: (_notifBody.toList()..shuffle()).first,
      payload: '',
      scheduledDate: DateTime.now(),
    );

    _pages=[
      HomePage(
        goToWorkout: () => _setIndexToWorkout(), 
        goToActivityLog:  () => _setIndexToActivityLog()
      ),
      WorkoutPage(),
      ProfileHome(),
    ];
    _getdata();

  }
  
  // Build the User Interface
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: localIsSet
          ? WillPopScope(
            onWillPop: onWillPop,
            child: IndexedStack(
              index: currentIndex,
              children: _pages,
              ),
          )
          : SafeArea(
              child: SizedBox(
              height: displayHeight(context),
              child: Padding(
                padding: const EdgeInsets.only(top: 60),
                child: Center(child: CircularProgressIndicator()),
              ),
            )),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index){
          setState(() {
            currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center_outlined),
            label: 'Workout',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_box_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
