import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_player/video_player.dart';

import '../../providers/complaint_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../config/theme_config.dart';

enum MediaType { photo, video }

class FileComplaintScreen extends StatefulWidget {
  const FileComplaintScreen({super.key});

  @override
  State<FileComplaintScreen> createState() => _FileComplaintScreenState();
}

class _FileComplaintScreenState extends State<FileComplaintScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();

  String _selectedCategory = AppConstants.complaintCategories.first;
  String _selectedPriority = 'medium';
  
  // Media
  List<File> _selectedImages = [];
  List<File> _selectedVideos = [];
  MediaType _selectedMediaType = MediaType.photo;
  bool _showMediaOptions = false;
  
  // Audio
  File? _recordedAudio;
  bool _isRecording = false;
  bool _isPlaying = false;
  final AudioRecorder _audioRecorder = AudioRecorder();
  Duration _recordingDuration = Duration.zero;
  String? _recordingPath;
  
  // Location
  Position? _currentPosition;
  bool _isGettingLocation = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _checkPermissions();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _audioRecorder.dispose();
    super.dispose();
  }

  Future<void> _checkPermissions() async {
    await Permission.camera.request();
    await Permission.microphone.request();
    await Permission.storage.request();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isGettingLocation = true;
    });

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (mounted) {
        setState(() {
          _currentPosition = position;
          _isGettingLocation = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isGettingLocation = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to get location: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 1024,
      maxHeight: 1024,
    );

    if (pickedFile != null) {
      setState(() {
        _selectedImages.add(File(pickedFile.path));
        _showMediaOptions = false;
      });
    }
  }

  Future<void> _pickVideo(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickVideo(
      source: source,
      maxDuration: const Duration(minutes: 2),
    );

    if (pickedFile != null) {
      setState(() {
        _selectedVideos.add(File(pickedFile.path));
        _showMediaOptions = false;
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  void _removeVideo(int index) {
    setState(() {
      _selectedVideos.removeAt(index);
    });
  }

  Future<void> _startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        final directory = await getTemporaryDirectory();
        final path = '${directory.path}/recording_${DateTime.now().millisecondsSinceEpoch}.m4a';
        
        await _audioRecorder.start(
          const RecordConfig(
            encoder: AudioEncoder.aacLc,
            bitRate: 128000,
            sampleRate: 44100,
          ),
          path: path,
        );

        setState(() {
          _isRecording = true;
          _recordingPath = path;
        });

        // Update recording duration
        _audioRecorder.onStateChanged().listen((state) {
          if (state is RecordingState && state is Recording) {
            setState(() {
              _recordingDuration = state.duration;
            });
          }
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Microphone permission denied'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to start recording: $e'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  Future<void> _stopRecording() async {
    try {
      final path = await _audioRecorder.stop();
      
      if (path != null) {
        setState(() {
          _recordedAudio = File(path);
          _isRecording = false;
          _recordingDuration = Duration.zero;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Audio recorded successfully'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to stop recording: $e'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  void _deleteAudio() {
    setState(() {
      _recordedAudio = null;
      _recordingPath = null;
    });
  }

  Future<void> _submitComplaint() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedImages.isEmpty && _selectedVideos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one photo or video'),
          backgroundColor: AppTheme.warningColor,
        ),
      );
      return;
    }

    if (_currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enable location services'),
          backgroundColor: AppTheme.warningColor,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = context.read<AuthProvider>();
      final complaintProvider = context.read<ComplaintProvider>();

      if (authProvider.currentUser == null) {
        throw Exception('User not authenticated');
      }

      // TODO: Upload images/videos to S3 and get URLs
      final photoUrls = <String>[];
      final videoUrls = <String>[];
      
      // Combine photo and video URLs
      final allMediaUrls = [...photoUrls, ...videoUrls];
      
      // Get audio URL if recorded
      String? audioUrl;
      if (_recordedAudio != null) {
        // TODO: Upload audio to S3
        audioUrl = 'mock-audio-url';
      }

      // Create complaint
      await complaintProvider.createComplaint(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _selectedCategory,
        priority: _selectedPriority,
        photoUrls: allMediaUrls,
        location: _currentPosition!,
        address: _addressController.text.trim().isEmpty
            ? null
            : _addressController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(AppConstants.successMessageComplaintFiled),
            backgroundColor: AppTheme.successColor,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to file complaint: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('File Complaint'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _submitComplaint,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Submit',
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
              // Location Status
              _buildLocationCard(),
              const SizedBox(height: 16),

              // Category
              _buildCategoryDropdown(),
              const SizedBox(height: 16),

              // Priority
              _buildPrioritySelector(),
              const SizedBox(height: 16),

              // Title
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title *',
                  hintText: 'Brief description of the issue',
                  prefixIcon: Icon(Icons.title),
                ),
                validator: AppValidators.validateTitle,
              ),
              const SizedBox(height: 16),

              // Description (Text or Audio)
              _buildDescriptionSection(),
              const SizedBox(height: 16),

              // Address (Optional)
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Address (Optional)',
                  hintText: 'Enter the exact location',
                  prefixIcon: Icon(Icons.location_on),
                ),
              ),
              const SizedBox(height: 16),

              // Media Upload (Photo or Video)
              _buildMediaUploadSection(),
              const SizedBox(height: 24),

              // Submit Button
              ElevatedButton(
                onPressed: _isLoading ? null : _submitComplaint,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Submit Complaint',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocationCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _currentPosition != null
                    ? AppTheme.successColor.withOpacity(0.1)
                    : Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.location_on,
                color: _currentPosition != null
                    ? AppTheme.successColor
                    : Colors.orange,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isGettingLocation ? 'Getting location...' : 'Location',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    _currentPosition != null
                        ? '${_currentPosition!.latitude.toStringAsFixed(6)}, ${_currentPosition!.longitude.toStringAsFixed(6)}'
                        : 'Location not available',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: _currentPosition != null
                          ? Colors.green
                          : Colors.orange,
                    ),
                  ),
                ],
              ),
            ),
            if (_currentPosition == null)
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _getCurrentLocation,
                tooltip: 'Retry',
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedCategory,
      decoration: const InputDecoration(
        labelText: 'Category *',
        prefixIcon: Icon(Icons.category),
      ),
      items: AppConstants.complaintCategories.map((category) {
        return DropdownMenuItem(
          value: category,
          child: Text(AppHelpers.getCategoryLabel(category)),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _selectedCategory = value;
          });
        }
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select a category';
        }
        return null;
      },
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
          children: AppConstants.priorities.map((priority) {
            final isSelected = _selectedPriority == priority;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: priority != AppConstants.priorities.last ? 8 : 0,
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
                          ? AppHelpers.getPriorityColor(priority)
                          : Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      AppHelpers.getPriorityLabel(priority),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 4),
        Text(
          _getPriorityLabel(_selectedPriority),
          style: TextStyle(
            fontSize: 12,
            color: AppHelpers.getPriorityColor(_selectedPriority),
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Description *',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        
        // Tab bar for Text/Audio
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () {
                    // Text input is already visible
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.edit, size: 16, color: AppTheme.primaryColor),
                        const SizedBox(width: 4),
                        Text(
                          'Text',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: () {
                    _showAudioOption();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.mic, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          'Audio',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // Text input
        TextFormField(
          controller: _descriptionController,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: 'Provide details about the issue',
            prefixIcon: Icon(Icons.description),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              if (_recordedAudio == null) {
                return 'Please enter text or record audio';
              }
            }
            return null;
          },
        ),

        // Audio recording section
        if (_recordedAudio != null || _isRecording)
          Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      _isRecording ? Icons.mic : Icons.mic_none,
                      color: _isRecording ? Colors.red : Colors.blue,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _isRecording
                          ? 'Recording... ${_formatDuration(_recordingDuration)}'
                          : 'Audio Recorded',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: _isRecording ? Colors.red : Colors.blue,
                      ),
                    ),
                    const Spacer(),
                    if (!_isRecording)
                      IconButton(
                        icon: const Icon(Icons.delete, size: 20),
                        onPressed: _deleteAudio,
                        color: Colors.red,
                      ),
                  ],
                ),
                if (_isRecording)
                  const SizedBox(height: 8),
                if (_isRecording)
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _stopRecording,
                          icon: const Icon(Icons.stop, size: 18),
                          label: const Text('Stop Recording'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
      ],
    );
  }

  void _showAudioOption() {
    if (_recordedAudio == null && !_isRecording) {
      showModalBottomSheet(
        context: context,
        builder: (context) => Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Record Audio Description',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.mic),
                title: const Text('Start Recording'),
                onTap: () {
                  Navigator.pop(context);
                  _startRecording();
                },
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildMediaUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Media (Photo or Video) *',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),

        // Media type selector
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _selectedMediaType = MediaType.photo;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: _selectedMediaType == MediaType.photo
                          ? Colors.white
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.photo_library,
                          size: 16,
                          color: _selectedMediaType == MediaType.photo
                              ? AppTheme.primaryColor
                              : Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Photo',
                          style: TextStyle(
                            fontSize: 14,
                            color: _selectedMediaType == MediaType.photo
                                ? AppTheme.primaryColor
                                : Colors.grey[600],
                            fontWeight: _selectedMediaType == MediaType.photo
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _selectedMediaType = MediaType.video;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: _selectedMediaType == MediaType.video
                          ? Colors.white
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.videocam,
                          size: 16,
                          color: _selectedMediaType == MediaType.video
                              ? AppTheme.primaryColor
                              : Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Video',
                          style: TextStyle(
                            fontSize: 14,
                            color: _selectedMediaType == MediaType.video
                                ? AppTheme.primaryColor
                                : Colors.grey[600],
                            fontWeight: _selectedMediaType == MediaType.video
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // Display selected media
        if (_selectedImages.isNotEmpty || _selectedVideos.isNotEmpty)
          _buildMediaGrid()
        else
          _buildMediaUploadButton(),
      ],
    );
  }

  Widget _buildMediaGrid() {
    final totalMediaCount = _selectedImages.length + _selectedVideos.length;

    return SizedBox(
      height: 200,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: totalMediaCount + 1,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          if (index == totalMediaCount) {
            // Add more button
            return _buildMediaUploadButton(isMini: true);
          }

          // Determine if it's an image or video
          bool isImage = index < _selectedImages.length;
          final media = isImage
              ? _selectedImages[index]
              : _selectedVideos[index - _selectedImages.length];

          return Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: isImage
                    ? Image.file(
                        media,
                        width: 120,
                        height: 200,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        width: 120,
                        height: 200,
                        color: Colors.grey[300],
                        child: const Center(
                          child: Icon(Icons.videocam, size: 48, color: Colors.grey),
                        ),
                      ),
              ),
              Positioned(
                top: 4,
                right: 4,
                child: GestureDetector(
                  onTap: () {
                    if (isImage) {
                      _removeImage(index);
                    } else {
                      _removeVideo(index - _selectedImages.length);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 4,
                left: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isImage ? Icons.image : Icons.videocam,
                        size: 12,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isImage ? 'Photo' : 'Video',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMediaUploadButton({bool isMini = false}) {
    return InkWell(
      onTap: () {
        setState(() {
          _showMediaOptions = !_showMediaOptions;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: isMini ? 120 : double.infinity,
        height: isMini ? 200 : 150,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey[300]!,
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
        child: _showMediaOptions
            ? _buildMediaOptions(isMini)
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _selectedMediaType == MediaType.photo
                        ? Icons.add_photo_alternate
                        : Icons.add_circle,
                    size: isMini ? 32 : 48,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isMini ? 'Add More' : 'Add ${_selectedMediaType == MediaType.photo ? 'Photos' : 'Videos'}',
                    style: TextStyle(
                      fontSize: isMini ? 12 : 16,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tap for options',
                    style: TextStyle(
                      fontSize: isMini ? 10 : 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildMediaOptions(bool isMini) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        InkWell(
          onTap: () {
            setState(() {
              _showMediaOptions = false;
            });
            _showSourceDialog('camera');
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Icon(
                  Icons.camera_alt,
                  size: isMini ? 28 : 32,
                  color: AppTheme.primaryColor,
                ),
                const SizedBox(height: 4),
                Text(
                  'Camera',
                  style: TextStyle(
                    fontSize: isMini ? 11 : 12,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () {
            setState(() {
              _showMediaOptions = false;
            });
            _showSourceDialog('gallery');
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Icon(
                  Icons.photo_library,
                  size: isMini ? 28 : 32,
                  color: AppTheme.primaryColor,
                ),
                const SizedBox(height: 4),
                Text(
                  'Gallery',
                  style: TextStyle(
                    fontSize: isMini ? 11 : 12,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showSourceDialog(String defaultSource) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                _selectedMediaType == MediaType.photo ? Icons.camera_alt : Icons.videocam,
              ),
              title: Text(_selectedMediaType == MediaType.photo
                  ? 'Take ${_selectedMediaType == MediaType.photo ? 'Photo' : 'Video'}'
                  : 'Record Video'),
              onTap: () {
                Navigator.pop(context);
                if (_selectedMediaType == MediaType.photo) {
                  _pickImage(ImageSource.camera);
                } else {
                  _pickVideo(ImageSource.camera);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                if (_selectedMediaType == MediaType.photo) {
                  _pickImage(ImageSource.gallery);
                } else {
                  _pickVideo(ImageSource.gallery);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes);
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
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
