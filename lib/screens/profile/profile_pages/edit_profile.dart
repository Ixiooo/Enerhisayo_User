import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enerhisayo/models/LocalSharedPref.dart';
import 'package:enerhisayo/models/UserData.dart';
import 'package:enerhisayo/models/UserProgress.dart';
import 'package:enerhisayo/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EditProfile extends StatefulWidget {

  static const routeName = '/edit_profile';

  const EditProfile({ Key? key }) : super(key: key);

  @override
  State<EditProfile> createState() => _EditProfileState();

}

class _EditProfileState extends State<EditProfile> {


  final _updateProfileFormKey = GlobalKey<FormState>();  

  // Variable Declarations
  String _newGender = '';
  String _newCategory = '';
  double _newBMI= 0;

  final emailController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final ageController = TextEditingController();
  final heightController = TextEditingController();
  final weightController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  
  String _currentEmail = '';
  String _newSubscription = '1';
  String _oldSubscription = '0';
  String _oldCategory = '';
  
  String _currentUserId='';
  String _currentFirstName = '';
  String _currentLastName = '';
  String _currentWeek = '';
  String _currentDay = '';
  String _currentGender = '';
  String _currentCategory = '';
  double _currentBMI = 0;
  double _currentAge = 0;
  double _currentHeight = 0;
  double _currentWeight = 0;

  bool isLoaded = false;

  // Compute New BMI of User based on Weight and Height
  double _computeBmi(double height, double weight){
    double heightInMeters = height/100;
    double bmi = weight/(heightInMeters * heightInMeters);
    String bmi_rounded = bmi.toStringAsFixed(1);
    return double.parse(bmi_rounded);
  }

  // Update Profile Info of User in Database
  Future _updateProfile() async{

    final isValid = _updateProfileFormKey.currentState!.validate();

    if (!isValid){
      Utils.showToast('Please Fill up the Necessary Fields');
      return;
    } 

    try{
      _updateProfileFormKey.currentState!.save();

      _newBMI=_computeBmi(_currentHeight, _currentWeight);
      if(_newBMI >= 25 && _newBMI <= 29.9){
        _newCategory = 'Overweight';
      }else if(_newBMI >= 30 &&_newBMI <= 34.9){
        _newCategory = 'Obese Class I';
      }else if(_newBMI >= 35 &&_newBMI <= 39.9){
        _newCategory = 'Obese Class II';
      }else if(_newBMI >= 40){
        _newCategory = 'Obese Class III';
      }else{
        _newCategory = 'Not Qualified';
        Utils.showToast('BMI not Qualified');
        return;
      }

      FocusScope.of(context).unfocus();

      final docUserData = FirebaseFirestore.instance.collection('users').doc(_currentUserId);

      await docUserData.update({
         'firstName' : _currentFirstName,
         'lastName' : _currentLastName,
         'email' : _currentEmail,
         'gender' : _currentGender,
         'age' : _currentAge,
         'height' : _currentHeight,
         'weight' : _currentWeight,
         'bmi' : _newBMI,
         'category' : _newCategory,
         'subscription' : double.parse(_newSubscription) ,
      });

      final int _currentDayProgress = LocalSharedPreferences.getDay();
      final int _currentWeekProgress = LocalSharedPreferences.getWeek();

      if(_oldSubscription != _newSubscription){

        if(double.parse(_oldSubscription)>double.parse(_newSubscription)){
          // Get User Progress ID
          final progressData = FirebaseFirestore.instance.collection('userProgress').where('user_id', isEqualTo: _currentUserId);
          final progressDataSnapshot = await progressData.get();
          UserProgress userProgress = UserProgress.fromJson(progressDataSnapshot.docs[0].data());
          final data = FirebaseFirestore.instance.collection('userProgress').doc(userProgress.id);
          data.update({
            'day' : 1,
            'week': 1
          });
        }
      }

      if(_currentCategory != _newCategory)
      {
        // Get User Progress ID
        final progressData = FirebaseFirestore.instance.collection('userProgress').where('user_id', isEqualTo: _currentUserId);
        final progressDataSnapshot = await progressData.get();
        UserProgress userProgress = UserProgress.fromJson(progressDataSnapshot.docs[0].data());
        final data = FirebaseFirestore.instance.collection('userProgress').doc(userProgress.id);
        data.update({
            'day' : 1,
            'week': 1
          });
      }


      Utils.showToast('Profile updated successfully, restart the app to apply the changes');
      Navigator.pop(context);

    } catch (e){
      Utils.showToast(e.toString());
    }
  }

