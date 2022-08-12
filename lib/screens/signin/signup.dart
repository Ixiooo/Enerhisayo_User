import 'package:email_validator/email_validator.dart';
import 'package:enerhisayo/main.dart';
import 'package:enerhisayo/models/LocalSharedPref.dart';
import 'package:enerhisayo/models/UserData.dart';
import 'package:enerhisayo/models/UserProgress.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enerhisayo/utils/utils.dart';
import 'package:flutter/services.dart';
import 'package:enerhisayo/utils/size_helpers.dart';

class SignUp extends StatefulWidget {

  final Function() onClickedSignIn;

  const SignUp({ Key? key, required this.onClickedSignIn }) : super(key: key);

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {

  // Variable Declarations
  final signUpFormKey = GlobalKey<FormState>();  
  final emailController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final ageController = TextEditingController();
  final heightController = TextEditingController();
  final weightController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  String genderDropdown = 'Male';
  String subscriptionDropdown = '1';
  String category = '';

  bool _isPasswordObscure = true;
  bool _isConfirmPasswordObscure = true;

  double bmi=0;

  double _computeBmi(double height, double weight){
    double heightInMeters = height/100;
    double bmi = weight/(heightInMeters * heightInMeters);
    String bmi_rounded = bmi.toStringAsFixed(1);
    return double.parse(bmi_rounded);
  }

  // Sign Up User to Database
  Future _signUp() async{

    final isValid = signUpFormKey.currentState!.validate();

    if (!isValid) return;

    // showDialog(
    //   context: context, 
    //   builder: (context) => const Center(child: CircularProgressIndicator()),
    // );
    
    try{
      

      bmi=_computeBmi(
        double.parse(heightController.text.trim()), 
        double.parse(weightController.text.trim())
      );

      if(bmi >= 25 && bmi <= 29.9){
        category = 'Overweight';
      }else if(bmi >= 30 &&bmi <= 34.9){
        category = 'Obese Class I';
      }else if(bmi >= 35 &&bmi <= 39.9){
        category = 'Obese Class II';
      }else if(bmi >= 40){
        category = 'Obese Class III';
      }else{
        category = 'Not Qualified';
        Utils.showToast('BMI not Qualified');
        return;
      }

      final docUserData = FirebaseFirestore.instance.collection('users').doc();
      final userData = UserData(
        id: docUserData.id,
        email: emailController.text.trim(),
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        gender: genderDropdown,
        age: double.parse(ageController.text.trim()),
        height: double.parse(heightController.text.trim()),
        weight: double.parse(weightController.text.trim()),
        bmi: bmi,
        subscription:double.parse(subscriptionDropdown),
        category: category
      );
      final userDataJson = userData.toJson();
      await docUserData.set(userDataJson);

      final docUserProgressData = FirebaseFirestore.instance.collection('userProgress').doc();
      final userProgressData = UserProgress(
        id: docUserProgressData.id,
        user_id: docUserData.id,
        week: 1,
        day: 1,
        );
      final userProgressDataJson = userProgressData.toJson();
      await docUserProgressData.set(userProgressDataJson);

      
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(), 
        password: passwordController.text.trim(),
      );

      Utils.showToast('Account Registered Successfully');
      await LocalSharedPreferences.setNewAccount(true);

      navigatorKey.currentState!.popUntil((route) => route.isFirst);


    } on FirebaseAuthException catch (e){
      // Utils.showToast(e.message!);
      Utils.showToast('An error occured, please try again later');
    }
    
    // Navigator.of(context).popAndPushNamed(MyHomePage.routeName);
  }

