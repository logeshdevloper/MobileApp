import 'package:flutter/material.dart';

import '../../common/auth/logout.dart';
import 'screens/home.dart';
import 'screens/category_page.dart';
import 'screens/order/order_page.dart';
import 'screens/profile_page.dart';
import 'screens/widgets/add_cart.dart';
import '../../utilis/constant.dart';
import '../../common/styles/color.dart';

class CustomerScreen extends StatefulWidget {
  const CustomerScreen({super.key});

  @override
  _CustomerScreenState createState() => _CustomerScreenState();
}

class _CustomerScreenState extends State<CustomerScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    Navigator.pop(context);
  }

  void _addCartScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CartScreen(cartItems: cartItems),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primaryColor,
        iconTheme: const IconThemeData(color: bgPrimary),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pops Mart',
              style: TextStyle(
                color: bgPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Fresh Food Everyday',
              style: TextStyle(
                color: bgPrimary.withOpacity(0.9),
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.shopping_cart, color: bgPrimary),
                Positioned(
                  right: 0,
                  child: ValueListenableBuilder<int>(
                    valueListenable: cartCountNotifier,
                    builder: (context, count, child) {
                      return count > 0
                          ? Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                color: secondaryColor,
                                shape: BoxShape.circle,
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 16,
                                minHeight: 16,
                              ),
                              child: Text(
                                '$count',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            )
                          : const SizedBox();
                    },
                  ),
                ),
              ],
            ),
            onPressed: _addCartScreen,
          ),
          const IconButton(
            icon: Icon(Icons.notifications_outlined, color: bgPrimary),
            onPressed: null, // You can add functionality here
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            const UserAccountsDrawerHeader(
              decoration: BoxDecoration(
                color: primaryColor,
              ),
              currentAccountPicture: CircleAvatar(
                backgroundColor: bgPrimary,
                child: Icon(
                  Icons.person,
                  size: 40,
                  color: primaryColor,
                ),
              ),
              accountName: Text(
                'Pops Mart',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              accountEmail: Text(
                'Fresh Food Everyday',
                style: TextStyle(
                  fontSize: 12,
                ),
              ),
            ),
            ListTile(
              selected: _selectedIndex == 0,
              selectedTileColor: highlightColor,
              leading: Icon(
                Icons.home,
                color: _selectedIndex == 0 ? primaryColor : textSecondary,
              ),
              title: Text(
                'Home',
                style: TextStyle(
                  color: _selectedIndex == 0 ? primaryColor : textSecondary,
                  fontWeight:
                      _selectedIndex == 0 ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              onTap: () => _onItemTapped(0),
            ),
            ListTile(
              selected: _selectedIndex == 1,
              selectedTileColor: highlightColor,
              leading: Icon(
                Icons.category,
                color: _selectedIndex == 1 ? primaryColor : textSecondary,
              ),
              title: Text(
                'Categories',
                style: TextStyle(
                  color: _selectedIndex == 1 ? primaryColor : textSecondary,
                  fontWeight:
                      _selectedIndex == 1 ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              onTap: () => _onItemTapped(1),
            ),
            ListTile(
              selected: _selectedIndex == 2,
              selectedTileColor: highlightColor,
              leading: Icon(
                Icons.receipt_long,
                color: _selectedIndex == 2 ? primaryColor : textSecondary,
              ),
              title: Text(
                'Orders',
                style: TextStyle(
                  color: _selectedIndex == 2 ? primaryColor : textSecondary,
                  fontWeight:
                      _selectedIndex == 2 ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              onTap: () => _onItemTapped(2),
            ),
            ListTile(
              selected: _selectedIndex == 3,
              selectedTileColor: highlightColor,
              leading: Icon(
                Icons.person,
                color: _selectedIndex == 3 ? primaryColor : textSecondary,
              ),
              title: Text(
                'Profile',
                style: TextStyle(
                  color: _selectedIndex == 3 ? primaryColor : textSecondary,
                  fontWeight:
                      _selectedIndex == 3 ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              onTap: () => _onItemTapped(3),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(
                Icons.shopping_cart,
                color: textSecondary,
              ),
              title: const Text(
                'Cart',
                style: TextStyle(
                  color: textSecondary,
                ),
              ),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: secondaryColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ValueListenableBuilder<int>(
                  valueListenable: cartCountNotifier,
                  builder: (context, count, child) {
                    return Text(
                      '$count',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
              ),
              onTap: _addCartScreen,
            ),
            ListTile(
              leading: const Icon(
                Icons.logout,
                color: textSecondary,
              ),
              title: const Text(
                'Logout',
                style: TextStyle(
                  color: textSecondary,
                ),
              ),
              onTap: () {
                logout(context);
              },
            ),
          ],
        ),
      ),
      body: Container(
        color: bgSecondary,
        child: Stack(
          children: [
            IndexedStack(
              index: _selectedIndex,
              children: const [
                HomePage(),
                CategoriesPage(),
                OrdersPage(),
                ProfilePage(),
              ],
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 16,
              child: ValueListenableBuilder<int>(
                valueListenable: cartCountNotifier,
                builder: (context, count, child) {
                  if (count == 0) return const SizedBox.shrink();
                  return GestureDetector(
                    onTap: _addCartScreen,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, -5),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '$count ${count == 1 ? 'item added' : 'items added'}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Container(
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(50)),
                            ),
                            padding: const EdgeInsets.all(3),
                            child: const Icon(
                              Icons.arrow_forward,
                              color: primaryColor,
                              size: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
