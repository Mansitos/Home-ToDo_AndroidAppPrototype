import 'package:flutter/material.dart';

class CategoriesScreen extends StatefulWidget {
  CategoriesScreen({Key? key}) : super(key: key);

  @override
  State<CategoriesScreen> createState() => CategoriesScreenState();
}

class CategoriesScreenState extends State<CategoriesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawerEnableOpenDragGesture: false,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: const Text("Categories"),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "AddCategory",
        onPressed: () {
          print("Add category button pressed");
        },
        tooltip: "Create new category",
        child: const Icon(Icons.add),
      ),
      body: CategoriesGridVisualizer(categories: ["🏠 All", "🌳 Garden", "🍴 Kitchen", "😽 Cat", "🚾 Bathroom", "🍔 Food", "🖥️ Office"]),
    );
  }
}


class CategoriesGridVisualizer extends StatefulWidget {
  const CategoriesGridVisualizer({Key? key, required this.categories}) : super(key: key);

  final List<String> categories;

  @override
  State<CategoriesGridVisualizer> createState() => CategoriesGridVisualizerState();
}

class CategoriesGridVisualizerState extends State<CategoriesGridVisualizer> {

  var additionalBordersPad = 4.0;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      // Create a grid with 2 columns. If you change the scrollDirection to
      // horizontal, this produces 2 rows.
      crossAxisCount: 2,
      // Generate 100 widgets that display their index in the List.
      children: List.generate(widget.categories.length, (index) {
        return Theme(
          data: ThemeData(textTheme: Theme.of(context).textTheme.apply(bodyColor: Colors.white)),
          child: Center(
            child: Padding(
              padding: EdgeInsets.only(left: (index+1)%2 * additionalBordersPad, right: index%2 * additionalBordersPad),
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      color: const Color.fromRGBO(70, 70, 70, 100),
                      child: Center(child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(widget.categories[index].substring(0,3),style: TextStyle(fontSize: 35),),
                          Text(widget.categories[index].substring(3),style: TextStyle(fontSize: 20),),
                        ],
                      )),
                    ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

