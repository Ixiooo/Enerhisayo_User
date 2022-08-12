import 'dart:async';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:enerhisayo/models/Exercises.dart';
import 'package:enerhisayo/utils/size_helpers.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enerhisayo/models/LocalSharedPref.dart';
import 'package:enerhisayo/models/WarmupExercises.dart';

class WarmupExercisesContent extends StatefulWidget {

  final List <WarmupExercises> selectedExercises;
  final WarmupExercises warmupExercises;
  final WarmupExercises? nextWarmupExercises;

  const WarmupExercisesContent({
    Key? key,
    required this.selectedExercises,
    required this.warmupExercises,
    required this.nextWarmupExercises
  }) : super(key: key);

  @override
  State<WarmupExercisesContent> createState() => _WarmupExercisesContentState();
}

class _WarmupExercisesContentState extends State<WarmupExercisesContent> {

  // Variable Declarations
  List <WarmupExercises> _selectedWarmupExercises = [];
  WarmupExercises? _currentWarmupExercises;
  WarmupExercises? _nextWarmupExercises;
  Exercise? _currentExercise;
  Timer? timer;
  
  bool isLastExercise = false;
  bool isUrlLoaded = false;
  bool hasVideo = true;
  int _currentWarmupExerciseIndex = 0;
  static int maxSeconds = 0;
  int seconds = 0;
  String videoUrl ='';

  double _screenHeight = 0;
  double _screenWidth = 0;
  bool _isSmallReso = false;

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

  //Start the Timer
  void _startTimer(bool reset){
    if(reset){
      _resetTimer();
    }
    timer = Timer.periodic(Duration(seconds: 1), (_) {
      if(seconds > 0 ){
        if (mounted == true) {
            setState(() {
              seconds--;
            });
        }
      }else{
        _stopTimer(false);
      }
     });
  }

  //Stop the Timer
  void _stopTimer(bool reset){
    if(reset){
      _resetTimer();
    }
    if (mounted == true) {
      setState(() {
        timer!.cancel();
      });
    }
  }

  //Reset the Timer
  void _resetTimer(){
    setState(() {
      seconds = maxSeconds;
    });
  }

  //Set the Video URL of Current Video
  void _setVideoURL()async{

    final getExerciseData = FirebaseFirestore.instance
                                            .collection("exercises")
                                            .where("exerciseName", isEqualTo: _currentWarmupExercises!.exerciseName);
    final getExerciseDataSnapshot = await getExerciseData.get();
    if(getExerciseDataSnapshot.docs.length > 0){
      _currentExercise = Exercise.fromJson(getExerciseDataSnapshot.docs[0].data());
      if(_currentExercise!.videoUrl == '' || _currentExercise!.videoUrl == null){
        setState(() {
          hasVideo=false;
        });
      }else{
        setState(() {
          hasVideo = true;
          videoUrl = _currentExercise!.videoUrl;
          isUrlLoaded = true;
        });
      }
    }else {
      setState(() {
        hasVideo=false;
      });
    }
  }

