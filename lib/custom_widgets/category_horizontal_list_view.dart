import 'package:flutter/material.dart';
import 'package:home_to_do/data_types/category.dart';
import 'package:home_to_do/pages/task_page.dart';
import 'package:home_to_do/utilities/categories_utilities.dart';

// Horizontal categories-list widget selector

class CategoryHorizontalListView extends StatefulWidget {
  const CategoryHorizontalListView({Key? key, required this.categories, required this.onChange}) : super(key: key);

  final List<Category> categories;
  final categoryCallback onChange;

  @override
  State<CategoryHorizontalListView> createState() => CategoryHorizontalListViewState();
}

typedef void CategoryCallback(Category val);

class CategoryHorizontalListViewState extends State<CategoryHorizontalListView> {
  var selected_index = 0;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: false,
      scrollDirection: Axis.horizontal,
      itemCount: widget.categories.length,
      itemBuilder: (BuildContext context, int index) => Padding(
        padding: const EdgeInsets.all(7),
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
              widget.onChange(widget.categories[index]);
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
