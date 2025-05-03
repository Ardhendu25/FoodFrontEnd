import 'package:flutter/material.dart';
import 'package:frontend/Admin/order_components/active_orders.dart';
import 'package:frontend/Admin/order_components/order_history.dart';

class AdminOrder extends StatefulWidget {
  const AdminOrder({super.key});

  @override
  State<AdminOrder> createState() => _AdminOrderState();
}

class _AdminOrderState extends State<AdminOrder> {
  var currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Container(
            child: NavigationBar(
              onDestinationSelected: (int index) {
                setState(() {
                  currentPageIndex = index;
                });
              },
              selectedIndex: currentPageIndex,
              destinations: [
                NavigationDestination(
                    icon: Icon(Icons.menu_open), label: "Active Orders"),
                NavigationDestination(
                    icon: Icon(Icons.menu), label: "Order History")
              ],
            ),
          ),
        ),
        body: [ActiveOrders(), OrderHistory()][currentPageIndex]);
  }
}
