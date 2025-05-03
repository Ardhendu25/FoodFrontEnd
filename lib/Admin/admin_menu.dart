import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/cloudinaryUpload.dart';
import 'package:frontend/components/get_image.dart';
import 'package:frontend/fetchdata.dart';
import 'package:http/http.dart' as http;

var server_url = dotenv.env["SERVER_URL"];
var url_addmenuitems = "${server_url}/AddMenuItems";
var url_addadvertisement = "${server_url}/AddAdvertisement";
var url_addcategory = "${server_url}/AddCategory";
var url_getmenuitems = "${server_url}/AddMenuItems";
var url_getadvertisement = "${server_url}/GetAdvertisement";

class AdminMenu extends StatefulWidget {
  const AdminMenu({super.key});

  @override
  State<AdminMenu> createState() => _AdminMenuState();
}

class _AdminMenuState extends State<AdminMenu> {
  var imagefile = [];
  var currentPage = 0;
  var menudata = [];
  var categories = [];

  getAdvertisement() async {
    var data = await getAdvertisementData(url_getadvertisement);
    setState(() {
      imagefile = data;
    });
  }

  getCategories() async {
    var res = await getCategory();
    if (res != null) {
      setState(() {
        categories = res;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getAdvertisement();
    getCategories();
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text("Menu Items"),
        backgroundColor: Colors.white,
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: AddvertisementSection()),
          SliverToBoxAdapter(child: AddCategory()),
          SliverToBoxAdapter(
              child: Container(
                  height: height - 56,
                  child: categories.length > 0
                      ? MenuItems(categories)
                      : Container()))
        ],
      ),
    );
  }

  Widget AddvertisementSection() {
    return Container(
      height: 200,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(top: 10, right: 10, left: 10),
            child: TextButton(
                style: ButtonStyle(
                    backgroundColor:
                        WidgetStateProperty.all<Color>(Colors.green)),
                onPressed: () async {
                  var image = await getImage();

                  if (image != null) {
                    showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) {
                          return Center(child: CircularProgressIndicator());
                        });

                    var new_image_url = await uploadCloud(image);
                    if (new_image_url != null) {
                      var response = await uploadData(
                              {"image": new_image_url}, url_addadvertisement)
                          .then((res) {
                        getAdvertisement();
                      });

                      Navigator.of(context).pop();
                    }
                  }
                },
                child: Padding(
                  padding: EdgeInsets.only(left: 10, right: 10),
                  child: Text(
                    "Add",
                    style: TextStyle(color: Colors.white),
                  ),
                )),
          ),
          !imagefile.isEmpty
              ? Expanded(
                  child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: imagefile.length,
                      itemBuilder: (context, index) {
                        return Container(
                            padding: EdgeInsets.all(10),
                            child: Stack(
                              children: [
                                Container(
                                  height: 100,
                                  width: 150,
                                  decoration: BoxDecoration(
                                      image: DecorationImage(
                                    image:
                                        NetworkImage(imagefile[index]["image"]),
                                    fit: BoxFit.fill,
                                    colorFilter: ColorFilter.mode(
                                      Colors.black.withOpacity(0.5),
                                      BlendMode.dstATop,
                                    ),
                                  )),
                                ),
                                Positioned(
                                    right: 0,
                                    child: GestureDetector(
                                      onTap: () async {
                                        await showDialog(
                                          context: context,
                                          barrierDismissible: false,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: const Text('Confirmation'),
                                              content: Text(
                                                  "Are you sure you want to delete this Add"),
                                              actions: <Widget>[
                                                TextButton(
                                                  child: const Text('Yes'),
                                                  onPressed: () async {
                                                    showDialog(
                                                        barrierDismissible:
                                                            false,
                                                        context: context,
                                                        builder: (context) {
                                                          return Center(
                                                              child:
                                                                  CircularProgressIndicator());
                                                        });
                                                    var admin = "6289625176";
                                                    var pass = "Iron1987@";
                                                    var res = await DeleteAdds(
                                                        imagefile[index],
                                                        admin,
                                                        pass);
                                                    if (res.statusCode == 200) {
                                                      await destroyCloud(
                                                          imagefile[index]
                                                              ["image"]);
                                                      setState(() {
                                                        imagefile
                                                            .removeAt(index);
                                                      });
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(SnackBar(
                                                              content: Text(
                                                                  "Add deleted successfully")));
                                                    } else {
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(SnackBar(
                                                              content: Text(
                                                                  "Something went wrong")));
                                                    }
                                                    Navigator.of(context).pop();
                                                    Navigator.of(context).pop();
                                                  },
                                                ),
                                                TextButton(
                                                  child: const Text('No'),
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                      child: Icon(
                                        Icons.delete_forever,
                                        //color: Colors.white,
                                        size: 30,
                                      ),
                                    ))
                              ],
                            ));
                      }),
                )
              : Expanded(
                  child: Container(
                      width: 200,
                      height: 200,
                      padding: EdgeInsets.all(10),
                      alignment: Alignment.center,
                      child: Container(
                        width: 180,
                        height: 180,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                            color: Colors.grey,
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                        child: const Text("Empty"),
                      )),
                ),
        ],
      ),
    );
  }

  Widget rowItemHeading(String name) {
    var width = MediaQuery.of(context).size.width;
    return Container(width: width * 0.12, child: Text(name));
  }
}

