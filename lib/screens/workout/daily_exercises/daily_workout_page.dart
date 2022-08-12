import 'dart:ui';

import 'package:enerhisayo/screens/workout/daily_exercises/daily_exercises_content.dart';
import 'package:enerhisayo/models/DailyRequirements.dart';
import 'package:enerhisayo/models/LocalSharedPref.dart';
import 'package:enerhisayo/models/DailyExercises.dart';
import 'package:enerhisayo/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../utils/size_helpers.dart';


class DailyWorkoutPage extends StatefulWidget {

  static const routeName = '/daily_workout_page';


  const DailyWorkoutPage({Key? key,}) : super(key: key);

  @override
  State<DailyWorkoutPage> createState() => _DailyWorkoutPageState();
}

class _DailyWorkoutPageState extends State<DailyWorkoutPage> {

  // Variable Declarations
  bool isDayComplete = false;
  bool isWorkoutTodayComplete = false;
  int selectedDay=0;
  int selectedWeek=0;
  String currentCategory = LocalSharedPreferences.getCategory();
  bool isExerciseSelected = false;
  int _exerciseCount = 0;
  int _currentWeek = 0;
  int _currentDay = 0;
  int _requiredMins = 0;
  int _minExercises = 0;
  
  List<DailyExercises> _selectedDailyExercises = [];
  Future<List<DailyExercises>>? _dailyExercisesFetched;
  Future<List<DailyExercises>> _getDailyExercises() async {

  QuerySnapshot dailyExercisesQuery =  await FirebaseFirestore.instance
                                        .collection("schedule")
                                        .where('day',isEqualTo: _currentDay)
                                        .where('week',isEqualTo: _currentWeek)
                                        .where('category',isEqualTo: currentCategory)
                                        .orderBy('exerciseName')
                                        .get();
    return dailyExercisesQuery.docs.map((doc) 
      => DailyExercises.fromJson(doc.data() as Map<String, dynamic>)).toList();
  }

  // Load the Exercises from Database
  Widget _loadDailyExercises(){
    return FutureBuilder<List<DailyExercises>>(
            future: _dailyExercisesFetched,
            builder: (context, snapshot) {
              if(snapshot.hasError){
                return Text('Something Went Wrong ${snapshot.error}');
              }
              else if(snapshot.hasData)
              {
                if (snapshot.connectionState == ConnectionState.done) {
                  final data = snapshot.data!;

                  return ListView(
                    physics: NeverScrollableScrollPhysics(),
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      children: data.map(_buildDailyExercises).toList(),
                  );
                } else if (snapshot.connectionState == ConnectionState.none) {
                  return Text("No data");
                } 
              }
              return Center(child: CircularProgressIndicator());
            },
          );
  }
  
