
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enerhisayo/models/LocalSharedPref.dart';
import 'package:enerhisayo/models/UserData.dart';
import 'package:enerhisayo/utils/size_helpers.dart';
import 'package:flutter/material.dart';

extension DecimalUtil on double {
  String expToStringAsFixed(int afterDecimal) => '${this.toString().split('.')[0]}.${this.toString().split('.')[1].substring(0,afterDecimal)}';
}

class ProfilePage extends StatefulWidget {
  
  const ProfilePage({ Key? key }) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();

}

class _ProfilePageState extends State<ProfilePage> {


  //Variable Declarations
  String _currentUserId='';

  double _screenHeight = 0;
  double _screenWidth = 0;
  bool _isSmallReso = false;

  bool _isProfileUpdated = false;
  
  Stream<List <UserData>> readUserInfo() => FirebaseFirestore.instance.collection('users').where('id',isEqualTo: _currentUserId).snapshots().map((snapshot) 
                                          => snapshot.docs.map((doc) => UserData.fromJson(doc.data())).toList());

  // Load Info of Current User
  Widget _loadUserProfile(){
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(_currentUserId).snapshots(),
      builder: (context, snapshot){
        if(snapshot.hasError){
          return Text('Something Went Wrong ${snapshot.error}');
        }
        else if(snapshot.hasData)
        {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
            
          } else{


            Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;
            // final data = snapshot.data!;
              return ListView(
                physics: NeverScrollableScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  children: [ 
                    Column(
                      children: [
                        _infoFields('First Name', data['firstName']),
                        SizedBox(height: 15), 
                        _infoFields('Last Name', data['lastName']),
                        SizedBox(height: 15), 
                        _infoFields('Email', data['email']),
                        SizedBox(height: 15), 
                        _infoFields('Age', data['age'].toStringAsFixed(0)),
                        SizedBox(height: 15), 
                        _infoFields('Gender',data['gender']),
                        SizedBox(height: 15), 
                        _infoFields('Category', data['category']),
                        SizedBox(height: 15), 
                        _infoFields('BMI', data['bmi'].toStringAsFixed(2)),
                        SizedBox(height: 15), 
                        _infoFields('Height', '${data['height'].toStringAsFixed(0)} cm'),
                        SizedBox(height: 15), 
                        _infoFields('Weight', '${data['weight'].toStringAsFixed(0)} kg'),
                        SizedBox(height: 15), 
                      ],
                    )
                  ],
              );

          } 
        }else
        {
          return Center(child: CircularProgressIndicator());
        }
      }
    );
  }

  // Display Info of Current User in Form
  Widget _infoFields(String title, String content){
    return Container(
      child: 
        Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  title,
                  textAlign: TextAlign.left,
                  style: Theme.of(context)
                    .textTheme
                    .headline4!
                    .copyWith(
                      fontWeight: FontWeight.w500,
                      fontSize: !_isSmallReso
                      ?20
                      :14,
                      color: Colors.red[600],
                    ),
                ),
              ],
            ),
            SizedBox(height: 4,),
            Row(
              children: [
                SizedBox(width: 5,),
                Text(
                  content,
                  textAlign: TextAlign.left,
                  style: Theme.of(context)
                    .textTheme
                    .bodyText2!
                    .copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: !_isSmallReso
                      ?32
                      :20,
                      color: Color(0xff526791),
                    ),
                ),
              ],
            ),
          ],
        ),
       
        // SizedBox(height: 15),
      
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
    _isProfileUpdated =true;
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
        child: Icon(Icons.edit),
        onPressed: (){
          Navigator.pushNamed(context, '/edit_profile').then((value) {
              setState(() {
                _getDataFromLocal();
              });
          });
        },
      ),
      body: _isProfileUpdated
      ?SingleChildScrollView(
        child: Padding(
          padding:const EdgeInsets.only(top:20, left: 18, right: 18,),
          child: _loadUserProfile()
        ),
      )
      :Container(),
      
    );
  }
}