import 'package:flutter/material.dart';

List<int> years = List.generate(
    DateTime.now().year - 1989, (index) => DateTime.now().year - index);

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
  'Toyota': ['Camry', 'Corolla', 'Prius', 'Rav4', 'Highlander', '4Runner', 'Tacoma', 'Tundra', 'Sienna'],
  'Honda': ['Accord', 'Civic', 'CR-V', 'Pilot', 'Odyssey', 'Ridgeline'],
  'Ford': ['Mustang', 'F-150', 'Explorer', 'Escape', 'Focus', 'Fusion', 'Edge'],
  'Chevrolet': ['Cruze', 'Malibu', 'Impala', 'Equinox', 'Traverse', 'Silverado', 'Camaro', 'Corvette'],
  'Volkswagen': ['Golf', 'Passat', 'Jetta', 'Tiguan', 'Atlas', 'Arteon', 'Touareg'],
  'Volvo': ['S60', 'S90', 'XC40', 'XC60', 'XC90'],
  'Subaru': ['Impreza', 'Legacy', 'Forester', 'Outback', 'Crosstrek', 'Ascent'],
};

List<String> colors = [
  'Black',
  'White',
  'Silver',
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
  const AddVehiclePage({Key? key}) : super(key: key);

  @override
  State<AddVehiclePage> createState() => _AddVehiclePageState();
}

class _AddVehiclePageState extends State<AddVehiclePage> {
  int yearSelected = years.first;
  late List<String> makes;
  late ValueNotifier<String> makeSelectedNotifier;
  late String modelSelected;
  String colorSelected = colors.first;
  String licensePlate = '';
  late List<String> makeAlphabet;
  late ValueNotifier<String> makeAlphabetSelectedNotifier;
  bool isLoadingMakes = true;
  bool isLoadingModels = true;
  bool isLoadingColors = true;

  @override
  void initState() {
    super.initState();
    makes = makeModels.keys.toList();
    makes.sort();
    makeAlphabet = makes.map((e) => e.substring(0, 1)).toSet().toList();
    makeAlphabet.sort();
    makeAlphabetSelectedNotifier = ValueNotifier<String>(makeAlphabet.first);
    makeSelectedNotifier = ValueNotifier<String>(makes.first);
    modelSelected = makeModels[makeSelectedNotifier.value]!.first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Vehicle Info'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(children: [
              DropdownButtonFormField<int>(
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
                                  .where(
                                      (e) => e.startsWith(makeAlphabetSelected))
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
              ValueListenableBuilder<String?>(
                valueListenable: makeSelectedNotifier,
                builder: (context, makeSelected, _) {
                  debugPrint('makeSelected: ${makeSelected!}');
                  debugPrint('modelSelected: $modelSelected');
                  return DropdownButtonFormField<String>(
                    value: modelSelected,
                    items: makeModels[makeSelected]!.map((String value) {
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
                    decoration: const InputDecoration(labelText: 'Model'),
                    menuMaxHeight: 300.0,
                  );
                },
              ),
              DropdownButtonFormField<String>(
                value: colorSelected,
                items: colors.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
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
              TextFormField(
                decoration: const InputDecoration(labelText: 'License Plate'),
                onChanged: (value) {
                  setState(() {
                    licensePlate = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // TODO: Save the vehicle information
                  // You can access the entered values using the state variables (make, model, year, etc.)
                },
                child: const Text('Save'),
              ),
            ])
          ],
        ),
      ),
    );
  }
}
