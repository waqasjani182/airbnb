import 'package:flutter/material.dart';
import 'search_results.dart'; // Make sure to import this

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final Map<String, bool> propertyTypes = {
    'Room': false,
    'Flat': false,
    'House': false,
  };

  String selectedCity = 'Peshawar';

  RangeValues priceRange = const RangeValues(0, 0);
  RangeValues ratingRange = const RangeValues(0, 0);

  final TextEditingController minPriceController = TextEditingController();
  final TextEditingController maxPriceController = TextEditingController();
  final TextEditingController minRatingController = TextEditingController();
  final TextEditingController maxRatingController = TextEditingController();

  DateTime? dateFrom;
  DateTime? dateTo;

  int adults = 0;
  int children = 0;

  bool bedroom = false;
  bool ac = false;
  bool tv = false;
  bool wifi = false;
  bool bathroom = false;
  bool kitchen = false;
  bool microwave = false;
  bool refrigerator = false;

  @override
  void dispose() {
    minPriceController.dispose();
    maxPriceController.dispose();
    minRatingController.dispose();
    maxRatingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Search Properties"),
        backgroundColor: Colors.red,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                buildPropertyCheckbox('Room'),
                buildPropertyCheckbox('Flat'),
                buildPropertyCheckbox('House'),
              ],
            ),
            const SizedBox(height: 20),

            const Text("City"),
            DropdownButton<String>(
              value: selectedCity,
              isExpanded: true,
              items: ['Peshawar', 'Karachi', 'Lahore', 'Islamabad']
                  .map((city) => DropdownMenuItem(
                value: city,
                child: Text(city),
              ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedCity = value!;
                });
              },
            ),

            const SizedBox(height: 20),
            const Text("Price Range (RS)"),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: minPriceController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "Min",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                const Text("to"),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: maxPriceController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "Max",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
            const Text("Rating"),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: minRatingController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "Min",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                const Text("to"),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: maxRatingController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "Max",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
            const Text("Date From"),
            InkWell(
              onTap: () async {
                DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                );
                if (picked != null) {
                  setState(() {
                    dateFrom = picked;
                  });
                }
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  dateFrom == null
                      ? "Select Date"
                      : "${dateFrom!.day}-${dateFrom!.month}-${dateFrom!.year}",
                ),
              ),
            ),

            const SizedBox(height: 20),
            const Text("Date To"),
            InkWell(
              onTap: () async {
                DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                );
                if (picked != null) {
                  setState(() {
                    dateTo = picked;
                  });
                }
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  dateTo == null
                      ? "Select Date"
                      : "${dateTo!.day}-${dateTo!.month}-${dateTo!.year}",
                ),
              ),
            ),

            const SizedBox(height: 20),
            const Text("Guests"),
            Row(
              children: [
                Expanded(child: buildGuestCounter("Adult", adults, (val) => setState(() => adults = val))),
                Expanded(child: buildGuestCounter("Child", children, (val) => setState(() => children = val))),
              ],
            ),

            const SizedBox(height: 20),
            const Text("Services"),
            buildServiceCheckbox('Bedroom', bedroom, (val) => setState(() => bedroom = val)),
            buildServiceCheckbox('AC', ac, (val) => setState(() => ac = val)),
            buildServiceCheckbox('TV', tv, (val) => setState(() => tv = val)),
            buildServiceCheckbox('WiFi', wifi, (val) => setState(() => wifi = val)),
            buildServiceCheckbox('Bathroom', bathroom, (val) => setState(() => bathroom = val)),
            buildServiceCheckbox('Kitchen', kitchen, (val) => setState(() => kitchen = val)),
            buildServiceCheckbox('Microwave', microwave, (val) => setState(() => microwave = val)),
            buildServiceCheckbox('Refrigerator', refrigerator, (val) => setState(() => refrigerator = val)),

            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      propertyTypes.updateAll((key, value) => false);
                      selectedCity = 'Peshawar';
                      priceRange = const RangeValues(0, 0);
                      ratingRange = const RangeValues(0, 0);
                      minPriceController.clear();
                      maxPriceController.clear();
                      minRatingController.clear();
                      maxRatingController.clear();
                      dateFrom = null;
                      dateTo = null;
                      adults = 0;
                      children = 0;
                      bedroom = ac = tv = wifi = bathroom = kitchen = microwave = refrigerator = false;
                    });
                  },
                  child: const Text("Clear All"),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.search),
                  label: const Text("Search"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SearchResultsScreen(
                          city: selectedCity,
                          propertyTypes: propertyTypes,
                          priceRange: RangeValues(
                            double.tryParse(minPriceController.text) ?? 0,
                            double.tryParse(maxPriceController.text) ?? 0,
                          ),
                          ratingRange: RangeValues(
                            double.tryParse(minRatingController.text) ?? 0,
                            double.tryParse(maxRatingController.text) ?? 0,
                          ),
                          dateFrom: dateFrom,
                          dateTo: dateTo,
                          adults: adults,
                          children: children,
                          services: {
                            'Bedroom': bedroom,
                            'AC': ac,
                            'TV': tv,
                            'WiFi': wifi,
                            'Bathroom': bathroom,
                            'Kitchen': kitchen,
                            'Microwave': microwave,
                            'Refrigerator': refrigerator,
                          },
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildPropertyCheckbox(String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Checkbox(
          value: propertyTypes[label],
          onChanged: (val) {
            setState(() {
              if (val != null) {
                propertyTypes[label] = val;
              }
            });
          },
        ),
        Text(label),
      ],
    );
  }

  Widget buildGuestCounter(String title, int count, ValueChanged<int> onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.remove),
              onPressed: () {
                if (count > 0) onChanged(count - 1);
              },
            ),
            Text('$count'),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                onChanged(count + 1);
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget buildServiceCheckbox(String title, bool value, ValueChanged<bool> onChanged) {
    return CheckboxListTile(
      title: Text(title),
      value: value,
      onChanged: (val) {
        if (val != null) {
          onChanged(val);
        }
      },
    );
  }
}
