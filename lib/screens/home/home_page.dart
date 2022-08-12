import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../utils/size_helpers.dart';
import '../../models/LocalSharedPref.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key, required this.goToWorkout, required this.goToActivityLog}) : super(key: key);

  final VoidCallback goToWorkout;
  final VoidCallback goToActivityLog;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  //Variable Declarations
  final user = FirebaseAuth.instance.currentUser!;
  String _currentEmailfromLocal = '';
  String _currentFirstName = '';
  String _currentLastName = '';
  String _currentWeek = '';
  String _currentDay = '';
  String _currentEmail = '';
  double _currentBMI = 0;
  double _currentSubscription = 0;

  double _screenHeight = 0;
  double _screenWidth = 0;
  bool _isSmallReso = false;

  // Code for the User Progress Record Bar
  Widget _createProgressRecordBar(){
    return Row(
      children: [
        SizedBox(width: displayWidth(context)*0.05,),
        Container(
          height:  displayHeight(context)*0.12,
          width: displayWidth(context)*0.9,
          decoration: BoxDecoration(
            color: Colors.white,
            // boxShadow:[ BoxShadow(
            //   color: Color.fromARGB(255, 184, 184, 184),
            //   blurRadius: 10,
            //   spreadRadius: 2,
            //   offset: Offset(0, 3)
            // )],
            borderRadius: BorderRadius.circular(25),
          ),
          child: Row(
            children: [
              // First Name Circle Avatar
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 27,
                      backgroundColor: Colors.red[400],
                      foregroundColor: Colors.white,
                      child: Text(_currentFirstName[0], style: const TextStyle(fontSize: 28),),
                    ),
                  ],
                )
              ),
              // Name and Progress
              Expanded(
                flex: 6,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_currentFirstName} ${_currentLastName}',
                      textAlign: TextAlign.left,
                      style: Theme.of(context)
                        .textTheme
                        .headline4!
                        .copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: !_isSmallReso
                          ?24
                          :18,
                          color: Color(0xff526791),
                        ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Week ${_currentWeek}, Day ${_currentDay}',
                      textAlign: TextAlign.left,
                      style: Theme.of(context)
                        .textTheme
                        .bodyText2!
                        .copyWith(
                          fontWeight: FontWeight.w400,
                          fontSize: !_isSmallReso
                          ?22
                          :16,
                          color: Color(0xff526791),
                        ),
                    ),
                  ],
                )
              ),
              // Subscription
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      '${_currentSubscription.toStringAsFixed(0)} Week \n Workout',
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                        .textTheme
                        .bodyText2!
                        .copyWith(
                          fontWeight: FontWeight.w400,
                          fontSize:  !_isSmallReso
                          ?16
                          :14,
                          color: Color(0xff526791),
                        ),
                    ),
                  ],
                )
              )
          ])
        )
      ]
    );
  }
  
  // Code for the Menu Item Workout and Activity Logs
  Widget _createMenuItems(){
    return Row(
      children: [
        SizedBox(width: displayWidth(context)*0.05,),
        Container(
          height:  displayHeight(context)*0.28,
          width: displayWidth(context)*0.4,
          decoration: BoxDecoration(
            color: Color(0xFFF1F1F1),
            boxShadow:[ BoxShadow(
              color: Colors.black45,
              blurRadius: 10,
              spreadRadius: 2,
              offset: Offset(0, 3)
            )],
            borderRadius: BorderRadius.circular(25),
          ),
          child: Material(
            color:  Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(25),
              splashColor: Colors.red[200],
              onTap: () {
                widget.goToWorkout();
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image(
                    image: AssetImage('assets/workout.png'),
                        width: displayHeight(context)*0.14, height: displayHeight(context)*0.14,
                    fit: BoxFit.contain),
                    SizedBox(height: displayHeight(context)*0.01,),
                    Text(
                      'Weekly Workout',
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                        .textTheme
                        .headline4!
                        .copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 20,
                          color: Color(0xff526791),
                        ),
                    ),
                ]),
            ),
          ),
        ),
        SizedBox(width: displayWidth(context)*0.1,),
        Container(
          height:  displayHeight(context)*0.28,
          width: displayWidth(context)*0.4,
          decoration: BoxDecoration(
            color: Color(0xFFF1F1F1),
            boxShadow:[ BoxShadow(
              color: Colors.black45,
              blurRadius: 10,
              spreadRadius: 2,
              offset: Offset(0, 3)
            )],
            borderRadius: BorderRadius.circular(25),
          ),
          child: Material(
            color:  Colors.transparent,
            child: InkWell(
              onTap: () {
                widget.goToActivityLog();
              },
              borderRadius: BorderRadius.circular(25),
              splashColor: Colors.red[200],
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image(
                    image: AssetImage('assets/notes.png'),
                        width: displayHeight(context)*0.14, height: displayHeight(context)*0.14,
                    fit: BoxFit.contain
                  ),
                  SizedBox(height: displayHeight(context)*0.01,),
                  Text(
                      'Activity Notes',
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                        .textTheme
                        .headline4!
                        .copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 20,
                          color: Color(0xff526791),
                        ),
                    ),
                ]),
            ),
          ),
        )
      ]
    );
  }

  //Get Data Stored in the Local Shared Prefs of Current User
  void _getDataFromLocal() async {
    _currentWeek = LocalSharedPreferences.getWeek().toString();
    _currentDay = LocalSharedPreferences.getDay().toString();
    _currentFirstName = LocalSharedPreferences.getFirstName();
    _currentLastName = LocalSharedPreferences.getLastName();
    _currentEmailfromLocal = LocalSharedPreferences.getEmail();
    _currentBMI = LocalSharedPreferences.getBMI();
    _currentSubscription = LocalSharedPreferences.getSubscription();
  }

  //Identify Screen Size of Device of User
  void _getScreenSize(){
    _screenHeight = displayHeight(context);
    _screenWidth = displayWidth(context);
    if(_screenHeight <= 896 && _screenWidth <=414){
      setState(() {
        _isSmallReso = true;
      });
    }else{
      setState(() {
        _isSmallReso = false;
      });
    }
  }

  // Run the Functions after Startup but before the build method 
  @override
  void didChangeDependencies(){
    _getScreenSize();
  }

  // Run the Functions on Startup
  @override
    void initState() {
    super.initState();
    _getDataFromLocal();
  }

  // Build the User Interface
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [

              // Background Image
              Positioned(
                child: Container(
                  height: displayHeight(context)*0.85,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image:  AssetImage('assets/backgroundBlue.png'),
                      fit: BoxFit.cover,
                    ),
                    color: Colors.red[400]
                  ),
                ),
              ),
              
              // Greeting Text
              Positioned(
                top: displayHeight(context)*0.05,
                child: Padding(
                  padding: const EdgeInsets.only(top: 40, left: 20, right: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hi ${_currentFirstName},',
                        textAlign: TextAlign.left,
                        style: Theme.of(context)
                        .textTheme
                        .headline4!
                        .copyWith(
                          fontWeight: FontWeight.w900,
                          fontSize: !_isSmallReso
                          ?46
                          :42,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Let\'s Start Working Out',
                        textAlign: TextAlign.left,
                        style: Theme.of(context)
                        .textTheme
                        .subtitle1!
                        .copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: !_isSmallReso
                          ?28
                          :22,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Progress Record
              Positioned(
                top: displayHeight(context)*0.27,
                child: _createProgressRecordBar(),
              ),
              
              // Bottom White Background
              Positioned(
                top: displayHeight(context)*0.65,
                child: Container(
                  height: displayHeight(context)*0.55,
                  width: displayWidth(context),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(50), topRight: Radius.circular(50) ),
                  ),
                ),
              ),  
          
              // Menu Items
              Positioned(
              top: displayHeight(context)*0.57,
              child: _createMenuItems(),
            ),
            ]
          ), 
        ]
      ),
    );
  }
}
