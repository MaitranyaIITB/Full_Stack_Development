import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  Map data={};

  @override
  Widget build(BuildContext context) {
    data = data.isNotEmpty ? data : ModalRoute.of(context)?.settings.arguments as Map;
    print(data);
    String bgImage= data['isDaytime']? 'day.png':'night.png';
    Color? bgcolor = data['isDaytime'] ? Colors.lightBlue[700] : Colors.indigo[700];

    return Scaffold(
      backgroundColor: bgcolor,
      body: SafeArea(
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/$bgImage'),
                fit: BoxFit.cover,
              ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0,120.0,0,0),
            child: Column(
              children: <Widget>[
                TextButton.icon(
                    onPressed:() async {
                      dynamic result = await Navigator.pushNamed(context, '/location');
                      setState(() {
                        data={
                          'time':result['time'],
                          'location':result['location'],
                          'isDaytime':result['isDaytime'],
                          'flag':result['flag'],
                        };
                      });
                    },
                    icon: Icon(
                        Icons.edit_location,
                        color: Colors.grey,
                    ),
                    label: Text(
                        'Edit Location',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 25.0,
                        ),
                    ),
                ),
                SizedBox(height: 20.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      data['location'],
                      style: TextStyle(
                      fontSize: 38.0,
                      letterSpacing: 2.0,
                      color: Colors.white,
                    ),
                    ),
                  ],
                ),
                SizedBox(height: 20.0),
                Text(
                  data['time'],
                  style: TextStyle(
                    fontSize: 66.0,
                    letterSpacing: 2.0,
                    color: Colors.white,
                  ),
                ),
                ],
            ),
          ),
      ),
      ),
    );
  }
}
