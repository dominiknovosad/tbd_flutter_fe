import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Web Login App',
      theme: ThemeData(
        primaryColor: Colors.orange,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const LoginScreen(),
      routes: {
        '/profile': (context) => const ProfileScreen(customerId: 1),
      },
    );
  }
}

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(24.0),
          width: 400,
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.orange.shade200,
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Prihlásenie',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const EmailLoginScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Prihlásenie pre zákazníkov',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const IcoLoginScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Prihlásenie pre firmy',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(height: 20),
              Column(
                children: [
                  const Text(
                    'Registrovať sa môžete ako',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const CustomerRegistrationForm()),
                          );
                        },
                        child: const Text(
                          'Zákaznik',
                          style: TextStyle(
                            color: Color.fromARGB(255, 10, 7, 1),
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const Text(
                        '|',
                        style: TextStyle(fontSize: 16),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const CompanyRegistrationForm()),
                          );
                        },
                        child: const Text(
                          'Firma',
                          style: TextStyle(
                            color: Color.fromARGB(255, 10, 7, 1),
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

// Obrazovka prihlásenia cez e-mail a heslo
class EmailLoginScreen extends StatelessWidget {
  const EmailLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    // Funkcia na odoslanie prihlasovacej požiadavky
    Future<void> login(BuildContext context) async {
      final String email = emailController.text.trim();
      final String password = passwordController.text.trim();

      if (email.isEmpty || password.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Prosím vyplňte e-mail a heslo!')),
        );
        return;
      }

      final url = Uri.parse('http://localhost:8080/customer/login');

      try {
        // Odoslanie požiadavky
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'username': email, 'password': password}),
        );

        print('Odosielam JSON: ${json.encode({
              'username': email,
              'password': password
            })}');
        print('Response status code: ${response.statusCode}');
        print('Response body: ${response.body}');

        if (response.statusCode == 200) {
          final responseData = json.decode(response.body);
          final token = responseData['token'];
          final customerId = responseData['customerId'];

          // Uloženie tokenu do SharedPreferences
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('jwt_token', token);

          // Navigácia na profilovú obrazovku
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ProfileScreen(customerId: customerId),
            ),
          );
        } else if (response.statusCode == 400) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Chyba: ${response.body}')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Nesprávne prihlasovacie údaje!')),
          );
        }
      } catch (error) {
        print('Chyba pripojenia: $error');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Chyba pripojenia: $error')),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Prihlásenie'),
        backgroundColor: Colors.orange,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(24.0),
            width: 400,
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.shade200,
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Prihlásenie',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'E-mail',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Heslo',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => login(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Prihlásiť sa',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ProfileScreen extends StatefulWidget {
  final int customerId;

  const ProfileScreen({super.key, required this.customerId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? customerData;
  List<dynamic>? vehicleData;
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    fetchCustomerData();
    fetchVehicleData();
  }

  // Fetch customer profile data
  Future<void> fetchCustomerData() async {
    final url =
        Uri.parse('http://localhost:8080/customer/${widget.customerId}');

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          final decodedResponse = utf8.decode(response.bodyBytes);
          customerData = json.decode(decodedResponse);
          isLoading = false;
        });
      } else {
        throw Exception('Chyba pri načítaní údajov');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        hasError = true;
      });
    }
  }

  // Fetch vehicle data
  Future<void> fetchVehicleData() async {
    final url = Uri.parse(
        'http://localhost:8080/vehicle/customerid/${widget.customerId}');

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          final decodedResponse = utf8.decode(response.bodyBytes);
          vehicleData = json.decode(decodedResponse);

          // If the vehicle data is empty, set an empty list
          if (vehicleData == null || vehicleData!.isEmpty) {
            vehicleData = []; // Assign empty list if no vehicles are found
          }
        });
      } else {
        // Handle if status code is not 200 (but don't set hasError to true)
        setState(() {
          vehicleData = []; // Display an empty list if something goes wrong
        });
      }
    } catch (e) {
      setState(() {
        vehicleData = []; // Display an empty list in case of error
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil zákazníka'),
        backgroundColor: Colors.orange,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : hasError
              ? const Center(child: Text('Nepodarilo sa načítať údaje.'))
              : Center(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Tlačítka nad tabuľkami
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EditProfile(
                                        customerId: widget.customerId,
                                      ),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                ),
                                child: Text('Edit Profile'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AddVehicleScreen(
                                        customerId: widget.customerId,
                                      ),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                ),
                                child: Text('Add Vehicle'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Row to position tables side by side
                          Row(
                            children: [
                              // Prvá tabuľka (Profil zákazníka)
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Tvoj profil',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 10),
                                    DataTable(
                                      border: TableBorder.all(
                                        color: Colors.orange,
                                        width: 1.5,
                                      ),
                                      headingRowColor:
                                          MaterialStateColor.resolveWith(
                                              (states) => Colors.orange),
                                      headingTextStyle: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                      columns: const [
                                        DataColumn(label: Text('Atribút')),
                                        DataColumn(label: Text('Hodnota')),
                                      ],
                                      rows: [
                                        _buildRow(
                                            'Meno', customerData!['name']),
                                        _buildRow('Priezvisko',
                                            customerData!['surname']),
                                        _buildRow(
                                            'City', customerData!['city']),
                                        _buildRow('Telephone',
                                            customerData!['telephone']),
                                        _buildRow('Birthdate',
                                            customerData!['birthdate']),
                                        _buildRow(
                                            'Email', customerData!['email']),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 0),

                              // Druhá tabuľka (Vozidlá)
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Vozidlá',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 10),
                                    DataTable(
                                      border: TableBorder.all(
                                        color: Colors.orange,
                                        width: 1.5,
                                      ),
                                      headingRowColor:
                                          MaterialStateColor.resolveWith(
                                              (states) => Colors.orange),
                                      headingTextStyle: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                      columns: const [
                                        DataColumn(label: Text('Značka')),
                                        DataColumn(label: Text('Model')),
                                        DataColumn(
                                            label: Text('1. registrace')),
                                        DataColumn(label: Text('VIN')),
                                      ],
                                      rows: vehicleData
                                              ?.map<DataRow>((vehicle) {
                                            return DataRow(cells: [
                                              DataCell(Text(
                                                  vehicle['brand'] ?? 'N/A')),
                                              DataCell(Text(
                                                  vehicle['model'] ?? 'N/A')),
                                              DataCell(Text(
                                                  vehicle['registeredAt'] ??
                                                      'N/A')),
                                              DataCell(Text(
                                                  vehicle['vin'] ?? 'N/A')),
                                            ]);
                                          }).toList() ??
                                          [],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
    );
  }

  DataRow _buildRow(String label, String? value) {
    return DataRow(
      cells: [
        DataCell(Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold),
        )),
        DataCell(Text(value ?? 'N/A')),
      ],
    );
  }
}

class AddVehicleScreen extends StatefulWidget {
  final int customerId;

  const AddVehicleScreen({super.key, required this.customerId});

  @override
  _AddVehicleScreenState createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen> {
  final TextEditingController brandController = TextEditingController();
  final TextEditingController modelController = TextEditingController();
  final TextEditingController registeredAtController = TextEditingController();
  final TextEditingController vinController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<void> addVehicle() async {
    final url = Uri.parse('http://localhost:8080/vehicle/add');
    final vehicleData = {
      "customerId": widget.customerId,
      "brand": brandController.text,
      "model": modelController.text,
      "registeredAt": registeredAtController.text,
      "vin": vinController.text,
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(vehicleData),
      );

      if (response.statusCode == 200) {
        // Successfully added vehicle
        // Use Navigator.pushReplacement to go back to ProfileScreen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ProfileScreen(customerId: widget.customerId),
          ),
        );
      } else {
        throw Exception('Chyba pri pridávaní vozidla');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pridať vozidlo'),
        backgroundColor: Colors.orange,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(24.0),
            width: 400,
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.shade200,
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Pridať nové vozidlo',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: brandController,
                    decoration:
                        const InputDecoration(labelText: 'Značka vozidla'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Prosím zadajte značku vozidla';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: modelController,
                    decoration:
                        const InputDecoration(labelText: 'Model vozidla'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Prosím zadajte model vozidla';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: registeredAtController,
                    decoration:
                        const InputDecoration(labelText: 'Dátum registrácie'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Prosím zadajte dátum registrácie';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: vinController,
                    decoration:
                        const InputDecoration(labelText: 'VIN (max 17 znakov)'),
                    maxLength: 17,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Prosím zadajte VIN';
                      }
                      if (value.length != 17) {
                        return 'VIN musí mať presne 17 znakov';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState?.validate() ?? false) {
                        addVehicle();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Vozidlo bolo pridané')),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange),
                    child: const Text(
                      'Pridať vozidlo',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class EditProfile extends StatefulWidget {
  final int customerId;

  const EditProfile({super.key, required this.customerId});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfile> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController surnameController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController telephoneController = TextEditingController();
  final TextEditingController birthdateController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final _formKey = GlobalKey<FormState>();

  // Simulované hodnoty
  String currentName = "";
  String currentSurname = "";
  String currentCity = "";
  String currentTelephone = "";
  String currentBirthdate = "";
  String currentEmail = "";

  Future<void> fetchCustomerData() async {
    final url =
        Uri.parse('http://localhost:8080/customer/${widget.customerId}');
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Posielanie tokenu
        },
      );

      if (response.statusCode == 200) {
        final decodedResponse = utf8.decode(response.bodyBytes);
        final customerData = json.decode(decodedResponse);
        setState(() {
          currentName = customerData['name'];
          currentSurname = customerData['surname'];
          currentCity = customerData['city'];
          currentTelephone = customerData['telephone'];
          currentBirthdate = customerData['birthdate'];
          currentEmail = customerData['email'];

          nameController.text = currentName;
          surnameController.text = currentSurname;
          cityController.text = currentCity;
          telephoneController.text = currentTelephone;
          birthdateController.text = currentBirthdate;
          emailController.text = currentEmail;
        });
      } else {
        throw Exception('Chyba pri načítaní údajov');
      }
    } catch (e) {
      print('Error fetching customer data: $e');
    }
  }

  Future<void> updateProfile() async {
    final url = Uri.parse(
        'http://localhost:8080/customer/editprofile/${widget.customerId}');
    final customerData = {
      "name": nameController.text,
      "surname": surnameController.text,
      "city": cityController.text,
      "telephone": telephoneController.text,
      "birthdate": birthdateController.text,
      "email": emailController.text,
      "password":
          _passwordController.text.isNotEmpty ? _passwordController.text : null,
    };

    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(customerData),
      );

      if (response.statusCode == 200) {
        Navigator.pop(context); // Úspešné aktualizovanie, vrátim sa späť
      } else {
        throw Exception('Chyba pri aktualizácii profilu');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchCustomerData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Úprava profilu'),
        backgroundColor: Colors.orange,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(24.0),
            width: 400,
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.shade200,
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Úprava profilu',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Aktuálna hodnota nad textovým poľom
                  Text('Aktuálna hodnota: $currentName',
                      style: TextStyle(fontSize: 12, color: Colors.black)),
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Meno'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Zadajte vaše meno';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Text('Aktuálna hodnota: $currentSurname',
                      style: TextStyle(fontSize: 12, color: Colors.black)),
                  TextFormField(
                    controller: surnameController,
                    decoration: const InputDecoration(labelText: 'Priezvisko'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Zadajte vaše priezvisko';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Text('Aktuálna hodnota: $currentCity',
                      style: TextStyle(fontSize: 12, color: Colors.black)),
                  TextFormField(
                    controller: cityController,
                    decoration: const InputDecoration(labelText: 'Mesto'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Zadajte miesto';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Text('Aktuálna hodnota: $currentTelephone',
                      style: TextStyle(fontSize: 12, color: Colors.black)),
                  TextFormField(
                    controller: telephoneController,
                    decoration: const InputDecoration(labelText: 'Telefón'),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Zadajte telefónne číslo';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Text('Aktuálna hodnota: $currentBirthdate',
                      style: TextStyle(fontSize: 12, color: Colors.black)),
                  TextFormField(
                    controller: birthdateController,
                    decoration:
                        const InputDecoration(labelText: 'Dátum narodenia'),
                    keyboardType: TextInputType.datetime,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Zadajte dátum narodenia';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Text('Aktuálna hodnota: $currentEmail',
                      style: TextStyle(fontSize: 12, color: Colors.black)),
                  TextFormField(
                    controller: emailController,
                    decoration: const InputDecoration(labelText: 'E-mail'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Zadajte váš e-mail';
                      }
                      if (!RegExp(
                              r"^[a-zA-Z0-9._%+-]+@[a-zAZ0-9.-]+\.[a-zA-Z]{2,}$")
                          .hasMatch(value)) {
                        return 'Zadajte platný e-mail';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  // Polia pre zmenu hesla
                  const Text('Zmeniť heslo', style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(labelText: 'Nové heslo'),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Prosím zadajte nové heslo';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _confirmPasswordController,
                    decoration:
                        const InputDecoration(labelText: 'Potvrďte heslo'),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Prosím potvrďte heslo';
                      }
                      if (value != _passwordController.text) {
                        return 'Heslá sa musia zhodovať';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState?.validate() ?? false) {
                        updateProfile();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Profil bol upravený')),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange),
                    child: const Text(
                      'Upravit profil',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Obrazovka prihlásenia cez ičo a heslo
class IcoLoginScreen extends StatelessWidget {
  const IcoLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController icoController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    // Funkcia na odoslanie prihlasovacej požiadavky
    Future<void> login(BuildContext context) async {
      final String ico = icoController.text.trim();
      final String password = passwordController.text.trim();

      if (ico.isEmpty || password.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Prosím vyplňte IČO a heslo!')),
        );
        return;
      }

      final url = Uri.parse('http://localhost:8080/company/login');

      try {
        // Odoslanie požiadavky
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'ico': ico, 'password': password}),
        );

        print('Odosielam JSON: ${json.encode({
              'ico': ico,
              'password': password
            })}');
        print('Response status code: ${response.statusCode}');
        print('Response body: ${response.body}');

        if (response.statusCode == 200) {
          final responseData = json.decode(response.body);

          final token = responseData['token'];
          // Ensure companyId is treated as a String here
          final companyId =
              responseData['companyId'].toString(); // Convert it to String

          // Uloženie tokenu do SharedPreferences
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('jwt_token', token);

          // Navigácia na profilovú obrazovku
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ProfileScreenCompany(companyId: companyId),
            ),
          );
        } else if (response.statusCode == 400) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Chyba: ${response.body}')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Nesprávne prihlasovacie údaje!')),
          );
        }
      } catch (error) {
        print('Chyba pripojenia: $error');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Chyba pripojenia: $error')),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Prihlásenie firmy'),
        backgroundColor: Colors.orange,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(24.0),
            width: 400,
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.shade200,
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Prihlásenie firmy',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: icoController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'IČO',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.business),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Heslo',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    login(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Prihlásiť sa',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ProfileScreenCompany extends StatefulWidget {
  final String companyId; // Ensure the companyId is a String

  const ProfileScreenCompany({super.key, required this.companyId});

  @override
  _ProfileScreenCompanyState createState() => _ProfileScreenCompanyState();
}

class _ProfileScreenCompanyState extends State<ProfileScreenCompany> {
  Map<String, dynamic>? companyData; // To hold the company data
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    fetchCompanyData(); // Load the company data when the screen is initialized
  }

  // Function to fetch company data
  Future<void> fetchCompanyData() async {
    final url = Uri.parse(
        'http://localhost:8080/company/${widget.companyId}'); // Use companyId from widget

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token =
          prefs.getString('jwt_token'); // Get JWT token from SharedPreferences

      // Send the GET request with token for authentication
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Add token to the header
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          companyData = json.decode(response.body); // Parse response data
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          hasError = true;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        hasError = true;
      });
      print("Error fetching company data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil firmy'),
        backgroundColor: Colors.orange,
      ),
      body: isLoading
          ? const Center(
              child:
                  CircularProgressIndicator(), // Show loading spinner while data is loading
            )
          : hasError
              ? const Center(
                  child: Text(
                      'Nepodarilo sa načítať údaje.')) // Show error message if data fetch fails
              : Center(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          // Company Profile Table
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 20),
                                Text('Tvoj profil',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold)),
                                const SizedBox(height: 10),
                                DataTable(
                                  border: TableBorder.all(
                                    color: Colors.orange,
                                    width: 1.5,
                                  ),
                                  headingRowColor:
                                      MaterialStateColor.resolveWith(
                                          (states) => Colors.orange),
                                  headingTextStyle: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                  columns: const [
                                    DataColumn(label: Text('Atribút')),
                                    DataColumn(label: Text('Hodnota')),
                                  ],
                                  rows: companyData == null
                                      ? [] // If no company data, return an empty table
                                      : [
                                          _buildRow('Company Name',
                                              companyData!['companyName']),
                                          _buildRow('Address',
                                              companyData!['address']),
                                          _buildRow(
                                              'Email', companyData!['email']),
                                          _buildRow('IČO',
                                              companyData!['ico'].toString()),
                                          _buildRow('Telephone',
                                              companyData!['telephone']),
                                        ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
    );
  }

  // Helper method to build a row in the DataTable
  DataRow _buildRow(String label, String? value) {
    return DataRow(
      cells: [
        DataCell(Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold),
        )),
        DataCell(Text(value ?? 'N/A')), // Display 'N/A' if value is null
      ],
    );
  }
}

