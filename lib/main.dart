import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/Admin/admin_navigation.dart';
import 'package:frontend/Auth/login.dart';
import 'package:frontend/fetchdata.dart';

class MyService {
  Future<bool> asyncInit() async {
    var user = await getUserData();
    if (user != null) {
      var res = await Authentication(user[1]);
      if (res.statusCode == 200) {
        return true;
      }
    }
    return false;
  }
}

void main() async {
  await dotenv.load(fileName: ".env");

  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
  ));

  runApp(FutureBuilder(
    future: MyService().asyncInit(),
    builder: (_, snap) {
      if (snap.connectionState == ConnectionState.done && snap.data != null) {
        var check = false;

        if (snap.data != null) {
          check = snap.data as bool;
        }

        return MaterialApp(
            debugShowCheckedModeBanner: false,
            initialRoute: "login",
            theme: ThemeData(scaffoldBackgroundColor: Colors.white),
            routes: {
              "login": (context) => Login(),
              "admin": (context) => AdminNavigation()
            });
      }
      return Container(
          color: Colors.white,
          alignment: Alignment.center,
          child: CircularProgressIndicator(
            strokeWidth: 2,
          ));
    },
  ));
}
