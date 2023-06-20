import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart';

class Place {
  String? streetNumber;
  String? street;
  String? city;
  String? province;
  String? postalCode;

  Place({
    this.streetNumber,
    this.street,
    this.city,
    this.province,
    this.postalCode,
  });

  @override
  String toString() {
    return '$streetNumber, $street, $city, $province, $postalCode';
  }
}

class Suggestion {
  final String placeId;
  final String description;

  Suggestion(this.placeId, this.description);

  @override
  String toString() {
    return 'Suggestion(description: $description, placeId: $placeId)';
  }
}

class PlaceApiProvider {
  final client = Client();

  PlaceApiProvider(this.sessionToken);

  final sessionToken;
  final apiKey = 'AIzaSyByejbYzjTBQNgfrMKi5XIj3IDotnh3rNI';

  Future<List<Suggestion>> fetchSuggestions(
      String input, String lang, String country) async {
    try {
      final request = Uri.parse(
          'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&types=address&language=$lang&components=country:CA&key=$apiKey&sessiontoken=$sessionToken');
      final response = await client.get(request);

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        debugPrint(result.toString());
        if (result['status'] == 'OK') {
          // compose suggestions in a list
          return result['predictions']
              .map<Suggestion>(
                  (p) => Suggestion(p['place_id'], p['description']))
              .toList();
        }
        if (result['status'] == 'ZERO_RESULTS') {
          return [];
        }
        throw Exception(result['error_message']);
      } else {
        throw Exception('Failed to fetch suggestion');
      }
    } catch (e) {
      debugPrint(e.toString());
      return [];
    }
  }

  Future<Place> getPlaceDetailFromId(String placeId) async {
    try {
      final Uri request = Uri.parse(
          'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&fields=address_component&key=$apiKey&sessiontoken=$sessionToken');
      final response = await client.get(request);

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        debugPrint(result.toString());
        if (result['status'] == 'OK') {
          final components =
              result['result']['address_components'] as List<dynamic>;
          // build result
          final place = Place();
          for (var c in components) {
            final List type = c['types'];
            if (type.contains('street_number')) {
              place.streetNumber = c['long_name'];
            }
            if (type.contains('route')) {
              place.street = c['long_name'];
            }
            if (type.contains('locality')) {
              place.city = c['long_name'];
            }
            if (type.contains('administrative_area_level_1')) {
              place.province = c['long_name'];
            }
            if (type.contains('postal_code')) {
              place.postalCode = c['long_name'];
            }
          }
          return place;
        }
        throw Exception(result['error_message']);
      } else {
        throw Exception('Failed to fetch suggestion');
      }
    } catch (e) {
      debugPrint(e.toString());
      return Place();
    }
  }
}
