import 'package:flutter/material.dart';
import 'package:fit_tracker/app/home/account/account_page.dart';
import 'package:fit_tracker/app/home/cupertino_home_scaffold.dart';
import 'package:fit_tracker/app/home/entries/entries_page.dart';
import 'package:fit_tracker/app/home/workouts/workouts_page.dart';
import 'package:fit_tracker/app/home/tab_item.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TabItem _currentTab = TabItem.workouts;

  final Map<TabItem, GlobalKey<NavigatorState>> navigatorKeys = {
    TabItem.workouts: GlobalKey<NavigatorState>(),
    TabItem.entries: GlobalKey<NavigatorState>(),
    TabItem.account: GlobalKey<NavigatorState>(),
  };

  Map<TabItem, WidgetBuilder> get widgetBuilders {
    return {
      TabItem.workouts: (_) => WorkoutPage(),
      TabItem.entries: (_) => EntriesPage(),
      TabItem.account: (_) => AccountPage(),
    };
  }

  void _select(TabItem tabItem) {
    if (tabItem == _currentTab) {
      // pop to first route
      navigatorKeys[tabItem]!.currentState?.popUntil((route) => route.isFirst);
    } else {
      setState(() => _currentTab = tabItem);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async =>
          !(await navigatorKeys[_currentTab]!.currentState?.maybePop() ??
              false),
      child: CupertinoHomeScaffold(
        currentTab: _currentTab,
        onSelectTab: _select,
        widgetBuilders: widgetBuilders,
        navigatorKeys: navigatorKeys,
      ),
    );
  }
}
