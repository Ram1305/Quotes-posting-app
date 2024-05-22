import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kavithaiquote/login.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  bool _isUsernameValid = true;

  bool _isEmailValid = true;
  bool _isPasswordValid = true;
  bool _isConfirmPasswordValid = true;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _signUpInProgress = false;
  String? _passwordErrorText;
  void _validateUsername(String username) {
    final usernameRegExp = RegExp(r'^[a-zA-Z]+$');
    setState(() {
      _isUsernameValid = usernameRegExp.hasMatch(username);
    });
  }

  void _validateEmail(String email) {
    final emailRegExp = RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$');
    setState(() {
      _isEmailValid = emailRegExp.hasMatch(email);
    });
  }

  void _validatePassword(String password) {
    final passwordRegExp =
        RegExp(r'^(?=.*[A-Z])(?=.*[a-z])(?=.*[0-9])(?=.*[\W_]).{8,}$');
    setState(() {
      _isPasswordValid =
          password.isNotEmpty && passwordRegExp.hasMatch(password);
    });

    if (password.isNotEmpty) {
      if (!passwordRegExp.hasMatch(password)) {
        setState(() {
          _passwordErrorText = ' please enter your password';
        });
      } else {
        setState(() {
          _passwordErrorText = ' password must be 8 characters';
        });
      }
    } else {
      setState(() {
        _passwordErrorText = 'Password  okk';
      });
    }
  }

  void _validateConfirmPassword(String confirmPassword) {
    setState(() {
      _isConfirmPasswordValid = _passwordController.text == confirmPassword;
    });
  }

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  void _toggleConfirmPasswordVisibility() {
    setState(() {
      _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
    });
  }

  Future<void> _signUpWithEmailAndPassword(
    String username,
    String email,
    String password,
    String confirmPassword,
  ) async {
    setState(() {
      _signUpInProgress = true;
    });
    try {
      FirebaseAuth _auth = FirebaseAuth.instance;
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        String uid = userCredential.user!.uid;
        await _saveUserDataToFirestore(
          uid,
          username,
          email,
          password,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sign up successful!'),
            duration: Duration(seconds: 3),
          ),
        );

        // Navigate to login screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      }
    } catch (e) {
      // Show error message using a SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Email or Password is wrong or already registered?.'),
          duration: Duration(seconds: 3),
        ),
      );

      print('Error signing up: $e');
    } finally {
      setState(() {
        _signUpInProgress = false;
      });
    }
  }

  Future<void> _saveUserDataToFirestore(
      String uid, String username, String email, String password) async {
    try {
      await FirebaseFirestore.instance.collection('user').doc(uid).set({
        'uid': uid,
        'username': username,
        'email': email,
        'password': password,
      });
      print('User data saved to Firestore: $email, $password');
    } catch (e) {
      print('Error saving user data to Firestore: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: 80,
              ),
              ClipPath(
                clipper: MyClipper(), // Custom clipper for curve effect
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(45.0),
                  ),
                  child: Image.asset(
                    "assets/hi.png",
                    height: 250,
                    width: 600,
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Text('Sign Up',
                  style: TextStyle(
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                    color: Colors.lightBlueAccent,
                  )),
              SizedBox(
                height: 20,
              ),
              TextField(
                controller: _usernameController,
                onChanged: _validateUsername,
                decoration: InputDecoration(
                  labelText: 'Username',
                  labelStyle: TextStyle(
                    color: Colors.lightBlueAccent,
                  ),
                  errorText: _isUsernameValid
                      ? null
                      : 'Please enter your username', // Display error text if not valid
                  prefixIcon: Icon(
                    Icons.person,
                    color: Colors.lightBlueAccent,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(45.0),
                    borderSide: BorderSide(
                      color: Colors.lightBlueAccent,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 12,
              ),
              TextField(
                keyboardType: TextInputType.emailAddress,
                controller: _emailController,
                onChanged: _validateEmail,
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(
                    color: Colors.lightBlueAccent,
                  ),
                  prefixIcon: Icon(
                    Icons.email,
                    color: Colors.lightBlueAccent,
                  ),
                  errorText: _isEmailValid
                      ? null
                      : 'Please enter a valid email (e.g., abc@gmail.com).',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(45.0),
                    borderSide: BorderSide(
                        color: Colors.lightBlueAccent), // Outline border color
                  ),
                ),
              ),
              SizedBox(height: 22),
              TextField(
                controller: _passwordController,
                onChanged: _validatePassword,
                obscureText: !_isPasswordVisible,
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: TextStyle(
                    color: Colors.lightBlueAccent,
                  ),
                  prefixIcon: Icon(
                    Icons.lock,
                    color: Colors.lightBlueAccent,
                  ),
                  errorText: _isPasswordValid
                      ? null
                      : 'Password must contain one uppercase letter, one lowercase letter, one digit, and one special character.',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(45.0),
                    borderSide: BorderSide(
                        color: Colors.lightBlueAccent), // Outline border color
                  ),
                  suffixIcon: IconButton(
                    onPressed: _togglePasswordVisibility,
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.lightBlueAccent,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 22),
              TextField(
                controller: _confirmPasswordController,
                onChanged: _validateConfirmPassword,
                obscureText: !_isConfirmPasswordVisible,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  labelStyle: TextStyle(
                    color: Colors.lightBlueAccent,
                  ),
                  errorText:
                      _isConfirmPasswordValid ? null : 'Passwords do not match',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(45.0),
                    borderSide: BorderSide(
                        color: Colors.lightBlueAccent), // Outline border color
                  ),
                  prefixIcon: Icon(
                    Icons.lock,
                    color: Colors.lightBlueAccent,
                  ),
                  suffixIcon: IconButton(
                    onPressed: _toggleConfirmPasswordVisibility,
                    icon: Icon(
                      _isConfirmPasswordVisible
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.lightBlueAccent,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _signUpInProgress
                    ? null
                    : () {
                        if (_usernameController.text.isEmpty) {
                          setState(() {
                            _isUsernameValid = false;
                          });
                        }
                        if (_emailController.text.isEmpty) {
                          setState(() {
                            _isEmailValid = false;
                          });
                        }
                        if (_passwordController.text.isEmpty) {
                          setState(() {
                            _isPasswordValid = false;
                          });
                        }

                        if (_confirmPasswordController.text.isEmpty) {
                          setState(() {
                            _isConfirmPasswordValid = false;
                          });
                        } else {
                          _signUpWithEmailAndPassword(
                            _usernameController.text,
                            _emailController.text,
                            _passwordController.text,
                            _confirmPasswordController.text,
                          );
                        }
                      },
                style: ElevatedButton.styleFrom(
                  primary: Colors.lightBlueAccent, // Background color
                  onPrimary: Colors.white, // Text color
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30), // Rounded corners
                  ),
                  elevation: 3, // Shadow elevation
                ),
                child: Text(
                  'Sign Up',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                alignment: Alignment.bottomRight,
                child: GestureDetector(
                  onTap: () {
                    // Navigate to login screen
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                    );
                  },
                  child: Text('Already have an account? -->',
                      style: TextStyle(
                        color: Colors.lightBlueAccent,
                        fontSize: 16,
                      )),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MyClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 50);
    path.quadraticBezierTo(
        size.width / 2, size.height, size.width, size.height - 50);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
