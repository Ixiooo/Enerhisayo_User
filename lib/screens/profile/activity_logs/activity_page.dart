import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enerhisayo/models/ActivityLogData.dart';
import 'package:enerhisayo/models/LocalSharedPref.dart';
import 'package:enerhisayo/utils/size_helpers.dart';
import 'package:flutter/material.dart';

class ActivityPage extends StatefulWidget {

  const ActivityPage({ Key? key }) : super(key: key);

  @override
  State<ActivityPage> createState() => _ActivityPageState();
  
}

class _ActivityPageState extends State<ActivityPage> {

  //Variable Declarations
  double _screenHeight = 0;
  double _screenWidth = 0;
  bool _isSmallReso = false;
  bool _isLogEmpty = false;
  String _currentUserId='';

  final activityLogs = FirebaseFirestore.instance.collection('activityLogs');

  // Load the Stream of Activity Logs from Database
  Stream<List <ActivityLogData>> readActivityLogs() => FirebaseFirestore.instance.collection('activityLogs').where('user_id',isEqualTo: _currentUserId).orderBy('createdAt', descending: true).snapshots().map((snapshot) 
                                          => snapshot.docs.map((doc) => ActivityLogData.fromJson(doc.data())).toList());

  // Load the Activity Logs to App
  Widget _loadActivityLogs(){
    return StreamBuilder<List<ActivityLogData>>(
      stream: readActivityLogs(),
      builder: (context, snapshot){
        if(snapshot.hasError){
          return Text('Something Went Wrong ${snapshot.error}');
        }
        else if(snapshot.hasData)
        {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
            
          } else{
            final data = snapshot.data!;

            if(data.length>=1){
              return ListView(
                physics: NeverScrollableScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  children: data.map(_buildActivityLogs).toList(),
              );
            }
            else{
              
              return Center(
                child: Text(
                  'No Activity Logs Yet',
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
              );
            }

          } 
        }else
        {
          return Center(child: CircularProgressIndicator());
        }
      }
    );
  }

  // Display Fetched Activity Logs to UI
  Widget _buildActivityLogs (ActivityLogData activityLogData){
    return
      InkWell(
        onTap: (){
          Navigator.of(context).pushNamed(
            '/edit_activity_log', 
            arguments: {
              'activityLogId': activityLogData.id, 
              'activityLogTitle': activityLogData.title,
              'activityLogContent': activityLogData.content,
            }
          );
        },
        child: Column(
          children: [
            SizedBox(height: 15,),
            Row(
              children: [
                SizedBox(width: displayWidth(context)*0.05,),
                Container(
                  height:  displayHeight(context)*0.12,
                  width: displayWidth(context)*0.9,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow:[ BoxShadow(
                      color: Color.fromARGB(255, 184, 184, 184),
                      blurRadius: 10,
                      spreadRadius: 2,
                      offset: Offset(0, 3)
                    )],
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Row(
                    children: [
                      // Name and Progress
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top:12, left:12, right:12, bottom: 5),
                              child: Text(
                                activityLogData.title,
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
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                activityLogData.content,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                                textAlign: TextAlign.left,
                                style: Theme.of(context)
                                  .textTheme
                                  .bodyText2!
                                  .copyWith(
                                    fontWeight: FontWeight.w400,
                                    fontSize: !_isSmallReso
                                    ?18
                                    :12,
                                    color: Color(0xff526791),
                                  ),
                              ),
                            ),
                          ],
                        )
                      ),
                  ]),
              ),
            ]),
          ],
        ),
      );
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

  //Get Data Stored in the Local Shared Prefs of Current User
  void _getDataFromLocal() async {
    _currentUserId = LocalSharedPreferences.getId();
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
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: (){
          Navigator.pushNamed(context, '/add_activity_log');
        },
      ),
      body: SingleChildScrollView(
            child: Column(
            children: [
      
              SizedBox(height: 15),
              _loadActivityLogs()
              
            ],
          ),
      )
    );
  }
}