class AddCategory extends StatefulWidget {
  const AddCategory({super.key});

  @override
  State<AddCategory> createState() => _AddCategoryState();
}

class _AddCategoryState extends State<AddCategory> {
  var imagefile = [];

  getData() async {
    var data = await getCategory();
    setState(() {
      imagefile = data;
    });
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return Container(
      height: 200,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(top: 10, right: 10, left: 10),
            child: TextButton(
                style: ButtonStyle(
                    backgroundColor:
                        WidgetStateProperty.all<Color>(Colors.green)),
                onPressed: () async {
                  await showDialog(
                      context: context,
                      builder: (context) {
                        var image;
                        var name;
                        var choosen = false;
                        return StatefulBuilder(builder: (context, setState) {
                          return AlertDialog(
                            scrollable: true,
                            title: Text("Add Category"),
                            content: Container(
                              width: width * 0.5,
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      GestureDetector(
                                        child: Icon(Icons.image),
                                        onTap: () async {
                                          var newImage = await getImage();
                                          if (newImage != "") {
                                            setState(() {
                                              image = newImage;
                                              choosen = true;

                                              //Image.network(newImage.path.toString());
                                            });
                                          }
                                        },
                                      ),
                                      image != null
                                          ? choosen
                                              ? Container(
                                                  width: 100,
                                                  height: 100,
                                                  child: Image(
                                                    image: Image.network(
                                                            image.path)
                                                        .image,
                                                    fit: BoxFit.cover,
                                                  ),
                                                )
                                              : Container(
                                                  width: 100,
                                                  height: 100,
                                                  child: Image.network(image),
                                                )
                                          : Text("No image")
                                    ],
                                  ),
                                  Container(
                                    margin: EdgeInsets.all(10),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text("name"),
                                        TextField(
                                          onChanged: (value) {
                                            setState(() {
                                              name = value;
                                            });
                                          },
                                          keyboardType: TextInputType.number,
                                          decoration: InputDecoration(
                                              hintText:
                                                  name != null ? "$name" : "",
                                              border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10))),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                        color: Colors.green,
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: TextButton(
                                        onPressed: () async {
                                          showDialog(
                                              context: context,
                                              builder: (context) {
                                                return Center(
                                                    child:
                                                        CircularProgressIndicator());
                                              });

                                          var new_image_url =
                                              await uploadCloud(image);
                                          if (new_image_url != null) {
                                            var response = await uploadData({
                                              "name": name,
                                              "image": new_image_url
                                            }, url_addcategory)
                                                .then((res) {
                                              getData();
                                            });
                                          }
                                          Navigator.of(context).pop();
                                          Navigator.of(context).pop();
                                        },
                                        child: Text(
                                          "Submit",
                                          style: TextStyle(color: Colors.white),
                                        )),
                                  )
                                ],
                              ),
                            ),
                          );
                        });
                      });
                },
                child: Padding(
                  padding: EdgeInsets.only(left: 10, right: 10),
                  child: Text(
                    "Add",
                    style: TextStyle(color: Colors.white),
                  ),
                )),
          ),
          !imagefile.isEmpty
              ? Expanded(
                  child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: imagefile.length,
                      itemBuilder: (context, index) {
                        return Container(
                            padding: EdgeInsets.all(10),
                            child: Stack(
                              children: [
                                Container(
                                  height: 100,
                                  width: 150,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                      image: DecorationImage(
                                    image:
                                        NetworkImage(imagefile[index]["image"]),
                                    fit: BoxFit.fill,
                                    colorFilter: ColorFilter.mode(
                                      Colors.black.withOpacity(0.3),
                                      BlendMode.dstATop,
                                    ),
                                  )),
                                  child: Text(
                                    imagefile[index]["name"],
                                    style:
                                        TextStyle(fontWeight: FontWeight.w700),
                                  ),
                                ),
                                Positioned(
                                    right: 0,
                                    child: GestureDetector(
                                      onTap: () async {
                                        await showDialog(
                                          context: context,
                                          barrierDismissible: false,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: const Text('Confirmation'),
                                              content: Text(
                                                  "Are you sure you want to delete this Add"),
                                              actions: <Widget>[
                                                TextButton(
                                                  child: const Text('Yes'),
                                                  onPressed: () async {
                                                    showDialog(
                                                        barrierDismissible:
                                                            false,
                                                        context: context,
                                                        builder: (context) {
                                                          return Center(
                                                              child:
                                                                  CircularProgressIndicator());
                                                        });
                                                    var admin = "6289625176";
                                                    var pass = "Iron1987@";
                                                    var res =
                                                        await DeleteCategory(
                                                            imagefile[index],
                                                            admin,
                                                            pass);
                                                    if (res.statusCode == 200) {
                                                      await destroyCloud(
                                                          imagefile[index]
                                                              ["image"]);
                                                      setState(() {
                                                        imagefile
                                                            .removeAt(index);
                                                      });
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(SnackBar(
                                                              content: Text(
                                                                  "Category deleted successfully")));
                                                    } else {
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(SnackBar(
                                                              content: Text(
                                                                  "Something went wrong")));
                                                    }
                                                    Navigator.of(context).pop();
                                                    Navigator.of(context).pop();
                                                  },
                                                ),
                                                TextButton(
                                                  child: const Text('No'),
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                      child: Icon(
                                        Icons.delete_forever,
                                        //color: Colors.white,
                                        size: 30,
                                      ),
                                    ))
                              ],
                            ));
                      }),
                )
              : Expanded(
                  child: Container(
                      width: 200,
                      height: 200,
                      padding: EdgeInsets.all(10),
                      alignment: Alignment.center,
                      child: Container(
                        width: 180,
                        height: 180,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                            color: Colors.grey,
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                        child: const Text("Empty"),
                      )),
                ),
        ],
      ),
    );
  }
}

