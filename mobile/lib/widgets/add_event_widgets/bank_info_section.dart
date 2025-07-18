import 'package:flutter/material.dart';
import '../../models/event_sub_models.dart';

class BankInfoSection extends StatefulWidget {
  final BankInfo? bankInfo;
  final Function(BankInfo?) onBankInfoChanged;

  const BankInfoSection({
    super.key,
    this.bankInfo,
    required this.onBankInfoChanged,
  });

  @override
  State<BankInfoSection> createState() => _BankInfoSectionState();
}

class _BankInfoSectionState extends State<BankInfoSection> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _bankNameController;
  late TextEditingController _accountHolderController;
  late TextEditingController _cardNumberController;
  late TextEditingController _clabeController;
  bool _showBankInfo = false;

  @override
  void initState() {
    super.initState();
    _bankNameController = TextEditingController(text: widget.bankInfo?.bankName ?? '');
    _accountHolderController = TextEditingController(text: widget.bankInfo?.name ?? '');
    _cardNumberController = TextEditingController(text: widget.bankInfo?.tarjeta ?? '');
    _clabeController = TextEditingController(text: widget.bankInfo?.clabe ?? '');
    // Show form if bank info already exists
    _showBankInfo = widget.bankInfo != null;
  }

  @override
  void dispose() {
    _bankNameController.dispose();
    _accountHolderController.dispose();
    _cardNumberController.dispose();
    _clabeController.dispose();
    super.dispose();
  }

  void _saveBankInfo() {
    if (_formKey.currentState!.validate()) {
      final bankInfo = BankInfo(
        bankName: _bankNameController.text.trim(),
        name: _accountHolderController.text.trim(),
        tarjeta: _cardNumberController.text.trim(),
        clabe: _clabeController.text.trim(),
      );
      widget.onBankInfoChanged(bankInfo);
    }
  }

  void _clearBankInfo() {
    _formKey.currentState!.reset();
    _bankNameController.clear();
    _accountHolderController.clear();
    _cardNumberController.clear();
    _clabeController.clear();
    widget.onBankInfoChanged(null);
  }

  void _toggleBankInfo(bool? value) {
    setState(() {
      _showBankInfo = value ?? false;
    });
    
    if (!_showBankInfo) {
      // Clear bank info when unchecking
      _clearBankInfo();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Bank Information',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontSize: 14,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
            Row(
              children: [
                if (_showBankInfo && widget.bankInfo != null)
                  TextButton(
                    onPressed: _clearBankInfo,
                    child: const Text('Clear'),
                  ),
                Checkbox(
                  value: _showBankInfo,
                  onChanged: _toggleBankInfo,
                ),
              ],
            ),
          ],
        ),
        if (_showBankInfo) ...[
          const SizedBox(height: 8),
          Form(
            key: _formKey,
            onChanged: _saveBankInfo,
            child: Column(
              children: [
                _buildTextField(
                  controller: _bankNameController,
                  label: 'Bank Name',
                  hint: 'Enter bank name',
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Bank name is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: _accountHolderController,
                  label: 'Account Holder',
                  hint: 'Enter account holder name',
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Account holder name is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: _cardNumberController,
                  label: 'Card Number',
                  hint: 'Enter card number',
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Card number is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: _clabeController,
                  label: 'CLABE',
                  hint: 'Enter CLABE number',
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'CLABE is required';
                    }
                    if (value.length != 18) {
                      return 'CLABE must be 18 digits';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required String? Function(String?) validator,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.onSecondaryContainer,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.error,
            width: 1,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      validator: validator,
    );
  }
} 