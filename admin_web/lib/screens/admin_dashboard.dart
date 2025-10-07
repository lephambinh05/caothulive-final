import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/youtube_link.dart';
import 'admin_settings.dart';
import 'admin_support.dart';
import '../main.dart';
import '../widgets/admin_shell.dart';
import '../widgets/link_form_dialog.dart';
import '../widgets/confirm_dialog.dart';
import 'admin_downloads.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

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

  Future<void> _addLink() async {
    final result = await showDialog<YouTubeLink?>(
      context: context,
      builder: (context) => const LinkFormDialog(),
    );

    if (result != null && mounted) {
      try {
        await _firestore.collection('youtube_links').add(result.toFirestore());
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Thêm link thành công'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Có lỗi xảy ra khi thêm link'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _editLink(YouTubeLink link) async {
    final result = await showDialog<YouTubeLink?>(
      context: context,
      builder: (context) => LinkFormDialog(link: link),
    );

    if (result != null && mounted) {
      try {
        await _firestore
            .collection('youtube_links')
            .doc(link.id)
            .update(result.toFirestore());
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cập nhật link thành công'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Có lỗi xảy ra khi cập nhật link'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _deleteLink(YouTubeLink link) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => ConfirmDialog(
        title: 'Xác nhận xóa',
        content: 'Bạn có chắc chắn muốn xóa link "${link.title}"?',
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await _firestore
            .collection('youtube_links')
            .doc(link.id)
            .delete();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Xóa link thành công'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Có lỗi xảy ra khi xóa link'),
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
      breadcrumbs: const ['Trang chủ', 'Dashboard'],
      title: 'Dashboard',
      subtitle: 'Quản lý danh sách YouTube links',
      selectedIndex: 0,
      onDestinationSelected: (i) {
        if (i == 0) return;
        if (i == 1) {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AdminDownloadsScreen()),
          );
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
        FilledButton.icon(onPressed: _addLink, icon: const Icon(Icons.add), label: const Text('Thêm link')),
        const SizedBox(width: 8),
        FilledButton.tonalIcon(icon: const Icon(Icons.logout), label: const Text('Đăng xuất'), onPressed: _signOut),
      ],
      search: TextField(
        decoration: InputDecoration(
          hintText: 'Tìm kiếm theo tiêu đề hoặc URL...',
          prefixIcon: const Icon(Icons.search),
        ),
        onChanged: (value) {
          setState(() {
            // simple client-side filter handled below
          });
        },
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('youtube_links')
            .orderBy('priority', descending: false) // Sắp xếp theo priority (1-5)
            .orderBy('created_at', descending: true) // Sau đó sắp xếp theo ngày tạo
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            debugPrint('Firestore stream (admin) error: ${snapshot.error}');
            return const Center(
              child: Text('Có lỗi xảy ra khi tải dữ liệu'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            debugPrint('Firestore stream (admin) connecting...');
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final docs = snapshot.data?.docs ?? [];
          debugPrint('Firestore stream (admin) received ${docs.length} docs');
          for (final doc in docs) {
            final data = doc.data() as Map<String, dynamic>;
            debugPrint(' - doc ${doc.id}: title=${data['title']}, url=${data['url']}, created_at=${data['created_at']}');
          }

          var links = docs.map((doc) {
            return YouTubeLink.fromFirestore(doc);
          }).toList() ?? [];

          // optional client-side filtering by current search text in header
          // extract search text from the TextField if needed
          // This demo keeps it simple; you can lift the TextEditingController up to filter live.

          if (links.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.library_music_outlined, size: 72, color: theme.disabledColor),
                    const SizedBox(height: 16),
                    Text('Chưa có link nào', style: theme.textTheme.titleMedium?.copyWith(color: theme.disabledColor)),
                    const SizedBox(height: 8),
                    Text('Hãy thêm link đầu tiên để bắt đầu', style: theme.textTheme.bodyMedium?.copyWith(color: theme.disabledColor)),
                    const SizedBox(height: 16),
                    FilledButton.icon(onPressed: _addLink, icon: const Icon(Icons.add), label: const Text('Thêm link')),
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
                return _PaginatedLinksTable(
                  links: links,
                  rowsPerPage: rowsPerPage,
                  onEdit: _editLink,
                  onDelete: _deleteLink,
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _LinksDataSource extends DataTableSource {
  _LinksDataSource({required this.links, required this.onEdit, required this.onDelete});

  List<YouTubeLink> links;
  final void Function(YouTubeLink) onEdit;
  final void Function(YouTubeLink) onDelete;
  int _selectedCount = 0;

  void sort<T extends Comparable>(Comparable<T> Function(YouTubeLink d) getField, bool ascending) {
    links.sort((a, b) {
      final aValue = getField(a);
      final bValue = getField(b);
      return ascending ? Comparable.compare(aValue, bValue) : Comparable.compare(bValue, aValue);
    });
    notifyListeners();
  }

  @override
  DataRow? getRow(int index) {
    if (index >= links.length) return null;
    final link = links[index];
    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(Text(link.title, style: const TextStyle(fontWeight: FontWeight.w600))),
        DataCell(SizedBox(width: 360, child: Text(link.url, overflow: TextOverflow.ellipsis))),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: link.priorityColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${link.priority} - ${link.priorityName}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ),
        DataCell(Text('${link.createdAt.day}/${link.createdAt.month}/${link.createdAt.year}')),
        DataCell(Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(tooltip: 'Sửa', onPressed: () => onEdit(link), icon: const Icon(Icons.edit)),
            IconButton(tooltip: 'Xóa', onPressed: () => onDelete(link), icon: const Icon(Icons.delete, color: Colors.redAccent)),
          ],
        )),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => links.length;

  @override
  int get selectedRowCount => _selectedCount;
}

class _PaginatedLinksTable extends StatefulWidget {
  final List<YouTubeLink> links;
  final int rowsPerPage;
  final void Function(YouTubeLink) onEdit;
  final void Function(YouTubeLink) onDelete;

  const _PaginatedLinksTable({
    required this.links,
    required this.rowsPerPage,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<_PaginatedLinksTable> createState() => _PaginatedLinksTableState();
}

class _PaginatedLinksTableState extends State<_PaginatedLinksTable> {
  late _LinksDataSource _source;
  bool _sortAsc = true;
  int _sortColumnIndex = 0;

  @override
  void initState() {
    super.initState();
    _source = _LinksDataSource(links: widget.links, onEdit: widget.onEdit, onDelete: widget.onDelete);
  }

  @override
  void didUpdateWidget(covariant _PaginatedLinksTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.links != widget.links) {
      _source = _LinksDataSource(links: widget.links, onEdit: widget.onEdit, onDelete: widget.onDelete);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PaginatedDataTable(
      header: const Text('Danh sách link'),
      rowsPerPage: widget.rowsPerPage,
      columns: [
        DataColumn(
          label: const Text('Tiêu đề'),
          onSort: (i, asc) {
            setState(() {
              _sortColumnIndex = i;
              _sortAsc = asc;
              _source.sort((d) => d.title.toLowerCase() as Comparable<String>, asc);
            });
          },
        ),
        const DataColumn(label: Text('URL')),
        DataColumn(
          label: const Text('Mức độ ưu tiên'),
          onSort: (i, asc) {
            setState(() {
              _sortColumnIndex = i;
              _sortAsc = asc;
              _source.sort((d) => d.priority as Comparable<int>, asc);
            });
          },
        ),
        DataColumn(
          label: const Text('Ngày tạo'),
          onSort: (i, asc) {
            setState(() {
              _sortColumnIndex = i;
              _sortAsc = asc;
              _source.sort((d) => d.createdAt.millisecondsSinceEpoch as Comparable<int>, asc);
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
