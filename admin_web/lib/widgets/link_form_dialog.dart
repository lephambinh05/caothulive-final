import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/youtube_link.dart';

class LinkFormDialog extends StatefulWidget {
  final YouTubeLink? link;

  const LinkFormDialog({super.key, this.link});

  @override
  State<LinkFormDialog> createState() => _LinkFormDialogState();
}

class _LinkFormDialogState extends State<LinkFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _urlController = TextEditingController();
  int _selectedPriority = 3;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.link != null) {
      _titleController.text = widget.link!.title;
      _urlController.text = widget.link!.url;
      _selectedPriority = widget.link!.priority;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  String? _extractVideoId(String url) {
    // Hàm trích xuất video ID từ URL YouTube
    RegExp regExp = RegExp(
      r'^.*(youtu.be\/|v\/|u\/\w\/|embed\/|watch\?v=|\&v=)([^#\&\?]*).*',
      caseSensitive: false,
      multiLine: false,
    );
    
    if (regExp.hasMatch(url)) {
      return regExp.firstMatch(url)!.group(2);
    }
    return null;
  }

  String? _validateYouTubeUrl(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập URL';
    }
    
    if (!value.contains('youtube.com') && !value.contains('youtu.be')) {
      return 'URL phải là link YouTube hợp lệ';
    }
    
    if (_extractVideoId(value) == null) {
      return 'URL YouTube không hợp lệ';
    }
    
    return null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final link = YouTubeLink(
        id: widget.link?.id,
        title: _titleController.text.trim(),
        url: _urlController.text.trim(),
        createdAt: widget.link?.createdAt ?? DateTime.now(),
        priority: _selectedPriority,
      );

      Navigator.of(context).pop(link);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Có lỗi xảy ra'),
            backgroundColor: Colors.red,
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
    final isEditing = widget.link != null;
    
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(isEditing ? 'Sửa Link' : 'Thêm Link Mới'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Tiêu đề video',
                hintText: 'Nhập tiêu đề video',
                prefixIcon: Icon(Icons.title),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Vui lòng nhập tiêu đề';
                }
                if (value.trim().length < 3) {
                  return 'Tiêu đề phải có ít nhất 3 ký tự';
                }
                return null;
              },
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _urlController,
              decoration: const InputDecoration(
                labelText: 'URL YouTube',
                hintText: 'https://www.youtube.com/watch?v=...',
                prefixIcon: Icon(Icons.link),
              ),
              keyboardType: TextInputType.url,
              validator: _validateYouTubeUrl,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),
            // Priority selector
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Mức độ ưu tiên',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: List.generate(5, (index) {
                    final priority = index + 1;
                    final isSelected = _selectedPriority == priority;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedPriority = priority),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? _getPriorityColor(priority) : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected ? _getPriorityColor(priority) : Colors.grey.shade300,
                              width: 2,
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(
                                priority.toString(),
                                style: TextStyle(
                                  color: isSelected ? Colors.white : Colors.grey.shade700,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                _getPriorityName(priority),
                                style: TextStyle(
                                  color: isSelected ? Colors.white : Colors.grey.shade600,
                                  fontSize: 10,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Hủy'),
        ),
        FilledButton(
          onPressed: _isLoading ? null : _save,
          child: _isLoading
              ? const SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(isEditing ? 'Cập nhật' : 'Thêm'),
        ),
      ],
    );
  }

  Color _getPriorityColor(int priority) {
    switch (priority) {
      case 1:
        return Colors.red;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.blue;
      case 4:
        return Colors.grey;
      case 5:
        return Colors.grey.shade400;
      default:
        return Colors.blue;
    }
  }

  String _getPriorityName(int priority) {
    switch (priority) {
      case 1:
        return 'Rất cao';
      case 2:
        return 'Cao';
      case 3:
        return 'Trung bình';
      case 4:
        return 'Thấp';
      case 5:
        return 'Rất thấp';
      default:
        return 'Trung bình';
    }
  }
}
