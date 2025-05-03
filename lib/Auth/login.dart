import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:frontend/Admin/admin_navigation.dart';
import 'package:frontend/Auth/recoverpassword.dart';
import 'package:frontend/fetchdata.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}
// ignore_for_file: prefer_const_constructors

class _LoginState extends State<Login> {
  var submitted = false;
  TextEditingController phoneController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  @override
  void dispose() {
    super.dispose();

    phoneController.dispose();
    passwordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    errorText() {
      if (submitted) {
        if (phoneController.text.isEmpty) {
          return "Input is required";
        } else if (phoneController.text.length < 10) {
          return "Must be of length 10";
        }
      }
      return null;
    }

    errorTextPassword() {
      if (submitted) {
        if (passwordController.text.isEmpty) {
          return "Input is required";
        }
      }
      return null;
    }

    return SafeArea(
      child: Scaffold(
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(0.0),
            child: Container(),
          ),
          body: Stack(
            alignment: Alignment.center,
            children: [
              Visibility(
                visible: width > 800,
                child: Image.asset(
                  color: Colors.black.withOpacity(0.5),
                  "assets/images/FoodBackgroundImage.png",
                  width: width,
                  height: height,
                  fit: BoxFit.cover,
                  colorBlendMode: BlendMode.darken,
                ),
              ),
              Visibility(
                visible: width <= 800,
                child: Container(
                  color: Color.fromARGB(156, 7, 255, 164),
                  width: width,
                  height: height,
                  alignment: Alignment.topRight,
                  padding: EdgeInsets.only(top: 10, right: 10),
                  child: Text(
                    "Login",
                    style: TextStyle(
                        fontSize: 30,
                        color: Colors.white,
                        decoration: TextDecoration.none),
                  ),
                ),
              ),
              Container(
                //margin: EdgeInsets.only(top: 100),
                padding: EdgeInsets.all(min(500, width) * 0.1),
                width: min(500, width),
                height: width <= 800 ? height : 600,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: width <= 800
                        ? BorderRadius.only(topRight: Radius.circular(width))
                        : BorderRadius.all(Radius.circular(20))),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                        alignment: Alignment.centerLeft,
                        padding: EdgeInsets.only(bottom: 40),
                        child: Text(
                          "BECC Admin",
                          style: TextStyle(fontSize: 30, color: Colors.red),
                        )),
                    TextField(
                      maxLength: 10,
                      keyboardType: TextInputType.phone,
                      controller: phoneController,
                      decoration: InputDecoration(
                          errorText: errorText(),
                          hintText: "Phone",
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10))),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                          errorText: errorTextPassword(),
                          hintText: "Password",
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10))),
                    ),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 100,
                          ),
                          TextButton(
                              style: ButtonStyle(
                                  overlayColor: WidgetStateProperty.all<Color>(
                                      Colors.white)),
                              onPressed: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => RecoverPassword()));
                              },
                              child: Text(
                                "forgot password",
                              )),
                        ]),
                    SizedBox(
                      height: 40,
                    ),
                    SizedBox(
                      height: 40,
                      width: width,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (phoneController.text.isEmpty ||
                              phoneController.text.length < 10 ||
                              passwordController.text.isEmpty) {
                            setState(() {
                              submitted = true;
                            });
                            return;
                          }
                          setState(() {
                            submitted = false;
                          });
                          showDialog(
                              context: context,
                              builder: (context) {
                                return Center(
                                    child: CircularProgressIndicator());
                              });
                          var res = await LogIn({
                            "username": phoneController.text,
                            "password": passwordController.text,
                          });
                          Navigator.of(context).pop();
                          if (res.statusCode == 200) {
                            await saveUserData([
                              phoneController.text,
                              jsonDecode(res.body)["token"]
                            ]);

                            Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                    builder: (context) => AdminNavigation()),
                                (Route<dynamic> route) => false);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text(res.statusCode == 400
                                    ? "Incorrect username or password"
                                    : "Something went wrong")));
                          }
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromARGB(187, 16, 130, 230)),
                        child: Text(
                          "Login",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          )),
    );
  }
}
