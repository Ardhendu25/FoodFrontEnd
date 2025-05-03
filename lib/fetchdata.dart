import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

var serverUrl = dotenv.env["SERVER_URL"];
var urlSignup = "$serverUrl/signup";
var urlLogin = "$serverUrl/login";
var urlAdminLogin = "$serverUrl/adminlogin";
var urlGetName = "$serverUrl/getUserName";
var urlchangePass = "$serverUrl/changePassword";
var urlAuth = "$serverUrl/auth";
var urlUserExist = "$serverUrl/userAlreadyExist";
var urlGetMenuitems = "$serverUrl/GetMenuitems";
var urlGetAdminMenuitems = "$serverUrl/GetAdminMenuitems";
var urlGetMenuitemsGreater = "$serverUrl/GetMenuitemsGreater";
var urlUpdateMenuitems = "$serverUrl/UpdateMenuItems";
var urlDeleteMenuitems = "$serverUrl/DeleteMenuItems";
var urlGetCart = "$serverUrl/GetCarts";
var urlDeleteCart = "$serverUrl/DeleteCart";
var urlMakeOrder = "$serverUrl/MakeOrder";
var urlGetUserOrder = "$serverUrl/GetUserOrders";
var urlGetPendingOrder = "$serverUrl/GetOrders";
var urlGetOrderHistory = "$serverUrl/GetOrderHistory";
var urlGetMenuItemById = "$serverUrl/GetMenuItemById";
var urlGetPopulerItems = "$serverUrl/GetPopulerItems";
var urlGetCategory = "$serverUrl/GetCategory";
var urlUpdateOrder = "$serverUrl/UpdateOrder";
var urlDeleteOrder = "$serverUrl/DeleteOrder";
var urlSearchMenuItems = "$serverUrl/SearchMenuitems";
var urlGetRazorpayOrerId = "$serverUrl/getRazorpayPaymentOrderId";
var urlGetUsersData = "$serverUrl/GetAdminUsers";
var urlEditUsersData = "$serverUrl/EditUser";
var urlDeleteUsersData = "$serverUrl/DeleteUser";
var urlDeleteAdd = "$serverUrl/DeleteAddvertisement";
var urlDeleteCategory = "$serverUrl/DeleteCategory";

var filterTimes = {
  "Evening time": 12 * 60,
  "Dinner time": 21 * 60,
  "Mid-night time": 0
};

Future<void> saveUserData(List<String> data) async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  preferences.setStringList("userfood", data);
}

Future getUserData() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  return preferences.getStringList("userfood");
}

Future deleteUserData() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  preferences.remove("userfood");
}

Future getRozarpayOrderId(data) async {
  /*var user = await getUserData();
  data["userId"] = user[0];*/
  //data["phone"] = "6289625176";

  var response = await http.post(Uri.parse(urlGetRazorpayOrerId),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(data));

  return response;
}

Future uploadData(data, url) async {
  var user = await getUserData();
  data["userId"] = user[0];

  var response = await http.post(Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(data));

  return response;
}

