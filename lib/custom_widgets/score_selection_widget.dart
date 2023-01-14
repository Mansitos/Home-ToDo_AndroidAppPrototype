import 'package:flutter/material.dart';

// Score selection ⭐⭐⭐⭐⭐ widget (for new_task_form)

class ScoreSelection extends StatefulWidget {
  const ScoreSelection({Key? key, required this.formKey, required this.onChange, required this.startingScore}) : super(key: key);

  final GlobalKey<FormState> formKey;
  final intCallback onChange;
  final int startingScore;

  @override
  State<ScoreSelection> createState() => ScoreSelectionState();
}

typedef void intCallback(int val);

class ScoreSelectionState extends State<ScoreSelection> {
  int maxScore = 5;
  int? selectedScore;
  double h = 23;
  double w = 23;
  double pad = 1;
  double iconDim = 22;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: (w + pad * 2) * maxScore,
      height: h + pad * 2,
      child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.all(0),
          itemCount: maxScore,
          itemBuilder: (ctx, index) {
            return Padding(
              padding: EdgeInsets.all(pad),
              child: SizedBox(
                height: h,
                width: w,
                child: IconButton(
                    onPressed: () {
                      setState(() {
                        int newScore = index + 1;
                        selectedScore = newScore;
                        widget.onChange(newScore);
                      });
                    },
                    iconSize: iconDim,
                    padding: const EdgeInsets.all(0),
                    icon: Icon(
                      Icons.star,
                      color: _getStarColor(index + 1, widget.startingScore),
                    )),
              ),
            );
          }),
    );
  }

  Color _getStarColor(int starValue, int selectedScore) {
    if (starValue <= selectedScore) {
      return Colors.white;
    } else {
      return Colors.black45;
    }
  }
}
