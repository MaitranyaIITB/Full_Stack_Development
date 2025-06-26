import 'package:http/http.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

class WorldTime{

  String location;
  String time='';
  String flag;
  String url;
  bool isDaytime=true;

  WorldTime({this.location='Kolkata', this.flag='india.png', this.url='Asia/Kolkata'});
  Future<void> getTime() async {
    try {
      Response response = await get(Uri.parse(
          'https://www.timeapi.io/api/Time/current/zone?timeZone=$url'));
      Map data = jsonDecode(response.body);
      String datetime = data['dateTime'];
      DateTime now = DateTime.parse(datetime);
      time = DateFormat.jm().format(now);
      isDaytime = now.hour > 6 && now.hour < 20 ? true : false;
    }
    catch (e) {
      print('caught error: $e');
      time = 'could not get time data';
    }
}
}