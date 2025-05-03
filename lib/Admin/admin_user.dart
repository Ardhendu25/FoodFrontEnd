import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend/fetchdata.dart';
import 'package:intl/intl.dart';

class AdminUser extends StatefulWidget {
  const AdminUser({super.key});

  @override
  State<AdminUser> createState() => _AdminUserState();
}

class _AdminUserState extends State<AdminUser> {
  List data = [];

  getUsersData() async {
    var res = await getAllUsers();
    if (res.statusCode == 200) {
      setState(() {
        data = jsonDecode(res.body) as List;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getUsersData();
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;

    var columns = [
      "Index",
      "Delete",
      "Edit",
      "ID",
      "name",
      "username",
      "password",
      "createdAt",
      "updatedAt"
    ];
    var query = columns[0];
    var val = "";
    var colindex = 0;

    return Scaffold(
      appBar: AppBar(
        title: Text("Users Data"),
        backgroundColor: Colors.white,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 10, right: 10, left: 10),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      margin: EdgeInsets.all(10),
                      height: 40,
                      alignment: Alignment.center,
                      child: Text(
                        "Total: ${data.length}",
                        style: TextStyle(color: Colors.white),
                      )),
                  Container(
                    margin: const EdgeInsets.all(10),
                    child: DropdownButton(
                        //enableFilter: true,
                        value: query,
                        onChanged: (value) {
                          setState(() {
                            query = value as String;
                          });
                        },
                        items: columns.map((item) {
                          return DropdownMenuItem(
                              value: item == "Edit" ? "None" : item,
                              child: Text(item == "Edit" ? "None" : item));
                        }).toList()),
                  ),
                  Container(
                    width: 200,
                    padding: EdgeInsets.all(10),
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          val = value;
                        });
                      },
                      decoration: InputDecoration(
                          hintText: "Search",
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10))),
                    ),
                  ),
                  TextButton(
                      style: ButtonStyle(
                          backgroundColor:
                              WidgetStateProperty.all<Color>(Colors.green)),
                      onPressed: () {
                        getUsersData();
                      },
                      child: Text(
                        "Refresh",
                        style: TextStyle(color: Colors.white),
                      )),
                ],
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Stack(
                children: [
                  SingleChildScrollView(
                    //scrollDirection: Axis.horizontal,
                    controller: new ScrollController(),
                    padding: const EdgeInsets.only(left: 10),
                    child: DataTable(
                        showCheckboxColumn: false,
                        //key: Key(change.toString()),
                        headingRowColor: WidgetStateProperty.all<Color>(
                            Color.fromARGB(31, 96, 164, 242)),
                        columns: columns.map((item) {
                          return DataColumn(
                              onSort: (columnIndex, ascending) => {
                                    setState(() {
                                      data.sort((a, b) =>
                                          a[columns[columnIndex]].compareTo(
                                              b[columns[columnIndex]]));
                                    })
                                  },
                              label: Container(width: 100, child: Text(item)));
                        }).toList(),
                        rows: data.asMap().entries.map((item) {
                          var col = false;
                          return DataRow(
                              onSelectChanged: (value) {
                                setState(() {
                                  col = !col;
                                });
                              },
                              color: WidgetStateProperty.resolveWith<Color?>(
                                  (Set<WidgetState> states) {
                                if (states.contains(WidgetState.hovered)) {
                                  return Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withOpacity(0.09);
                                }

                                return null;
                              }),
                              cells: [
                                DataCell(Container(
                                    width: 100,
                                    child: Text(item.key.toString()))),
                                DataCell(Container(
                                    width: 100,
                                    child: TextButton(
                                        style: ButtonStyle(
                                            alignment: Alignment.center,
                                            backgroundColor:
                                                WidgetStateProperty.all<Color>(
                                                    Colors.green)),
                                        onPressed: () async {
                                          await showDialog(
                                              context: context,
                                              builder: (context) {
                                                return StatefulBuilder(
                                                    builder: (context,
                                                            setState) =>
                                                        AlertDialog(
                                                          scrollable: true,
                                                          title: Text(
                                                              "Delete User"),
                                                          content: DeleteUser(
                                                            user: item.value,
                                                          ),
                                                        ));
                                              });
                                        },
                                        child: Text(
                                          "Delete",
                                          style: TextStyle(color: Colors.white),
                                        )))),
                                DataCell(Container(
                                    width: 100,
                                    child: TextButton(
                                        style: ButtonStyle(
                                            alignment: Alignment.center,
                                            backgroundColor:
                                                WidgetStateProperty.all<Color>(
                                                    Colors.green)),
                                        onPressed: () async {
                                          await showDialog(
                                              context: context,
                                              builder: (context) {
                                                return StatefulBuilder(
                                                    builder: (context,
                                                            setState) =>
                                                        AlertDialog(
                                                          scrollable: true,
                                                          title:
                                                              Text("Edit User"),
                                                          content: EditUser(
                                                            user: item.value,
                                                          ),
                                                        ));
                                              });
                                        },
                                        child: Text(
                                          "Edit",
                                          style: TextStyle(color: Colors.white),
                                        )))),
                                DataCell(Container(
                                    width: 100,
                                    child: SelectableText(
                                        "${item.value["_id"]}"))),
                                DataCell(Container(
                                    width: 100,
                                    child: SelectableText(
                                        "${item.value["name"]}"))),
                                DataCell(Container(
                                    width: 100,
                                    child: SelectableText(
                                        "${item.value["username"]}"))),
                                DataCell(Container(
                                    width: 100,
                                    child: SelectableText(
                                        "${item.value["password"]}"))),
                                DataCell(Container(
                                    width: 100,
                                    child: SelectableText(
                                        "${DateFormat("dd-MM-yyyy").format(DateTime.parse(item.value["createdAt"].toString()).toLocal())} at ${DateFormat('hh:mm a').format(DateTime.parse(item.value["createdAt"].toString()).toLocal())}"))),
                                DataCell(Container(
                                    width: 100,
                                    child: SelectableText(
                                        "${DateFormat("dd-MM-yyyy").format(DateTime.parse(item.value["updatedAt"].toString()).toLocal())} at ${DateFormat('hh:mm a').format(DateTime.parse(item.value["updatedAt"].toString()).toLocal())}"))),
                              ]);
                        }).toList()),
                  ),
                  SingleChildScrollView(
                      padding: const EdgeInsets.only(left: 10),
                      child: DataTable(
                          headingRowColor: WidgetStateProperty.all<Color>(
                              Color.fromARGB(255, 60, 172, 227)),
                          columns: columns.map((item) {
                            int sortstate = 1;
                            return DataColumn(
                                onSort: (columnIndex, ascending) => {
                                      setState(() {
                                        colindex = columnIndex;
                                      }),
                                      if (columns[columnIndex] != "veg" &&
                                          columns[columnIndex] != "Edit" &&
                                          columns[columnIndex] != "special" &&
                                          columns[columnIndex] != "ID")
                                        {
                                          setState(() {
                                            if (sortstate == 0) {
                                              data.sort((a, b) {
                                                return a[columns[columnIndex]]
                                                    .compareTo(b[
                                                        columns[columnIndex]]);
                                              });
                                            } else if (sortstate == 1) {
                                              data.sort((a, b) {
                                                return b[columns[columnIndex]]
                                                    .compareTo(a[
                                                        columns[columnIndex]]);
                                              });
                                            }
                                            sortstate = sortstate ^ 1;
                                          })
                                        },
                                    },
                                label: Container(
                                    // color: Colors.amber,
                                    width: 100,
                                    child: Text(
                                      item,
                                      style: TextStyle(
                                          color: (columns[colindex] == item)
                                              ? Colors.white
                                              : Colors.black),
                                    )));
                          }).toList(),
                          rows: [])),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class EditUser extends StatefulWidget {
  const EditUser({super.key, this.user});

  final user;
  @override
  State<EditUser> createState() => _EditUserState();
}

class _EditUserState extends State<EditUser> {
  var name;
  var password;
  var adminpass;
  @override
  void initState() {
    super.initState();
    setState(() {
      name = widget.user["name"];
      password = widget.user["password"];
      adminpass = "";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          //width: 100,
          margin: EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Admin Password"),
              TextField(
                onChanged: (value) {
                  setState(() {
                    adminpass = value;
                  });
                },
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                    hintText: "Admin Password",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10))),
              ),
            ],
          ),
        ),
        Container(
          //width: 100,
          margin: EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Name"),
              TextField(
                onChanged: (value) {
                  setState(() {
                    name = value;
                  });
                },
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                    hintText: name,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10))),
              ),
            ],
          ),
        ),
        Container(
          //width: 100,
          margin: EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Password"),
              TextField(
                onChanged: (value) {
                  setState(() {
                    password = value;
                  });
                },
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                    hintText: password,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10))),
              ),
            ],
          ),
        ),
        Container(
          margin: EdgeInsets.only(left: 10, right: 10),
          child: TextButton(
              style: ButtonStyle(
                  backgroundColor:
                      WidgetStateProperty.all<Color>(Colors.green)),
              onPressed: () async {
                if (adminpass.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Admin Password is required")));
                  return;
                }
                showDialog(
                    context: context,
                    builder: (context) {
                      return Center(child: CircularProgressIndicator());
                    });
                var userid = await getUserData();
                var res = await EditUserData({
                  "name": name,
                  "password": password,
                  "username": widget.user["username"]
                }, "6289625176", adminpass);
                if (res.statusCode == 200) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Userdata Updated Successfully")));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Invalid Admin Password")));
                }
                Navigator.of(context).pop();
              },
              child: Text(
                "Save",
                style: TextStyle(color: Colors.white),
              )),
        ),
      ],
    );
  }
}

