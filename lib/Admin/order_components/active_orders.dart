import 'package:flutter/material.dart';
import 'package:frontend/fetchdata.dart';
import 'package:intl/intl.dart';

class ActiveOrders extends StatefulWidget {
  const ActiveOrders({super.key});

  @override
  State<ActiveOrders> createState() => _ActiveOrdersState();
}

class _ActiveOrdersState extends State<ActiveOrders> {
  var data = [];
  var colindex = 0;
  var searchCategory = "None";
  var searchValue = "";
  var searchKey = 0;
  var key = 0;

  getOrders() async {
    var res;
    if (searchCategory != "None") {
      res = await getPendingOrders({searchCategory: searchValue});
    } else
      res = await getPendingOrders();
    setState(() {
      if (res != null) {
        data = res as List;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    getOrders();
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;

    var columns = [
      "Index",
      "Save",
      "Details",
      "OrderId",
      "userId",
      "Time",
      "Pin",
      "totalPrice",
      "address",
      "deliveryStatus",
      "paymentStatus",
      "paymentMode",
    ];
    var searchField = [
      "None",
      "userId",
      "deliveryStatus",
      "paymentStatus",
      "address",
      "pin",
      "OrderId"
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text("Active Orders"),
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
                  DropdownButton(
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                    value: searchCategory,
                    items: searchField.map((element) {
                      return DropdownMenuItem(
                          child: Text(element), value: element);
                    }).toList(),
                    onChanged: (values) {
                      setState(() {
                        if (values == "None") {
                          searchValue = "";
                          searchKey = searchKey ^ 1;
                        }
                        searchCategory = values.toString();
                      });
                    },
                  ),
                  Container(
                    width: 200,
                    padding: EdgeInsets.all(10),
                    child: TextField(
                      key: Key(searchKey.toString()),
                      onChanged: (value) {
                        setState(() {
                          searchValue = value;
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
                        getOrders();
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
                    padding: const EdgeInsets.only(left: 10),
                    child: DataTable(
                        key: Key(key.toString()),
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
                        rows: data.asMap().entries.map((items) {
                          var col = false;
                          var item = items.value;
                          var ind = items.key;

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
                                DataCell(
                                    Container(width: 100, child: Text("$ind"))),
                                DataCell(Container(
                                    width: 100,
                                    child: TextButton(
                                        style: ButtonStyle(
                                            alignment: Alignment.center,
                                            backgroundColor:
                                                WidgetStateProperty.all<Color>(
                                                    Colors.green)),
                                        onPressed: () async {
                                          showDialog(
                                              context: context,
                                              builder: (context) {
                                                return Center(
                                                    child:
                                                        CircularProgressIndicator());
                                              });
                                          var res = await updateOrderItem(item);
                                          if (res.statusCode == 200 &&
                                              item["deliveryStatus"] !=
                                                  "pending") {
                                            setState(() {
                                              data.remove(item);
                                              key = key ^ 1;
                                            });
                                          }

                                          Navigator.of(context).pop();
                                        },
                                        child: Text(
                                          "Save",
                                          style: TextStyle(color: Colors.white),
                                        )))),
                                DataCell(Container(
                                    width: 100,
                                    child: TextButton(
                                        onPressed: () async {
                                          await showDialog(
                                              context: context,
                                              builder: (context) {
                                                return StatefulBuilder(builder:
                                                    (context, setState) {
                                                  return AlertDialog(
                                                    scrollable: true,
                                                    backgroundColor:
                                                        Colors.white,
                                                    title: const Text(
                                                        "Order Summary"),
                                                    content: Column(
                                                      children: (item["items"]
                                                              as List)
                                                          .asMap()
                                                          .entries
                                                          .map((val) {
                                                        return ItemDetails(
                                                            item: val.value,
                                                            index: val.key);
                                                      }).toList(),
                                                    ),
                                                  );
                                                });
                                              });
                                          //Navigator.of(context).pop();
                                        },
                                        style: ButtonStyle(
                                            alignment: Alignment.center,
                                            backgroundColor:
                                                WidgetStateProperty.all<Color>(
                                                    Colors.green)),
                                        child: Text(
                                          "View",
                                          style: TextStyle(color: Colors.white),
                                        )))),
                                DataCell(Container(
                                    width: 100,
                                    child: SelectableText("${item["_id"]}"))),
                                DataCell(Container(
                                    width: 100,
                                    child:
                                        SelectableText("${item["userId"]}"))),
                                DataCell(Container(
                                    width: 100,
                                    child: SelectableText(
                                        "${DateFormat("dd-MM-yyyy").format(DateTime.parse(item["createdAt"].toString()).toLocal())} at ${DateFormat('hh:mm a').format(DateTime.parse(item["createdAt"].toString()).toLocal())}"))),
                                DataCell(Container(
                                    width: 100,
                                    child: SelectableText("${item["pin"]}"))),
                                DataCell(Container(
                                    width: 100,
                                    child: SelectableText(
                                        "${item["totalPrice"]}"))),
                                DataCell(Container(
                                    width: 100,
                                    child:
                                        SelectableText("${item["address"]}"))),
                                DataCell(Container(
                                  //width: 100,
                                  child: DropdownButton(
                                      onChanged: (value) {
                                        setState(() {
                                          item["deliveryStatus"] = value;
                                        });
                                      },
                                      value: item["deliveryStatus"],
                                      items: const [
                                        DropdownMenuItem(
                                            value: "pending",
                                            child: Text(
                                              "pending",
                                              style: TextStyle(
                                                  color: Colors.black),
                                            )),
                                        DropdownMenuItem(
                                            value: "successful",
                                            child: Text(
                                              "successful",
                                              style: TextStyle(
                                                  color: Colors.green),
                                            )),
                                        DropdownMenuItem(
                                            value: "unsuccessful",
                                            child: Text(
                                              "unsuccessful",
                                              style:
                                                  TextStyle(color: Colors.red),
                                            )),
                                        DropdownMenuItem(
                                            value: "cancel",
                                            child: Text("cancel",
                                                style: TextStyle(
                                                    color: Colors.blue)))
                                      ]),
                                )),
                                DataCell(Container(
                                    //width: 100,
                                    child: DropdownButton(
                                        onChanged: (value) {
                                          setState(() {
                                            item["paymentStatus"] = value;
                                          });
                                        },
                                        value: item["paymentStatus"],
                                        items: const [
                                      DropdownMenuItem(
                                          value: "pending",
                                          child: Text("pending",
                                              style: TextStyle(
                                                  color: Colors.black))),
                                      DropdownMenuItem(
                                          value: "successful",
                                          child: Text("successful",
                                              style: TextStyle(
                                                  color: Colors.green))),
                                      DropdownMenuItem(
                                          value: "unsuccessful",
                                          child: Text("unsuccessful",
                                              style: TextStyle(
                                                  color: Colors.red))),
                                      DropdownMenuItem(
                                          value: "cancel",
                                          child: Text("cancel",
                                              style: TextStyle(
                                                  color: Colors.blue)))
                                    ]))),
                                DataCell(Container(
                                    width: 100,
                                    child: SelectableText(
                                        "${item["paymentMode"]}"))),
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
                                              data.sort((a, b) => a[
                                                      columns[columnIndex]]
                                                  .compareTo(
                                                      b[columns[columnIndex]]));
                                            } else if (sortstate == 1) {
                                              data.sort((a, b) => b[
                                                      columns[columnIndex]]
                                                  .compareTo(
                                                      a[columns[columnIndex]]));
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

class ItemDetails extends StatefulWidget {
  const ItemDetails({super.key, this.item, this.index});
  final item;
  final index;

  @override
  State<ItemDetails> createState() => _ItemDetailsState();
}

class _ItemDetailsState extends State<ItemDetails> {
  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var item = widget.item;

    return Container(
        width: width,
        margin: EdgeInsets.all(20),
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(color: Colors.white, boxShadow: [
          BoxShadow(color: Colors.grey, offset: Offset(0.0, 1.0), blurRadius: 1)
        ]),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              Column(children: [
                item["image"] != null
                    ? Image.network(
                        item["image"],
                        fit: BoxFit.cover,
                        height: 100,
                        width: 100,
                      )
                    : Container(
                        width: 100,
                        height: 100,
                        color: Colors.grey,
                      ),
              ]),
              Container(
                margin: EdgeInsets.only(left: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SelectableText(
                      "Item : ${widget.index + 1}",
                      style: const TextStyle(fontSize: 20),
                    ),
                    SelectableText(
                      "Item ID : " + item["id"],
                      style: const TextStyle(fontSize: 20),
                    ),
                    Text(
                      "Name : " + item["name"],
                      style: const TextStyle(fontSize: 20),
                    ),
                    Text(
                      "Price:${item["price"]}₹",
                      style: TextStyle(color: Colors.grey),
                    ),
                    Text(
                      "Plate number:${item["quantity"]}",
                      style: TextStyle(color: Colors.grey),
                    ),
                    Text(
                      "Plate type:${item["platetype"]}",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ));
  }
}
