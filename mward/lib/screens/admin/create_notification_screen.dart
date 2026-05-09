import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../../providers/notification_provider.dart';
import '../../providers/auth_provider.dart';
import '../../config/theme_config.dart';
import '../../config/mock_config.dart';
import '../../utils/helpers.dart';

class CreateNotificationScreen extends StatefulWidget {
  const CreateNotificationScreen({super.key});

  @override
  State<CreateNotificationScreen> createState() => _CreateNotificationScreenState();
}

class _CreateNotificationScreenState extends State<CreateNotificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  final _expiryDateController = TextEditingController();

  String _selectedType = 'news';
  String _selectedTarget = 'all'; // 'all' or specific ward
  int _selectedPriority = 3;
  DateTime? _expiryDate;
  File? _selectedImage;
  bool _isSending = false;

  final List<String> _types = ['news', 'alert', 'update', 'broadcast'];
  final List<String> _wards = ['Ward 1', 'Ward 2', 'Ward 3', 'Ward 4', 'Ward 5'];
  final List<String> _priorities = ['1', '2', '3', '4', '5'];

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    _expiryDateController.dispose();
    super.dispose();
  }

  Future<void> _sendNotification() async {
    setState(() {
      _isSending = true;
    });

    try {
      final authProvider = context.read<AuthProvider>();
      final notificationProvider = context.read<NotificationProvider>();

      // TODO: Upload image to S3 if selected
      String? imageUrl;
      if (_selectedImage != null) {
        // imageUrl = await uploadImageToS3(_selectedImage!);
      }

      if (_selectedTarget == 'all' || _selectedType == 'broadcast') {
        // Send broadcast notification
        await notificationProvider.sendBroadcastNotification(
          title: _titleController.text.trim(),
          message: _messageController.text.trim(),
          createdBy: authProvider.currentUser?.userId ?? 'admin',
          creatorName: authProvider.currentUser?.name,
          imageUrl: imageUrl,
          expiryDate: _expiryDate,
          priority: _selectedPriority,
        );
      } else {
        // Send ward-specific notification
        await notificationProvider.sendWardNotification(
          title: _titleController.text.trim(),
          message: _messageController.text.trim(),
          wardCode: _selectedTarget,
          createdBy: authProvider.currentUser?.userId ?? 'admin',
          creatorName: authProvider.currentUser?.name,
          imageUrl: imageUrl,
          expiryDate: _expiryDate,
          priority: _selectedPriority,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notification sent successfully!'),
            backgroundColor: AppTheme.successColor,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send notification: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Notification'),
        actions: [
          TextButton(
            onPressed: _isSending ? null : _sendNotification,
            child: _isSending
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Send',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Notification Type
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Notification Type',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        children: _types.map((type) {
                          return ChoiceChip(
                            label: Text(type.toUpperCase()),
                            selected: _selectedType == type,
                            onSelected: (selected) {
                              setState(() {
                                _selectedType = type;
                                if (type == 'broadcast') {
                                  _selectedTarget = 'all';
                                }
                              });
                            },
                            selectedColor: AppTheme.primaryColor,
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      hintText: 'Enter notification title',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a title';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Message
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextFormField(
                    controller: _messageController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Message',
                      hintText: 'Enter notification message',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a message';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Target Audience
              if (_selectedType != 'broadcast')
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Target Audience',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: RadioListTile(
                              title: const Text('All Wards'),
                              value: 'all',
                              groupValue: _selectedTarget,
                              onChanged: (value) {
                                setState(() {
                                  _selectedTarget = value!;
                                });
                              },
                            ),
                          ),
                          Expanded(
                            child: RadioListTile(
                              title: const Text('Specific Ward'),
                              value: 'ward',
                              groupValue: _selectedTarget,
                              onChanged: (value) {
                                setState(() {
                                  _selectedTarget = value!;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      if (_selectedTarget == 'ward') ...[
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: 'Select Ward',
                            border: OutlineInputBorder(),
                          ),
                          items: _wards.map((ward) {
                            return DropdownMenuItem(
                              value: ward,
                              child: Text(ward),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedTarget = value!;
                            });
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Priority
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Priority',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Slider(
                        value: _selectedPriority.toDouble(),
                        min: 1,
                        max: 5,
                        divisions: 4,
                        label: 'Priority $_selectedPriority',
                        onChanged: (value) {
                          setState(() {
                            _selectedPriority = value.toInt();
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Image
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Image (Optional)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (_selectedImage != null)
                        Stack(
                          children: [
                            Container(
                              height: 200,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(8),
                                image: DecorationImage(
                                  image: FileImage(_selectedImage!),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () {
                                  setState(() {
                                    _selectedImage = null;
                                  });
                                },
                                style: IconButton.styleFrom(
                                  backgroundColor: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      OutlinedButton.icon(
                        onPressed: _pickImage,
                        icon: const Icon(Icons.image),
                        label: Text(_selectedImage == null
                            ? 'Add Image'
                            : 'Change Image'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Expiry Date
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextFormField(
                    controller: _expiryDateController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Expiry Date (Optional)',
                      hintText: 'Tap to select expiry date',
                      border: const OutlineInputBorder(),
                      suffixIcon: const Icon(Icons.calendar_today),
                    ),
                    onTap: () async {
                      final selectedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 30)),
                      );

                      if (selectedDate != null) {
                        final selectedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );

                        if (selectedTime != null) {
                          setState(() {
                            _expiryDate = DateTime(
                              selectedDate.year,
                              selectedDate.month,
                              selectedDate.day,
                              selectedTime.hour,
                              selectedTime.minute,
                            );
                            _expiryDateController.text =
                                AppHelpers.formatDateTime(_expiryDate!);
                          });
                        }
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