class MenuItems extends StatefulWidget {
  const MenuItems(this.categories, {super.key});
  final categories;

  @override
  State<MenuItems> createState() => _MenuItemsState();
}

class _MenuItemsState extends State<MenuItems> {
  var menudata = [];
  var categories = [];
  var groupby;
  var groupbyId;
  var colindex = 0;
  var query = "None", val;
  var columnsWithNumbers = [
    "price",
    "stock",
    "halfprice",
    "rating",
  ];

  getMenu() async {
    var time = DateTime.now().toUtc().toIso8601String();
    var data = [];
    if (query == "None") {
      data = await getAdminMenuitemsData(0, 0, groupbyId, time);
    } else if (columnsWithNumbers.contains(query)) {
      data = await getMenuitemsGreaterData(
          0, 0, groupbyId, time, {"$query": int.parse(val)});
    } else {
      data = await getAdminMenuitemsData(
          0, 0, groupbyId, time, {"$query": "$val"});
    }
    setState(() {
      menudata = data;
    });
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      categories = widget.categories;
      groupby = widget.categories[0]["name"];
      groupbyId = widget.categories[0]["_id"];
    });
    getMenu();
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    var image,
        name,
        price,
        stock,
        category,
        halfprice,
        veg = false,
        cooktime,
        deliverytime,
        description,
        rating,
        special = false;
    var columns = [
      "Index",
      "Edit",
      "ID",
      "image",
      "name",
      "price",
      "stock",
      "halfprice",
      "veg",
      "cooktime",
      "deliverytime",
      "description",
      "rating",
      "special",
      "timezone"
    ];

    var change = false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 10, right: 10, left: 10),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                AddMenuItem([], "add"),
                Container(
                  margin: const EdgeInsets.all(10),
                  child: DropdownButton(
                      value: groupby,
                      onChanged: (value) {
                        setState(() {
                          groupby = value as String;
                        });
                      },
                      items: categories.map((item) {
                        return DropdownMenuItem(
                            onTap: () {
                              setState(() {
                                groupbyId = item["_id"];
                              });
                            },
                            value: item["name"],
                            child: Text(item["name"]));
                      }).toList()),
                ),
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
                      getMenu();
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
                                    menudata.sort((a, b) =>
                                        a[columns[columnIndex]].compareTo(
                                            b[columns[columnIndex]]));
                                  })
                                },
                            label: Container(width: 100, child: Text(item)));
                      }).toList(),
                      rows: menudata.asMap().entries.map((item) {
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
                                  child: AddMenuItem(item.value, "edit"))),
                              DataCell(Container(
                                  width: 100,
                                  child:
                                      SelectableText("${item.value["_id"]}"))),
                              DataCell(Container(
                                  height: 60,
                                  width: 100,
                                  padding: EdgeInsets.all(10),
                                  child: Image.network(
                                    item.value["image"],
                                    fit: BoxFit.fill,
                                    width: 40,
                                    height: 40,
                                  ))),
                              DataCell(Container(
                                  width: 100,
                                  child:
                                      SelectableText("${item.value["name"]}"))),
                              DataCell(Container(
                                  width: 100,
                                  child: SelectableText(
                                      "${item.value["price"]}"))),
                              DataCell(Container(
                                  width: 100,
                                  child: SelectableText(
                                      "${item.value["stock"]}"))),
                              DataCell(Container(
                                  width: 100,
                                  child: SelectableText(
                                      "${item.value["halfprice"]}"))),
                              DataCell(Container(
                                  width: 100,
                                  child:
                                      SelectableText("${item.value["veg"]}"))),
                              DataCell(Container(
                                  width: 100,
                                  child: SelectableText(
                                      "${item.value["cooktime"]}"))),
                              DataCell(Container(
                                  width: 100,
                                  child:
                                      Text("${item.value["deliverytime"]}"))),
                              DataCell(Container(
                                  width: 100,
                                  child: Text("${item.value["description"]}"))),
                              DataCell(Container(
                                  width: 100,
                                  child: SelectableText(
                                      "${item.value["rating"]}"))),
                              DataCell(Container(
                                  width: 100,
                                  child: SelectableText(
                                      "${item.value["special"]}"))),
                              DataCell(Container(
                                  width: 100,
                                  child: SelectableText(
                                      "${item.value["timezone"]}"))),
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
                                            menudata.sort((a, b) => a[
                                                    columns[columnIndex]]
                                                .compareTo(
                                                    b[columns[columnIndex]]));
                                          } else if (sortstate == 1) {
                                            menudata.sort((a, b) => b[
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
    );
  }
}

