import 'package:flutter/material.dart';
import 'package:fit_tracker/constants/keys.dart';
import 'package:fit_tracker/constants/strings.dart';

enum TabItem { workouts, entries, account }

class TabItemData {
  const TabItemData(
      {required this.key, required this.title, required this.icon});

  final String key;
  final String title;
  final IconData icon;

  static const Map<TabItem, TabItemData> allTabs = {
    TabItem.workouts: TabItemData(
      key: Keys.workoutsTab,
      title: Strings.workouts,
      icon: Icons.work,
    ),
    TabItem.entries: TabItemData(
      key: Keys.entriesTab,
      title: Strings.entries,
      icon: Icons.view_headline,
    ),
    TabItem.account: TabItemData(
      key: Keys.accountTab,
      title: Strings.account,
      icon: Icons.person,
    ),
  };
}
