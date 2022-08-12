import 'package:enerhisayo/utils/utils.dart';
import 'package:enerhisayo/utils/size_helpers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enerhisayo/models/LocalSharedPref.dart';
import 'package:enerhisayo/models/WarmupExercises.dart';

class WorkoutPage extends StatefulWidget {

  static const routeName = '/workout_page';

  const WorkoutPage({Key? key}) : super(key: key);

  @override
  State<WorkoutPage> createState() => _WorkoutPageState();
}

class _WorkoutPageState extends State<WorkoutPage> {

  // Variable Declarations
  final user = FirebaseAuth.instance.currentUser!;
  int subscription = 0, progressDay=0, progressWeek=0;
  bool isUpdated = false;
  bool isGenerated = false;
  String isPressed = '';

  int warmupExerciseCount = 0;
  int _dailyExerciseCount = 0;

  double _screenHeight = 0;
  double _screenWidth = 0;
  bool _isSmallReso = false;

  List<Widget> _weeklyWorkoutList = [];
  List<Widget> _warmupExercisesList = [];

  List<WarmupExercises> _selectedWarmupExercises = [];

  Future<List<WarmupExercises>>? _warmupExercisesFetched;

  // Generate the Workout Based on the Subscription of User
  void _generateWorkout() {
    setState(() {
      // _weeklyWorkoutList.add(_workout());
      for(int weekCounter = 0; weekCounter < subscription; weekCounter++){
        _weeklyWorkoutList.add(_workoutWeek(weekCounter+1));
        
        for(int dayCounter = 0; dayCounter < 6; dayCounter++){
          _weeklyWorkoutList.add(_workOutDay(dayCounter+1, weekCounter+1));
        }
      }
    });
  }

  // Generate the Workout Based on the Subscription of User
  void _getExerciseCount() async{

    QuerySnapshot warmupExercisesQuery =  await FirebaseFirestore.instance
                                            .collection("warmupExercises")
                                            .get();
    warmupExerciseCount = warmupExercisesQuery.docs.length;
  
  }
  
  //Get Data Stored in the Local Shared Prefs of Current User
  void _loadUserData(){
    setState(() {
      subscription = LocalSharedPreferences.getSubscription().toInt();
      progressDay = LocalSharedPreferences.getDay();
      progressWeek = LocalSharedPreferences.getWeek();
      isUpdated = true;
    });
  }
  
  //Rebuild the User Interface after Checking if Daily Workout is Finished
  void _refreshUI(){
    _loadUserData();
    _weeklyWorkoutList.clear();
    _generateWorkout();
  }
 
  //Identify Screen Size of Device of User
  void _getScreenSize(){
    _screenHeight = displayHeight(context);
    _screenWidth = displayWidth(context);
    if(_screenHeight < 896 && _screenWidth <414){
      setState(() {
        _isSmallReso = true;
      });
    }else{
      setState(() {
        _isSmallReso = false;
      });
    }
  }

  // Generate Data for Weekly Exercises
  Widget _workoutWeek(int week){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
        children: [

          SizedBox(height: 10),

          Text(
            "Week ${week}",
            style: Theme.of(context)
            .textTheme
            .subtitle1!
            .copyWith(
              fontWeight: FontWeight.w700,
              fontSize: !_isSmallReso
              ?32
              :22,
              color: Colors.white,
            ),
          ),
          
          SizedBox(height: 10),
          
          Row(
            crossAxisAlignment:CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height:  displayHeight(context)*0.09,
                width: displayWidth(context)*0.85,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(25),
                    splashColor: Colors.red[200],
                    onTap: () {
                      Navigator.of(context).pushNamed('/warmup_exercises_page');
                    },
                    child: Row(
                      children: [
                        // Exercise Day
                        Expanded(
                          flex: 10,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'Warmup Exercises',
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                  .textTheme
                                  .headline4!
                                  .copyWith(
                                    fontWeight: FontWeight.w700,
                                    fontSize: !_isSmallReso
                                    ?28
                                    :20,
                                    color: Color(0xff526791),
                                  ),
                              ),
                            ],
                          )
                        ),
                    ]),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 10),

        ],
    );
  }

  // Generate Data for Daily Exercises
  Widget _workOutDay(int day, int week){

    bool weekDone =  false;
    bool dayDone =  false;
    bool isFirstDay =  false;

    if(progressWeek==week) {
      if(progressDay >= day){
        dayDone = true;
      }
      weekDone = false;
    }
    if(progressWeek>week) {
      if(progressDay >= day){
        dayDone = true;
      }
      weekDone = true;
    }
    if(day==1){
      isFirstDay=true;
    }

    return 
    Column(
      children: [
        Row(
          crossAxisAlignment:CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height:  displayHeight(context)*0.08,
              width: displayWidth(context)*0.85,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(25),
                  splashColor: Colors.red[200],
                  onTap: () {
                    if(weekDone || dayDone){
                      Navigator.of(context)
                      .pushNamed('/daily_workout_page', arguments: {'selectedDay': day, 'selectedWeek': week})
                      .then((value){
                        setState(() {
                          _refreshUI();
                        });
                      });

                    }
                    else{
                      Utils.showToast(isFirstDay
                        ?"Please Complete Week ${week-1} Day 6 Workout First"
                        :"Please Complete Week ${week} Day ${day-1} Workout First");
                    }
                  },
                  child: Row(
                    children: [
                      // Day No.
                      Expanded(
                        flex: 2,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 22,
                              backgroundColor: Colors.red[400],
                              foregroundColor: Colors.white,
                              child: Text('${day}', style: TextStyle(fontSize: 21),),
                            ),
                          ],
                        )
                      ),
                      // Day No. and No. of Exercises
                      Expanded(
                        flex: 6,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Day ${day}',
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                .textTheme
                                .headline4!
                                .copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontSize: !_isSmallReso
                                  ?28
                                  :20,
                                  color: Color(0xff526791),
                                ),
                            )
                          ],
                        )
                      ),
                      // Day No. and No. of Exercises
                      Expanded(
                        flex: 2,
                        child: Icon(
                          weekDone || dayDone
                          ?Icons.check
                          :Icons.lock_outline,
                          color: weekDone || dayDone
                          ?Colors.red[400]
                          :Colors.red[400],
                        ),
                      ),
                  ]),
                ),
              ),
            ),
          ],
        ),
    SizedBox(height: 6)
      ],
    );
  }

  // Run the Functions after Startup but before the build method 
  @override
  void didChangeDependencies() {

    _weeklyWorkoutList.clear();
    _getScreenSize();
    _generateWorkout();
  }

  // Run the Functions on Startup
  @override 
  void initState() {
    // TODO: implement initState
    super.initState();

    _getExerciseCount();
    _loadUserData();
  }

  // Build the User Interface
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isUpdated 
      ?Container(
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/backgroundBlue.png'),
            fit: BoxFit.cover,
          ),
          color: Colors.red[400],
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(top:20, left:20, right:20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children:  [
                  Text(
                     'Weekly Workout',
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
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: _weeklyWorkoutList.length,
                      itemBuilder: (context,index){
                    return _weeklyWorkoutList[index];
                  })
                ],
              ),
            ),
          ),
        ),
      )
      :SafeArea(
        child: SizedBox(
          height: displayHeight(context),
          child: Padding(
            padding: const EdgeInsets.only(top: 60),
            child: Center(child: CircularProgressIndicator()),
          ),
        )
      ),
      
    );
  }
}

