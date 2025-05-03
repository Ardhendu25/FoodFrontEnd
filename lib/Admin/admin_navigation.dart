import 'package:flutter/material.dart';
import 'package:frontend/Admin/admin_menu.dart';
import 'package:frontend/Admin/admin_notifications.dart';
import 'package:frontend/Admin/admin_order.dart';
import 'package:frontend/Admin/admin_report.dart';
import 'package:frontend/Admin/admin_user.dart';
import 'package:frontend/Admin/order_components/active_orders.dart';
import 'package:frontend/Admin/order_components/order_history.dart';

class AdminNavigation extends StatefulWidget {
  const AdminNavigation({super.key});
  @override
  State<AdminNavigation> createState() => _AdminNavigationState();
}

class _AdminNavigationState extends State<AdminNavigation> {
  var currentIndex = 0;

  var pages = [
    AdminUser(),
    AdminMenu(),
    ActiveOrders(),
    OrderHistory(),
    AdminReport(),
    AdminNotifications()
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Row(
          children: [
            NavigationRail(
                backgroundColor: Colors.white,
                indicatorColor: Color.fromARGB(255, 36, 151, 245),
                extended: true,
                onDestinationSelected: (index) {
                  setState(() {
                    if (index != 0) {
                      setState(() {
                        currentIndex = index - 1;
                      });
                    }
                  });
                },
                destinations: [
                  NavigationRailDestination(
                      padding: EdgeInsets.only(bottom: 50),
                      icon: Icon(Icons.admin_panel_settings),
                      label: Text("Admin")),
                  NavigationRailDestination(
                      icon: Icon(Icons.person), label: Text("Users")),
                  NavigationRailDestination(
                      icon: Icon(Icons.menu), label: Text("MenuItems")),
                  NavigationRailDestination(
                      icon: Icon(Icons.menu_open),
                      label: Text("Active Orders")),
                  NavigationRailDestination(
                      icon: Icon(Icons.food_bank_outlined),
                      label: Text("Order History")),
                  NavigationRailDestination(
                      icon: Icon(Icons.report), label: Text("Report")),
                  NavigationRailDestination(
                      icon: Icon(Icons.notification_add),
                      label: Text("Notification"))
                ],
                selectedIndex: currentIndex + 1),
            Expanded(child: pages[currentIndex])
          ],
        ));
  }
}
