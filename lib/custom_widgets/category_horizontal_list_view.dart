import 'package:flutter/material.dart';
import 'package:home_to_do/data_types/category.dart';
import 'package:home_to_do/utilities/categories_utilities.dart';

class CategoryHorizontalListView extends StatefulWidget {
  const CategoryHorizontalListView({Key? key, required this.categories}) : super(key: key);

  final List<Category> categories;

  @override
  State<CategoryHorizontalListView> createState() => CategoryHorizontalListViewState();
}

class CategoryHorizontalListViewState extends State<CategoryHorizontalListView> {
  var selected_index = 0;

  @override
  Widget build(BuildContext context) {
    // TODO: Remove
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
          child: Text(serializeCategory(widget.categories[index])),
          style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0))));
    } else {
      return ElevatedButton(
          onPressed: () {
            setState(() {
              selected_index = index;
            });
          },
          child: Text(serializeCategory(widget.categories[index])),
          style: ElevatedButton.styleFrom(primary: Colors.amber, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0))));
    }
  }
}
