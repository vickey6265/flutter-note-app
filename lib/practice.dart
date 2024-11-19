void main() {

  print("Welcome to Dart / Flutter");
  var myC = myClass(); //created instance of a class
  myC.printName('vivek'); //function calling
  myC.personalDetails('vivek','dart');
  print(myC.Add(5, 6));
  print(myC.Add(55, 66));

  //lists
  var listNum = [10,20,30,40];
  listNum.add(50);
  print(listNum);
  listNum.remove(10);
  print(listNum);

  var copyListNum = [];
  copyListNum.addAll(listNum);
  copyListNum.insert(2, "vivek");
  copyListNum.insertAll(3, listNum);
  copyListNum[1] = "krishna";
  copyListNum.replaceRange(0, 3, ['a','b','c','d']);
  print(copyListNum);
  print("Length: ${copyListNum.length}");
  print("First: ${copyListNum.first}");
  print("Last: ${copyListNum.last}");
  print("Is Empty?: ${copyListNum.isEmpty ? "Yes" : "No"}");

  //we can make changes in final at compile time - can not be ressign
  final name = "vivek";

  final String address;
  address = "Home";

  var names = ["a","b","c"];
  names.add("d");

  //const - can not make changes at compile time - it will be constant throughout life cycle of an application

  //loops
  for (int i = 0; i <= 10; i++) {
    print("Number is: $i");
  }

  //do while will execute at once no matter what.
  int num = 5;
  do {
    print("do happen");
  }while(num<6);
  
  // while() {
  //
  // }
}

//created instance of a class
class myClass {
  void printName(String name) { // Declaration
    print("$name"); //definition
  }

  void personalDetails(String name,String course) {
    print('$name$course');
  }

  int Add(int a, int b) {
    int sum = a+b;
    return sum;
  }
}