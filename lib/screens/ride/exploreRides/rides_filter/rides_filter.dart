import 'package:corider/screens/ride/exploreRides/rides_filter/filter_sort_enum.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class RidesFilter extends StatefulWidget {
  final Function(RideOfferFilter) onFilterChanged;
  final Function(RideOfferSortBy) onSortChanged;

  const RidesFilter({
    Key? key,
    required this.onFilterChanged,
    required this.onSortChanged,
  }) : super(key: key);

  @override
  State<RidesFilter> createState() => _RidesFilterState();
}

class _RidesFilterState extends State<RidesFilter> {
  String selectedFilter = describeEnum(RideOfferFilter.ALL);
  String selectedSort = describeEnum(RideOfferSortBy.DEFAULT);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      color: Colors.grey[200],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Filter'),
          DropdownButton<String>(
              value: selectedFilter,
              onChanged: (value) {
                setState(() {
                  selectedFilter = value!;
                });
                widget.onFilterChanged(RideOfferFilter.values.firstWhere((filter) => describeEnum(filter) == value));
              },
              items: RideOfferFilter.values.map((filter) {
                return DropdownMenuItem(
                  value: describeEnum(filter),
                  child: Text(
                    describeEnum(filter)[0].toUpperCase() + describeEnum(filter).substring(1),
                  ),
                );
              }).toList()),
          const Text('Sort by'),
          DropdownButton<String>(
              value: selectedSort,
              onChanged: (value) {
                setState(() {
                  selectedSort = value!;
                });
                widget.onSortChanged(RideOfferSortBy.values.firstWhere((sort) => describeEnum(sort) == value));
              },
              items: RideOfferSortBy.values.map((sort) {
                return DropdownMenuItem(
                  value: describeEnum(sort),
                  child: Text(
                    describeEnum(sort)[0].toUpperCase() + describeEnum(sort).substring(1),
                  ),
                );
              }).toList()),
        ],
      ),
    );
  }
}
