import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:home_to_do/custom_widgets/category_form_dialog.dart';
import 'package:home_to_do/data_types/category.dart';
import '/utilities/globals.dart' as globals;
import '/utilities/categories_utilities.dart' as categories;

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({Key? key}) : super(key: key);

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
        title: const Text("My Categories"),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "AddCategory",
        onPressed: () {
          setState(() {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return const CategoryDialogForm(modifyMode: false, modifyIndex: -1);
                }).then((_) => setState(() {}));
          });
        },
        tooltip: "Create new category",
        child: const Icon(Icons.add),
      ),
      body: _categoryPageMainWidgetBuilder(),
    );
  }

  Widget _categoryPageMainWidgetBuilder() {
    if (globals.categories.length > 1) {
      return CategoriesGridVisualizer();
    } else {
      return _noCategoriesWidgetBuilder();
    }
  }

  Widget _noCategoriesWidgetBuilder() {
    return Center(
        child: Padding(
      padding: const EdgeInsets.all(50),
      child: SizedBox(
        height: 300,
        child: Column(
          children: const [
            Text("No categories found!", style: TextStyle(fontSize: 22, color: Colors.white)),
            Padding(
              padding: EdgeInsets.all(12),
              child: Text("😭",
                  style: TextStyle(
                    fontSize: 75,
                  )),
            ),
            Text(
              "Try to create a new category by pressing the + button at the bottom right!",
              style: TextStyle(
                fontSize: 14,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    ));
  }

// 🍔
}

class CategoriesGridVisualizer extends StatefulWidget {
  const CategoriesGridVisualizer({Key? key}) : super(key: key);

  @override
  State<CategoriesGridVisualizer> createState() => CategoriesGridVisualizerState();
}

class CategoriesGridVisualizerState extends State<CategoriesGridVisualizer> {
  var additionalBordersPad = 4.0;
  late Offset _tapDownPosition;
  final List<Category> categoriesList = globals.categories.sublist(1);

  @override
  Widget build(BuildContext context) {
    List<Category> categoriesList = globals.categories.sublist(1);

    return GridView.count(
      // Create a grid with n columns.
      crossAxisCount: 2,
      // Generate widgets that display their index in the List.
      children: List.generate(categoriesList.length, (index) {
        return Theme(
          data: ThemeData(textTheme: Theme.of(context).textTheme.apply(bodyColor: Colors.white)),
          child: Center(
            child: Padding(
              padding: EdgeInsets.only(left: (index + 1) % 2 * additionalBordersPad, right: index % 2 * additionalBordersPad),
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: SizedBox(
                  width: double.infinity,
                  height: double.infinity,
                  child: TextButton(
                    onPressed: () {},
                    onLongPress: () {},
                    child: GestureDetector(
                      onTapDown: (TapDownDetails details) {
                        setState(() {
                          _tapDownPosition = details.globalPosition;
                        });
                      },
                      onLongPress: () {
                        showMenu(
                            context: context,
                            position: RelativeRect.fromLTRB(
                              _tapDownPosition.dx,
                              _tapDownPosition.dy,
                              _tapDownPosition.dx,
                              _tapDownPosition.dy,
                            ),
                            items: <PopupMenuEntry>[
                              PopupMenuItem(
                                onTap: () {
                                  categories.deleteCategory(index + 1).then((_) => setState(() {}));
                                },
                                value: 0,
                                child: Row(
                                  children: const <Widget>[
                                    Icon(Icons.delete, color: Colors.red,),
                                    Text("Delete", style: TextStyle(color: Colors.red),),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                onTap: () {
                                  // Navigator.pop close the pop-up while showing the dialog.
                                  // We have to wait till the animations finish, and then open the dialog.
                                  WidgetsBinding.instance?.addPostFrameCallback((_) {
                                    setState(() {
                                      showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return CategoryDialogForm(modifyMode: true, modifyIndex: index + 1);
                                          }).then((_) => setState(() {}));
                                    });
                                  });
                                },
                                value: 1,
                                child: Row(
                                  children: const <Widget>[
                                    Icon(Icons.edit),
                                    Text("Modify"),
                                  ],
                                ),
                              )
                            ]);
                      },
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        color: const Color.fromRGBO(70, 70, 70, 100),
                        child: Center(
                            child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              categoriesList[index].emoji,
                              style: const TextStyle(fontSize: 35),
                            ),
                            Text(
                              categoriesList[index].name,
                              style: const TextStyle(fontSize: 20),
                            ),
                          ],
                        )),
                      ),
                    ),
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
