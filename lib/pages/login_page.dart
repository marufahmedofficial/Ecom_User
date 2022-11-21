import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';

import '../auth/authservice.dart';
import '../models/user_model.dart';
import '../providers/user_provider.dart';
import 'launcher_page.dart';

class LoginPage extends StatefulWidget {
  static const String routeName = '/login';

  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _errMsg = '';
  late UserProvider userProvider;

  @override
  void didChangeDependencies() {
    userProvider = Provider.of<UserProvider>(context, listen: false);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(24),
            shrinkWrap: true,
            children: [
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                      filled: true,
                      prefixIcon: Icon(Icons.email),
                      labelText: 'Email Address'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Provide a valid email address';
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: TextFormField(
                  controller: _passwordController,
                  //obscureText: true,
                  decoration: const InputDecoration(
                      filled: true,
                      prefixIcon: Icon(Icons.lock),
                      labelText: 'Password(at least 6 characters)'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Provide a valid password';
                    }
                    return null;
                  },
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  _authenticate(true);
                },
                child: const Text('Login'),
              ),
              TextButton.icon(
                icon: const Icon(
                  Icons.g_mobiledata,
                  size: 30,
                ),
                onPressed: _signInWithGoogle,
                label: const Text('Sign In with Google'),
              ),
              Row(
                children: [
                  const Text('New User?'),
                  TextButton(
                    onPressed: () {
                      _authenticate(false);
                    },
                    child: const Text('Register'),
                  ),
                ],
              ),
              Row(
                children: [
                  const Text(
                    'Forgot password',
                    style: TextStyle(fontSize: 18, color: Colors.red),
                  ),
                  TextButton(
                    onPressed: () {
                      AuthService.forgotPassword();
                    },
                    child: const Text('Click Here'),
                  ),
                ],
              ),
              OutlinedButton(
                onPressed: () {
                  _loginAsGuest();
                },
                child: const Text('Login as Guest'),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  _errMsg,
                  style: const TextStyle(fontSize: 18, color: Colors.red),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _authenticate(bool tag) async {
    if (_formKey.currentState!.validate()) {
      EasyLoading.show(status: 'Please wait', dismissOnTap: false);
      final email = _emailController.text;
      final password = _passwordController.text;
      try {
        UserCredential credential;
        if (tag) {
          credential = await AuthService.login(email, password);
        } else {
          credential = await AuthService.register(email, password);
          final userModel = UserModel(
            userId: credential.user!.uid,
            email: credential.user!.email!,
            userCreationTime:
            Timestamp.fromDate(credential.user!.metadata.creationTime!),
          );
          await userProvider.addUser(userModel);
        }
        EasyLoading.dismiss();
        if (mounted) {
          Navigator.pushReplacementNamed(context, LauncherPage.routeName);
        }
      } on FirebaseAuthException catch (error) {
        EasyLoading.dismiss();
        setState(() {
          _errMsg = error.message!;
        });
      }
    }
  }

  void _signInWithGoogle() async {
    try {
      final credential = await AuthService.signInWithGoogle();
      final userExists = await userProvider.doesUserExist(credential.user!.uid);
      if (!userExists) {
        EasyLoading.show(status: 'Redirecting...');
        final userModel = UserModel(
          userId: credential.user!.uid,
          email: credential.user!.email!,
          displayName: credential.user!.displayName,
          imageUrl: credential.user!.photoURL,
          phone: credential.user!.phoneNumber,
          userCreationTime: Timestamp.fromDate(DateTime.now()),
        );
        await userProvider.addUser(userModel);
        EasyLoading.dismiss();
      }
      if (mounted) {
        Navigator.pushReplacementNamed(context, LauncherPage.routeName);
      }
    } catch (error) {
      EasyLoading.dismiss();
      rethrow;
    }
  }

  void _loginAsGuest() {
    EasyLoading.show(status: 'Please Wait');
    AuthService.loginAsGuest().then((value) {
      EasyLoading.dismiss();
      Navigator.pushReplacementNamed(context, LauncherPage.routeName);
    }).catchError((error) {
      EasyLoading.dismiss();
    });
  }
}