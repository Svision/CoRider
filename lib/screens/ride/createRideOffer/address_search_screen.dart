import 'package:corider/providers/place_api_provider.dart';
import 'package:corider/widgets/address_search.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:geocoding/geocoding.dart';
import 'package:tuple/tuple.dart';

class AddressSearchScreen extends StatefulWidget {
  const AddressSearchScreen({Key? key}) : super(key: key);

  @override
  _AddressSearchScreenState createState() => _AddressSearchScreenState();
}

class _AddressSearchScreenState extends State<AddressSearchScreen> {
  final _controller = TextEditingController();
  String _streetNumber = '';
  String _street = '';
  String _city = '';
  String _province = '';
  String _postalCode = '';
  bool _isSaveLoading = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Search Address'),
        ),
        body: Container(
          margin: const EdgeInsets.only(left: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 8, right: 16),
                child: TextField(
                  controller: _controller,
                  readOnly: true,
                  onTap: () async {
                    // generate a new token here
                    final sessionToken = const Uuid().v4();
                    final Suggestion? result = await showSearch(
                      context: context,
                      delegate: AddressSearch(sessionToken),
                    );
                    // This will change the text displayed in the TextField
                    if (result != null) {
                      final placeDetails = await PlaceApiProvider(sessionToken)
                          .getPlaceDetailFromId(result.placeId);
                      setState(() {
                        _controller.text = result.description;
                        _streetNumber = placeDetails.streetNumber!;
                        _street = placeDetails.street!;
                        _city = placeDetails.city!;
                        _province = placeDetails.province!;
                        _postalCode = placeDetails.postalCode!;
                      });
                    }
                  },
                  decoration: const InputDecoration(
                    icon: Icon(
                      Icons.search,
                      color: Colors.black,
                    ),
                    hintText: "Enter your address",
                  ),
                ),
              ),
              const SizedBox(height: 20.0),
              Text('Street Number: $_streetNumber'),
              Text('Street: $_street'),
              Text('City: $_city'),
              Text('Province: $_province'),
              Text('Postal Code: $_postalCode'),
              const SizedBox(height: 20.0),
              Center(
                child: _isSaveLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: () async {
                          setState(() {
                            _isSaveLoading = true;
                          });
                          List<Location> locations =
                              await locationFromAddress(_controller.text);
                          final Tuple2<String, LatLng> text2location = Tuple2(
                              _controller.text,
                              LatLng(locations.first.latitude,
                                  locations.first.longitude));
                          setState(() {
                            _isSaveLoading = false;
                          });
                          Navigator.pop(context, text2location);
                        },
                        child: const Text('Save'),
                      ),
              ),
            ],
          ),
        ));
  }
}
