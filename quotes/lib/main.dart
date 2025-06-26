import 'package:flutter/material.dart';
import 'package:quotes/quote.dart';

void main() {
  runApp(MaterialApp(
    home: quotelist(),
  ));
}

class quotelist extends StatefulWidget {
  @override
  State<quotelist> createState() => _quotelistState();
}
class _quotelistState extends State<quotelist> {

  List<Quote> quotes=[
    Quote(text:'The best way to get started is to quit talking and start doing',author:'Walt Disney'),
    Quote(text:'Our greatest glory is not in never falling',author:'Nelson Mandela'),
    Quote(text:'Knowing yourself is the beginning of all wisdom', author:'Aristotle'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title:Text('Awesome Quotes'),
        centerTitle: true,
        backgroundColor: Colors.redAccent,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: quotes.map((quote)=>Quotecard(quote: quote,delete: (){
          setState(() {
            quotes.remove(quote);
          });
        })).toList(),
      ),
    );
  }
}

class Quotecard extends StatelessWidget {
  final Quote quote;
  final void Function() delete;
  Quotecard({required this.quote,required this.delete});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              quote.text,
              style: TextStyle(
                fontSize: 18.0,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 6.0),
            Text(
              quote.author,
              style: TextStyle(
                fontSize: 14.0,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 8.0),
            TextButton.icon(
              onPressed: delete,
              label: Text('delete quote'),
              icon:Icon(Icons.delete),
            )
          ],
        ),
      ),
    );
  }
}
