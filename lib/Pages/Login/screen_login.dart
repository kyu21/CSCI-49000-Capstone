import 'package:flutter/material.dart';

import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:google_fonts/google_fonts.dart';

class ScreenLogin extends StatelessWidget {
  // Controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      backgroundColor: Colors.black,
      body: Container(
        alignment: Alignment.topCenter,
        margin: EdgeInsets.symmetric(
          horizontal: 30,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Local Helper',
                textAlign: TextAlign.center,
                style: GoogleFonts.openSans(
                  color: Colors.white,
                  fontSize: 50,
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Enter your email and password below.',
                textAlign: TextAlign.center,
                style: GoogleFonts.openSans(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 125),
              _buildTextField(
                nameController,
                Icons.account_circle,
                'Username',
              ),
              SizedBox(height: 20),
              _buildTextField(
                passwordController,
                Icons.lock,
                'Password',
              ),
              SizedBox(height: 30),
              MaterialButton(
                elevation: 0,
                minWidth: double.maxFinite,
                height: 50,
                onPressed: () {},
                color: Colors.green,
                child: Text(
                  'Login',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                textColor: Colors.white,
              ),
              SizedBox(height: 20),
              SignInButton(
                Buttons.Google,
                text: 'Sign up with Google',
                padding: EdgeInsets.symmetric(
                  horizontal: 60,
                  vertical: 10,
                ),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }

// Built in functions

  _buildTextField(
      TextEditingController controller, IconData icon, String labelText) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: Colors.blue,
        ),
      ),
      child: TextField(
        controller: controller,
        style: TextStyle(
          color: Colors.black,
        ),
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(
            horizontal: 10,
          ),
          labelText: labelText,
          labelStyle: TextStyle(
            color: Colors.black,
          ),
          icon: Icon(
            icon,
            color: Colors.black,
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
