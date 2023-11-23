import 'package:flutter/material.dart';
import 'package:flutter_google_maps_webservices/places.dart';
import 'package:google_places_autocomplete_text_field/google_places_autocomplete_text_field.dart';

class PlaceSearchScreen extends StatefulWidget {
  const PlaceSearchScreen({super.key});

  @override
  _PlaceSearchScreenState createState() => _PlaceSearchScreenState();
}

class _PlaceSearchScreenState extends State<PlaceSearchScreen> {
  final GoogleMapsPlaces _places =
      GoogleMapsPlaces(apiKey: 'AIzaSyCSYkw7DzU0Ha4-gpDdwl7kHO84IW7CtlU');
  final TextEditingController _searchController = TextEditingController();
  final List<PlacesSearchResult> _searchResults = [];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<List<PlacesSearchResult>> _searchPlaces(String searchTerm) async {
    PlacesSearchResponse response = await _places.searchByText(searchTerm);
    return response.results;
  }

  void onItemSelected(PlacesSearchResult selectedPlace) async {}

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
        ),
        decoration: BoxDecoration(
            color: Colors.grey.withOpacity(.3),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.redAccent, width: 2)),
        child: GooglePlacesAutoCompleteTextFormField(
            proxyURL: 'https://cors-anywhere.herokuapp.com/',
            inputDecoration: const InputDecoration(
                border: InputBorder.none, hintText: "Search here"),
            textEditingController: _searchController,
            googleAPIKey: 'AIzaSyCSYkw7DzU0Ha4-gpDdwl7kHO84IW7CtlU',
            decoration: const InputDecoration(
                border: InputBorder.none, focusedBorder: InputBorder.none),
            getPlaceDetailWithLatLng: (predictions) {
              print(predictions.description);
              // Update the UI with the received predictions
              // return ListView.builder(
              //   shrinkWrap: true,
              //   itemCount: predictions.length,
              //   itemBuilder: (context, index) {
              //     return ListTile(
              //       title: Text(predictions[index].description),
              //       onTap: () => _onItemSelected(predictions[index]),
              //     );
              //   },
              // );
            },
            itmClick: (prediction) {
              _searchController.text = prediction.description!;
              _searchController.selection = TextSelection.fromPosition(
                  TextPosition(offset: prediction.description!.length));
            }),
      ),
    );
  }
}
