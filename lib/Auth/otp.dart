import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

var APPWRITE_ENDPOINT = dotenv.env["APPWRITE_ENDPOINT"].toString();
var APPWRITE_PROJECT = dotenv.env["APPWRITE_PROJECT"].toString();

final client = Client()
    .setEndpoint(APPWRITE_ENDPOINT.toString())
    .setProject(APPWRITE_PROJECT);
final account = Account(client);

class OtpVerification extends StatefulWidget {
  const OtpVerification(this.userId, {super.key});
  final userId;
  @override
  State<OtpVerification> createState() => _OtpVerificationState();
}

class _OtpVerificationState extends State<OtpVerification> {
  @override
  Widget build(BuildContext context) {
    TextEditingController pinController = TextEditingController();
    final String userId = widget.userId.toString();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
      ),
      body: Container(
          padding: const EdgeInsets.all(50),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Phone Verification",
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
              const Text("An otp has been sent to your phone number"),
              PinCodeTextField(
                controller: pinController,
                appContext: context,
                length: 6,
                obscureText: true,
              ),
              const Text(
                "Enter otp",
                style: TextStyle(fontSize: 20),
              ),
              Container(
                margin: const EdgeInsets.only(top: 20),
                child: ElevatedButton(
                  onPressed: () async {
                    try {
                      await account.deleteSessions();
                    } catch (e) {
                      print(e);
                      //No active session
                    }
                    try {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return Center(child: CircularProgressIndicator());
                          });
                      final res = await account.updatePhoneSession(
                          userId: userId,
                          secret: pinController.text.toString());

                      print("verfied");

                      Navigator.of(context).pop(true);
                      Navigator.of(context).pop(true);
                    } catch (e) {
                      print(e);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(e.toString().contains("limit")
                              ? "Maximum limit exceeded"
                              : "Invalid OTP")));
                      Navigator.of(context).pop(false);
                    }
                  },
                  style: ButtonStyle(
                      fixedSize: WidgetStateProperty.all<Size>(Size(200, 40)),
                      backgroundColor:
                          WidgetStateProperty.all<Color>(Colors.green)),
                  child: const Text(
                    "Verify",
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
              )
            ],
          )),
    );
  }
}
