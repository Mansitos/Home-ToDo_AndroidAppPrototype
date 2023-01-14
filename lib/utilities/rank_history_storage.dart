import 'dart:io';
import 'package:home_to_do/data_types/rank_history_entry.dart';
import 'package:home_to_do/utilities/rank_history_utilities.dart';
import 'package:path_provider/path_provider.dart';
import '/utilities/globals.dart' as globals;
import 'package:flutter/material.dart';

// This class handle/allows Rank History Entries persistency over sessions.
// The class provides file save/load mechanism for rankHistoryEntries.

class RankHistoryStorage {
// Getting the local documents path
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localRankHistoryPath async {
    final path = await _localPath;

    File file = File('$path/rankHistory.txt');

    if (file.existsSync()) {
      return file;
    } else {
      debugPrint(" > Creating RankHistory file because it was missing!");
      file = await File('$path/rankHistory.txt').create(recursive: true);
      if (file.existsSync()) {}
    }
    return file;
  }

  Future<File> saveRankHistoryToFile(List<RankHistoryEntry> rankHistoryEntries) async {
    final file = await _localRankHistoryPath;

    String encode = "";
    if (rankHistoryEntries.isNotEmpty) {
      for (int i = 0; i <= rankHistoryEntries.length - 1; i++) {
        encode += serializeRankHistoryEntry(rankHistoryEntries[i]);
        encode += '|';
      }
      encode = encode.substring(0, encode.length - 1); // Remove last separator
    }

    debugPrint("\n > Rank History Entries saved successfully! location/path: " + file.path);
    debugPrint(rankHistoryEntries.toString());
    return await file.writeAsString(encode);
  }

  Future<bool> loadRankHistoryFromFile() async {
    try {
      final file = await _localRankHistoryPath;
      final contents = await file.readAsString();

      List<String> encodedRankHistoryEntries = contents.split('|');
      List<RankHistoryEntry> rankHistoryEntries = [];

      if (encodedRankHistoryEntries.length > 1) {
        for (var i = 0; i < encodedRankHistoryEntries.length; i++) {
          RankHistoryEntry entryToAdd = decodeSerializedRankHistoryEntry(encodedRankHistoryEntries[i]);
          rankHistoryEntries.add(entryToAdd);
        }
      } else {
        rankHistoryEntries.add(RankHistoryEntry(startDate: DateTime(0), endDate: DateTime.now(), firstUser: "firstUser", secondUser: "secondUser", thirdUser: "thirdUser", firstScore: 0, secondScore: 0, thirdScore: 0));
        print(" > No saved rank history entries! Restoring the default one!");
        await globals.rankHistoryStorage.saveRankHistoryToFile(rankHistoryEntries);
      }

      // Updating globals entry
      globals.rankHistoryEntries = rankHistoryEntries;
      debugPrint(" > Rank History Entries loaded successfully! (" + rankHistoryEntries.length.toString() + ")");
      debugPrint(rankHistoryEntries.toString());
      return true;
    } catch (e) {
      debugPrint(" > Error in loading Rank History Entries file!");
      debugPrint(e.toString());
      return false;
    }
  }
}
