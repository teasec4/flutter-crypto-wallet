
import 'package:flutter/material.dart';

import 'balance_page.dart';
import 'coin_list_page.dart';


class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  final List<Widget> _pages = [const BalancePage(), const CoinListPage()];

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var _pos = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: _BottomNavigationBar(
        onTap: (pos) {
          setState(() {
            _pos = pos;
          });
        },
      ),
      backgroundColor: const Color(0XFFF3A00FF),
      body: widget._pages[_pos],
    );
  }
}

class _BottomNavigationBar extends StatelessWidget {
  const _BottomNavigationBar({required this.onTap});

  final Function(int) onTap;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      onDestinationSelected: onTap,
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_filled),
          label: 'Portfolio',
        ),
        NavigationDestination(
          icon: Icon(Icons.equalizer),
          label: 'Prices',
        ),
      ],
    );
  }
}
