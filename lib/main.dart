import 'package:enerhisayo/api/notification_api.dart';
import 'package:enerhisayo/screens/profile/activity_logs/add_activity_log.dart';
import 'package:enerhisayo/screens/workout/daily_exercises/daily_workout_page.dart';
import 'package:enerhisayo/screens/profile/activity_logs/edit_activity_log.dart';
import 'package:enerhisayo/screens/profile/profile_pages/edit_profile.dart';
import 'package:enerhisayo/screens/workout/workout_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:enerhisayo/utils/utils.dart';
import 'package:flutter/services.dart';
import 'models/LocalSharedPref.dart';
import 'package:enerhisayo/screens/home/my_homeApp.dart';
import 'package:enerhisayo/screens/workout/warmup/warmup_exercises_page.dart';
import 'package:enerhisayo/screens/signin/auth_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    // Replace with actual values
    options: const FirebaseOptions(
      apiKey: "AIzaSyA02v_GVaAXaC85JM9YMuAQDxJaa7yhDak",
      appId: "1:311955706534:android:4298adc513a7359c745a67",
      messagingSenderId: "311955706534",
      projectId: "enerhisayo-a7572",
      storageBucket: "enerhisayo-a7572.appspot.com",
    ),
  );
  await LocalSharedPreferences.init();
      
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
  ));
  runApp( const MyApp());
}

  final navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);


  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      scaffoldMessengerKey: Utils.messengerKey,
      title: 'Enerhisayo',
      theme: ThemeData(
        primarySwatch: Colors.red,
        scaffoldBackgroundColor: const Color(0xFFF1F1F1),
        splashFactory: InkRipple.splashFactory
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if(snapshot.connectionState == ConnectionState.waiting){
            return const Center(child: CircularProgressIndicator());
          } 
          else if(snapshot.hasError){
            return const Center(child: Text("Something Went Wrong"));
          }
          else if(snapshot.hasData){
            return const MyHomePage();
          }
          else{
            return const AuthPage();
          }
        }
      ),
       //Page Routing for App Routes
      routes: {
        MyHomePage.routeName : (BuildContext context) => const MyHomePage(),
        AuthPage.routeName : (BuildContext context) =>const AuthPage(),
        WorkoutPage.routeName : (BuildContext context) => const WorkoutPage(),
        DailyWorkoutPage.routeName : (BuildContext context) => const DailyWorkoutPage(),
        WarmupExercisesPage.routeName : (BuildContext context) => const WarmupExercisesPage(),
        AddActivityLog.routeName : (BuildContext context) => const AddActivityLog(),
        EditActivityLog.routeName : (BuildContext context) => const EditActivityLog(),
        EditProfile.routeName : (BuildContext context) => const EditProfile(),
      },
    );
  }
}
