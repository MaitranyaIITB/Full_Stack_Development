import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    home: IDcard(),
  ));
}


class IDcard extends StatefulWidget {
  const IDcard({super.key});

  @override
  State<IDcard> createState() => _IDcardState();
}

class _IDcardState extends State<IDcard> {
  int level = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange[300],
      appBar: AppBar(
        title: Text('BJP ID CARD',
        style: TextStyle(
          color: Colors.white,
          fontSize: 30.0,
          fontWeight: FontWeight.bold,
        ),
        ),
        backgroundColor: Colors.green,
        centerTitle: true,
        elevation: 0.0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            level += 1;
          });
        },
        backgroundColor: Colors.green,
        child: Icon(Icons.add),
       ),
      body: Padding(
          padding: EdgeInsets.fromLTRB(30.0, 40.0, 30.0, 0.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Center(
                child: CircleAvatar(
                  backgroundImage: AssetImage('assets/Papa.jpg'),
                  radius: 80.0,
                ),
              ),
              Divider(
                height: 90.0,
                color: Colors.red[800],
              ),
              SizedBox(height: 10.0),
              Text(
                'MAHESH BAPU',
                style: TextStyle(
                  color: Colors.red,
                  letterSpacing: 2.0,
                  fontSize: 28.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 30.0),
              Text(
                '$level',
                style: TextStyle(
                    fontSize: 28.0,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2.0,

              ),
                ),
              SizedBox(height: 30.0),
              Row(
                children: <Widget>[
                  Icon(
                    Icons.facebook,
                    color: Colors.red,
                  ),
                  SizedBox(width: 10.0),
                  Text(
                    'Maheshrao Patil',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 32.0,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30.0),
              Row(
                children: <Widget>[
                  Icon(
                    Icons.call,
                    color: Colors.red,
                  ),
                  SizedBox(width: 10.0),
                  Text(
                    '+91 96047 32006',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 32.0,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30.0),
              Center(
                child: Image.network(
                    'https://imgs.search.brave.com/Ew6dYjI_OHQXrd5EqxrMlQRXBgTazLkJhHQ92FAVJXc/rs:fit:500:0:0:0/g:ce/aHR0cHM6Ly93d3cu/ZnJlZXBuZ2xvZ29z/LmNvbS91cGxvYWRz/L2JqcC9mcmVlLWJq/cC1wbmctbG9nby10/cmFuc3BhcmVudC1j/aXJjbGUtc3ltYm9s/LTIucG5n',
                  width:250,
                  height:250,
                )
              )
            ],
            ),
          ),
      );
  }
}
