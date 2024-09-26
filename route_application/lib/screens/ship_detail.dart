import 'package:flutter/material.dart';
import 'map_screen.dart';  // Import your map screen
import 'package:flutter/widgets.dart';

class ShipDetailScreen extends StatefulWidget {
  @override
  _ShipDetailScreenState createState() => _ShipDetailScreenState();
}

class _ShipDetailScreenState extends State<ShipDetailScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for form fields
  final TextEditingController _imoController = TextEditingController();
  final TextEditingController _shipNameController = TextEditingController();
  final TextEditingController _flagStateController = TextEditingController();
  final TextEditingController _cargoTypeController = TextEditingController();
  final TextEditingController _captainNameController = TextEditingController();
  final TextEditingController _captainContactController = TextEditingController();
  final TextEditingController _captainAddressController = TextEditingController();
  final TextEditingController _draftController = TextEditingController();
  final TextEditingController _shipLengthController = TextEditingController();
  final TextEditingController _shipSpeedController = TextEditingController();
  final TextEditingController _breadthController = TextEditingController();
  final TextEditingController _displacementController = TextEditingController();
  final TextEditingController _blockCoefficientController = TextEditingController();
  final TextEditingController _shipCapacityController = TextEditingController();

  @override
  void dispose() {
    // Dispose of controllers to avoid memory leaks
    _imoController.dispose();
    _shipNameController.dispose();
    _flagStateController.dispose();
    _cargoTypeController.dispose();
    _captainNameController.dispose();
    _captainContactController.dispose();
    _captainAddressController.dispose();
    _draftController.dispose();
    _shipLengthController.dispose();
    _shipSpeedController.dispose();
    _breadthController.dispose();
    _displacementController.dispose();
    _blockCoefficientController.dispose();
    _shipCapacityController.dispose();
    super.dispose();
  }

  // Validate and submit form
  void _validateAndSubmit() {
    if (_formKey.currentState!.validate()) {
      // Print form details
      print("IMONumber: ${_imoController.text}");
      print("ShipName: ${_shipNameController.text}");
      print("FlagState: ${_flagStateController.text}");
      print("Type of Cargo: ${_cargoTypeController.text}");
      print("Captain Name: ${_captainNameController.text}");
      print("Captain Contact: ${_captainContactController.text}");
      print("Captain Address: ${_captainAddressController.text}");
      print("Design Draft: ${_draftController.text}");
      print("Ship Length: ${_shipLengthController.text}");
      print("Ship Speed: ${_shipSpeedController.text}");
      print("Mounted Breadth: ${_breadthController.text}");
      print("Displacement: ${_displacementController.text}");
      print("Block Coefficient: ${_blockCoefficientController.text}");
      print("Ship Capacity: ${_shipCapacityController.text}");

      // Navigate to the next screen (e.g., MapScreen)
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MapScreen()), // Ensure MapScreen is implemented
      );
    }
  }

  // Helper method to create text fields
  Widget _buildTextField(String label, TextEditingController controller, {bool isNumber = false}) {
  double textFieldHeight = MediaQuery.of(context).size.height * 0.08; // Adjust height based on screen size
  return Padding(
    padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height * 0.01), // Adjust padding
    child: Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        height: textFieldHeight,
        child: TextFormField(
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(
              color: Colors.blueGrey[700],
              fontSize: MediaQuery.of(context).size.width * 0.04, // Adjust font size
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.04,
              vertical: MediaQuery.of(context).size.height * 0.02,
            ), // Adjust padding
          ),
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '$label is required';
            }
            return null;
          },
        ),
      ),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Ship Details",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: MediaQuery.of(context).size.width * 0.05, 
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 19, 13, 36),
        elevation: 5,
      ),
      body: Stack(
        children: [
          // Gradient Background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blueGrey[800]!, const Color.fromARGB(255, 2, 92, 133)!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Padding(
          padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04), // Adjust padding
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 20),
                    Text(
                      "Please enter the ship details",
                      style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width * 0.06,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildTextField("IMO Number", _imoController),
                    _buildTextField("Ship Name", _shipNameController),
                    _buildTextField("Flag State", _flagStateController),
                    _buildTextField("Type of Cargo", _cargoTypeController),
                    _buildTextField("Captain Name", _captainNameController),
                    _buildTextField("Captain Contact", _captainContactController, isNumber: true),
                    _buildTextField("Captain Address", _captainAddressController),
                    _buildTextField("Design Draft", _draftController, isNumber: true),
                    _buildTextField("Ship Length", _shipLengthController, isNumber: true),
                    _buildTextField("Ship Speed", _shipSpeedController, isNumber: true),
                    _buildTextField("Mounted Breadth", _breadthController, isNumber: true),
                    _buildTextField("Displacement", _displacementController, isNumber: true),
                    _buildTextField("Block Coefficient", _blockCoefficientController),
                    _buildTextField("Ship Capacity", _shipCapacityController, isNumber: true),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _validateAndSubmit,
                      child: const Text(
                        'Submit',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color:Color.fromARGB(255, 171, 233, 247)),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding:  EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height * 0.02),
                        backgroundColor: const Color.fromARGB(255, 9, 42, 99),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 5,
                        shadowColor: Colors.blueAccent.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Animated Background Widget
class AnimatedBackground extends StatefulWidget {
  @override
  _AnimatedBackgroundState createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground> {
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(seconds: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blueGrey[900]!, const Color.fromARGB(255, 14, 115, 162)!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [0.0, 1.0],
        ),
      ),
    );
  }
}
