import 'package:flutter/material.dart';

class OrganizerSection extends StatefulWidget {
  final String name;
  final String phone;
  final bool isOrganizer;
  final Function(String name, String phone, bool isOrganizer) onOrganizerChanged;

  const OrganizerSection({
    required this.name,
    required this.phone,
    required this.isOrganizer,
    required this.onOrganizerChanged,
    super.key,
  });

  @override
  State<OrganizerSection> createState() => _OrganizerSectionState();
}

class _OrganizerSectionState extends State<OrganizerSection> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late bool _isOrganizer;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.name);
    _phoneController = TextEditingController(text: widget.phone);
    _isOrganizer = widget.isOrganizer;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _updateOrganizer() {
    widget.onOrganizerChanged(
      _nameController.text,
      _phoneController.text,
      _isOrganizer,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Your Name and Contact', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Row(
          children: const [
            Icon(Icons.info_outline, size: 18, color: Colors.orange),
            SizedBox(width: 4),
            Text('Not for Public Display, for Verification', style: TextStyle(fontSize: 12)),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            hintText: 'Name',
            border: OutlineInputBorder(),
          ),
          onChanged: (_) => _updateOrganizer(),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _phoneController,
          decoration: const InputDecoration(
            hintText: 'Phone Number',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.phone,
          onChanged: (_) => _updateOrganizer(),
        ),
        const SizedBox(height: 20),
        const Text('Are you the organizer of this event?', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  backgroundColor: _isOrganizer ? Colors.orange.shade50 : null,
                  side: BorderSide(color: _isOrganizer ? Colors.orange : Colors.grey.shade300),
                ),
                onPressed: () {
                  setState(() => _isOrganizer = true);
                  _updateOrganizer();
                },
                child: Text('Yes', style: TextStyle(color: _isOrganizer ? Colors.orange : Colors.black)),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  backgroundColor: !_isOrganizer ? Colors.orange.shade50 : null,
                  side: BorderSide(color: !_isOrganizer ? Colors.orange : Colors.grey.shade300),
                ),
                onPressed: () {
                  setState(() => _isOrganizer = false);
                  _updateOrganizer();
                },
                child: Text('No', style: TextStyle(color: !_isOrganizer ? Colors.orange : Colors.black)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: const [
            Icon(Icons.info_outline, size: 18, color: Colors.orange),
            SizedBox(width: 4),
            Expanded(
              child: Text(
                'If YES, only you can make Modifications. If NO, the Community will maintain it',
                style: TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
      ],
    );
  }
} 