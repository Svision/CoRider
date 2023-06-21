import 'package:corider/providers/user_state.dart';
import 'package:corider/models/vehicle_model.dart';
import 'package:corider/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

List<int> years = List.generate(
    DateTime.now().year - 1989, (index) => DateTime.now().year - index);

List<int> availableSeats = [1, 2, 3, 4, 5, 6, 7, 8];

Map<String, List<String>> makeModels = {
  'Audi': ['A3', 'A4', 'A5', 'A6', 'A7', 'A8', 'Q3', 'Q5', 'Q7', 'TT', 'R8'],
  'BMW': [
    'X1',
    'X2',
    'X3',
    'X4',
    'X5',
    'X6',
    'X7',
    'Z4',
    'M2',
    'M3',
    'M4',
    'M5',
    'M6',
    'M8',
    'i3',
    'i8'
  ],
  'Mercedes-Benz': [
    'A-Class',
    'C-Class',
    'E-Class',
    'S-Class',
    'GLA',
    'GLB',
    'GLC',
    'GLE',
    'GLS',
    'CLA',
    'CLS',
    'SLC',
    'SL',
    'AMG GT'
  ],
  'Tesla': ['Model 3', 'Model S', 'Model X', 'Model Y', 'Roadster'],
  'Toyota': [
    'Camry',
    'Corolla',
    'Prius',
    'Rav4',
    'Highlander',
    '4Runner',
    'Tacoma',
    'Tundra',
    'Sienna'
  ],
  'Honda': ['Accord', 'Civic', 'CR-V', 'Pilot', 'Odyssey', 'Ridgeline'],
  'Ford': ['Mustang', 'F-150', 'Explorer', 'Escape', 'Focus', 'Fusion', 'Edge'],
  'Chevrolet': [
    'Cruze',
    'Malibu',
    'Impala',
    'Equinox',
    'Traverse',
    'Silverado',
    'Camaro',
    'Corvette'
  ],
  'Volkswagen': [
    'Golf',
    'Passat',
    'Jetta',
    'Tiguan',
    'Atlas',
    'Arteon',
    'Touareg'
  ],
  'Volvo': ['S60', 'S90', 'XC40', 'XC60', 'XC90'],
  'Subaru': ['Impreza', 'Legacy', 'Forester', 'Outback', 'Crosstrek', 'Ascent'],
};

List<String> colors = [
  'Black',
  'White',
  'Gray',
  'Red',
  'Blue',
  'Green',
  'Brown',
  'Yellow',
  'Orange',
  'Purple',
  'Pink',
  'Other',
];

class AddVehiclePage extends StatefulWidget {
  final VehicleModel? vehicle;
  const AddVehiclePage({Key? key, required this.vehicle}) : super(key: key);

  @override
  State<AddVehiclePage> createState() => _AddVehiclePageState();
}

class _AddVehiclePageState extends State<AddVehiclePage> {
  int yearSelected = years.first;
  late List<String> makes;
  late VehicleModel? vehicle;
  late ValueNotifier<String> makeSelectedNotifier;
  late TextEditingController _licensePlateController;
  late String modelSelected;
  late int availableSeatsSelected;
  String colorSelected = colors.first;
  String? licensePlate = '';
  late List<String> makeAlphabet;
  late ValueNotifier<String> makeAlphabetSelectedNotifier;
  bool isLoadingMakes = true;
  bool isLoadingModels = true;
  bool isLoadingColors = true;

  @override
  void initState() {
    super.initState();
    vehicle = widget.vehicle;
    debugPrint(vehicle?.toJson().toString());
    makes = makeModels.keys.toList();
    makes.sort();
    makeAlphabet = makes.map((e) => e.substring(0, 1)).toSet().toList();
    makeAlphabet.sort();

    if (vehicle != null) {
      yearSelected = vehicle!.year!;
      makeAlphabetSelectedNotifier =
          ValueNotifier<String>(vehicle!.make!.substring(0, 1));
      makeSelectedNotifier = ValueNotifier<String>(vehicle!.make!);
      modelSelected = vehicle!.model!;
      colorSelected = vehicle!.color!;
      licensePlate = vehicle!.licensePlate;
      availableSeatsSelected = vehicle!.availableSeats ?? 4;
    } else {
      makeAlphabetSelectedNotifier = ValueNotifier<String>(makeAlphabet.first);
      makeSelectedNotifier = ValueNotifier<String>(makes.first);
      modelSelected = makeModels[makeSelectedNotifier.value]!.first;
      availableSeatsSelected = 4;
    }
    _licensePlateController = TextEditingController(text: licensePlate);
  }

