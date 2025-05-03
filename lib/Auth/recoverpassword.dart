import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/Auth/otp.dart';
import 'package:frontend/fetchdata.dart';

var APPWRITE_ENDPOINT = dotenv.env["APPWRITE_ENDPOINT"].toString();
var APPWRITE_PROJECT = dotenv.env["APPWRITE_PROJECT"].toString();

final account = Account(Client()
    .setEndpoint(APPWRITE_ENDPOINT.toString())
    .setProject(APPWRITE_PROJECT.toString())
    .setSelfSigned(status: true));

class RecoverPassword extends StatefulWidget {
  const RecoverPassword({super.key});

  @override
  State<RecoverPassword> createState() => _RecoverPasswordState();
}

class _RecoverPasswordState extends State<RecoverPassword> {
  TextEditingController phoneController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController repasswordController = TextEditingController();

  var showPassword = false;
  var phoneError = '';
  var verified = false;
  var passwordError = '';
  var repasserror = '';

  String _validatePassword(String password) {
    // Reset error message
    var _errorMessage = '';
    // Password length greater than 8
    if (password.length < 8) {
      _errorMessage += 'Password must be longer than 8 characters.\n';
    }
    // Contains at least one uppercase letter
    if (!password.contains(RegExp(r'[A-Z]'))) {
      _errorMessage += '• Uppercase letter is missing.\n';
    }
    // Contains at least one lowercase letter
    if (!password.contains(RegExp(r'[a-z]'))) {
      _errorMessage += '• Lowercase letter is missing.\n';
    }
    // Contains at least one digit
    if (!password.contains(RegExp(r'[0-9]'))) {
      _errorMessage += '• Digit is missing.\n';
    }
    // Contains at least one special character
    if (!password.contains(RegExp(r'[!@#%^&*(),.?":{}|<>]'))) {
      _errorMessage += '• Special character is missing.\n';
    }
    // If there are no error messages, the password is valid
    return _errorMessage;
  }

  @override
  void dispose() {
    super.dispose();

    phoneController.dispose();
    passwordController.dispose();
    repasswordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text("Recover Password"),
      ),
      body: Column(
        children: [
          Visibility(
            visible: verified,
            child: Padding(
              padding: EdgeInsets.all(width * 0.1),
              child: TextField(
                controller: passwordController,
                onChanged: (val) {
                  setState(() {
                    passwordError = '';
                  });
                },
                obscureText: !showPassword,
                decoration: InputDecoration(
                    errorText: !passwordError.isEmpty ? passwordError : null,
                    hintText: "New password",
                    suffixIcon: GestureDetector(
                        onTap: () {
                          setState(() {
                            showPassword = !showPassword;
                          });
                        },
                        child: showPassword
                            ? Icon(
                                Icons.visibility,
                                color: Colors.grey,
                              )
                            : Icon(
                                Icons.visibility_off,
                                color: Colors.grey,
                              )),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10))),
              ),
            ),
          ),
          Visibility(
            visible: verified,
            child: Padding(
              padding: EdgeInsets.only(
                  left: width * 0.1, right: width * 0.1, bottom: width * 0.1),
              child: TextField(
                controller: repasswordController,
                onChanged: (val) {
                  setState(() {
                    repasserror = '';
                  });
                },
                obscureText: !showPassword,
                decoration: InputDecoration(
                    errorText: !repasserror.isEmpty ? repasserror : null,
                    hintText: "Re-enter password",
                    suffixIcon: GestureDetector(
                        onTap: () {
                          setState(() {
                            showPassword = !showPassword;
                          });
                        },
                        child: showPassword
                            ? Icon(
                                Icons.visibility,
                                color: Colors.grey,
                              )
                            : Icon(
                                Icons.visibility_off,
                                color: Colors.grey,
                              )),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10))),
              ),
            ),
          ),
          Visibility(
            visible: !verified,
            child: Padding(
              padding: EdgeInsets.all(width * 0.1),
              child: TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                maxLength: 10,
                onChanged: (val) {
                  setState(() {
                    phoneError = '';
                  });
                },
                decoration: InputDecoration(
                    errorText: !phoneError.isEmpty ? phoneError : null,
                    hintText: "Phone",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10))),
              ),
            ),
          ),
          Visibility(
            visible: !verified,
            child: Padding(
              padding: EdgeInsets.all(width * 0.1),
              child: SizedBox(
                height: 40,
                width: width,
                child: ElevatedButton(
                  onPressed: () async {
                    setState(() {
                      if (phoneController.text.length < 10) {
                        phoneError = "Minimum length is 10";
                      }
                    });
                    if (phoneError.isEmpty) {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return Center(child: CircularProgressIndicator());
                          });
                      var res = await checkUserExist(phoneController.text);
                      if (res.statusCode == 200) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("User does not exist")));
                      } else {
                        try {
                          final res = await account.createPhoneToken(
                              userId: ID.unique(),
                              phone: '+91${phoneController.text}');
                          if (!res.userId.isEmpty) {
                            final resv = await Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (context) =>
                                        OtpVerification(res.userId)));

                            try {
                              await account.deleteSessions();
                            } catch (e) {
                              //No active session
                            }
                            if (resv != null && resv) {
                              setState(() {
                                verified = resv;
                              });
                            }
                          }
                          try {
                            await account.deleteSessions();
                          } catch (e) {
                            //No active session
                          }
                        } catch (e) {
                          //print(e);
                          print(e);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(e.toString().contains("limit")
                                  ? "OTP limit exceeded. Try again after sometime"
                                  : "Something went wrong")));
                        }
                      }
                      Navigator.of(context).pop();
                    }
                  },
                  child:
                      Text("Send OTP", style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(187, 16, 130, 230)),
                ),
              ),
            ),
          ),
          Visibility(
            visible: verified,
            child: Padding(
              padding: EdgeInsets.all(width * 0.1),
              child: SizedBox(
                height: 40,
                width: width,
                child: ElevatedButton(
                  onPressed: () async {
                    setState(() {
                      passwordError =
                          _validatePassword(passwordController.text);
                      if (passwordController.text !=
                          repasswordController.text) {
                        repasserror = "Did not match";
                      }
                    });
                    if (passwordError.isEmpty &&
                        passwordController.text == repasswordController.text) {
                      var res = await ChangePassword(
                          phoneController.text, passwordController.text);

                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(res.statusCode == 200
                              ? "Password changed successfully"
                              : "Something went wrong")));
                    }
                  },
                  child: Text("Save", style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(187, 16, 130, 230)),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
