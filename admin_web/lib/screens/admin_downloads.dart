import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/download_item.dart';
import '../widgets/admin_shell.dart';
import '../widgets/confirm_dialog.dart';

class AdminDownloadsScreen extends StatefulWidget {
  const AdminDownloadsScreen({super.key});

  @override
  State<AdminDownloadsScreen> createState() => _AdminDownloadsScreenState();
}

class _AdminDownloadsScreenState extends State<AdminDownloadsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<void> _signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Có lỗi xảy ra khi đăng xuất'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _addDownload() async {
    final result = await showDialog<DownloadItem?>(
      context: context,
      builder: (context) => const DownloadFormDialog(),
    );

    if (result != null && mounted) {
      try {
        await _firestore.collection('downloads').add(result.toFirestore());
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Thêm download thành công'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Có lỗi xảy ra khi thêm download'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _editDownload(DownloadItem download) async {
    final result = await showDialog<DownloadItem?>(
      context: context,
      builder: (context) => DownloadFormDialog(download: download),
    );

    if (result != null && mounted) {
      try {
        await _firestore
            .collection('downloads')
            .doc(download.id)
            .update(result.toFirestore());
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cập nhật download thành công'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Có lỗi xảy ra khi cập nhật download'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _deleteDownload(DownloadItem download) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => ConfirmDialog(
        title: 'Xác nhận xóa',
        content: 'Bạn có chắc chắn muốn xóa download "${download.platformName} v${download.version}"?',
      ),
    );

    if (confirmed == true && mounted) {
      try {
        // Delete file from storage if exists
        if (download.downloadUrl.isNotEmpty) {
          try {
            final ref = _storage.refFromURL(download.downloadUrl);
            await ref.delete();
          } catch (e) {
            // File might not exist, continue with deletion
          }
        }

        await _firestore
            .collection('downloads')
            .doc(download.id)
            .delete();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Xóa download thành công'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Có lỗi xảy ra khi xóa download'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return AdminShell(
      breadcrumbs: const ['Trang chủ', 'Quản lý Downloads'],
      title: 'Quản lý Downloads',
      subtitle: 'Quản lý các file download cho ứng dụng mobile',
      selectedIndex: 1,
      onDestinationSelected: (i) {
        if (i == 0) {
          Navigator.of(context).pop();
        }
        if (i == 2) {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AdminSettingsScreen()),
          );
        }
        if (i == 3) {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AdminSupportScreen()),
          );
        }
      },
      actions: [
        FilledButton.icon(
          onPressed: _addDownload, 
          icon: const Icon(Icons.add), 
          label: const Text('Thêm Download')
        ),
        const SizedBox(width: 8),
        FilledButton.tonalIcon(
          icon: const Icon(Icons.logout), 
          label: const Text('Đăng xuất'), 
          onPressed: _signOut
        ),
      ],
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('downloads')
            .orderBy('platform', descending: false)
            .orderBy('created_at', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            debugPrint('Firestore stream (downloads) error: ${snapshot.error}');
            return const Center(
              child: Text('Có lỗi xảy ra khi tải dữ liệu'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            debugPrint('Firestore stream (downloads) connecting...');
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final docs = snapshot.data?.docs ?? [];
          debugPrint('Firestore stream (downloads) received ${docs.length} docs');

          var downloads = docs.map((doc) {
            return DownloadItem.fromFirestore(doc);
          }).toList() ?? [];

          if (downloads.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.download_outlined, size: 72, color: theme.disabledColor),
                    const SizedBox(height: 16),
                    Text('Chưa có download nào', style: theme.textTheme.titleMedium?.copyWith(color: theme.disabledColor)),
                    const SizedBox(height: 8),
                    Text('Hãy thêm download đầu tiên để bắt đầu', style: theme.textTheme.bodyMedium?.copyWith(color: theme.disabledColor)),
                    const SizedBox(height: 16),
                    FilledButton.icon(onPressed: _addDownload, icon: const Icon(Icons.add), label: const Text('Thêm Download')),
                  ],
                ),
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final rowsPerPage = constraints.maxHeight > 600 ? 10 : 5;
                return _PaginatedDownloadsTable(
                  downloads: downloads,
                  rowsPerPage: rowsPerPage,
                  onEdit: _editDownload,
                  onDelete: _deleteDownload,
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _DownloadsDataSource extends DataTableSource {
  _DownloadsDataSource({required this.downloads, required this.onEdit, required this.onDelete});

  List<DownloadItem> downloads;
  final void Function(DownloadItem) onEdit;
  final void Function(DownloadItem) onDelete;
  int _selectedCount = 0;

  void sort<T extends Comparable>(Comparable<T> Function(DownloadItem d) getField, bool ascending) {
    downloads.sort((a, b) {
      final aValue = getField(a);
      final bValue = getField(b);
      return ascending ? Comparable.compare(aValue, bValue) : Comparable.compare(bValue, aValue);
    });
    notifyListeners();
  }

  @override
  DataRow? getRow(int index) {
    if (index >= downloads.length) return null;
    final download = downloads[index];
    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: download.platformColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(download.platformName, style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        DataCell(Text('v${download.version}', style: const TextStyle(fontWeight: FontWeight.w600))),
        DataCell(Text(download.size)),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: download.isActive ? Colors.green : Colors.orange,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              download.isActive ? 'Hoạt động' : 'Tạm dừng',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ),
        DataCell(Text('${download.releaseDate.day}/${download.releaseDate.month}/${download.releaseDate.year}')),
        DataCell(Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(tooltip: 'Sửa', onPressed: () => onEdit(download), icon: const Icon(Icons.edit)),
            IconButton(tooltip: 'Xóa', onPressed: () => onDelete(download), icon: const Icon(Icons.delete, color: Colors.redAccent)),
          ],
        )),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => downloads.length;

  @override
  int get selectedRowCount => _selectedCount;
}

class _PaginatedDownloadsTable extends StatefulWidget {
  final List<DownloadItem> downloads;
  final int rowsPerPage;
  final void Function(DownloadItem) onEdit;
  final void Function(DownloadItem) onDelete;

  const _PaginatedDownloadsTable({
    required this.downloads,
    required this.rowsPerPage,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<_PaginatedDownloadsTable> createState() => _PaginatedDownloadsTableState();
}

class _PaginatedDownloadsTableState extends State<_PaginatedDownloadsTable> {
  late _DownloadsDataSource _source;
  bool _sortAsc = true;
  int _sortColumnIndex = 0;

  @override
  void initState() {
    super.initState();
    _source = _DownloadsDataSource(downloads: widget.downloads, onEdit: widget.onEdit, onDelete: widget.onDelete);
  }

  @override
  void didUpdateWidget(covariant _PaginatedDownloadsTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.downloads != widget.downloads) {
      _source = _DownloadsDataSource(downloads: widget.downloads, onEdit: widget.onEdit, onDelete: widget.onDelete);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PaginatedDataTable(
      header: const Text('Danh sách Downloads'),
      rowsPerPage: widget.rowsPerPage,
      columns: [
        DataColumn(
          label: const Text('Nền tảng'),
          onSort: (i, asc) {
            setState(() {
              _sortColumnIndex = i;
              _sortAsc = asc;
              _source.sort((d) => d.platform.toLowerCase() as Comparable<String>, asc);
            });
          },
        ),
        DataColumn(
          label: const Text('Phiên bản'),
          onSort: (i, asc) {
            setState(() {
              _sortColumnIndex = i;
              _sortAsc = asc;
              _source.sort((d) => d.version as Comparable<String>, asc);
            });
          },
        ),
        const DataColumn(label: Text('Kích thước')),
        const DataColumn(label: Text('Trạng thái')),
        DataColumn(
          label: const Text('Ngày phát hành'),
          onSort: (i, asc) {
            setState(() {
              _sortColumnIndex = i;
              _sortAsc = asc;
              _source.sort((d) => d.releaseDate.millisecondsSinceEpoch as Comparable<int>, asc);
            });
          },
        ),
        const DataColumn(label: Text('Thao tác')),
      ],
      sortColumnIndex: _sortColumnIndex,
      sortAscending: _sortAsc,
      source: _source,
    );
  }
}

// Import statements for other screens
import 'admin_settings.dart';
import 'admin_support.dart';
