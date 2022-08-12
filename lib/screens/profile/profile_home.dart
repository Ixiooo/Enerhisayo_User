import 'package:enerhisayo/screens/profile/activity_logs/activity_page.dart';
import 'package:enerhisayo/screens/profile/profile_pages/profile_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../models/LocalSharedPref.dart';
class ProfileHome extends StatefulWidget {

  const ProfileHome({ Key? key }) : super(key: key);

  @override
  State<ProfileHome> createState() => _ProfileHomeState();
}

class _ProfileHomeState extends State<ProfileHome> {

  // This page is the parent page of 2 Tabs in Profile which is Activity Logs and Profile

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

  // Run the Functions on Startup
  @override
  void initState() {

    super.initState();
  }

  // Build the User Interface
  @override
  Widget build(BuildContext context) {

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          flexibleSpace: Image(
            image: AssetImage('assets/backgroundBlue.png'),
            fit: BoxFit.cover,
          ),
          backgroundColor: Colors.red[400],
          bottom: TabBar(
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'Activity Logs', icon: Icon(Icons.date_range_outlined,)),
              Tab(text: 'Profile', icon: Icon(Icons.person_rounded,))
            ],
          ),
          actions: [
            IconButton(
            icon: Icon(Icons.logout_outlined),
                      color: Colors.white,
                      iconSize: 38,
            onPressed: (){
              setState(() {
                logout();
              });
            }, 
          )
          ],
        ),
        body: TabBarView(
          children: [
            ActivityPage(),
            ProfilePage()
          ],
        )
      ),
    );
  }
}