  // Sign up Form Fields
  Widget _signUpForm(){
      return Form(
        key: signUpFormKey,
        child: Column(
          children: [
            
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
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            TextFormField(
              controller: emailController,
              textInputAction: TextInputAction.next,
              enableSuggestions: false,
              keyboardType: TextInputType.visiblePassword,
              decoration: const InputDecoration(
                hintText: 'Email'
              ),
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (email) =>
                  email != null && !EmailValidator.validate(email)
                      ? 'Enter a valid Email'
                      : null,
            ),

            const SizedBox(height: 10),
            
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
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            TextFormField(
              controller: firstNameController,
              textInputAction: TextInputAction.next,
              enableSuggestions: false,
              keyboardType: TextInputType.visiblePassword,
              decoration: const InputDecoration(
                hintText: 'First Name'
              ),
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (firstName) => firstName!.isEmpty ? 'First Name is empty' : null,
            ),

            const SizedBox(height: 10),

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
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            TextFormField(
              controller: lastNameController,
              textInputAction: TextInputAction.next,
              enableSuggestions: false,
              keyboardType: TextInputType.visiblePassword,
              decoration: const InputDecoration(
                hintText: 'Last Name'
              ),
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (lastName) => lastName!.isEmpty ? 'Last Name is empty' : null,
            ),

            const SizedBox(height: 10),

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
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            TextFormField(
              controller: ageController,
              textInputAction: TextInputAction.next,
              enableSuggestions: false,
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                hintText: 'Age'
              ),
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (age) => age!.isEmpty ? 'Age is empty' : null,
            ),

            const SizedBox(height: 10),
            
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
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            DropdownButton<String>(
              isExpanded: true,
              value: genderDropdown,
              elevation: 16,
              style: const TextStyle(color: Colors.black),
              underline: Container(
                height: 2,
                color: Colors.red,
              ),
              onChanged: (String? newValue) {
                setState(() {
                  genderDropdown = newValue!;
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

            const SizedBox(height: 10),

            // Height
            Row(
              children: [
                Column(
                  children: const [
                    Text(
                      'Height (cm)',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            TextFormField(
              controller: heightController,
              textInputAction: TextInputAction.next,
              enableSuggestions: false,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*'))],
              decoration: const InputDecoration(
                hintText: 'Height (cm)'
              ),
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (height) => height!.isEmpty ? 'Height is empty' : null,
            ),

            const SizedBox(height: 10),

            // Weight
            Row(
              children: [
                Column(
                  children: const [
                    Text(
                      'Weight (kg)',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            TextFormField(
              controller: weightController,
              textInputAction: TextInputAction.next,
              enableSuggestions: false,
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                hintText: 'Weight (kg)'
              ),
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (weight) => weight!.isEmpty ? 'Weight is empty' : null,
            ),

            const SizedBox(height: 10),
            
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
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            DropdownButton<String>(
              isExpanded: true,
              value: subscriptionDropdown,
              elevation: 16,
              style: const TextStyle(color: Colors.black),
              underline: Container(
                height: 2,
                color: Colors.red,
              ),
              onChanged: (String? newValue) {
                setState(() {
                  subscriptionDropdown = newValue!;
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

            //Password
            Row(
              children: [
                Column(
                  children: const [
                    Text(
                      'Password',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            TextFormField(
              controller: passwordController,
              textInputAction: TextInputAction.next,
              decoration:  InputDecoration(
                hintText: 'Password',
                suffixIcon: IconButton(
                  icon:  _isPasswordObscure ? Icon(Icons.visibility) : Icon(Icons.visibility_off),
                  splashColor: Colors.red[200],
                  splashRadius: 20,
                  color: Colors.red,
                  onPressed: (){
                    setState(() {
                      _isPasswordObscure = !_isPasswordObscure;
                    });
                  },
                ),
                
              ),
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (password) =>
                  password!.isEmpty ? 'Password is empty' : 
                  password != confirmPasswordController.text ? 'Passwords do not match' : null,
              obscureText: _isPasswordObscure,
            ),
           
            const SizedBox(height: 10),
            
            //Confirm Password
            Row(
              children: [
                Column(
                  children: const [
                    Text(
                      'Confirm Password',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            TextFormField(
              controller: confirmPasswordController,
              textInputAction: TextInputAction.done,
              decoration:  InputDecoration(
                hintText: 'Confirm Password',
                suffixIcon: IconButton(
                  icon:  _isConfirmPasswordObscure ? Icon(Icons.visibility) : Icon(Icons.visibility_off),
                  splashColor: Colors.red[200],
                  splashRadius: 20,
                  color: Colors.red,
                  onPressed: (){
                    setState(() {
                      _isConfirmPasswordObscure = !_isConfirmPasswordObscure;
                    });
                  },
                ),
                
              ),
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (confirmPassword) => 
                  confirmPassword!.isEmpty ? 'Confirm Password is empty' : 
                  confirmPassword != passwordController.text ? 'Passwords do not match' : null,
              obscureText: _isConfirmPasswordObscure,
            ),
           
            const SizedBox(height: 25),

            Center(
              child: SizedBox(
                height: 40,
                width: displayWidth(context) / 2,
                child: ElevatedButton.icon(
                    style: ButtonStyle(
                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.0),
                    ))),
                    onPressed: () {
                      if(signUpFormKey.currentState!.validate()){
                        _signUp();
                        FocusScope.of(context).unfocus();
                      }
                      else{
                        Utils.showToast('Fill up necessary fields correctly');
                        FocusScope.of(context).unfocus();
                      }
                    },
                    icon: const Icon(Icons.lock_open),
                    label: const Text('Sign Up')),
              ),
            ),
            
          ],
        ),
      );
    }

  // Delete data when the screen closes
  void dispose(){
    emailController.dispose();
    passwordController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    ageController.dispose();
    heightController.dispose();
    weightController.dispose();
    confirmPasswordController.dispose();

    super.dispose();
  }

  // Build the UI
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      resizeToAvoidBottomInset: true,

      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 70,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: const [
            Image(
            image: AssetImage('assets/logo.png'),
                width: 60, height: 60,
            fit: BoxFit.cover),
            Text(
              'ENERHISAYO',
              style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w900,
                  fontSize: 24),
            ),
          ],
        ),
        actions: [],
      ),
      
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(left: 30, right: 30, bottom: 45),
        child: Column(children: [

          SizedBox(
            child: Image(
              image: const AssetImage('assets/register_icon.png'),
              height: 200,
              width: displayWidth(context),
              fit: BoxFit.contain,
            ),
          ),

          const Text(
            'Create Your Account',
            style: TextStyle(
              fontWeight: FontWeight.w600, 
              fontSize: 22,
              color: Colors.black87,
              ),
          ),
          
          const SizedBox(height: 15),

          _signUpForm(),
          
          const SizedBox(height: 30),

          RichText(
              text: TextSpan(
                  text: 'Already have an account?   ',
                  style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w400),
                  children: [
                TextSpan(
                    recognizer: TapGestureRecognizer()
                      ..onTap = widget.onClickedSignIn,
                    text: 'Login',
                    style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w600)
                  )
              ])
          )

        ]),
      ),
    );
  }
}