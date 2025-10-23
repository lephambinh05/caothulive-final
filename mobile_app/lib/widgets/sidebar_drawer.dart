import 'package:flutter/material.dart';
import 'app_sidebar.dart';

class SidebarDrawer extends StatefulWidget {
  final Widget child;
  final Function(String)? onRouteChanged;

  const SidebarDrawer({
    super.key,
    required this.child,
    this.onRouteChanged,
  });

  @override
  State<SidebarDrawer> createState() => _SidebarDrawerState();
}

class _SidebarDrawerState extends State<SidebarDrawer>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleSidebar() {
    print('Toggle sidebar: _isOpen = $_isOpen');
    if (_isOpen) {
      _closeSidebar();
    } else {
      _showSidebarOverlay();
    }
  }

  void _closeSidebar() {
    print('Close sidebar: _isOpen = $_isOpen');
    if (_isOpen) {
      setState(() {
        _isOpen = false;
      });
      Navigator.of(context).pop(); // Đóng overlay dialog
    }
  }

  void _onRouteChanged(String route) {
    _closeSidebar();
    widget.onRouteChanged?.call(route);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Main content
        widget.child,
        
        // Hamburger button - LUÔN HIỂN THỊ TRÊN CÙNG
        Positioned(
          top: MediaQuery.of(context).padding.top + 10,
          left: 16,
          child: _buildHamburgerButton(),
        ),
      ],
    );
  }

  void _showSidebarOverlay() {
    print('Show sidebar overlay: _isOpen = $_isOpen');
    if (!_isOpen) {
      setState(() {
        _isOpen = true;
      });
      
      showGeneralDialog(
        context: context,
        barrierDismissible: true,
        barrierLabel: '',
        barrierColor: Colors.black54,
        transitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (context, animation, secondaryAnimation) {
          return Container();
        },
        transitionBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(-1.0, 0.0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            )),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Material(
                elevation: 20,
                child: AppSidebar(
                  onClose: _closeSidebar,
                  onItemTap: _onRouteChanged,
                ),
              ),
            ),
          );
        },
      ).then((_) {
        // Reset state khi dialog đóng
        print('Dialog closed, resetting state');
        if (mounted) {
          setState(() {
            _isOpen = false;
          });
        }
      });
    }
  }

  Widget _buildHamburgerButton() {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _toggleSidebar,
          borderRadius: BorderRadius.circular(25),
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Container(
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Top line
                    Container(
                      height: 2,
                      width: 20,
                      decoration: BoxDecoration(
                        color: _isOpen ? Colors.transparent : Colors.black87,
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                    
                    const SizedBox(height: 4),
                    
                    // Middle line
                    Container(
                      height: 2,
                      width: 20,
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                    
                    const SizedBox(height: 4),
                    
                    // Bottom line
                    Container(
                      height: 2,
                      width: 20,
                      decoration: BoxDecoration(
                        color: _isOpen ? Colors.transparent : Colors.black87,
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
