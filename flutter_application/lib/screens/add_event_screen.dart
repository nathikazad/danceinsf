import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../widgets/add_event_widgets/repeat_section.dart';
import '../widgets/add_event_widgets/location_section.dart';
import '../widgets/add_event_widgets/upload_section.dart';
import '../widgets/add_event_widgets/organizer_section.dart';

class AddEventScreen extends ConsumerStatefulWidget {
  const AddEventScreen({super.key});

  @override
  ConsumerState<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends ConsumerState<AddEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _costController = TextEditingController();
  final _ticketLinkController = TextEditingController();

  String _eventType = 'Social';
  String _eventStyle = 'Bachata';
  DateTime? _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  // Reusable styles
  static const _sectionHeaderStyle = TextStyle(fontWeight: FontWeight.bold);
  static const _infoTextStyle = TextStyle(fontSize: 12);


  @override
  void dispose() {
    _nameController.dispose();
    _costController.dispose();
    _ticketLinkController.dispose();
    super.dispose();
  }

  void _handleCreate() {
    if (_formKey.currentState!.validate()) {
      // TODO: Save event to Supabase
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Create New'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildNameField(),
            const SizedBox(height: 20),
            _buildTypeSection(),
            const SizedBox(height: 20),
            RepeatSection(
              onDateSelected: (date) => setState(() => _selectedDate = date),
            ),
            const SizedBox(height: 20),
            _buildTimeSection(),
            const SizedBox(height: 20),
            _buildCostSection(),
            const SizedBox(height: 20),
            const LocationSection(),
            const SizedBox(height: 20),
            _buildTicketsSection(),
            const SizedBox(height: 20),
            UploadSection(
              onUpload: () {
                // TODO: Implement file upload
              },
            ),
            const SizedBox(height: 20),
            const OrganizerSection(),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _handleCreate,
                child: const Text('Create', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Reusable widgets
  Widget _buildSectionHeader(String title) {
    return Text(title, style: _sectionHeaderStyle);
  }

  Widget _buildInfoRow(String text) {
    return Row(
      children: [
        const Icon(Icons.info_outline, size: 18, color: Colors.orange),
        const SizedBox(width: 4),
        Text(text, style: _infoTextStyle),
      ],
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String hintText,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        border: const OutlineInputBorder(),
      ),
      keyboardType: keyboardType,
      validator: validator,
    );
  }

  Widget _buildButtonGroup({
    required List<String> options,
    required String selectedValue,
    required Function(String) onSelected,
  }) {
    return Row(
      children: options.map((option) {
        final isSelected = option == selectedValue;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: option != options.last ? 8 : 0,
            ),
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                backgroundColor: isSelected ? Colors.orange.shade50 : null,
                side: BorderSide(
                  color: isSelected ? Colors.orange : Colors.grey.shade300,
                ),
              ),
              onPressed: () => onSelected(option),
              child: Text(
                option,
                style: TextStyle(
                  color: isSelected ? Colors.orange : Colors.black,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }


  Future<void> _pickTime(bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  Widget _buildNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Name'),
        const SizedBox(height: 8),
        _buildFormField(
          controller: _nameController,
          hintText: 'Name',
          validator: (v) => v == null || v.isEmpty ? 'Please enter a name' : null,
        ),
      ],
    );
  }

  Widget _buildTypeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Type'),
        const SizedBox(height: 8),
        _buildButtonGroup(
          options: ['Social', 'Class'],
          selectedValue: _eventType,
          onSelected: (value) => setState(() => _eventType = value),
        ),
        const SizedBox(height: 8),
        _buildButtonGroup(
          options: ['Bachata', 'Salsa'],
          selectedValue: _eventStyle,
          onSelected: (value) => setState(() => _eventStyle = value),
        ),
      ],
    );
  }

  Widget _buildTimeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Start Time'),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => _pickTime(true),
                style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 18)),
                child: Text(_startTime == null ? 'Start Time' : _startTime!.format(context)),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton(
                onPressed: () => _pickTime(false),
                style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 18)),
                child: Text(_endTime == null ? 'End Time' : _endTime!.format(context)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCostSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Cost'),
        const SizedBox(height: 8),
        _buildFormField(
          controller: _costController,
          hintText: 'Cost',
        ),
      ],
    );
  }

  Widget _buildTicketsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Tickets Link'),
        const SizedBox(height: 4),
        _buildInfoRow('Link for Customers to Buy Tickets'),
        const SizedBox(height: 8),
        _buildFormField(
          controller: _ticketLinkController,
          hintText: 'Sample Link',
        ),
      ],
    );
  }
}