  @override
  Widget build(BuildContext context) {
    final userState = Provider.of<UserState>(context);
    final currentUser = userState.currentUser!;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Vehicle Info'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(children: [
                Row(
                  children: [
                    SizedBox(
                        width: 80,
                        child: DropdownButtonFormField<int>(
                          value: yearSelected,
                          items: years.map((int value) {
                            return DropdownMenuItem<int>(
                              value: value,
                              child: Text(value.toString()),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              yearSelected = value!;
                            });
                          },
                          decoration: const InputDecoration(labelText: 'Year'),
                          menuMaxHeight: 300.0,
                        )),
                    const SizedBox(width: 18),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: colorSelected,
                        items: colors.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Row(
                              children: [
                                Container(
                                  width: 16,
                                  height: 16,
                                  color: Utils.getColorFromValue(value),
                                  margin: const EdgeInsets.only(right: 8),
                                ),
                                Text(value),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            colorSelected = value!;
                          });
                        },
                        decoration: const InputDecoration(labelText: 'Color'),
                        menuMaxHeight: 300.0,
                      ),
                    )
                  ],
                ),
                Row(
                  children: [
                    SizedBox(
                      width: 80,
                      child: DropdownButtonFormField<String>(
                        value: makeAlphabetSelectedNotifier.value,
                        items: makeAlphabet.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            makeSelectedNotifier.value = makeModels.keys
                                .where((e) => e.startsWith(value!))
                                .first;
                            modelSelected =
                                makeModels[makeSelectedNotifier.value]!.first;
                            makeAlphabetSelectedNotifier.value = value!;
                          });
                        },
                        decoration:
                            const InputDecoration(labelText: 'Make Initial'),
                        menuMaxHeight: 300.0,
                      ),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                        child: ValueListenableBuilder<String?>(
                            valueListenable: makeAlphabetSelectedNotifier,
                            builder: (context, makeAlphabetSelected, _) {
                              debugPrint(
                                  'makeAlphabetSelected: ${makeAlphabetSelected!}');
                              return DropdownButtonFormField<String>(
                                value: makeSelectedNotifier.value,
                                items: makeModels.keys
                                    .where((e) =>
                                        e.startsWith(makeAlphabetSelected))
                                    .map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    modelSelected = makeModels[value!]!.first;
                                    makeSelectedNotifier.value = value;
                                  });
                                },
                                decoration:
                                    const InputDecoration(labelText: 'Make'),
                                menuMaxHeight: 300.0,
                              );
                            })),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: ValueListenableBuilder<String?>(
                        valueListenable: makeSelectedNotifier,
                        builder: (context, makeSelected, _) {
                          debugPrint('makeSelected: ${makeSelected!}');
                          debugPrint('modelSelected: $modelSelected');
                          return DropdownButtonFormField<String>(
                            value: modelSelected,
                            items:
                                makeModels[makeSelected]!.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                modelSelected = value!;
                              });
                            },
                            decoration:
                                const InputDecoration(labelText: 'Model'),
                            menuMaxHeight: 300.0,
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 18),
                    SizedBox(
                      width: 120,
                      child: DropdownButtonFormField<int>(
                        value: availableSeatsSelected,
                        items: availableSeats.map((int value) {
                          return DropdownMenuItem<int>(
                            value: value,
                            child: Text(value.toString()),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            availableSeatsSelected = value!;
                          });
                        },
                        decoration: const InputDecoration(
                            labelText: 'Availabile Seats'),
                        menuMaxHeight: 300.0,
                      ),
                    )
                  ],
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'License Plate'),
                  textCapitalization: TextCapitalization.characters,
                  controller: _licensePlateController,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^[A-Z0-9]{1,7}$'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      licensePlate = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    VehicleModel savedVehicle = VehicleModel(
                        year: yearSelected,
                        make: makeSelectedNotifier.value,
                        model: modelSelected,
                        color: colorSelected,
                        licensePlate: licensePlate,
                        availableSeats: availableSeatsSelected);
                    debugPrint(savedVehicle.toJson().toString());
                    currentUser
                        .saveVehicle(userState, savedVehicle)
                        .then((err) => {
                              if (err == null)
                                {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content:
                                          Text('Vehicle information saved!'),
                                      duration: Duration(seconds: 2),
                                    ),
                                  ),
                                  Navigator.of(context).pop(savedVehicle),
                                }
                              else
                                {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Error: $err'),
                                      duration: const Duration(seconds: 2),
                                    ),
                                  ),
                                }
                            });
                  },
                  child: vehicle == null
                      ? const Text('Add New Vehicle')
                      : const Text('Update Vehicle'),
                ),
                const SizedBox(height: 32),
                if (vehicle != null)
                  ElevatedButton(
                    onPressed: () {
                      currentUser.deleteVehicle(userState).then((err) => {
                            if (err == null)
                              {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text('Vehicle information deleted!'),
                                    duration: Duration(seconds: 2),
                                  ),
                                ),
                                Navigator.of(context).pop(),
                              }
                            else
                              {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error: $err'),
                                    duration: const Duration(seconds: 2),
                                  ),
                                ),
                              }
                          });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Colors.red, // Set the background color to red
                    ),
                    child: const Text('Delete'),
                  ),
              ])
            ],
          ),
        ),
      ),
    );
  }
}
