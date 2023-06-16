import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'dart:io';
import "package:google_maps_webservice/places.dart";
import 'package:http/http.dart' as http;


class LocationService {
 static final String key = 'AIzaSyCJc75czqiuE1L-bq8WUYyZr0pR2kMt-m0';

  static Future<String> getPlaceId(String input) async {
    final String url =
        'https://maps.googleapis.com/maps/api/place/findplacefromtext/json?input=$input&inputtype=textquery';
        

    var response = await http.get(Uri.parse(url));
print('response body:...........................................${response.body}');
    if (response.statusCode == 200) {
      var convert;
      var json = convert.jsonDecode(response.body);
      var placeId = json['candidates'][0]['place_id'] as String;
      return placeId;
      
    } else {
      throw Exception('Failed to get place ID');
    }
  }
  
}