class _DataSource extends DataTableSource {
  final List data;

  _DataSource({required this.data});

  @override
  DataRow? getRow(int index) {
    if (index >= data.length) {
      return null;
    }

    final item = data[index];

    return DataRow(cells: [
      DataCell(Text("Index")),
      DataCell(Icon(Icons.delete)),
      DataCell(Icon(Icons.edit)),
      DataCell(Container(
        height: 60,
        width: 60,
        padding: EdgeInsets.all(10),
        child: Image.asset(
          item["image"],
          fit: BoxFit.fill,
          width: 40,
          height: 40,
        ),
      )),
      DataCell(Text(item["name"].toString())),
      DataCell(Text("30")),
      DataCell(Text("399₹")),
    ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => 100;

  @override
  int get selectedRowCount => 0;
}

class AddMenuItem extends StatefulWidget {
  const AddMenuItem(this.item, this.type, {super.key});
  final item, type;

  @override
  State<AddMenuItem> createState() => _AddMenuItemState();
}

class _AddMenuItemState extends State<AddMenuItem> {
  var choosen = false;
  var categories = [];

  getData() async {
    var data = await getCategory();
    setState(() {
      categories = data;
    });
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    var image,
        name,
        price,
        stock,
        categoryId,
        halfprice,
        veg = false,
        cooktime,
        deliverytime,
        description,
        rating,
        special = false,
        timezonestart = TimeOfDay.now(),
        timezoneend = TimeOfDay.now();

    var change = false;
    var type = widget.type;
    var item = widget.item;
    var oldimage = null;

    return TextButton(
        style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all<Color>(Colors.green)),
        onPressed: () async {
          if (type == "edit") {
            choosen = false;
            image = item["image"];
            oldimage = item["image"];
            name = item["name"];
            price = item["price"];
            stock = item["stock"];

            categoryId = item["categoryId"];
            halfprice = item["halfprice"];
            veg = item["veg"];
            cooktime = item["cooktime"];
            deliverytime = item["deliverytime"];
            description = item["description"];
            rating = item["rating"];
            special = item["special"];
            var time = item["timezone"].toString().split("-");
            var times = time[0].split(":");
            var timee = time[1].split(":");

            timezonestart = TimeOfDay(
                hour: int.parse(times[0]), minute: int.parse(times[1]));
            timezoneend = TimeOfDay(
                hour: int.parse(timee[0]), minute: int.parse(timee[1]));
          }

          await showDialog(
              context: context,
              builder: (context) {
                return StatefulBuilder(
                  builder: (context, setState) => AlertDialog(
                      scrollable: true,
                      title: Text(
                          type == "add" ? "Add Menu Item" : "Edit Menu Item"),
                      content: Column(
                        children: [
                          Row(
                            children: [
                              GestureDetector(
                                child: Icon(Icons.image),
                                onTap: () async {
                                  var newImage = await getImage();
                                  if (newImage != "") {
                                    setState(() {
                                      image = newImage;
                                      choosen = true;

                                      //Image.network(newImage.path.toString());
                                    });
                                  }
                                },
                              ),
                              image != null
                                  ? choosen
                                      ? Container(
                                          width: 100,
                                          height: 100,
                                          child: Image(
                                            image:
                                                Image.network(image.path).image,
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      : Container(
                                          width: 100,
                                          height: 100,
                                          child: Image.network(image))
                                  : Text("No image")
                            ],
                          ),
                          Container(
                            width: min(width, 500),
                            margin: EdgeInsets.all(10),
                            child: Row(
                              children: [
                                Text(
                                    "Timezone Start: ${timezonestart.hour}:${timezonestart.minute}  "),
                                ElevatedButton(
                                    style: ButtonStyle(
                                        backgroundColor:
                                            WidgetStateProperty.all<Color>(
                                                Colors.green)),
                                    onPressed: () async {
                                      var time = await showTimePicker(
                                          context: context,
                                          initialTime: timezonestart);
                                      if (time != null) {
                                        setState(() {
                                          timezonestart = time;
                                        });
                                      }
                                    },
                                    child: Text(
                                      "Choose",
                                      style: TextStyle(color: Colors.white),
                                    ))
                              ],
                            ),
                          ),
                          Container(
                            width: min(width, 500),
                            margin: EdgeInsets.all(10),
                            child: Row(
                              children: [
                                Text(
                                    "Timezone End: ${timezoneend.hour}:${timezoneend.minute}  "),
                                ElevatedButton(
                                    style: ButtonStyle(
                                        backgroundColor:
                                            WidgetStateProperty.all<Color>(
                                                Colors.green)),
                                    onPressed: () async {
                                      var time = await showTimePicker(
                                          context: context,
                                          initialTime: timezoneend);
                                      if (time != null) {
                                        setState(() {
                                          timezoneend = time;
                                        });
                                      }
                                    },
                                    child: Text(
                                      "Choose",
                                      style: TextStyle(color: Colors.white),
                                    ))
                              ],
                            ),
                          ),
                          Container(
                            width: min(width, 500),
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
                                  decoration: InputDecoration(
                                      hintText: name != null ? name : "",
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10))),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Category"),
                                DropdownMenu(
                                    //enableFilter: true,
                                    width: min(500, width),
                                    initialSelection: categoryId,
                                    onSelected: (value) {
                                      setState(() {
                                        categoryId = value;
                                      });
                                    },
                                    dropdownMenuEntries: categories.map((item) {
                                      return DropdownMenuEntry(
                                          value: item["_id"],
                                          label: item["name"]);
                                    }).toList()),
                              ],
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Price"),
                                TextField(
                                  onChanged: (value) {
                                    setState(() {
                                      price = value;
                                    });
                                  },
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                      hintText: price != null ? "$price" : "",
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10))),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Half Price"),
                                TextField(
                                  onChanged: (value) {
                                    setState(() {
                                      halfprice = value;
                                    });
                                  },
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                      hintText:
                                          halfprice != null ? "$halfprice" : "",
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10))),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Rating"),
                                TextField(
                                  onChanged: (value) {
                                    setState(() {
                                      rating = value;
                                    });
                                  },
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                      hintText: rating != null ? "$rating" : "",
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10))),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Description"),
                                TextField(
                                  maxLines: 5,
                                  onChanged: (value) {
                                    setState(() {
                                      description = value;
                                    });
                                  },
                                  keyboardType: TextInputType.multiline,
                                  decoration: InputDecoration(
                                      hintText: description != null
                                          ? description
                                          : "",
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10))),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  margin: EdgeInsets.all(10),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text("Cooking Time"),
                                      TextField(
                                        onChanged: (value) {
                                          setState(() {
                                            cooktime = value;
                                          });
                                        },
                                        keyboardType: TextInputType.number,
                                        decoration: InputDecoration(
                                            hintText: cooktime != null
                                                ? "$cooktime"
                                                : "In Minutes",
                                            border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10))),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  //width: 100,
                                  margin: EdgeInsets.all(10),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text("Delivery Time"),
                                      TextField(
                                        onChanged: (value) {
                                          setState(() {
                                            deliverytime = value;
                                          });
                                        },
                                        keyboardType: TextInputType.number,
                                        decoration: InputDecoration(
                                            hintText: deliverytime != null
                                                ? "$deliverytime"
                                                : "In Minutes",
                                            border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10))),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Container(
                                  margin: EdgeInsets.all(10),
                                  child: Row(
                                    children: [
                                      Text("Veg"),
                                      Checkbox(
                                          value: veg,
                                          onChanged: (value) {
                                            setState(() {
                                              veg = value as bool;
                                            });
                                          }),
                                    ],
                                  )),
                              Container(
                                  margin: EdgeInsets.all(10),
                                  child: Row(
                                    children: [
                                      Text("Special"),
                                      Checkbox(
                                          value: special,
                                          onChanged: (value) {
                                            setState(() {
                                              special = value as bool;
                                            });
                                          }),
                                    ],
                                  )),
                            ],
                          ),
                          Container(
                            margin: EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Stock"),
                                TextField(
                                  onChanged: (value) {
                                    setState(() {
                                      stock = value;
                                    });
                                  },
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                      hintText: stock != null ? "$stock" : "",
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10))),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              Visibility(
                                visible: type == "edit",
                                child: Container(
                                  margin: EdgeInsets.only(left: 10, right: 10),
                                  child: TextButton(
                                      style: ButtonStyle(
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
                                        var response = await deleteMenuItem(
                                            {"_id": item["_id"]});

                                        Navigator.of(context).pop();
                                      },
                                      child: Text(
                                        "Remove",
                                        style: TextStyle(color: Colors.white),
                                      )),
                                ),
                              ),
                              TextButton(
                                  style: ButtonStyle(
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
                                    var imageUrl = image;

                                    if (choosen)
                                      imageUrl = await uploadCloud(image);

                                    var data = {
                                      "name": name,
                                      "price": price,
                                      "stock": stock,
                                      "categoryId": categoryId,
                                      "image": imageUrl,
                                      "halfprice": halfprice,
                                      "veg": veg,
                                      "cooktime": cooktime,
                                      "deliverytime": deliverytime,
                                      "description": description,
                                      "rating": rating,
                                      "special": special,
                                      "timezoneStart": timezonestart.hour * 60 +
                                          timezonestart.minute,
                                      "timezoneEnd": timezoneend.hour * 60 +
                                          timezoneend.minute,
                                      "timezoneCompare":
                                          timezonestart.hour * 60 +
                                                  timezonestart.minute >
                                              timezoneend.hour * 60 +
                                                  timezoneend.minute,
                                      "timezone":
                                          "${timezonestart.hour}:${timezonestart.minute}-${timezoneend.hour}:${timezoneend.minute}"
                                    };
                                    if (type == "add") {
                                      var response = await uploadData(
                                          data, url_addmenuitems);
                                    } else {
                                      data["_id"] = item["_id"];
                                      var response = await updateMenuItem(data);
                                      if (response.statusCode == 200 &&
                                          oldimage != imageUrl) {
                                        await destroyCloud(oldimage);
                                      }
                                    }

                                    Navigator.of(context).pop();
                                  },
                                  child: Text(type == "add" ? "Submit" : "Save",
                                      style: TextStyle(color: Colors.white))),
                            ],
                          )
                        ],
                      )),
                );
              });
          if (change) {
            setState(() {
              change = false;
            });
          }
        },
        child: Padding(
          padding: EdgeInsets.only(left: 10, right: 10),
          child: Text(
            (type == "add" ? "Add" : "Edit"),
            style: TextStyle(color: Colors.white),
          ),
        ));
  }
}