// Obrazovka resetovania hesla
class ResetPasswordScreen extends StatelessWidget {
  const ResetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController emailController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Resetovanie hesla'),
        backgroundColor: Colors.orange,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(24.0),
            width: 400,
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.shade200,
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Resetovanie hesla',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Zadajte svoj e-mail',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    final email = emailController.text;
                    // TODO: Implement reset password logic
                    print('Reset hesla pre e-mail: $email');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Odoslať žiadosť',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CustomerRegistrationForm extends StatefulWidget {
  const CustomerRegistrationForm({super.key});

  @override
  _CustomerRegistrationFormState createState() =>
      _CustomerRegistrationFormState();
}

class _CustomerRegistrationFormState extends State<CustomerRegistrationForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  Future<void> registerCustomer() async {
    final url = Uri.parse('http://localhost:8080/customer/register');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'name': _firstNameController.text,
        'surname': _lastNameController.text,
        'birthdate': _birthDateController.text,
        'email': _emailController.text,
        'telephone': _phoneController.text,
        'city': _addressController.text,
        'password': _passwordController.text,
      }),
    );

    if (response.statusCode == 200) {
      // Ak je odpoveď úspešná
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Registrácia bola úspešná!'),
      ));
    } else {
      // Ak nastane chyba pri registrácii
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Chyba pri registrácii!'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrácia nového zákazníka'),
        backgroundColor: Colors.orange,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(24.0),
            width: 400,
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.shade200,
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Registrácia zákazníka',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _firstNameController,
                    decoration: const InputDecoration(labelText: 'Meno'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Prosím zadajte vaše meno';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _lastNameController,
                    decoration: const InputDecoration(labelText: 'Priezvisko'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Prosím zadajte vaše priezvisko';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _birthDateController,
                    decoration: const InputDecoration(
                        labelText: 'Dátum narodenia - (DD.MM.RRRR)'),
                    keyboardType: TextInputType.datetime,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Prosím zadajte dátum narodenia';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'E-mail'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Prosím zadajte váš e-mail';
                      }
                      if (!RegExp(
                              r"^[a-zA-Z0-9._%+-]+@[a-zAZ0-9.-]+\.[a-zA-Z]{2,}$")
                          .hasMatch(value)) {
                        return 'Prosím zadajte platný e-mail';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(labelText: 'Telefón'),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Prosím zadajte telefónne číslo';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _addressController,
                    decoration:
                        const InputDecoration(labelText: 'Miesto bydliska'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Prosím zadajte miesto bydliska';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(labelText: 'Heslo'),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Prosím zadajte heslo';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _confirmPasswordController,
                    decoration:
                        const InputDecoration(labelText: 'Heslo pre kontrolu'),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Prosím zadajte heslo pre kontrolu';
                      }
                      if (value != _passwordController.text) {
                        return 'Heslá sa musia zhodovať';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState?.validate() ?? false) {
                        registerCustomer();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Registrácia prebehla úspešne')),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange),
                    child: const Text(
                      'Registrovať sa',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CompanyRegistrationForm extends StatefulWidget {
  const CompanyRegistrationForm({super.key});

  @override
  _CompanyRegistrationFormState createState() =>
      _CompanyRegistrationFormState();
}

class _CompanyRegistrationFormState extends State<CompanyRegistrationForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameofcompanyController =
      TextEditingController();
  final TextEditingController _icoofcomapanyController =
      TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  Future<void> registerCompany() async {
    final url = Uri.parse('http://localhost:8080/company/register');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'companyName': _nameofcompanyController.text,
        'ico': _icoofcomapanyController.text,
        'email': _emailController.text,
        'telephone': _phoneController.text,
        'address': _addressController.text,
        'password': _passwordController.text,
      }),
    );

    if (response.statusCode == 200) {
      // Ak je odpoveď úspešná
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Registrácia bola úspešná!'),
      ));
    } else {
      // Ak nastane chyba pri registrácii
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Chyba pri registrácii!'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrácia firmy'),
        backgroundColor: Colors.orange,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(24.0),
            width: 400,
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.shade200,
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Registrácia firmy',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _nameofcompanyController,
                    decoration: const InputDecoration(labelText: 'Názov firmy'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Prosím zadajte názov vašej firmy';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _icoofcomapanyController,
                    decoration: const InputDecoration(labelText: 'IČO'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Prosím zadajte IČO firmy';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'E-mail'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Prosím zadajte váš e-mail';
                      }
                      if (!RegExp(
                              r"^[a-zA-Z0-9._%+-]+@[a-zAZ0-9.-]+\.[a-zA-Z]{2,}$")
                          .hasMatch(value)) {
                        return 'Prosím zadajte platný e-mail';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(labelText: 'Telefón'),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Prosím zadajte telefónne číslo';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _addressController,
                    decoration:
                        const InputDecoration(labelText: 'Adresa firmy'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Prosím zadajte miesto firmy';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(labelText: 'Heslo'),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Prosím zadajte heslo';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _confirmPasswordController,
                    decoration:
                        const InputDecoration(labelText: 'Heslo pre kontrolu'),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Prosím zadajte heslo pre kontrolu';
                      }
                      if (value != _passwordController.text) {
                        return 'Heslá sa musia zhodovať';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState?.validate() ?? false) {
                        registerCompany();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Registrácia prebehla úspešne')),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange),
                    child: const Text(
                      'Registrovať sa',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
