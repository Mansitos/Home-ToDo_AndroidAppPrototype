import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:home_to_do/data_types/rank_history_entry.dart';
import 'package:home_to_do/utilities/generic_utilities.dart';
import 'globals.dart' as globals;

Future<void> createNewRankHistoryEntry(DateTime startDate, DateTime endDate, String first, String second, String third, int firstScore, int secondScore, int thirdScore) async {
  RankHistoryEntry newRankHistoryEntry = RankHistoryEntry(startDate: startDate, endDate: endDate, firstUser: first, secondUser: second, thirdUser: third, firstScore: firstScore, secondScore: secondScore, thirdScore: thirdScore);
  globals.rankHistoryEntries.add(newRankHistoryEntry);
  debugPrint("\n > New Rank History Entry saved!\n" + serializeRankHistoryEntry(newRankHistoryEntry));
  await globals.rankHistoryStorage.saveRankHistoryToFile(globals.rankHistoryEntries);
}

RankHistoryEntry decodeSerializedRankHistoryEntry(String encode) {
  List<String> data = encode.split('/');
  return RankHistoryEntry(startDate: decodeDate(data[0]), endDate: decodeDate(data[1]), firstUser: data[2], secondUser: data[3], thirdUser: data[4], firstScore: int.parse(data[5]), secondScore: int.parse(data[6]), thirdScore: int.parse(data[7]));
}

String serializeRankHistoryEntry(RankHistoryEntry RankHistoryEntry) {
  return RankHistoryEntry.startDate.toString() + "/" + RankHistoryEntry.endDate.toString() + "/" + RankHistoryEntry.firstUser + "/" + RankHistoryEntry.secondUser + "/" + RankHistoryEntry.thirdUser + "/" + RankHistoryEntry.firstScore.toString() + "/" + RankHistoryEntry.secondScore.toString() + "/" + RankHistoryEntry.thirdScore.toString();
}
