import 'package:bobfriend/screen/load/loading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:bobfriend/validator/validator.dart';
import 'package:provider/provider.dart';
import '../../provider/user.dart';

class LoginSignupScreen extends StatefulWidget {
  const LoginSignupScreen({Key? key}) : super(key: key);

  @override
  State<LoginSignupScreen> createState() => _LoginSignupScreen();
}

class _LoginSignupScreen extends State<LoginSignupScreen> {
  Duration get loginTime => const Duration(milliseconds: 2250);
  final _authentication = FirebaseAuth.instance;

  void updateUserDatabase(final dynamic data, final dynamic profileUrl, final dynamic univ){
    FirebaseFirestore.instance
        .collection('user')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .set({
      'nickname': data.additionalSignupData!['nickname'],
      'email': data.name,
      'profile_image': profileUrl,
      'univ': univ,
      'temperature': 36.5,
      'friends': [],
      'isRider': false,
      'isDelivering': false,
    });
    FirebaseFirestore.instance
        .collection('user')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('myDelivery').doc('myDelivery').set({
      'riderId': '',
      'restaurantName': '',
      'status': '',
      'deliveryLocation': '',
      'menu': [],
      'price': [],
      'count': [],
      'orderTime': Timestamp.now(),
      'orderId': '',
    });
  }

  Future<String?> setUser(SignupData data) async {
    FirebaseAuth.instance.currentUser!.sendEmailVerification();

    List<String?> parsedEmail = data.name!.split('@');
    String? emailDomain = parsedEmail[1];
    late final String univ;

    if(emailDomain != null){
      if(emailDomain.compareTo('inha.edu.kr') == 0){
        univ = 'inha';
      }
      else if(emailDomain.compareTo('ajou.ac.kr') == 0){
        univ = 'ajou';
      }
    }
    else{
      return '????????? ?????? ???????????? ??????????????????';
    }

    final profileRef = FirebaseStorage.instance
        .ref().child('profile_image')
        .child('basic.jpeg');

    await profileRef.getDownloadURL().then(
            (profileUrl) => updateUserDatabase(data, profileUrl, univ)
    );
    return null;
  }
  Future<String?> _authUser(LoginData data) {
    debugPrint('Name: ${data.name}, Password: ${data.password}');

    return Future.delayed(loginTime).then((_) async {
      try{
        await _authentication.signInWithEmailAndPassword(
          email: data.name,
          password: data.password,
        );

      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          debugPrint('user-not-found');
          return '?????? ???????????? ????????? ???????????? ?????????';
        } else if (e.code == 'wrong-password') {
          debugPrint('wrong-password');
          return '??????????????? ????????????';
        }
        return null;
      }

    });
  }
  Future<String?> _signupUser(SignupData data) {
    debugPrint('?????????: ${data.name}, ????????????: ${data.password}');
    return Future.delayed(loginTime).then((_) async {
      try{
        await _authentication.createUserWithEmailAndPassword(
            email: data.name ?? '',
            password: data.password ?? ''
        ).then((value) => setUser(data));

      } on FirebaseAuthException catch(e){
        if(e.code == 'email-already-in-use'){
          debugPrint('email-already-exits');
          return '?????? ????????? ??????????????????';
        }
      }
      return null;
    });
  }
  Future<String?> _recoverPassword(String name) {
    debugPrint('Name: $name');
    return Future.delayed(loginTime).then((_) async {
      await FirebaseAuth.instance.setLanguageCode("kr");
      await FirebaseAuth.instance.sendPasswordResetEmail(email: name);
      return null;
    });
  }

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTap: (){
        FocusScope.of(context).unfocus();
      },
      child: FlutterLogin(
        theme: LoginTheme(
            primaryColor: Colors.deepOrangeAccent,
            accentColor: Colors.white,
            errorColor: Colors.red
        ),
        title: '?????????',
        onLogin: _authUser,
        onSignup: _signupUser,
        userValidator: emailValidator,
        passwordValidator: passwordValidator,
        onRecoverPassword: _recoverPassword,
        navigateBackAfterRecovery: true,
        userType: LoginUserType.email,
        onSubmitAnimationCompleted: (){
          Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) => LoadingScreen(),
          ));
        },
        messages: LoginMessages(
          userHint: '?????????',
          passwordHint: '????????????',
          loginButton: '?????????',
          signupButton: '????????????',
          forgotPasswordButton: '???????????? ??????',
          recoverPasswordIntro: '?????? ???????????? ??????????????????',
          recoverPasswordButton: '?????? ???????????? ??????',
          goBackButton: '????????????',
          recoverPasswordDescription: '?????? ???????????? ?????? ??????????????? ???????????????',
          recoverPasswordSuccess: '?????? ???????????? ?????? ??????????????? ?????????????????????',
          confirmPasswordHint: '???????????? ??????',
          additionalSignUpSubmitButton: '??????',
          additionalSignUpFormDescription: '???????????? ??????????????????',
          confirmPasswordError: '??????????????? ???????????? ????????????',
          signUpSuccess: '???????????? ??????!',
          flushbarTitleSuccess: '???????????????',
          flushbarTitleError: '??????',
        ),
        additionalSignupFields: const [
          UserFormField(
            keyName: 'nickname',
            displayName: '?????????',
            icon: Icon(Icons.abc_rounded),
            fieldValidator: nicknameValidator,
          )
        ],
      ),
    );
  }
}