  // Form for Editing Profile
  Widget _editProfileForm(){
     return ListView(
                physics: NeverScrollableScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  children: [ 
                    Form(
                    key: _updateProfileFormKey,
                    child: Column(
                      children: [

                        // First Name
                        Row(
                          children: [
                            Column(
                              children: const [
                                Text(
                                  'First Name',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 22,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                  
                        TextFormField(
                          initialValue: _currentFirstName,
                          // controller: firstNameController..text=_currentFirstName,
                          textCapitalization: TextCapitalization.sentences,
                          textInputAction: TextInputAction.next,
                          enableSuggestions: false,
                          decoration: const InputDecoration(
                            hintText: 'First Name'
                          ),
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (value) => value!.isEmpty ? 'Enter First Name' : null,
                          onSaved: (value) => setState((){
                            _currentFirstName = value!;
                          }),
                        ),

                        SizedBox(height: 15), 

                        // Last Name
                        Row(
                          children: [
                            Column(
                              children: const [
                                Text(
                                  'Last Name',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 22,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                  
                        TextFormField(
                          initialValue: _currentLastName,
                          // controller: lastNameController..text=_currentLastName,
                          textCapitalization: TextCapitalization.sentences,
                          textInputAction: TextInputAction.next,
                          enableSuggestions: false,
                          decoration: const InputDecoration(
                            hintText: 'Last Name'
                          ),
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (value) => value!.isEmpty ? 'Enter Last Name' : null,
                          onSaved: (value) => setState((){
                            _currentLastName = value!;
                          }),
                        ),

                        SizedBox(height: 15), 

                        // Email
                        Row(
                          children: [
                            Column(
                              children: const [
                                Text(
                                  'Email',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 22,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                  
                        TextFormField(
                          initialValue: _currentEmail,
                          // controller: emailController..text=_currentEmail,
                          textCapitalization: TextCapitalization.sentences,
                          textInputAction: TextInputAction.next,
                          enableSuggestions: false,
                          decoration: const InputDecoration(
                            hintText: 'Email'
                          ),
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (value) => value!.isEmpty ? 'Enter Email' : null,
                          onSaved: (value) => setState((){
                            _currentEmail = value!;
                          }),
                          
                        ),

                        SizedBox(height: 15), 

                        // Age
                        Row(
                          children: [
                            Column(
                              children: const [
                                Text(
                                  'Age',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 22,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                  
                        TextFormField(
                          initialValue: _currentAge.toStringAsFixed(0),
                          // controller: ageController..text=_currentAge.toStringAsFixed(0),
                          textInputAction: TextInputAction.next,
                          enableSuggestions: false,
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
                          decoration: const InputDecoration(
                            hintText: 'Age'
                          ),
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (value) => value!.isEmpty ? 'Enter Age' : null,
                          onSaved: (value) => setState((){
                            _currentAge = double.parse(value!);
                          }),
                        ),

                        SizedBox(height: 15), 

                        // Gender
                        Row(
                          children: [
                            Column(
                              children: const [
                                Text(
                                  'Gender',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 22,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        DropdownButton<String>(
                          isExpanded: true,
                          value: _currentGender,
                          elevation: 16,
                          style: const TextStyle(color: Colors.black),
                          underline: Container(
                            height: 2,
                            color: Colors.red,
                          ),
                          onChanged: (String? newValue) {
                            setState(() {
                              _currentGender = newValue!;
                            });
                          },
                          items: <String>['Male', 'Female']
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),

                        // Height
                        Row(
                          children: [
                            Column(
                              children: const [
                                Text(
                                  'Height(cm)',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 22,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                  
                        TextFormField(
                          initialValue: _currentHeight.toStringAsFixed(0),
                          // controller: heightController..text=_currentHeight.toStringAsFixed(0),
                          textInputAction: TextInputAction.next,
                          enableSuggestions: false,
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
                          decoration: const InputDecoration(
                            hintText: 'Height'
                          ),
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (value) => value!.isEmpty ? 'Enter Height' : null,onSaved: (value) => setState((){
                            _currentHeight = double.parse(value!);
                          }),
                        ),

                        SizedBox(height: 15), 

                        // Weight
                        Row(
                          children: [
                            Column(
                              children: const [
                                Text(
                                  'Weight(kg)',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 22,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                  
                        TextFormField(
                          initialValue: _currentWeight.toStringAsFixed(0),
                          // controller: weightController..text=_currentWeight.toStringAsFixed(0),
                          textInputAction: TextInputAction.next,
                          enableSuggestions: false,
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
                          decoration: const InputDecoration(
                            hintText: 'Weight'
                          ),
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (value) => value!.isEmpty ? 'Enter Weight' : null,
                          onSaved: (value) => setState((){
                            _currentWeight = double.parse(value!);
                          }),
                        ),

                        SizedBox(height: 15),
            
                        // Subscription
                        Row(
                          children: [
                            Column(
                              children: const [
                                Text(
                                  'Subscription(Weeks)',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 22,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        DropdownButton<String>(
                          isExpanded: true,
                          value: _newSubscription,
                          elevation: 16,
                          style: const TextStyle(color: Colors.black),
                          underline: Container(
                            height: 2,
                            color: Colors.red,
                          ),
                          onChanged: (String? newValue) {
                            setState(() {
                              _newSubscription = newValue!;
                            });
                          },
                          items: <String>['1', '2','3','4']
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),

                        const SizedBox(height: 10),

                      
                      ],
                    ),
                  ),
              ],
            );

  }

  //Get Data of Current User in Database
  void _getdata() async {
    final data = FirebaseFirestore.instance.collection('users').doc(_currentUserId);
    final snapshot = await data.get();

    UserData userModel = UserData.fromJson(snapshot.data()!);
    _currentUserId = userModel.id;
    _currentEmail = userModel.email;
    _currentFirstName = userModel.firstName;
    _currentLastName = userModel.lastName;
    _currentGender = userModel.gender;
    _newSubscription = userModel.subscription.toStringAsFixed(0); 
    _currentAge =  userModel.age;
    _currentHeight = userModel.height;
    _currentWeight = userModel.weight;
    _currentBMI = userModel.bmi;
    _currentCategory = userModel.category;

    _oldSubscription = _newSubscription;

    setState(() {
      isLoaded = true;
    });
  }

  // Run the Functions on Startup
  @override
  void initState() {
    super.initState();
    _currentUserId = LocalSharedPreferences.getId();
    _getdata();
  }

  // Build the User Interface
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
        actions: [
          TextButton(
            child: Text(
              'Save',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600
              )
            ),
            onPressed: (){
              setState(() {
                _updateProfile();
              });
            }, 
          )
        ],
      ),

      body: isLoaded
      ?SingleChildScrollView(
        child: Padding(
          padding:const EdgeInsets.only(top:15, left: 15, right: 15,),
          child: _editProfileForm()
        ),
      )
      :Container(),
      
    );
  }
  
}