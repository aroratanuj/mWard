import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../../providers/notification_provider.dart';
import '../../providers/auth_provider.dart';
import '../../config/theme_config.dart';

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

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    _expiryDateController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _selectExpiryDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (time != null) {
        setState(() {
          _expiryDate = DateTime(
            picked.year,
            picked.month,
            picked.day,
            time.hour,
            time.minute,
          );
          _expiryDateController.text =
              '${picked.day}/${picked.month}/${picked.year} ${time.hour}:${time.minute.toString().padLeft(2, '0')}';
        });
      }
    }
  }

  Future<void> _sendNotification() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

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
              _buildTypeSelector(),
              const SizedBox(height: 16),
              _buildTitleField(),
              const SizedBox(height: 16),
              _buildMessageField(),
              const SizedBox(height: 16),
              _buildImageUploader(),
              const SizedBox(height: 16),
              _buildTargetSelector(),
              const SizedBox(height: 16),
              _buildPrioritySelector(),
              const SizedBox(height: 16),
              _buildExpiryDateField(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Notification Type',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: _types.map((type) {
            final isSelected = _selectedType == type;
            return FilterChip(
              label: Text(type.toUpperCase()),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedType = type;
                  if (type == 'broadcast') {
                    _selectedTarget = 'all';
                  }
                });
              },
              selectedColor: AppTheme.primaryColor.withOpacity(0.2),
              checkmarkColor: AppTheme.primaryColor,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTitleField() {
    return TextFormField(
      controller: _titleController,
      decoration: const InputDecoration(
        labelText: 'Title *',
        hintText: 'Enter notification title',
        prefixIcon: Icon(Icons.title),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter a title';
        }
        if (value.trim().length < 5) {
          return 'Title must be at least 5 characters';
        }
        return null;
      },
    );
  }

  Widget _buildMessageField() {
    return TextFormField(
      controller: _messageController,
      maxLines: 5,
      decoration: const InputDecoration(
        labelText: 'Message *',
        hintText: 'Enter notification message',
        prefixIcon: Icon(Icons.message),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter a message';
        }
        if (value.trim().length < 10) {
          return 'Message must be at least 10 characters';
        }
        return null;
      },
    );
  }

  Widget _buildImageUploader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Image (Optional)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        if (_selectedImage != null) ...[
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  _selectedImage!,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black54,
                  ),
                  onPressed: () {
                    setState(() {
                      _selectedImage = null;
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
        OutlinedButton.icon(
          onPressed: _pickImage,
          icon: const Icon(Icons.image),
          label: const Text('Select Image'),
        ),
      ],
    );
  }

  Widget _buildTargetSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Target Audience',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedTarget,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.people),
          ),
          items: [
            const DropdownMenuItem(
              value: 'all',
              child: Text('All Wards (Broadcast)'),
            ),
            ..._wards.map((ward) {
              return DropdownMenuItem(
                value: ward,
                child: Text(ward),
              );
            }),
          ],
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedTarget = value;
              });
            }
          },
          enabled: _selectedType != 'broadcast',
        ),
      ],
    );
  }

  Widget _buildPrioritySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Priority',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: List.generate(5, (index) {
            final priority = index + 1;
            final isSelected = _selectedPriority == priority;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: index < 4 ? 8 : 0,
                ),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _selectedPriority = priority;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? _getPriorityColor(priority)
                          : Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$priority',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey[700],
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 4),
        Text(
          _getPriorityLabel(_selectedPriority),
          style: TextStyle(
            fontSize: 12,
            color: _getPriorityColor(_selectedPriority),
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildExpiryDateField() {
    return TextFormField(
      controller: _expiryDateController,
      readOnly: true,
      decoration: InputDecoration(
        labelText: 'Expiry Date (Optional)',
        hintText: 'Select expiry date and time',
        prefixIcon: const Icon(Icons.event),
        suffixIcon: IconButton(
          icon: const Icon(Icons.calendar_today),
          onPressed: _selectExpiryDate,
        ),
      ),
      onTap: _selectExpiryDate,
    );
  }

  Color _getPriorityColor(int priority) {
    switch (priority) {
      case 1:
        return Colors.blue;
      case 2:
        return Colors.green;
      case 3:
        return Colors.orange;
      case 4:
        return Colors.red;
      case 5:
        return Colors.red.shade900;
      default:
        return Colors.grey;
    }
  }

  String _getPriorityLabel(int priority) {
    switch (priority) {
      case 1:
        return 'Very Low';
      case 2:
        return 'Low';
      case 3:
        return 'Medium';
      case 4:
        return 'High';
      case 5:
        return 'Urgent';
      default:
        return '';
    }
  }
}
