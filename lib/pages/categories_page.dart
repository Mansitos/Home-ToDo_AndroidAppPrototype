import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:home_to_do/custom_widgets/category_form_dialog.dart';
import 'package:home_to_do/custom_widgets/pop_up_message.dart';
import 'package:home_to_do/data_types/category.dart';
import '/utilities/globals.dart' as globals;
import '/utilities/categories_utilities.dart' as categories;

// Main Widget of the Categories Page
class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({Key? key}) : super(key: key);

  @override
  State<CategoriesScreen> createState() => CategoriesScreenState();
}

class CategoriesScreenState extends State<CategoriesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
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

  // Just a widget selector
  Widget _categoryPageMainWidgetBuilder() {
    if (globals.categories.length > 1) {
      return CategoriesGridVisualizer();
    } else {
      return _noCategoriesWidgetBuilder();
    }
  }

  // Main Widget in case of no categories to visualize
  Widget _noCategoriesWidgetBuilder() {
    return Center(
        child: Padding(
      padding: const EdgeInsets.all(50),
      child: SizedBox(
        height: 300,
        child: Column(
          children: const [
            Text("No Categories Found!", style: TextStyle(fontSize: 24, color: Colors.white)),
            Padding(
              padding: EdgeInsets.all(12),
              child: Text("😭",
                  style: TextStyle(
                    fontSize: 45, // !!! WARNING: if too big: BUG on RENDER
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
}

// Categories Grid Visualizer
class CategoriesGridVisualizer extends StatefulWidget {
  const CategoriesGridVisualizer({Key? key}) : super(key: key);

  @override
  State<CategoriesGridVisualizer> createState() => CategoriesGridVisualizerState();
}

class CategoriesGridVisualizerState extends State<CategoriesGridVisualizer> {
  var additionalBordersPad = 4.0;
  late Offset _tapDownPosition;
  final List<Category> categoriesList = globals.categories.sublist(1); // first is removed: because the default one

  @override
  Widget build(BuildContext context) {
    List<Category> categoriesList = globals.categories.sublist(1);

    return GridView.count(
      crossAxisCount: 2,
      children: List.generate(categoriesList.length, (index) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: Padding(
              padding: EdgeInsets.only(left: (index + 1) % 2 * additionalBordersPad, right: index % 2 * additionalBordersPad),
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
                                // Navigator.pop close the pop-up while showing the dialog.
                                // We have to wait till the animations finish, and then open the dialog.
                                WidgetsBinding.instance?.addPostFrameCallback((_) {
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text("🔥 Confirm Category Delete?"),
                                          content: const Text("Tasks from this category will be moved to default category \"🏠 All\".\nYou can't undo this operation"),
                                          actions: <Widget>[
                                            Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: <Widget>[
                                                  FloatingActionButton(
                                                    heroTag: "UndoCategoryDelete",
                                                    onPressed: () {
                                                      setState(() {
                                                        debugPrint("Category delete cancelled!");
                                                        Navigator.of(context).pop();
                                                      });
                                                    },
                                                    tooltip: "Cancel",
                                                    child: const Icon(Icons.cancel),
                                                  ),
                                                  FloatingActionButton(
                                                    heroTag: "ConfirmDelete",
                                                    backgroundColor: Colors.redAccent,
                                                    onPressed: () {
                                                      debugPrint("Category Delete confirmed!");
                                                      categories.deleteCategory(index + 1).then((_) => setState(() {}));
                                                      Navigator.of(context).pop();
                                                      showPopUpMessage(context, "💣", "Category Deleted!", null);
                                                    },
                                                    tooltip: "Confirm",
                                                    child: const Icon(Icons.delete),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        );
                                      });
                                });
                              },
                              value: 0,
                              child: Row(
                                children: const <Widget>[
                                  Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  Text(
                                    "Delete",
                                    style: TextStyle(color: Colors.red),
                                  ),
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
                      margin: EdgeInsets.zero,
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
                            style: const TextStyle(fontSize: 50),
                          ),
                          Container(
                            height: 7,
                          ),
                          Text(
                            categoriesList[index].name,
                            style: const TextStyle(fontSize: 24, color: Colors.white),
                          ),
                        ],
                      )),
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
