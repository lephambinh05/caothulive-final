import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/download_item.dart';

class DownloadFormDialog extends StatefulWidget {
  final DownloadItem? download;

  const DownloadFormDialog({super.key, this.download});

  @override
  State<DownloadFormDialog> createState() => _DownloadFormDialogState();
}

class _DownloadFormDialogState extends State<DownloadFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _versionController = TextEditingController();
  final _sizeController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  String _selectedPlatform = 'ios';
  bool _isActive = true;
  DateTime _releaseDate = DateTime.now();
  String _downloadUrl = '';
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    if (widget.download != null) {
      _versionController.text = widget.download!.version;
      _sizeController.text = widget.download!.size;
      _descriptionController.text = widget.download!.description;
      _selectedPlatform = widget.download!.platform;
      _isActive = widget.download!.isActive;
      _releaseDate = widget.download!.releaseDate;
      _downloadUrl = widget.download!.downloadUrl;
    }
  }

  @override
  void dispose() {
    _versionController.dispose();
    _sizeController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    try {
      setState(() {
        _isUploading = true;
      });

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: _selectedPlatform == 'ios' ? ['ipa'] : ['apk'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final file = result.files.first;
        final fileName = '${_selectedPlatform}_${_versionController.text}_${DateTime.now().millisecondsSinceEpoch}.${_selectedPlatform == 'ios' ? 'ipa' : 'apk'}';
        
        // Upload to Firebase Storage
        final ref = FirebaseStorage.instance.ref().child('downloads/$fileName');
        final uploadTask = ref.putFile(File(file.path!));
        
        final snapshot = await uploadTask;
        final downloadUrl = await snapshot.ref.getDownloadURL();
        
        setState(() {
          _downloadUrl = downloadUrl;
          _sizeController.text = '${(file.size / (1024 * 1024)).toStringAsFixed(1)} MB';
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Upload file thành công'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi upload file: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _releaseDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _releaseDate) {
      setState(() {
        _releaseDate = picked;
      });
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      if (_downloadUrl.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vui lòng upload file trước khi lưu'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      final now = DateTime.now();
      final download = DownloadItem(
        id: widget.download?.id ?? '',
        platform: _selectedPlatform,
        version: _versionController.text.trim(),
        size: _sizeController.text.trim(),
        downloadUrl: _downloadUrl,
        description: _descriptionController.text.trim(),
        releaseDate: _releaseDate,
        isActive: _isActive,
        createdAt: widget.download?.createdAt ?? now,
        updatedAt: now,
      );

      Navigator.of(context).pop(download);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Dialog(
      child: Container(
        width: 600,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.download == null ? 'Thêm Download' : 'Sửa Download',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              
              // Platform Selection
              Text('Nền tảng', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('iOS'),
                      value: 'ios',
                      groupValue: _selectedPlatform,
                      onChanged: (value) {
                        setState(() {
                          _selectedPlatform = value!;
                          _downloadUrl = ''; // Reset URL when platform changes
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('Android'),
                      value: 'android',
                      groupValue: _selectedPlatform,
                      onChanged: (value) {
                        setState(() {
                          _selectedPlatform = value!;
                          _downloadUrl = ''; // Reset URL when platform changes
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Version
              TextFormField(
                controller: _versionController,
                decoration: const InputDecoration(
                  labelText: 'Phiên bản',
                  hintText: 'Ví dụ: 1.0.0',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập phiên bản';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // File Upload
              Text('File ứng dụng', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: theme.dividerColor),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    if (_downloadUrl.isNotEmpty) ...[
                      Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'File đã được upload',
                              style: TextStyle(color: Colors.green, fontWeight: FontWeight.w500),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _downloadUrl = '';
                                _sizeController.clear();
                              });
                            },
                            child: const Text('Xóa'),
                          ),
                        ],
                      ),
                    ] else ...[
                      Icon(
                        _selectedPlatform == 'ios' ? Icons.phone_iphone : Icons.android,
                        size: 48,
                        color: theme.disabledColor,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Chọn file ${_selectedPlatform == 'ios' ? '.ipa' : '.apk'}',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _isUploading ? null : _pickFile,
                      icon: _isUploading 
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.upload),
                      label: Text(_isUploading ? 'Đang upload...' : 'Chọn file'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // Size
              TextFormField(
                controller: _sizeController,
                decoration: const InputDecoration(
                  labelText: 'Kích thước',
                  hintText: 'Ví dụ: 45.2 MB',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập kích thước';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Mô tả',
                  hintText: 'Mô tả về phiên bản này...',
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập mô tả';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Release Date
              Text('Ngày phát hành', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              InkWell(
                onTap: _selectDate,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: theme.dividerColor),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today),
                      const SizedBox(width: 12),
                      Text(
                        '${_releaseDate.day}/${_releaseDate.month}/${_releaseDate.year}',
                        style: theme.textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Active Status
              SwitchListTile(
                title: const Text('Kích hoạt'),
                subtitle: const Text('Hiển thị trên trang download'),
                value: _isActive,
                onChanged: (value) {
                  setState(() {
                    _isActive = value;
                  });
                },
              ),
              const SizedBox(height: 24),
              
              // Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Hủy'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: _submit,
                    child: Text(widget.download == null ? 'Thêm' : 'Cập nhật'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
