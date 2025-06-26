import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    home:Home()
  ));
}
class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(
        title: Text('My First App'),
        centerTitle: true,
        backgroundColor: Colors.red[600],
      ),
      body: Row(
        children:<Widget> [
          Expanded(
              flex: 1,
              child: Image.asset('assets/nature-1.jpg')
          ),
          Expanded(
            flex: 2,
            child: Container(
              color: Colors.cyan,
              padding: EdgeInsets.all(30),
              child: Text('1'),
            ),
          ),
          Expanded(
            flex:2,
            child: Container(
              color: Colors.pinkAccent,
              padding: EdgeInsets.all(30),
              child: Text('2'),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              color: Colors.amber,
              padding: EdgeInsets.all(30),
              child: Text('3'),
            ),
          ),

        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: Text('Click'),
        backgroundColor: Colors.orange,
      ),
    );
  }
}
