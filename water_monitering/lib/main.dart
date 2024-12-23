import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:charts_flutter/flutter.dart' as charts;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Water Monitoring Dashboard',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool isPowerOn = false;
  int waterLimit = 500;
  String leakStatus = 'Safe';
  int _selectedIndex = 0;

  final DatabaseReference _database = FirebaseDatabase.instance.reference();

  final PageController _pageController = PageController();

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Set background color to black
      appBar: AppBar(
        title: const Text('Water Monitoring & Leak Detection'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text('Water Monitor'),
            ),
            ListTile(
              title: const Text('Dashboard'),
              onTap: () {
                _onItemTapped(0);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Alerts'),
              onTap: () {
                _onItemTapped(1);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Reports'),
              onTap: () {
                _onItemTapped(2);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Settings'),
              onTap: () {
                _onItemTapped(3);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: <Widget>[
          _buildDashboardPage(),
          _buildAlertsPage(),
          _buildReportsPage(),
          _buildSettingsPage(),
        ],
      ),
    );
  }

  Widget _buildDashboardPage() {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          // Control Section
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: <Widget>[
                SwitchListTile(
                  title: const Text('System Power'),
                  value: isPowerOn,
                  onChanged: (bool value) {
                    setState(() {
                      isPowerOn = value;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('System Power is now ${isPowerOn ? 'ON' : 'OFF'}'),
                      ),
                    );
                    _database.child('systemPower').set(isPowerOn);
                  },
                ),
                ListTile(
                  title: const Text('Current Water Limit'),
                  subtitle: Text('$waterLimit Liters'),
                  trailing: ElevatedButton(
                    onPressed: () {
                      _updateLimit();
                    },
                    child: const Text('Edit Limit'),
                  ),
                ),
                ListTile(
                  title: const Text('Leak Detection Status'),
                  subtitle: Text(leakStatus),
                ),
              ],
            ),
          ),
          // Graph Section
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: <Widget>[
                Card(
                  child: ListTile(
                    title: const Text('Water Flow Chart'),
                    subtitle: SizedBox(
                      height: 200.0,
                      child: WaterFlowChart.withSampleData(),
                    ),
                  ),
                ),
                const Card(
                  child: ListTile(
                    title: Text('Pressure Readings'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertsPage() {
    return StreamBuilder(
      stream: _database.child('alerts').limitToLast(10).onValue,
      builder: (context, snapshot) {
        if (snapshot.hasData && !snapshot.hasError && snapshot.data!.snapshot.value != null) {
          Map data = snapshot.data!.snapshot.value;
          List alerts = data.values.toList();
          return ListView.builder(
            itemCount: alerts.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(alerts[index]['title']),
                subtitle: Text(alerts[index]['description']),
              );
            },
          );
        } else {
          return const Center(
            child: Text(
              'No alerts available',
              style: TextStyle(color: Colors.white),
            ),
          );
        }
      },
    );
    return Center(
      child: Text(
        'Alerts Page',
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _buildReportsPage() {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Weekly Report',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          SizedBox(
            height: 200.0,
            child: WaterFlowChart.withSampleData(),
          ),
          SizedBox(
            height: 200.0,
            child: PressureReadingsChart.withSampleData(),
          ),
        ],
      ),
    );
  }
    return Center(
      child: Column(
        children: <Widget>[
          const Text(
            'Weekly Report',
            style: TextStyle(color: Colors.white, fontSize: 24),
          ),
          SizedBox(
            height: 200.0,
            child: WaterFlowChart.withSampleData(),
          ),
          const SizedBox(
            height: 200.0,
            child: Card(
              child: ListTile(
                title: Text('Pressure Readings'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsPage() {
    String contactNumber = '+94702195755';
    bool isDarkTheme = false;
    String userName = 'User Name';
    String phoneNumber = 'Phone Number';
    String homeAddress = 'Home Address';
    String profilePictureUrl = 'https://via.placeholder.com/150';

    @override
    Widget build(BuildContext context) {
      return SingleChildScrollView(
        child: Column(
          children: <Widget>[
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(profilePictureUrl),
            ),
            const SizedBox(height: 20),
            ListTile(
              title: const Text('User Name'),
              subtitle: Text(userName),
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  _editUserInfo('User Name', (value) {
                    setState(() {
                      userName = value;
                    });
                  });
                },
              ),
            ),
            ListTile(
              title: const Text('Phone Number'),
              subtitle: Text(phoneNumber),
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  _editUserInfo('Phone Number', (value) {
                    setState(() {
                      phoneNumber = value;
                    });
                  });
                },
              ),
            ),
            ListTile(
              title: const Text('Home Address'),
              subtitle: Text(homeAddress),
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  _editUserInfo('Home Address', (value) {
                    setState(() {
                      homeAddress = value;
                    });
                  });
                },
              ),
            ),
            ListTile(
              title: const Text('Contact Number'),
              subtitle: Text(contactNumber),
            ),
            SwitchListTile(
              title: const Text('Dark Theme'),
              value: isDarkTheme,
              onChanged: (bool value) {
                setState(() {
                  isDarkTheme = value;
                });
                // Change app theme logic here
              },
            ),
            ElevatedButton(
              onPressed: () {
                // Logout logic here
              },
              child: const Text('Logout'),
            ),
          ],
        ),
      );
    }

    void _editUserInfo(String field, Function(String) onSave) {
      showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          String newValue = '';
          return AlertDialog(
            title: Text('Edit $field'),
            content: TextField(
              onChanged: (value) {
                newValue = value;
              },
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  onSave(newValue);
                  Navigator.pop(context);
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      );
    }
    return Center(
      child: Text(
        'Settings Page',
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  void _updateLimit() {
    showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter the new water limit (liters):'),
          content: TextField(
            keyboardType: TextInputType.number,
            onSubmitted: (String value) {
              setState(() {
                waterLimit = int.tryParse(value) ?? waterLimit;
              });
              _database.child('waterLimit').set(waterLimit);
              Navigator.pop(context);
            },
          ),
        );
      },
    );
  }
}

class WaterFlowChart extends StatelessWidget {
  final List<charts.Series> seriesList;
  final bool animate;

  WaterFlowChart(this.seriesList, {required this.animate});

  /// Creates a [BarChart] with sample data and no transition.
  factory WaterFlowChart.withSampleData() {
    return WaterFlowChart(
      _createSampleData(),
      animate: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return charts.BarChart(
      seriesList,
      animate: animate,
    );
  }

  /// Create one series with sample hard coded data.
  static List<charts.Series<WaterFlow, String>> _createSampleData() {
    final data = [
      WaterFlow('Jan', 5),
      WaterFlow('Feb', 25),
      WaterFlow('Mar', 100),
      WaterFlow('Apr', 75),
    ];

    return [
      charts.Series<WaterFlow, String>(
        id: 'WaterFlow',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (WaterFlow flow, _) => flow.month,
        measureFn: (WaterFlow flow, _) => flow.flow,
        data: data,
      )
    ];
  }
}

/// Sample ordinal data type.
class WaterFlow {
  final String month;
  final int flow;

  WaterFlow(this.month, this.flow);
}