  // Build UI for Loaded Exercises
  Widget _buildDailyExercises(DailyExercises dailyExercises){
    isExerciseSelected = _selectedDailyExercises.contains(dailyExercises);
    
    return 
      Column(
        children: [
          SizedBox(height: 10,),

          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25)
            ),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Color(0xffEB5253),
                  width: 1
                ),
                borderRadius:  BorderRadius.circular(25),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black87.withOpacity(0.12),
                    blurRadius: 5.0,
                    spreadRadius: 1.1,
                  )
                ]
              ),
              child: ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25)
                ),
                title: Text(
                  dailyExercises.exerciseName,
                  style:Theme.of(context)
                  .textTheme
                  .bodyText2!
                  .copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: Colors.red[400],
                  )
                  ,
                ),
                subtitle: Text(
                  '${dailyExercises.count} Counts - ${dailyExercises.durationSecs} Seconds',
                  style:Theme.of(context)
                  .textTheme
                  .bodyText2!
                  .copyWith(
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    color: Color(0xff074AAB),
                  )
                ),
                trailing: isExerciseSelected
                ?Icon(
                  Icons.check_box,
                  color: Colors.red[400],
                )
                :Icon(
                  Icons.check_box_outline_blank,
                  color: Colors.red[400],
                ),
                onTap: () {
                  selectDailyExercises(dailyExercises);
                  // showToast(exercise.id);
                  // Navigator.of(context).pushNamed('/exercise_info', arguments: {'exerciseId': exercise.id, 'exerciseName': exercise.exerciseName});
                },
              ),
            ),
          ),
        ],
      );
  }

  // Continue Button to Proceed to the Next Page
  Widget _createFloatingActionButton(){
    return  Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
          width: 270,
          height: 60,
          child: FloatingActionButton.extended(
          label:_selectedDailyExercises.length >= _minExercises
            ?Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Continue',
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                    .textTheme
                    .headline4!
                    .copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 28,
                      color: Colors.white,
                    ),
                )
              ],
            )
            :Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Select ${_minExercises} or More Exercises ',
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                    .textTheme
                    .headline4!
                    .copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                      color: Colors.white,
                    ),
                ),

                Text(
                  '${_selectedDailyExercises.length} Selected', 
                  textAlign: TextAlign.center,
                    style: Theme.of(context)
                      .textTheme
                      .headline4!
                      .copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: Colors.white,
                      ),
                ),
              ],
            ),
            backgroundColor: Colors.red[400],
            onPressed: () {
              if(_selectedDailyExercises.length >= _minExercises ){
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => DailyExercisesContent(
                                        selectedDay: _currentDay,
                                        selectedWeek: _currentWeek,
                                        selectedExercises: _selectedDailyExercises,
                                        dailyExercises: _selectedDailyExercises[0],
                                        nextDailyExercises: _selectedDailyExercises.length > 1
                                          ? _selectedDailyExercises[1]
                                          : null
                                  )
                  )).then((value) => setState(() {
                    _selectedDailyExercises = [];
                    isDayComplete = LocalSharedPreferences.getDayStatus();
                    if(isDayComplete){
                      showWorkoutCompletedAlert();
                    }else{
                      _updateDayStatus(false);
                    }
                    
                  }));
              }
              else{
                Utils.showErrorDialog(context, "Please Select At Least ${_minExercises} Exercises", "Error");
              }
              
            },
          ),
        ),
    );
  }

  // Show Workout Completed Alert Dialog if User Completes the Workout
  Future<void> showWorkoutCompletedAlert() async {
    _updateDayStatus(false);
    return showDialog<void>(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Daily Workout'),
          content: SingleChildScrollView(
            child: Text(
              'Workout for Today Completed',
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Ok'),
              onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
              // onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }

  // Show the Dialog that Asks the User if He/She has Finished the Warmup Exercises
  Future<void> isWarmupFinishedDialog()async{
    isWorkoutTodayComplete = LocalSharedPreferences.getDailyWarmupStatus();
    if(!isWorkoutTodayComplete){
      showDialog<void>(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Before You Start'),
            content: Text(
              'Are You Done with the Warmup Exercises?',
            ),
            actions: <Widget>[
              TextButton(
                child: Text("Yes"),
                onPressed:  () {
                  LocalSharedPreferences.setDailyWarmupStatus(true);
                  Navigator.of(context).pop();  
                },
              ),
              TextButton(
                child: Text("No"),
                onPressed:  () {
                  Utils.showToast('Please Finish the Warmup Exercises First');
                  Navigator.popUntil(context, (route) => route.isFirst,);
                },
              ),
            ],
          );
        },
      );
    }
  }

  // Load the Exercises to an Initialized List
  Future _fetchDailyExercises () async{
    setState(() {
      _dailyExercisesFetched = _getDailyExercises();
    });
  }

  // Update Progress if User Finished the Warmup
  void _updateDayStatus(bool status) async{
    await LocalSharedPreferences.setDayStatus(status);
    setState(() {
      isDayComplete = status;
    });
  }

  // Get Number of Exercises
  void _getExerciseCount() async{

    QuerySnapshot dailyExercisesQuery =  await FirebaseFirestore.instance
                                            .collection("schedule")
                                            .where("day", isEqualTo: _currentDay)
                                            .where("week", isEqualTo: _currentWeek)
                                            .where("category", isEqualTo: currentCategory)
                                            .get();
    setState(() {
      _exerciseCount = dailyExercisesQuery.docs.length;
    });
  
  }

  // Add the Selected Exercise to List
  void selectDailyExercises(DailyExercises dailyExercises){
    // isExerciseSelected = true;
    final isSelected = _selectedDailyExercises.contains(dailyExercises);
    setState(() {
      isSelected ? _selectedDailyExercises.remove(dailyExercises)
                : _selectedDailyExercises.add(dailyExercises);
    });
  }

  // Get the Data of the Current User
  void _getUserData() {
    currentCategory = LocalSharedPreferences.getCategory();
  }

  // Get the Requirements of the Current Day
  void _getDailyRequirements() async {
    final dailyRequirementsData = FirebaseFirestore.instance.collection('dailyRequirements')
                  .where('day', isEqualTo: _currentDay)
                  .where('week', isEqualTo: _currentWeek)
                  .limit(1);
    final dailyRequirementsDatasnapshot = await dailyRequirementsData.get();
    if(dailyRequirementsDatasnapshot.docs.length == 0){
       _requiredMins = 0;
      _minExercises = 1;
    }else{
      DailyRequirements dailyRequirements = DailyRequirements.fromJson(dailyRequirementsDatasnapshot.docs[0].data());
      _requiredMins = dailyRequirements.requiredMins;
      _minExercises = dailyRequirements.minExercises;
    }
  }

  // Run the Functions after Startup but before the build method 
@override
void didChangeDependencies() {
  
  final data = ModalRoute.of(context)?.settings.arguments as Map<String, int>;
  _currentDay = data['selectedDay']!;
  _currentWeek = data['selectedWeek']!;

  _fetchDailyExercises();
  _getDailyRequirements();
  _getExerciseCount();
  super.didChangeDependencies();
}

  // Run the Functions on Startup
 @override
  void initState() {
    super.initState();

    _getUserData();
    
    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      isWarmupFinishedDialog();
    });
  }

  // Build the User Interface
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Daily Workout'),
        backgroundColor: Colors.red[400],
      ),
      body: SafeArea(
        child:Container(
          height: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/backgroundRed.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 3,sigmaY: 3),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(top:20, left:20, right:20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children:  [
                    Text(
                      "Week ${_currentWeek}",
                      style: Theme.of(context)
                      .textTheme
                      .headline4!
                      .copyWith(
                        fontWeight: FontWeight.w900,
                        fontSize: 42,
                        color: Colors.red[600],
                      ),
                    ),
            
                    Text(
                      "Day ${_currentDay} Exercises",
                      style: Theme.of(context)
                      .textTheme
                      .headline4!
                      .copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 28,
                        color: Color(0xff074AAB),
                      ),
                    ),
                    
                    SizedBox(height: 15),    
          
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 17, vertical: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.red.withOpacity(0.42),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.watch_later_outlined, color:  Color(0xff074AAB)),
                              const SizedBox(width: 7),
                              Text('${_requiredMins} Minutes', style: TextStyle(color:Color(0xff074AAB), fontSize: 14, fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                            
                        const SizedBox(width: 15),
          
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 17, vertical: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.red.withOpacity(0.42),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.fitness_center_outlined, color: Color(0xff074AAB),),
                              const SizedBox(width: 7),
                              Text('${_exerciseCount} Exercises', style: TextStyle(color:Color(0xff074AAB), fontSize: 14, fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                      ],
                    ),
          
                    SizedBox(height: 15),      
          
                    _loadDailyExercises(),
                    
                    SizedBox(height: displayHeight(context)*0.12),      
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: _createFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}