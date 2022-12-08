class User {
  User({required this.name, required this.score});

  String name;
  String image = "temp/path";
  int score;


  @override
  String toString() {
    return name;
  }

  void addScore(int add){
    this.score = this.score + add;
  }

  void removeScore(int remove){
    this.score = this.score - remove;
    if(this.score < 0){
      this.score = 0;
    }
  }
}
