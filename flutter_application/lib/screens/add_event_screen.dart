import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../widgets/add_event_widgets/repeat_section.dart';
import '../widgets/add_event_widgets/location_section.dart';
import '../widgets/add_event_widgets/upload_section.dart';
import '../widgets/add_event_widgets/organizer_section.dart';
import '../widgets/add_event_widgets/time_section.dart';
import '../widgets/add_event_widgets/cost_section.dart';
import '../widgets/add_event_widgets/tickets_section.dart';
import '../models/event_model.dart';
import '../controllers/event_controller.dart';

class AddEventScreen extends ConsumerStatefulWidget {
  const AddEventScreen({super.key});

  @override
  ConsumerState<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends ConsumerState<AddEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _eventController = EventController();

  // Partial event object
  late Event _event;
  DateTime? _selectedDateForOnce;

  @override
  void initState() {
    super.initState();
    // Initialize with default values
    _event = Event(
      eventId: '', // Will be set by the database
      name: '',
      type: EventType.social,
      style: DanceStyle.bachata,
      frequency: Frequency.once,
      location: Location(venueName: '', city: '', url: ''),
      schedule: SchedulePattern.once(),
      startTime: const TimeOfDay(hour: 0, minute: 0),
      endTime: const TimeOfDay(hour: 0, minute: 0),
      cost: 0.0,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handleCreate() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Update the event with the latest values
        _event = _event.copyWith(
          name: _nameController.text,
        );

        // Create the event using the controller
        await _eventController.createEvent(_event, _selectedDateForOnce);
        
        if (mounted) {
          context.pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error creating event: $e')),
          );
        }
      }
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
              schedule: _event.schedule,
              frequency: _event.frequency,
              onScheduleChanged: (newSchedule, newFrequency, newSelectedDate) => setState(() {
                _event = _event.copyWith(
                  schedule: newSchedule,
                  frequency: newFrequency,
                );
                _selectedDateForOnce = newSelectedDate;
              }),
            ),
            const SizedBox(height: 20),
            TimeSection(
              startTime: _event.startTime,
              endTime: _event.endTime,
              onStartTimeChanged: (time) => setState(() {
                if (time != null) {
                  _event = _event.copyWith(startTime: time);
                }
              }),
              onEndTimeChanged: (time) => setState(() {
                if (time != null) {
                  _event = _event.copyWith(endTime: time);
                }
              }),
            ),
            const SizedBox(height: 20),
            CostSection(
              initialCost: _event.cost,
              onCostChanged: (cost) => setState(() {
                _event = _event.copyWith(cost: cost);
              }),
              validator: (value) {
                if (value == null || value.isEmpty) return null;
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            LocationSection(
              location: _event.location,
              onLocationChanged: (newLocation) => setState(() {
                _event = _event.copyWith(location: newLocation);
              }),
            ),
            const SizedBox(height: 20),
            TicketsSection(
              initialTicketLink: _event.linkToEvent,
              onTicketLinkChanged: (link) => setState(() {
                _event = _event.copyWith(linkToEvent: link);
              }),
              validator: (value) {
                if (value == null || value.isEmpty) return null;
                final uri = Uri.tryParse(value);
                if (uri == null || !uri.isAbsolute) {
                  return 'Please enter a valid URL';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            UploadSection(
              fileUrl: _event.description,
              onFileChanged: (url) => setState(() {
                _event = _event.copyWith(description: url);
              }),
            ),
            const SizedBox(height: 20),
            OrganizerSection(
              name: _event.name,
              phone: '',
              isOrganizer: true,
              onOrganizerChanged: (name, phone, isOrganizer) {
                // Not using organizer info in the event model yet
              },
            ),
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

  Widget _buildNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Name', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            hintText: 'Name',
            border: OutlineInputBorder(),
          ),
          validator: (v) => v == null || v.isEmpty ? 'Please enter a name' : null,
        ),
      ],
    );
  }

  Widget _buildTypeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Type', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: _event.type == EventType.social ? Colors.orange.shade50 : null,
                    side: BorderSide(
                      color: _event.type == EventType.social ? Colors.orange : Colors.grey.shade300,
                    ),
                  ),
                  onPressed: () => setState(() {
                    _event = _event.copyWith(type: EventType.social);
                  }),
                  child: Text(
                    'Social',
                    style: TextStyle(
                      color: _event.type == EventType.social ? Colors.orange : Colors.black,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  backgroundColor: _event.type == EventType.class_ ? Colors.orange.shade50 : null,
                  side: BorderSide(
                    color: _event.type == EventType.class_ ? Colors.orange : Colors.grey.shade300,
                  ),
                ),
                onPressed: () => setState(() {
                  _event = _event.copyWith(type: EventType.class_);
                }),
                child: Text(
                  'Class',
                  style: TextStyle(
                    color: _event.type == EventType.class_ ? Colors.orange : Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: _event.style == DanceStyle.bachata ? Colors.orange.shade50 : null,
                    side: BorderSide(
                      color: _event.style == DanceStyle.bachata ? Colors.orange : Colors.grey.shade300,
                    ),
                  ),
                  onPressed: () => setState(() {
                    _event = _event.copyWith(style: DanceStyle.bachata);
                  }),
                  child: Text(
                    'Bachata',
                    style: TextStyle(
                      color: _event.style == DanceStyle.bachata ? Colors.orange : Colors.black,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  backgroundColor: _event.style == DanceStyle.salsa ? Colors.orange.shade50 : null,
                  side: BorderSide(
                    color: _event.style == DanceStyle.salsa ? Colors.orange : Colors.grey.shade300,
                  ),
                ),
                onPressed: () => setState(() {
                  _event = _event.copyWith(style: DanceStyle.salsa);
                }),
                child: Text(
                  'Salsa',
                  style: TextStyle(
                    color: _event.style == DanceStyle.salsa ? Colors.orange : Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
