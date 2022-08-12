import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:enerhisayo/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:enerhisayo/utils/utils.dart';
import 'package:enerhisayo/utils/size_helpers.dart';

class Login extends StatefulWidget {
  final VoidCallback onClickedSignUp;

  const Login({Key? key, required this.onClickedSignUp}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {

  // Variable Declarations
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final loginFormKey = GlobalKey<FormState>();
  String errorMessage = '';
  bool _isObscure = true;
  
  // Check if Credentials is for Admin
  Future<bool> checkIfDocExists(String email) async {
    try {
      // Get reference to Firestore collection
      var collectionRef = FirebaseFirestore.instance.collection('admin');

      var doc = await collectionRef.where('email', isEqualTo: email).get();

      return doc.docs.isNotEmpty;

    } catch (e) {
      throw e;
    }
  }

  // Sign in User to Database
  Future signIn() async {

    bool userExists = await checkIfDocExists(emailController.text.trim());

    if(!userExists){

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Container(height: displayHeight(context), child: const Center(child: CircularProgressIndicator())),
      );

      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim());
      } on FirebaseAuthException catch (e) {
        switch (e.code) {
          case "invalid-email":
            errorMessage = "Please enter a correct email.";
            break;
          case "user-not-found":
            errorMessage = "No records found.";
            break;
          case "wrong-password":
            errorMessage = "Password is incorrect.";
            break;
          case "user-disabled":
            errorMessage = "User with this email has been disabled.";
            break;
          default:
            errorMessage = "An error occured, please try again";
        }
        Utils.showToast(errorMessage);
      }
    
      navigatorKey.currentState!.popUntil((route) => route.isFirst);

    }else{
      Utils.showToast('User Credentials Invalid');
    }
  }

  // Login Form Fields
  Widget _loginForm() {
    return Form(
      key: loginFormKey,
      child: Column(
        children: [
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
                hintText: 'Enter Your Email',
                suffixIcon: Icon(
                  Icons.email,
                  color: Colors.red,
                )),
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (email) =>
                email != null && !EmailValidator.validate(email)
                    ? 'Enter a valid Email'
                    : null,
          ),
          const SizedBox(height: 10),
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
            textInputAction: TextInputAction.done,
            enableSuggestions: false,
            decoration: InputDecoration(
              hintText: 'Enter Your Password',
              suffixIcon: IconButton(
                icon: _isObscure
                    ? Icon(Icons.visibility)
                    : Icon(Icons.visibility_off),
                splashColor: Colors.red[200],
                splashRadius: 20,
                color: Colors.red,
                onPressed: () {
                  setState(() {
                    _isObscure = !_isObscure;
                  });
                },
              ),
            ),
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (password) =>
                password!.isEmpty ? 'Password is empty' : null,
            obscureText: _isObscure,
          ),
          const SizedBox(height: 20),
          Center(
            child: SizedBox(
              height: 40,
              width: displayWidth(context) / 2,
              child: ElevatedButton.icon(
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                      ),
                    ),
                  ),
                  onPressed: () {
                    if (loginFormKey.currentState!.validate()) {
                      signIn();
                      FocusScope.of(context).unfocus();
                    } else {
                      Utils.showToast('Fill up necessary fields correctly');
                      FocusScope.of(context).unfocus();
                    }
                  },
                  icon: const Icon(Icons.lock_open),
                  label: const Text('Sign In')),
            ),
          ),
        ],
      ),
    );
  }

  // Delete data when the screen closes
  void dispose() {
    emailController.dispose();
    passwordController.dispose();

    super.dispose();
  }

  // Build the UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(left: 30, right: 30, bottom: 45),
          child: Column(children: [
            SizedBox(
              child: Image(
                image: const AssetImage('assets/login_icon.png'),
                height: 200,
                width: displayWidth(context),
                fit: BoxFit.contain,
              ),
            ),
            const Text(
              'Welcome Back!',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 22,
                color: Colors.black87,
              ),
            ),
            const Text(
              'Login and Let\s Exercise',
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w400,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 15),
            _loginForm(),
            const SizedBox(height: 35),
            RichText(
                text: TextSpan(
                    text: 'Don\'t have an account?   ',
                    style: const TextStyle(
                        color: Colors.black, fontWeight: FontWeight.w400),
                    children: [
                  TextSpan(
                      recognizer: TapGestureRecognizer()
                        ..onTap = widget.onClickedSignUp,
                      text: 'Sign up Now!',
                      style: const TextStyle(
                          color: Colors.red, fontWeight: FontWeight.w600))
                ]))
          ]),
        ),
      ),
    );
  }
}