  //Buttons for Controlling the Timer
  Widget _buildButtons(){
    bool isRunning = timer == null ? false: timer!.isActive;
    final isCompleted = seconds == maxSeconds || seconds == 0;

    return isRunning || !isCompleted
    ? Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          child: Text(
            isRunning
            ?'Pause'
            :'Resume'
          ),
          onPressed: () {
            isRunning
            ?_stopTimer(false)
            :_startTimer(false);
          }, 
        ),
        SizedBox(width: 20,),
        ElevatedButton(
          child: Text(
            'Cancel'
          ),
          onPressed: () {
            _stopTimer(true);
          }, 
        ),
      ],
    )
    :seconds == 0
      ?Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            child: Text(
              seconds!=0
              ?'Start'
              :'Restart'
            ),
            onPressed: () {
              _startTimer(true);
            }, 
          ),

          SizedBox(width: 20,),

          ElevatedButton(
            child: Text(
             !isLastExercise
              ? 'Next'
              : 'End',
            ),
            onPressed: () {
              setState(() {
                _selectedWarmupExercises.removeAt(_currentWarmupExerciseIndex);
              });
              if(!isLastExercise){
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => WarmupExercisesContent(
                                        selectedExercises: _selectedWarmupExercises,
                                        warmupExercises: _selectedWarmupExercises[0],
                                        nextWarmupExercises: _selectedWarmupExercises.length > 1
                                          ? _selectedWarmupExercises[1]
                                          : null
                                  )
                  ));
              }else{
                LocalSharedPreferences.setWorkoutStatus(true); //Workout for Today Completed Dialog
                LocalSharedPreferences.setDailyWarmupStatus(true); //
                Navigator.popUntil(context, ModalRoute.withName('/warmup_exercises_page'));
              }
              
            }, 
          ),
        ],
      )
      :Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            child: Text(
              seconds!=0
              ?'Start'
              :'Restart'
            ),
            onPressed: () {
              _startTimer(true);
            }, 
          ),
        ],
      );
  }

  //Timer UI
  Widget _buildTimer(){
    bool isRunning = timer == null ? false: timer!.isActive;

    return Container(
       decoration:  BoxDecoration(
        color: Colors.red[400],
        shape: BoxShape.circle,
        border: Border.all(
          width: 10, 
          color: Colors.red[400]!
        ),
      ),
      height: displayHeight(context)*0.12,
      width: displayHeight(context)*0.12,
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          CircularProgressIndicator(
            value: seconds/maxSeconds,
            valueColor: AlwaysStoppedAnimation(
              isRunning
              ?Colors.black26
              :Colors.white
            ),
            backgroundColor: Colors.white,
            strokeWidth: 4,
          ),
          Center(child: _buildTime(),)
        ],
      ),
    );
  }

  //Timer UI
  Widget _timerText(){
    bool isRunning = timer == null ? false: timer!.isActive;

    bool isThreeDigits = false;
    if(seconds >99){
      isThreeDigits = true;
    }

    if(seconds == 0){
      return Icon(Icons.done, color: Colors.red,size:!_isSmallReso? 70 : 54,);
    }

    return Text(
      '${seconds} Secs',
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.center,
      style: Theme.of(context)
      .textTheme
      .headline4!
      .copyWith(
        fontWeight:FontWeight.w600,
        fontSize: 32,
        color: Colors.red[400],
      ),
    );
  }

  //Timer Text
  Widget _buildTime(){
    
    bool isThreeDigits = false;
    if(seconds >99){
      isThreeDigits = true;
    }

    if(seconds == 0){
      return Icon(Icons.done, color: Colors.white,size: !_isSmallReso ?74 : 58,);
    }

    return Text(
      '${seconds}',
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context)
      .textTheme
      .headline4!
      .copyWith(
        fontWeight: FontWeight.w600,
        fontSize: 
        isThreeDigits
          ?38
          :!_isSmallReso
            ?48
            :40,
        color: Colors.white,
      ),
    );
  }

  //Timer UI, Details, Controls and Buttons UI
  Widget _buildControls(){
    return Container(
      height: displayHeight(context)*0.4,
      width: displayWidth(context)*0.82,
      decoration: BoxDecoration(
        border: Border.all(
          color: Color(0xffEB5253),
          width: 1
        ),
        borderRadius: BorderRadius.circular(16),
        color: Colors.white.withOpacity(0.9),
      ),
      child: LayoutBuilder(builder: (context, constraints) => 
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
      
              //Timer Seconds
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        _timerText()
                      ],
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: constraints.maxHeight*0.03,),
              
              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          '${_currentWarmupExercises!.exerciseName}',
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          softWrap: false,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context)
                          .textTheme
                          .headline4!
                          .copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: !_isSmallReso
                            ?26
                            :22,
                            color: Colors.red[400],
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
      
              SizedBox(height: constraints.maxHeight*0.03,),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          'Rep Count',
                          style: TextStyle(color: Color(0xff074AAB),
                          fontSize: !_isSmallReso
                            ?20
                            :16),
                        ),
                        Text(
                          '${_currentWarmupExercises!.repCount.toString()} Rep(s)',
                          maxLines: 1,
                          softWrap: false,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.red[400], fontWeight: FontWeight.bold, 
                          fontSize: !_isSmallReso 
                          ?20
                          :16,),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          'Counts',
                          style: TextStyle(color:  Color(0xff074AAB),
                          fontSize: !_isSmallReso
                            ?20
                            :16),
                        ),
                        Text(
                          '${_currentWarmupExercises!.count.toString()} Count(s)',
                          maxLines: 1,
                          softWrap: false,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.red[400], fontWeight: FontWeight.bold, 
                          fontSize: !_isSmallReso
                            ?20
                            :16,),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: constraints.maxHeight*0.04,),
              
              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          'Rest Time',
                          style: TextStyle(color: Color(0xff074AAB),
                           fontSize: !_isSmallReso
                            ?20
                            :16,),
                        ),
                        Text(
                          !isLastExercise
                          ?'${_currentWarmupExercises!.restSecs} Seconds'
                          :'1 Minute',
                          maxLines: 1,
                          softWrap: false,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.red[400], fontWeight: FontWeight.bold, 
                           fontSize: !_isSmallReso
                            ?20
                            :16,),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text('Next Exercise',
                          style: TextStyle(color: Color(0xff074AAB),
                          fontSize: !_isSmallReso
                            ?20
                            :16),
                        ),
                        Text(
                          !isLastExercise
                          ?'${_nextWarmupExercises!.exerciseName}'
                          :'None',
                          maxLines: 1,
                          softWrap: false,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.red[400], 
                            fontWeight: FontWeight.bold, 
                            fontSize: !_isSmallReso
                            ?20
                            :16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      
              SizedBox(height: constraints.maxHeight*0.04,),
          
              _buildButtons(),
              
            ],
          ),
        ),
      ),
    );        
  }
  
  //Alert Confirmation if User Wants to Stop the Current Exercise
  Future<bool> _onWillPop() async {

    if(seconds != maxSeconds){
      _stopTimer(false);
    }

    return (
      await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Stop Warmup Exercises"),
          content: Text("Are you sure you want to stop your warmup exercises?"),
          actions: [
            TextButton(
              child: Text("Close"),
              onPressed:  () {
                Navigator.of(context).pop();  
              },
            ),
            TextButton(
              child: Text("Stop"),
              onPressed:  () {
                Navigator.popUntil(context, ModalRoute.withName('/warmup_exercises_page'));
              },
            ),
          ]
        );
      },
    )) ?? false;
  }
  
  //Load the Asset of Selected Exercise
  Widget _loadWarmupExercisesGif(String url){
    return hasVideo
    ?isUrlLoaded
      ?Container(
         decoration: BoxDecoration(
          border: Border.all(
            color: Color(0xffEB5253),
            width: 1
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: CachedNetworkImage(
              placeholder: (context, url) => Center(child: const CircularProgressIndicator()),
              imageUrl: url,
              fit:BoxFit.fill,
            )
          // Image.network( 
          //   url,
          //   loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
          //       if (loadingProgress == null) return child;
          //       return Column(
          //         mainAxisAlignment: MainAxisAlignment.center,
          //         crossAxisAlignment: CrossAxisAlignment.center,
          //         children: [
          //           Center(
          //             child: CircularProgressIndicator(
          //               // value: loadingProgress.expectedTotalBytes != null
          //               //     ? loadingProgress.cumulativeBytesLoaded /
          //               //         loadingProgress.expectedTotalBytes!.toInt()
          //               //     : null,
          //             ),
          //           ),
          //           SizedBox(height: 10,),
          //           Center(child: Text('Loading Video ...'))
          //         ],
          //       );
          //   },
          //   fit: BoxFit.fill,
          // ),
        ),
      )
      :Center(
        child: CircularProgressIndicator(),
      )
    :Center(
      child: Text(
        'No Video Available',
      )
    );
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
    
    maxSeconds = widget.warmupExercises.durationSecs;
    seconds = maxSeconds;
    _selectedWarmupExercises = widget.selectedExercises;
    _currentWarmupExercises = widget.warmupExercises;
    _nextWarmupExercises = widget.nextWarmupExercises??null;
    _currentWarmupExerciseIndex = widget.selectedExercises.indexOf(widget.warmupExercises);
    widget.nextWarmupExercises == null
      ?isLastExercise = true
      :isLastExercise = false;
    _setVideoURL();
  }


  // Build the User Interface
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Warmup Exercise'),
          backgroundColor: Colors.red[400],
        ),
        body: SafeArea(
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/backgroundRed.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 3,sigmaY: 3),
              child: Center(
                child: LayoutBuilder(builder: (context, constraints) => 
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.center,
                        children: [
                          Positioned(
                            bottom: constraints.maxHeight*0.55,
                            child: 
                            Container(
                              width: constraints.maxHeight*0.32,
                              height: constraints.maxHeight*0.4,
                              child: _loadWarmupExercisesGif(videoUrl)
                            )
                          ),
                          Positioned(
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 20),
                              child: _buildControls(),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
