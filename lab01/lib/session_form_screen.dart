import 'package:flutter/material.dart';

import 'routes.dart';
import 'session.dart';
import 'utils/format.dart';

class SessionFormScreen extends StatefulWidget {
  const SessionFormScreen({super.key, required this.args});

  final SessionFormArgs args;

  @override
  State<SessionFormScreen> createState() => _SessionFormScreenState();
}

class _SessionFormScreenState extends State<SessionFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final Session _initial = widget.args.initial ?? Session.empty();

  late final _titleController = TextEditingController(text: _initial.title);
  late final _capacityController = TextEditingController(
    text: _initial.capacity.toString(),
  );
  late final _venueController = TextEditingController(text: _initial.venue);
  late final _descriptionController = TextEditingController(
    text: _initial.description ?? '',
  );

  final _capacityFocus = FocusNode();
  final _venueFocus = FocusNode();
  final _descriptionFocus = FocusNode();

  late BugType _category = _initial.category;
  late DateTime _date = DateTime(
    _initial.scheduledAt.year,
    _initial.scheduledAt.month,
    _initial.scheduledAt.day,
  );
  late TimeOfDay _time = TimeOfDay(
    hour: _initial.scheduledAt.hour,
    minute: _initial.scheduledAt.minute,
  );
  late bool _liveDemo = _initial.liveDemo;

  bool _saving = false;
  bool _justSaved = false;

  bool get _isEditing => widget.args.initial != null;

  @override
  void initState() {
    super.initState();
    for (final controller in [
      _titleController,
      _capacityController,
      _venueController,
      _descriptionController,
    ]) {
      controller.addListener(_onFieldChanged);
    }
  }

  void _onFieldChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _titleController.dispose();
    _capacityController.dispose();
    _venueController.dispose();
    _descriptionController.dispose();
    _capacityFocus.dispose();
    _venueFocus.dispose();
    _descriptionFocus.dispose();
    super.dispose();
  }

  bool get _dirty {
    final combined = DateTime(
      _date.year,
      _date.month,
      _date.day,
      _time.hour,
      _time.minute,
    );
    return _titleController.text != _initial.title ||
        _category != _initial.category ||
        combined != _initial.scheduledAt ||
        _capacityController.text != _initial.capacity.toString() ||
        _liveDemo != _initial.liveDemo ||
        _venueController.text != _initial.venue ||
        _descriptionController.text != (_initial.description ?? '');
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );
    if (picked == null || !mounted) return;
    setState(() => _date = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _time);
    if (picked == null || !mounted) return;
    setState(() => _time = picked);
  }

  String? _validateTitle(String? value) {
    final title = (value ?? '').trim();
    if (title.length < 3 || title.length > 60) {
      return 'Title must be 3-60 characters';
    }
    return null;
  }

  String? _validateCapacity(String? value) {
    final capacity = int.tryParse((value ?? '').trim());
    if (capacity == null || capacity < 1 || capacity > 500) {
      return 'Capacity must be between 1 and 500';
    }
    if (_isEditing && capacity < _initial.attendees.length) {
      return 'Below current attendees (${_initial.attendees.length})';
    }
    return null;
  }

  String? _validateVenue(String? value) {
    final venue = (value ?? '').trim();
    if (venue.isEmpty) return 'Required';
    if (_liveDemo && !venue.contains('://')) {
      return 'A live-demo link must contain ://';
    }
    return null;
  }

  Future<void> _onSave() async {
    // formKey.currentState! is safe here: the Form above always builds a
    // non-null FormState before this handler can be invoked.
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;

    final scheduledAt = DateTime(
      _date.year,
      _date.month,
      _date.day,
      _time.hour,
      _time.minute,
    );
    final description = _descriptionController.text.trim();
    final session = Session(
      title: _titleController.text.trim(),
      category: _category,
      scheduledAt: scheduledAt,
      capacity: int.parse(_capacityController.text.trim()),
      attendees: _initial.attendees,
      liveDemo: _liveDemo,
      venue: _venueController.text.trim(),
      description: description.isEmpty ? null : description,
      favourite: _initial.favourite,
    );

    _justSaved = true;
    Navigator.of(context).pop(session);
  }

  Future<void> _confirmDiscard() async {
    final discard = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Discard changes?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Keep editing'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
    if (discard == true && mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_dirty || _justSaved,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _confirmDiscard();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_isEditing ? 'Edit confession' : 'New confession'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _titleController,
                  maxLength: 60,
                  decoration: const InputDecoration(labelText: 'Title'),
                  textInputAction: TextInputAction.next,
                  onTapOutside: (_) => FocusScope.of(context).unfocus(),
                  onFieldSubmitted: (_) => _capacityFocus.requestFocus(),
                  validator: _validateTitle,
                ),
                const SizedBox(height: 4),
                DropdownButtonFormField<BugType>(
                  initialValue: _category,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: [
                    for (final category in BugType.values)
                      DropdownMenuItem(
                        value: category,
                        child: Text(category.label),
                      ),
                  ],
                  onChanged: (value) {
                    if (value != null) setState(() => _category = value);
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: _pickDate,
                        child: InputDecorator(
                          decoration: const InputDecoration(labelText: 'Date'),
                          child: Text(formatDate(_date)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        onTap: _pickTime,
                        child: InputDecorator(
                          decoration: const InputDecoration(labelText: 'Time'),
                          child: Text(_time.format(context)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _capacityController,
                  focusNode: _capacityFocus,
                  decoration: const InputDecoration(labelText: 'Capacity'),
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  onTapOutside: (_) => FocusScope.of(context).unfocus(),
                  onFieldSubmitted: (_) => _venueFocus.requestFocus(),
                  validator: _validateCapacity,
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Live demo'),
                  subtitle: const Text(
                    'Venue is a repo/gist link instead of a room',
                  ),
                  value: _liveDemo,
                  onChanged: (value) => setState(() => _liveDemo = value),
                ),
                TextFormField(
                  controller: _venueController,
                  focusNode: _venueFocus,
                  decoration: InputDecoration(
                    labelText: _liveDemo ? 'Link' : 'Room',
                  ),
                  textInputAction: TextInputAction.next,
                  onTapOutside: (_) => FocusScope.of(context).unfocus(),
                  onFieldSubmitted: (_) => _descriptionFocus.requestFocus(),
                  validator: _validateVenue,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descriptionController,
                  focusNode: _descriptionFocus,
                  decoration: const InputDecoration(
                    labelText: 'Description (optional)',
                  ),
                  maxLines: 3,
                  textInputAction: TextInputAction.done,
                  onTapOutside: (_) => FocusScope.of(context).unfocus(),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _saving ? null : _onSave,
                  child: _saving
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
