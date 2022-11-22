import 'package:flutter/material.dart';

class CategoryHorizontalListView extends StatefulWidget {
  const CategoryHorizontalListView({Key? key, required this.categories}) : super(key: key);

  final List<String> categories;

  @override
  State<CategoryHorizontalListView> createState() => CategoryHorizontalListViewState();
}

class CategoryHorizontalListViewState extends State<CategoryHorizontalListView> {
  var selected_index = 0;

  @override
  Widget build(BuildContext context) {

    print("HORIZONTAL LIST CAT UPDATED!");

    return ListView.builder(
      shrinkWrap: false,
      scrollDirection: Axis.horizontal,
      itemCount: widget.categories.length,
      itemBuilder: (BuildContext context, int index) => Padding(
        padding: EdgeInsets.all(7),
        child: getCategoryButton(index),
      ),
    );
  }

  Widget getCategoryButton(int index) {
    if (index != selected_index) {
      return ElevatedButton(
          onPressed: () {
            setState(() {
              selected_index = index;
            });
          },
          child: Text(widget.categories[index]),
          style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0))));
    } else {
      return ElevatedButton(
          onPressed: () {
            setState(() {
              selected_index = index;
            });
          },
          child: Text(widget.categories[index]),
          style: ElevatedButton.styleFrom(primary: Colors.amber, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0))));
    }
  }
}