class DeleteUser extends StatefulWidget {
  const DeleteUser({super.key, this.user});
  final user;

  @override
  State<DeleteUser> createState() => _DeleteUserState();
}

class _DeleteUserState extends State<DeleteUser> {
  var name;
  var password;
  var adminpass;
  @override
  void initState() {
    super.initState();
    setState(() {
      name = widget.user["name"];
      password = widget.user["password"];
      adminpass = "";
    });
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return Container(
      child: Column(
        children: [
          Container(
            //width: 100,
            margin: EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Admin Password"),
                TextField(
                  onChanged: (value) {
                    setState(() {
                      adminpass = value;
                    });
                  },
                  decoration: InputDecoration(
                      hintText: "Admin Password",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10))),
                ),
              ],
            ),
          ),
          Container(
            //width: 100,
            margin: EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Phone"),
                Container(
                  child: Text(widget.user["username"]),
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all()),
                ),
              ],
            ),
          ),
          Container(
            //width: 100,
            margin: EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Name"),
                Container(
                  child: Text(name),
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all()),
                ),
              ],
            ),
          ),
          Container(
            //width: 100,
            margin: EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Password"),
                Container(
                  child: Text(password),
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all()),
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(left: 10, right: 10),
            child: TextButton(
                style: ButtonStyle(
                    backgroundColor:
                        WidgetStateProperty.all<Color>(Colors.green)),
                onPressed: () async {
                  if (adminpass.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Admin Password is required")));
                    return;
                  }
                  showDialog(
                      context: context,
                      builder: (context) {
                        return Center(child: CircularProgressIndicator());
                      });
                  var userid = await getUserData();
                  var res = await DeleteUserData({
                    "name": name,
                    "password": password,
                    "username": widget.user["username"]
                  }, "6289625176", adminpass);
                  if (res.statusCode == 200) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("User Deleted Successfully")));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Invalid Admin Password")));
                  }
                  Navigator.of(context).pop();
                },
                child: Text(
                  "Delete",
                  style: TextStyle(color: Colors.white),
                )),
          ),
        ],
      ),
    );
  }
}
