class RankHistoryEntry{

  RankHistoryEntry({required this.startDate, required this.endDate, required this.firstUser, required this.secondUser, required this.thirdUser, required this.firstScore, required this.secondScore, required this.thirdScore});

  DateTime startDate;
  DateTime endDate;
  String firstUser;
  String secondUser;
  String thirdUser;
  int firstScore;
  int secondScore;
  int thirdScore;

  @override toString(){
    return ("RankHistoryEntry | start: " +startDate.toString() + " end: " + endDate.toString() + "| 1°:" + firstUser+ "("+ firstScore.toString() +")| 2°:" + secondUser+ "("+ secondScore.toString() +")| 3°:" + thirdUser + "("+ thirdScore.toString() +")");
  }
}