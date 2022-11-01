import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {

  SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => SearchScreenState();
}

class SearchScreenState extends State<SearchScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawerEnableOpenDragGesture: false,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text("Search"),
      ),
      body: Text("Search"),
    );
  }
}
