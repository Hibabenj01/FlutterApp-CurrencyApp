import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_screenutil/flutter_screenutil.dart';

void main() {
  runApp(
    ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (context, child) => const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CurrencyApp',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontFamily: 'Roboto', fontSize: 16),
          bodyMedium: TextStyle(fontFamily: 'Roboto', fontSize: 14),
        ),
      ),
      home: const CurrencyConverter(),
    );
  }
}

class CurrencyConverter extends StatefulWidget {
  const CurrencyConverter({super.key});

  @override
  State<CurrencyConverter> createState() => _CurrencyConverterState();
}

class _CurrencyConverterState extends State<CurrencyConverter> {
  final TextEditingController _amountController = TextEditingController();
  String _convertedAmount = '';
  String _fromCurrency = 'MAD';
  String _toCurrency = 'EUR';

  final List<String> _currencies = [
    'DZD', 'EGP', 'ZAR', 'MAD', 'NGN', 'KES', 'XOF', 'TND', 'GHS', 'XOF',
    'USD', 'CAD', 'MXN', 'BRL', 'ARS', 'CLP', 'COP', 'VES', 'PEN',
    'CNY', 'INR', 'JPY', 'IDR', 'HKD', 'KRW', 'SGD', 'PKR', 'BDT', 'MYR', 'PHP', 'THB', 'TRY',
    'EUR', 'GBP', 'CHF', 'RUB', 'SEK', 'NOK', 'DKK', 'PLN', 'BGN', 'HRK', 'HUF', 'RSD',
    'AUD', 'NZD', 'FJD', 'PGK', 'WST'
  ];

  Map<String, double> _rates = {};
  bool _loadingRates = true;

  // API URL corrigée
  Future<void> _fetchRealTimeRates() async {
    try {
      final url = Uri.parse('https://api.exchangerate-api.com/v4/latest/USD');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          // Conversion explicite des taux en double
          _rates = Map<String, double>.from(
            data['rates'].map((key, value) => MapEntry(key, value.toDouble())),
          );
          _loadingRates = false;
        });
      } else {
        setState(() {
          _loadingRates = false;
        });
        throw Exception('Failed to fetch data');
      }
    } catch (e) {
      setState(() {
        _loadingRates = false;
      });
      debugPrint('Error fetching real-time rates: $e');
    }
  }

  Future<void> _convertCurrency() async {
    final amount = double.tryParse(_amountController.text);
    if (amount == null) {
      setState(() {
        _convertedAmount = 'Please enter a valid amount';
      });
      return;
    }

    try {
      final url = Uri.parse('https://api.exchangerate-api.com/v4/latest/$_fromCurrency');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final rate = data['rates'][_toCurrency];

        setState(() {
          _convertedAmount = (amount * rate).toStringAsFixed(2);
        });
      } else {
        throw Exception('Failed to fetch data');
      }
    } catch (error) {
      setState(() {
        _convertedAmount = 'Error fetching conversion rate';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchRealTimeRates();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/images/logo.png',
              width: 25.w,
              height: 25.h,
            ),
            SizedBox(width: 5.w),
            const Text(
              'CurrencyApp',
              style: TextStyle(
                fontWeight: FontWeight.w400,
                color: Colors.white,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.blueGrey.shade300,
        elevation: 8,
      ),
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.transparent, Colors.blueGrey.shade400],
                ),
              ),
              child: Center(
                child: Text(
                  'Real-Time Rates',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            _loadingRates
                ? const Center(child: CircularProgressIndicator())
                : Expanded(
              child: ListView.builder(
                itemCount: _currencies.length,
                itemBuilder: (context, index) {
                  final currency = _currencies[index];
                  final rate = _rates[currency] ?? 0.0;
                  return ListTile(
                    leading: const Icon(Icons.attach_money, color: Colors.blueGrey),
                    title: Text(
                      '$currency: ${rate != 0.0 ? rate.toStringAsFixed(2) : 'N/A'}',
                      style: TextStyle(fontSize: 17.sp),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/bcg.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(16.0.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Convert your currencies ',
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                  shadows: const [
                    Shadow(
                      color: Colors.white,
                      offset: Offset(1, 4),
                      blurRadius: 5,
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10.h),
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Amount',
                  hintText: 'Enter amount to convert',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.82),
                  labelStyle: TextStyle(fontSize: 16.sp, color: Colors.indigo.shade400),
                ),
              ),
              SizedBox(height: 12.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  _buildDropdown(_fromCurrency, (String? newValue) {
                    setState(() {
                      _fromCurrency = newValue!;
                    });
                  }),
                  SizedBox(width: 12.w),
                  Text(
                    'to',
                    style: TextStyle(
                      color: Colors.grey.shade800,
                      fontSize: 20,
                    ),
                  ),
                  SizedBox(width: 15.w),
                  _buildDropdown(_toCurrency, (String? newValue) {
                    setState(() {
                      _toCurrency = newValue!;
                    });
                  }),
                ],
              ),
              SizedBox(height: 15.h),
              ElevatedButton(
                onPressed: _convertCurrency,
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(180.w, 50.h),
                  backgroundColor: Colors.white,
                  side: const BorderSide(color: Colors.transparent, width: 3.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  elevation: 5,
                  shadowColor: Colors.black54.withOpacity(0.9),

                ),
                child: Text(
                  'Convert Now',
                  style: TextStyle(fontSize: 20),
                ),
              ),
              SizedBox(height: 20.h),
              Text(
                _convertedAmount.isEmpty ? '' : 'Converted Amount: $_convertedAmount $_toCurrency',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.red.withOpacity(0.85),
                  shadows: const [
                    Shadow(
                      color: Colors.white,
                      blurRadius: 30,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown(String selectedValue, Function(String?) onChanged) {
    return GestureDetector(
      onTap: () async {
        final selected = await showDialog<String>(
          context: context,
          builder: (BuildContext context) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Container(
                height: 350.h,
                padding: EdgeInsets.all(16.w),
                child: Column(
                  children: [
                    Text(
                      'Select Currency',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey,
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _currencies.length,
                        itemBuilder: (BuildContext context, int index) {
                          return ListTile(
                            leading: const Icon(
                              Icons.monetization_on,
                              color: Colors.black54,
                            ),
                            title: Text(
                              _currencies[index],
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w500,
                                color: Colors.blueGrey,
                              ),
                            ),
                            onTap: () {
                              Navigator.pop(context, _currencies[index]);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
        if (selected != null) onChanged(selected);
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black.withOpacity(0.85), Colors.transparent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(10.r),
          boxShadow: [
            BoxShadow(
              color: Colors.blueGrey.withOpacity(0.25),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              selectedValue,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Icon(
              Icons.arrow_drop_down,
              size: 28.sp,
              color: Colors.blueGrey.shade300,
            ),
          ],
        ),
      ),
    );
  }
}
