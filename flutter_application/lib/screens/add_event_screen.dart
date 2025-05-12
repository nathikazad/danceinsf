import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AddEventScreen extends ConsumerStatefulWidget {
  const AddEventScreen({super.key});

  @override
  ConsumerState<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends ConsumerState<AddEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _costController = TextEditingController();
  final _venueController = TextEditingController();
  final _cityController = TextEditingController();
  final _mapsLinkController = TextEditingController();
  final _ticketLinkController = TextEditingController();
  final _organizerNameController = TextEditingController();
  final _organizerPhoneController = TextEditingController();

  String _eventType = 'Social';
  String _eventStyle = 'Bachata';
  String _repeat = 'Once';
  DateTime? _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  bool _isOrganizer = false;
  Set<int>? _selectedWeekdays;
  int? _selectedWeekNumber;

  @override
  void dispose() {
    _nameController.dispose();
    _costController.dispose();
    _venueController.dispose();
    _cityController.dispose();
    _mapsLinkController.dispose();
    _ticketLinkController.dispose();
    _organizerNameController.dispose();
    _organizerPhoneController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _selectedDate = picked);
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
            // Name
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                hintText: 'Name',
                border: OutlineInputBorder(),
              ),
              validator: (v) => v == null || v.isEmpty ? 'Please enter a name' : null,
            ),
            const SizedBox(height: 16),
            // Type
            Row(
              children: [
                Expanded(
                  child: ToggleButtons(
                    isSelected: [_eventType == 'Social', _eventType == 'Class'],
                    onPressed: (i) => setState(() => _eventType = i == 0 ? 'Social' : 'Class'),
                    children: const [Text('Social'), Text('Class')],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ToggleButtons(
                    isSelected: [_eventStyle == 'Bachata', _eventStyle == 'Salsa'],
                    onPressed: (i) => setState(() => _eventStyle = i == 0 ? 'Bachata' : 'Salsa'),
                    children: const [Text('Bachata'), Text('Salsa')],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Repeat
            SizedBox(
              width: double.infinity,
              child: ToggleButtons(
                isSelected: [
                  _repeat == 'Once',
                  _repeat == 'Weekly',
                  _repeat == 'Monthly',
                ],
                onPressed: (i) => setState(() => _repeat = ['Once', 'Weekly', 'Monthly'][i]),
                children: const [
                  SizedBox(width: 80, child: Center(child: Text('Once'))),
                  SizedBox(width: 80, child: Center(child: Text('Weekly'))),
                  SizedBox(width: 80, child: Center(child: Text('Monthly'))),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (_repeat == 'Once')
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _pickDate,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedDate == null
                            ? 'Date'
                            : '${_selectedDate!.month}/${_selectedDate!.day}/${_selectedDate!.year}',
                      ),
                      const Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
              )
            else if (_repeat == 'Monthly')
              Column(
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(4, (index) {
                        final weeks = ['1st', '2nd', '3rd', '4th'];
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(weeks[index]),
                            selected: _selectedWeekNumber == index,
                            onSelected: (selected) {
                              setState(() {
                                _selectedWeekNumber = selected ? index : null;
                              });
                            },
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(7, (index) {
                        final days = ['M', 'T', 'W', 'Th', 'F', 'Sa', 'Su'];
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(days[index]),
                            selected: _selectedWeekdays?.contains(index) ?? false,
                            onSelected: (selected) {
                              setState(() {
                                _selectedWeekdays ??= {};
                                if (selected) {
                                  _selectedWeekdays!.add(index);
                                } else {
                                  _selectedWeekdays!.remove(index);
                                }
                              });
                            },
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              )
            else
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(7, (index) {
                    final days = ['M', 'T', 'W', 'Th', 'F', 'Sa', 'Su'];
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(days[index]),
                        selected: _selectedWeekdays?.contains(index) ?? false,
                        onSelected: (selected) {
                          setState(() {
                            _selectedWeekdays ??= {};
                            if (selected) {
                              _selectedWeekdays!.add(index);
                            } else {
                              _selectedWeekdays!.remove(index);
                            }
                          });
                        },
                      ),
                    );
                  }),
                ),
              ),
            // Start/End Time
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _pickTime(true),
                    child: Text(_startTime == null ? 'Start Time' : _startTime!.format(context)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _pickTime(false),
                    child: Text(_endTime == null ? 'End Time' : _endTime!.format(context)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Cost
            TextFormField(
              controller: _costController,
              decoration: const InputDecoration(
                labelText: 'Cost',
                hintText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            // Location
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _venueController,
                    decoration: const InputDecoration(
                      labelText: 'Venue Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: _cityController,
                    decoration: const InputDecoration(
                      labelText: 'City',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _mapsLinkController,
              decoration: const InputDecoration(
                labelText: 'Google Maps Link',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            // Link
            Row(
              children: const [
                Icon(Icons.info_outline, size: 18),
                SizedBox(width: 4),
                Text('Link for customer to buy tickets'),
              ],
            ),
            const SizedBox(height: 4),
            TextFormField(
              controller: _ticketLinkController,
              decoration: const InputDecoration(
                hintText: 'Placeholder',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            // Flyer
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.upload),
                  label: const Text('Upload'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Organizer info
            Row(
              children: const [
                Icon(Icons.info_outline, size: 18),
                SizedBox(width: 4),
                Text('Not for public display, for verification'),
              ],
            ),
            const SizedBox(height: 4),
            TextFormField(
              controller: _organizerNameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _organizerPhoneController,
              decoration: const InputDecoration(
                labelText: 'Phone number',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            // Organizer question
            Row(
              children: [
                const Text('Are you the organizer of this event?'),
                const SizedBox(width: 8),
                ToggleButtons(
                  isSelected: [_isOrganizer, !_isOrganizer],
                  onPressed: (i) => setState(() => _isOrganizer = i == 0),
                  children: const [Text('Yes'), Text('No')],
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: const [
                Icon(Icons.info_outline, size: 18),
                SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'If yes, only you can make modifications\nIf no, the community will maintain it.',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Create button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // TODO: Save event to Supabase
                    context.pop();
                  }
                },
                child: const Text('Create'),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 