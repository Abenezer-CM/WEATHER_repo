import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:provider/provider.dart';
import 'package:weatherapp/providers/theme_provider.dart';
import 'package:geolocator/geolocator.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  TextEditingController cityController = TextEditingController();

  String gpsUrl = "";

  var currentIndex = 0;
  String cityName = "";
  String countryName = "";
  String temp = "";
  String feelsLike = "";
  String main = "";
  String mainDesc = "";
  String windSpeed = "";
  String humidty = "";
  String visibility = "";
  String minTemp = "";
  String maxTemp = "";
  String seaLevel = "";
  String currentDate = "";
  String weatherIcon = "";
  String unitMeasurment = "";
  String groundLevel = "";
  String pressure = "";
  bool isweatherIcon = false;
  bool isLoading = true;
  bool isSearchByCity = false;

  Future<Object> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              backgroundColor: Colors.red[400],
              icon: InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: const Icon(Icons.close)),
              title: const Text("Location services are not enabled!"),
              actions: const [
                Text("try enabling them and reopen the app."),
              ],
            );
          });
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.

        setState(() {
          isLoading = false;
        });

        return showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                backgroundColor: Colors.red[400],
                icon: InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: const Icon(Icons.close)),
                title: const Text("Permission Denied!"),
                actions: const [
                  Text("give location permission and try again."),
                ],
              );
            });

        // Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    var userLocation = await Geolocator.getCurrentPosition();
    String longitude;
    String latitude;

    setState(() {
      longitude = userLocation.longitude.toString();
      latitude = userLocation.latitude.toString();

      var myProv = Provider.of<ThemeProvider>(context, listen: false);
      if (myProv.isImperial == true) {
        setState(() {
          unitMeasurment = "imperial";
        });
      } else {
        setState(() {
          unitMeasurment = "metric";
        });
      }

      gpsUrl =
          "https://api.openweathermap.org/data/2.5/weather?lat=$latitude&lon=$longitude&units=$unitMeasurment&appid=452981a3b5f97edd99f23de11d68f189";
    });
    getData(isSearchByCity);

    return userLocation;
  }

  Future<void> getData(bool isSearchByCity) async {
    var myProv = Provider.of<ThemeProvider>(context, listen: false);
    if (myProv.isImperial == true) {
      setState(() {
        unitMeasurment = "imperial";
      });
    } else {
      setState(() {
        unitMeasurment = "metric";
      });
    }

    String cityUrl =
        "https://api.openweathermap.org/data/2.5/weather?q=${cityController.text}&units=$unitMeasurment&appid=452981a3b5f97edd99f23de11d68f189";

    try {
      Response response =
          (isSearchByCity) ? await Dio().get(cityUrl) : await Dio().get(gpsUrl);

      DateTime now = DateTime.now();
      int year = now.year;
      int month = now.month;
      int day = now.day;

      setState(() {
        cityName = response.data["name"].toString();
        countryName = response.data["sys"]["country"].toString();
        temp = response.data["main"]["temp"].toStringAsFixed(0);
        feelsLike = response.data["main"]["feels_like"].toStringAsFixed(0);
        main = response.data["weather"][0]["main"].toString();
        mainDesc = response.data["weather"][0]["description"].toString();
        windSpeed = response.data["wind"]["speed"].toString();
        humidty = response.data["main"]["humidity"].toString();
        visibility = (response.data["visibility"] / 1000).toStringAsFixed(0);
        minTemp = response.data["main"]["temp_min"].toStringAsFixed(0);
        maxTemp = response.data["main"]["temp_max"].toStringAsFixed(0);
        seaLevel = response.data["main"]["sea_level"].toStringAsFixed(0);
        weatherIcon = response.data["weather"][0]["icon"].toString();
        groundLevel = response.data["main"]["grnd_level"].toString();
        pressure = response.data["main"]["pressure"].toString();
        isweatherIcon = true;

        currentDate = "$month/$day/$year";

        isLoading = false;
      });
    } on Exception {
      isLoading = false;
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              backgroundColor: Colors.red[400],
              icon: InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: const Icon(Icons.close)),
              title: const Text("Something Went wrong!"),
              actions: [
                (isSearchByCity)
                    ? const Text("try correcting the city name.")
                    : const Text("try reopening the app."),
              ],
            );
          });
    }
  }

  TextStyle myStyle(double size) {
    return TextStyle(fontWeight: FontWeight.w400, fontSize: size);
  }

  Row detailsWidget(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon),
        const SizedBox(
          width: 6,
        ),
        Text(
          text,
          style: const TextStyle(fontSize: 18),
        ),
      ],
    );
  }

  Card otherDetails(String text, String value) {
    print("value: $value");
    return Card(
        child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            text,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(
            height: 20,
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
          ),
          Container(
            height: 2,
            width: 30,
            color: Colors.red,
          )
        ],
      ),
    ));
  }

  @override
  void initState() {
    _determinePosition();

    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var myProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text("Weatherly App")),
      ),
      drawer: Drawer(
        child: Container(
          child: Padding(
            padding: const EdgeInsets.only(top: 70),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  color: Theme.of(context).colorScheme.surface,
                  height: 60,
                  width: double.infinity,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Light Mode"),
                      Padding(
                        padding: const EdgeInsets.only(left: 5, right: 5),
                        child: Switch(
                            value: myProvider.isDarkMode,
                            onChanged: (value) {
                              myProvider.changeTheme(value);
                            }),
                      ),
                      const Text("Dark Mode"),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                Container(
                  color: Theme.of(context).colorScheme.surface,
                  height: 50,
                  width: double.infinity,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Metric (℃)"),
                      Padding(
                        padding: const EdgeInsets.only(left: 5, right: 5),
                        child: Switch(
                            value: myProvider.isImperial,
                            onChanged: (value) async {
                              myProvider.changeMeasurment(value);

                              setState(() {
                                isLoading = true;
                              });
                              await _determinePosition();
                              getData(isSearchByCity);
                              setState(() {
                                isLoading = false;
                              });
                            }),
                      ),
                      const Text("Imperial (℉)"),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          Opacity(
            opacity: (isLoading) ? 0.3 : 1,
            child: SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          TextField(
                            textInputAction: TextInputAction.send,
                            onSubmitted: (value) {
                              FocusScope.of(context).unfocus();
                            },
                            onEditingComplete: () {
                              setState(() {
                                isSearchByCity = true;
                                isLoading = true;
                                getData(isSearchByCity);
                              });
                            },
                            controller: cityController,
                            decoration: InputDecoration(
                              focusedBorder: const OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20)),
                                borderSide: BorderSide(
                                  color: Color.fromARGB(255, 211, 215, 218),
                                ), // Border color when focused
                              ),
                              enabledBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                      color: Color.fromARGB(255, 174, 177, 180),
                                      width: 2.0),
                                  borderRadius: BorderRadius.circular(20)),
                              icon: const Icon(Icons.search),
                              hintText: "Search City",
                            ),
                            onChanged: (value) {},
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          Align(
                            alignment: Alignment.topLeft,
                            // city name and date column
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "$cityName, $countryName",
                                  style: myStyle(23),
                                ),
                                Text(
                                  currentDate,
                                  style: myStyle(12),
                                ),
                              ],
                            ),
                          ),
                          (isweatherIcon)
                              ? Image.network(
                                  fit: BoxFit.cover,
                                  height: 150,
                                  width: 300,
                                  'https://openweathermap.org/img/wn/$weatherIcon@4x.png',
                                )
                              : const Text("Loading Image..."),
                          Text(
                            (myProvider.isImperial) ? "$temp℉" : "$temp℃",
                            style: const TextStyle(
                                fontSize: 55, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "$main, $mainDesc",
                            style: const TextStyle(fontSize: 16),
                          ),
                          Text(
                            "Feels like $feelsLike℃.",
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 15, right: 15),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                detailsWidget(
                                    Icons.wind_power, "$windSpeed km/hr"),
                                detailsWidget(
                                    Icons.water_drop_outlined, "$humidty%"),
                                detailsWidget(
                                    Icons.visibility, "$visibility km"),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 25,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              otherDetails(
                                "Low",
                                (myProvider.isImperial)
                                    ? "$minTemp℉"
                                    : "$minTemp℃",
                              ),
                              otherDetails(
                                "High",
                                (myProvider.isImperial)
                                    ? "$maxTemp℉"
                                    : "$maxTemp℃",
                              ),
                              otherDetails("Sea Level", "$seaLevel hpa")
                            ],
                          ),
                          Card(
                            margin: const EdgeInsets.only(top: 20),
                            child: Padding(
                              padding: const EdgeInsets.only(top: 3),
                              child: SizedBox(
                                height: 120,
                                width: double.infinity,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Text(
                                          "Ground Level",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 23),
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Text(
                                          "$groundLevel hpa",
                                          style: const TextStyle(fontSize: 17),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      width: 50,
                                    ),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Text(
                                          "Pressure",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 23),
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Text(
                                          "$pressure hpa",
                                          style: const TextStyle(fontSize: 17),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          (isLoading)
              ? Center(
                  child: SizedBox(
                    height: 200,
                    width: 400,
                    child: const Column(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          "Fetching Data...",
                          style: TextStyle(fontSize: 20),
                        )
                      ],
                    ),
                  ),
                )
              : const Text(""),
        ],
      ),
    );
  }
}
