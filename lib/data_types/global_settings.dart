class GlobalSettings{
  GlobalSettings({required this.lastUniqueGeneratedID, required this.popUpMessagesEnabled, required this.compactTaskListViewEnabled, required this.alwaysShowExpiredTasks, required this.autoMonthOldDelete});

  bool popUpMessagesEnabled;
  int lastUniqueGeneratedID;
  bool compactTaskListViewEnabled;
  bool alwaysShowExpiredTasks;
  bool autoMonthOldDelete;
}