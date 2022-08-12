import 'package:flutter/material.dart';
import 'package:enerhisayo/screens/signin/login.dart';
import 'package:enerhisayo/screens/signin/signup.dart';


class AuthPage extends StatefulWidget {
  static const routeName = '/auth_page';

  const AuthPage({ Key? key }) : super(key: key);

  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool isLogin = true;
  @override
  Widget build(BuildContext context) => isLogin 
                                      ? Login(onClickedSignUp: toggle)
                                      : SignUp(onClickedSignIn: toggle);

    void toggle() => setState(() => isLogin = !isLogin);
  }