Future EditUserData(data, admin, pass) async {
  var response = await http.post(Uri.parse("$urlEditUsersData/$admin/$pass"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(data));

  return response;
}

Future DeleteUserData(data, admin, pass) async {
  var response = await http.post(Uri.parse("$urlDeleteUsersData/$admin/$pass"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(data));

  return response;
}

Future DeleteAdds(data, admin, pass) async {
  var response = await http.post(Uri.parse("$urlDeleteAdd/$admin/$pass"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(data));

  return response;
}

Future DeleteCategory(data, admin, pass) async {
  var response = await http.post(Uri.parse("$urlDeleteCategory/$admin/$pass"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(data));

  return response;
}

Future getAllUsers() async {
  var response = await http.get(
    Uri.parse("$urlGetUsersData"),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
  );

  return response;
}

Future getUserName() async {
  var user = await getUserData();

  var response = await http.get(
    Uri.parse("$urlGetName/${user[0]}"),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
  );

  return response;
}

Future ChangePassword(phone, pass) async {
  var response = await http.post(
    Uri.parse("$urlchangePass/$phone/$pass"),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
  );

  return response;
}

Future checkUserExist(userId) async {
  var response = await http.get(
    Uri.parse("$urlUserExist/$userId"),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
  );

  return response;
}

Future signUp(data) async {
  var response = await http.post(Uri.parse(urlSignup),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(data));

  return response;
}

Future LogIn(data) async {
  var response = await http.post(Uri.parse(urlAdminLogin),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(data));

  return response;
}

Future Authentication(token) async {
  var response = await http.get(
    Uri.parse(urlAuth),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'authorization': 'Bearer ' + token.toString()
    },
  );

  return response;
}

Future updateMenuItem(data) async {
  var response = await http.post(Uri.parse(urlUpdateMenuitems),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(data));

  return response;
}

Future updateOrderItem(data) async {
  var response = await http.post(Uri.parse(urlUpdateOrder),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(data));

  return response;
}

Future deleteMenuItem(data) async {
  var response = await http.post(Uri.parse(urlDeleteMenuitems),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(data));

  return response;
}

Future getAdvertisementData(url) async {
  var response = await http.get(
    Uri.parse(url),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
  );
  if (response.statusCode == 200) {
    return json.decode(response.body);
  }
  return null;
}

Future getCategory() async {
  var response = await http.get(
    Uri.parse(urlGetCategory),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
  );
  if (response.statusCode == 200) {
    return json.decode(response.body);
  }
  return null;
}

Future getPopulerItems() async {
  var response = await http.get(
    Uri.parse(urlGetPopulerItems),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
  );
  if (response.statusCode == 200) {
    return json.decode(response.body);
  }
  return null;
}

Future getUserOrders(page, limit) async {
  var userId = await getUserData();
  var response = await http.get(
      Uri.parse("$urlGetUserOrder/${userId[0]}/$page/$limit"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      });

  if (response.statusCode == 200) {
    return json.decode(response.body);
  }
  return null;
}

Future getPendingOrders([body]) async {
  if (body == null) body = {};

  var response = await http.post(Uri.parse(urlGetPendingOrder),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(body));
  if (response.statusCode == 200) {
    return json.decode(response.body);
  }
  return null;
}

Future getAllOrders(page, limit, [body]) async {
  if (body == null) body = {};

  var response = await http.post(Uri.parse("$urlGetOrderHistory/$page/$limit"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(body));
  if (response.statusCode == 200) {
    return json.decode(response.body);
  }
  return null;
}

Future deleteOrder(Id) async {
  var response = await http.post(
    Uri.parse("$urlDeleteOrder/$Id"),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
  );

  return response;
}

Future getMenuitemsData(page, limit, category, time, [body]) async {
  if (body == null) body = {};

  var veg = -1;
  var sortby = "Default";
  var timezone = DateTime.now().hour * 60 + DateTime.now().minute;
  //timezone = body[2];
  if (body[3] != "") {
    if (body[3] == "Pure veg")
      veg = 1;
    else
      veg = 0;
  }
  if (body[1] != "") sortby = body[1].toString().replaceAll(" ", "");
  if (body[2] != "") {
    timezone = filterTimes[body[2]]!.toInt();
  }

  var response = await http.post(
    Uri.parse(
        "$urlGetMenuitems/$category/$time/$veg/$timezone/$sortby?page=$page&limit=$limit"),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    //body: jsonEncode(body)
  );
  if (response.statusCode == 200) {
    return json.decode(response.body);
  }
  return null;
}

Future getMenuitemsGreaterData(page, limit, category, time, [body]) async {
  if (body == null) body = {};

  var response = await http.post(
      Uri.parse(
          "$urlGetMenuitemsGreater/$category/$time?page=$page&limit=$limit"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(body));
  if (response.statusCode == 200) {
    return json.decode(response.body);
  }
  return null;
}

Future getMenuitemsById(itemId) async {
  var response = await http.get(
    Uri.parse("$urlGetMenuItemById/$itemId"),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
  );
  if (response.statusCode == 200) {
    return json.decode(response.body);
  }
  return null;
}

Future searchMenuItems(time, page, limit, body) async {
  var response = await http.post(
      Uri.parse("$urlSearchMenuItems/$time?page=$page&limit=$limit"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(body));
  if (response.statusCode == 200) {
    return json.decode(response.body);
  }
  return null;
}

Future getCartData() async {
  var userId = await getUserData();
  var response = await http.get(
    Uri.parse("$urlGetCart/${userId[0]}"),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
  );
  if (response.statusCode == 200) {
    return json.decode(response.body);
  }
  return null;
}

Future deleteCart(userId, itemId) async {
  var userId = await getUserData();
  var response = await http.get(
    Uri.parse("$urlDeleteCart/${userId[0]}/$itemId"),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
  );
  return response;
}

Future makeOrder(items, totalprice, address, paymentStatus, paymentMode) async {
  var userId = await getUserData();
  var data = {
    "userId": userId[0],
    "items": [],
    "paymentStatus": paymentStatus,
    "paymentMode": paymentMode,
    "totalPrice": totalprice,
    "address": address
  };

  for (var i = 0; i < items.length; i++) {
    data['items'].add({
      "id": items[i][0]['_id'],
      "name": items[i][0]['name'],
      "platetype": items[i][0]['plate'],
      "quantity": items[i][0]['count'],
      "image": items[i][0]['image'],
      "price": items[i][0]['price']
    });
  }

  var response = await http.post(Uri.parse(urlMakeOrder),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(data));

  return response;
}

//Admin start...............

Future getAdminMenuitemsData(page, limit, category, time, [body]) async {
  if (body == null) body = {};

  var response = await http.post(
      Uri.parse(
          "$urlGetAdminMenuitems/$category/$time?page=$page&limit=$limit"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(body));
  if (response.statusCode == 200) {
    return json.decode(response.body);
  }
  return null;
}
//Admin end.................
