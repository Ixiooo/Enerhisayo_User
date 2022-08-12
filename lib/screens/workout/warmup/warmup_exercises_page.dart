import 'dart:ui';

import 'package:enerhisayo/models/LocalSharedPref.dart';
import 'package:enerhisayo/models/WarmupExercises.dart';
import 'package:enerhisayo/utils/utils.dart';
import 'package:enerhisayo/screens/workout/warmup/warmup_exercises_content.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../utils/size_helpers.dart';


class WarmupExercisesPage extends StatefulWidget {

  static const routeName = '/warmup_exercises_page';

  const WarmupExercisesPage({ Key? key }) : super(key: key);

  @override
  State<WarmupExercisesPage> createState() => _WarmupExercisesPageState();
}

class _WarmupExercisesPageState extends State<WarmupExercisesPage> {
  
  // Variable Declarations
  bool isWarmupSelected = false;
  int exerciseCount = 0;
  bool _isWorkoutComplete = false;

  List<Widget> _warmupExercisesList = [];
  
  List<WarmupExercises> _selectedWarmupExercises = [];
  
  Future<List<WarmupExercises>>? _warmupExercisesFetched;
  
  Future<List<WarmupExercises>> _getWarmupExercises() async {

  QuerySnapshot warmupExercisesQuery =  await FirebaseFirestore.instance
                                        .collection("warmupExercises")
                                        .orderBy("exerciseName")
                                        .get();
    return warmupExercisesQuery.docs.map((doc) 
      => WarmupExercises.fromJson(doc.data() as Map<String, dynamic>)).toList();
  }
  
  // Show Workout Completed Alert Dialog if User Completes the Workout
  Future<void> showWorkoutCompletedAlert() async {
    _updateWorkoutStatus(false);
    return showDialog<void>(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Daily Warmup'),
          content: SingleChildScrollView(
            child: Text(
              'Warmup Exercises Completed, You May Proceed to the Exercise Proper',
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Ok'),
              onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
            ),
          ],
        );
      },
    );
  }
  
  // Load the Warmup Exercises to an Initialized List
  Future _fetchWarmupExercises () async{
    setState(() {
      _warmupExercisesFetched = _getWarmupExercises();
    });
  }

  // Load the Warmup Exercises from Database
  Widget _loadWarmupExercises(){
    return FutureBuilder<List<WarmupExercises>>(
            future: _warmupExercisesFetched,
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
                      children: data.map(_buildWarmupExercises).toList(),
                  );
                } else if (snapshot.connectionState == ConnectionState.none) {
                  return Text("No data");
                } 
              }
              return Center(child: CircularProgressIndicator());
            },
          );
  }
  
  // Build UI for Loaded Warmup Exercises
  Widget _buildWarmupExercises(WarmupExercises warmupExercises){
    isWarmupSelected = _selectedWarmupExercises.contains(warmupExercises);
    
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
                  warmupExercises.exerciseName,
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
                  '${warmupExercises.count} Counts - ${warmupExercises.durationSecs} Seconds',
                  style:Theme.of(context)
                  .textTheme
                  .bodyText2!
                  .copyWith(
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    color: Color(0xff074AAB),
                  )
                ),
                trailing: isWarmupSelected
                ?Icon(
                  Icons.check_box,
                  color: Colors.red[400],
                )
                :Icon(
                  Icons.check_box_outline_blank,
                  color: Colors.red[400],
                ),
                onTap: () {
                  selectWarmupExercises(warmupExercises);
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
            label: _selectedWarmupExercises.length >= exerciseCount
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
                      fontWeight: FontWeight.w700,
                      fontSize: 28,
                      color: Colors.white,
                    ),
                ),
              ],
            )
            :Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Select ${exerciseCount} Exercises ',
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
                  '${_selectedWarmupExercises.length} Selected', 
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
              if(_selectedWarmupExercises.length >= exerciseCount){
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => WarmupExercisesContent(
                                        selectedExercises: _selectedWarmupExercises,
                                        warmupExercises: _selectedWarmupExercises[0],
                                        nextWarmupExercises: _selectedWarmupExercises.length > 1
                                          ? _selectedWarmupExercises[1]
                                          : null
                                  )
                  )).then((value) => setState(() {
                    _selectedWarmupExercises = [];
                    _isWorkoutComplete = LocalSharedPreferences.getWorkoutStatus();
                    if(_isWorkoutComplete){
                      showWorkoutCompletedAlert();
                    }else{
                      _updateWorkoutStatus(false);
                    }
                  }));
              }
              else{
                Utils.showErrorDialog(context, "Please Select ${exerciseCount} Exercises", "Error");
              }
              
            },
          ),
        ),
    );
  }
  
  // Update Workout Status if User Finished the Warmup
  void _updateWorkoutStatus(bool status) async{
    await LocalSharedPreferences.setWorkoutStatus(status);
    setState(() {
      _isWorkoutComplete = status;
    });
  }
  
  // Get Number of Warmup Exercises
  void _getExerciseCount() async{

    QuerySnapshot warmupExercisesQuery =  await FirebaseFirestore.instance
                                            .collection("warmupExercises")
                                            .get();
    setState(() {
      exerciseCount = warmupExercisesQuery.docs.length;
    });
  
  }

  // Add the Selected Exercise to List
  void selectWarmupExercises(WarmupExercises warmupExercises){
    // isWarmupSelected = true;
    final isSelected = _selectedWarmupExercises.contains(warmupExercises);
    setState(() {
      isSelected ? _selectedWarmupExercises.remove(warmupExercises)
                : _selectedWarmupExercises.add(warmupExercises);
    });
  }

  // Run the Functions on Startup
  @override
  void initState() {
    super.initState();
    
    _fetchWarmupExercises();
    _getExerciseCount();
  }

  // Build the User Interface
  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Daily Warmup'),
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
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        children: <TextSpan>[
                          TextSpan(
                            text: "Warmup",
                            style: Theme.of(context)
                            .textTheme
                            .headline4!
                            .copyWith(
                              fontWeight: FontWeight.w900,
                              fontSize: 38,
                              color: Colors.red[400],
                            ),
                          ),
                            TextSpan(
                            text: " Exercises",
                            style: Theme.of(context)
                            .textTheme
                            .headline4!
                            .copyWith(
                              fontWeight: FontWeight.w900,
                              fontSize: 38,
                              color: Colors.red[400],
                            ),
                          ),
                        ],
                      ),
                    ),
          
                    SizedBox(height: 15),    
          
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 17, vertical: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.red.withOpacity(0.12),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.watch_later_outlined, color:  Color(0xff074AAB)),
                              const SizedBox(width: 7),
                              Text('3-5 Minutes', style: TextStyle(color:Color(0xff074AAB), fontSize: 14, fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                            
                        const SizedBox(width: 15),
          
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 17, vertical: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.red.withOpacity(0.12),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.fitness_center_outlined, color: Color(0xff074AAB),),
                              const SizedBox(width: 7),
                              Text('${exerciseCount} Exercises', style: TextStyle(color:Color(0xff074AAB), fontSize: 14, fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                      ],
                    ),
          
                    SizedBox(height: 15),      
          
                    _loadWarmupExercises(),
                    
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