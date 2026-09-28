import 'package:flutter/material.dart';

void main() {
  runApp(const SalaryProApp());
}

class SalaryProApp extends StatelessWidget {
  const SalaryProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Salary Pro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F172A), 
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF8B5CF6),
          surface: Color(0xFF1E293B),
        ),
        useMaterial3: true,
      ),
      home: const DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 250,
            color: const Color(0xFF1E293B), 
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF3B82F6),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.account_balance_wallet, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Salary Pro',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 50),
                InkWell(
                  onTap: () => setState(() => _selectedIndex = 0),
                  child: _buildNavItem(Icons.grid_view, 'Dashboard', isSelected: _selectedIndex == 0),
                ),
                InkWell(
                  onTap: () => setState(() => _selectedIndex = 1),
                  child: _buildNavItem(Icons.calculate_outlined, 'Calculator', isSelected: _selectedIndex == 1),
                ),
              ],
            ),
          ),
          
          // Main Content
          Expanded(
            child: Container(
              color: const Color(0xFF0F172A),
              padding: const EdgeInsets.all(40),
              child: _selectedIndex == 0 ? _buildDashboard() : const CalculatorView(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        const Text(
          'Salary Overview',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Track your gross income, deductions and take-home salary.',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 30),
        
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: () => setState(() => _selectedIndex = 1),
              icon: const Icon(Icons.calculate, size: 18),
              label: const Text('Calculate Salary'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B5CF6),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 60),
        
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 20),
        
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () => setState(() => _selectedIndex = 1),
                child: _buildActionCard(Icons.calculate_outlined, 'Calculate Salary'),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(child: _buildActionCard(Icons.compare_arrows, 'Compare Offers (Pro)')),
          ],
        ),
      ],
    );
  }

  Widget _buildNavItem(IconData icon, String title, {bool isSelected = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF8B5CF6) : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.white60,
              size: 22,
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white60,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(IconData icon, String title) {
    return Container(
      padding: const EdgeInsets.all(24),
      height: 140,
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: const Color(0xFF8B5CF6), size: 28),
          const Spacer(),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}

class CalculatorView extends StatefulWidget {
  const CalculatorView({super.key});

  @override
  State<CalculatorView> createState() => _CalculatorViewState();
}

class _CalculatorViewState extends State<CalculatorView> {
  final TextEditingController _basicController = TextEditingController();
  final TextEditingController _houseRentController = TextEditingController();
  final TextEditingController _medicalController = TextEditingController();
  final TextEditingController _travelController = TextEditingController();
  final TextEditingController _taxRateController = TextEditingController();
  
  double _grossSalary = 0;
  double _taxDeduction = 0;
  double _netIncome = 0;
  bool _hasCalculated = false;

  void _calculate() {
    double basic = double.tryParse(_basicController.text) ?? 0;
    double houseRent = double.tryParse(_houseRentController.text) ?? 0;
    double medical = double.tryParse(_medicalController.text) ?? 0;
    double travel = double.tryParse(_travelController.text) ?? 0;
    double taxRate = double.tryParse(_taxRateController.text) ?? 0;
    
    setState(() {
      _grossSalary = basic + houseRent + medical + travel;
      _taxDeduction = _grossSalary * (taxRate / 100);
      _netIncome = _grossSalary - _taxDeduction;
      _hasCalculated = true;
    });
  }

  void _reset() {
    _basicController.clear();
    _houseRentController.clear();
    _medicalController.clear();
    _travelController.clear();
    _taxRateController.clear();
    setState(() {
      _hasCalculated = false;
    });
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              filled: true,
              fillColor: Color(0xFF0F172A),
              border: OutlineInputBorder(borderSide: BorderSide.none),
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Salary Calculator',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              OutlinedButton.icon(
                onPressed: _reset,
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Reset'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.redAccent,
                  side: const BorderSide(color: Colors.redAccent),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTextField('Basic Salary', _basicController),
                      _buildTextField('House Rent Allowance', _houseRentController),
                      _buildTextField('Medical Allowance', _medicalController),
                      _buildTextField('Travel Allowance', _travelController),
                      _buildTextField('Tax Rate (%)', _taxRateController),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _calculate,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF8B5CF6),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text('Calculate Salary', style: TextStyle(color: Colors.white, fontSize: 16)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 30),
              Expanded(
                flex: 2,
                child: _hasCalculated ? Container(
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF8B5CF6), Color(0xFF3B82F6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Tax Deduction', style: TextStyle(color: Colors.white70, fontSize: 16)),
                      const SizedBox(height: 5),
                      Text(
                        '\$${_taxDeduction.toStringAsFixed(2)}',
                        style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                      ),
                      const Divider(color: Colors.white30, height: 40),
                      const Text('Net Monthly Income', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      Text(
                        '\$${_netIncome.toStringAsFixed(2)}',
                        style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 30),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.black12,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Gross Salary', style: TextStyle(color: Colors.white70)),
                            Text('\$${_grossSalary.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ) : const SizedBox(),
              ),
            ],
          )
        ],
      ),
    );
  }
}

