import 'package:flutter/material.dart';
import '../../../core/app_theme.dart';
import '../domain/task.dart';
import 'add_task_screen.dart';
import 'task_detail_screen.dart';
import '../../profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;

  late final AnimationController _entranceController;
  late final Animation<double> _headerFade;
  late final Animation<Offset> _headerSlide;

  final List<Task> _tasks = [
    const Task(
      id: '1',
      title: 'Complete Flutter lab',
      description: 'Build the Campus Hub interface.',
    ),
    const Task(
      id: '2',
      title: 'Prepare project idea',
      description: 'Write a one-page app proposal.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _headerFade = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    );

    _headerSlide = Tween<Offset>(
      begin: const Offset(0, -0.15),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
      ),
    );

    _entranceController.forward();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  Future<void> _openAddTask() async {
    final newTask = await Navigator.of(context).push<Task>(
      PageRouteBuilder(
        pageBuilder: (_, animation, __) => FadeTransition(
          opacity: animation,
          child: const AddTaskScreen(),
        ),
        transitionDuration: const Duration(milliseconds: 280),
      ),
    );

    if (newTask != null) {
      setState(() => _tasks.insert(0, newTask));
    }
  }

  void _toggleTask(int index) {
    setState(() {
      final current = _tasks[index];
      _tasks[index] = current.copyWith(isCompleted: !current.isCompleted);
    });
  }

  void _deleteTask(int index) {
    final removed = _tasks[index];
    setState(() => _tasks.removeAt(index));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Removed "${removed.title}"'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () => setState(() => _tasks.insert(index, removed)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primaryTeal, AppTheme.accentCyan],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.school_rounded,
                  color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            const Text('Campus Hub'),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: IconButton.filledTonal(
              onPressed: _openAddTask,
              tooltip: 'Quick Add Task',
              icon: const Icon(Icons.add_rounded),
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primaryTeal, AppTheme.accentCyan],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.white24,
                      child: Icon(Icons.person_rounded, color: Colors.white),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Campus Hub',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Student Workspace',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.home_rounded),
                title: const Text('Dashboard'),
                selected: _selectedIndex == 0,
                onTap: () {
                  setState(() => _selectedIndex = 0);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.explore_rounded),
                title: const Text('Explore Courses'),
                selected: _selectedIndex == 1,
                onTap: () {
                  setState(() => _selectedIndex = 1);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.person_outline_rounded),
                title: const Text('Profile'),
                selected: _selectedIndex == 2,
                onTap: () {
                  setState(() => _selectedIndex = 2);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        switchInCurve: Curves.easeOutCubic,
        child: _buildBody(),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) =>
            setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore_rounded),
            label: 'Explore',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_selectedIndex == 1) {
      return const _ExplorePlaceholderView(key: ValueKey('explore'));
    }
    if (_selectedIndex == 2) {
      return const ProfileScreen(key: ValueKey('profile'));
    }

    final pendingCount = _tasks.where((t) => !t.isCompleted).length;

    return Center(
      key: const ValueKey('home'),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 960),
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            // Animated Greeting Banner
            FadeTransition(
              opacity: _headerFade,
              child: SlideTransition(
                position: _headerSlide,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0B5D7A), Color(0xFF137E9E)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryTeal.withValues(alpha: 0.22),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.16),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'FALL SEMESTER • WEEK 6',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Good morning!',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Your student workspace at a glance — $pendingCount active task${pendingCount == 1 ? '' : 's'} remaining.',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.85),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      FilledButton.icon(
                        onPressed: _openAddTask,
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppTheme.primaryTeal,
                        ),
                        icon: const Icon(Icons.add_rounded, size: 20),
                        label: const Text('Add a task'),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 22),

            // Animated Stat Cards Row
            Row(
              children: [
                Expanded(
                  child: _AnimatedStatCard(
                    icon: Icons.checklist_rounded,
                    accentColor: AppTheme.primaryTeal,
                    targetValue: _tasks.length,
                    label: 'Tasks',
                    subtitle: '$pendingCount pending',
                    delayMs: 120,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: _AnimatedStatCard(
                    icon: Icons.menu_book_rounded,
                    accentColor: AppTheme.accentCyan,
                    targetValue: 3,
                    label: 'Courses',
                    subtitle: 'Enrolled this term',
                    delayMs: 240,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            // Section Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'My tasks',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textDark,
                    letterSpacing: -0.3,
                  ),
                ),
                Text(
                  '${_tasks.where((t) => t.isCompleted).length}/${_tasks.length} completed',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textMuted,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Staggered Interactive Task Cards
            if (_tasks.isEmpty)
              Container(
                padding: const EdgeInsets.all(36),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppTheme.cardBorder),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.celebration_rounded,
                        size: 40, color: AppTheme.accentCyan),
                    SizedBox(height: 10),
                    Text(
                      'All caught up!',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Click "Add a task" to plan your next study goal.',
                      style: TextStyle(color: AppTheme.textMuted),
                    ),
                  ],
                ),
              )
            else
              ...List.generate(_tasks.length, (index) {
                final task = _tasks[index];
                return _InteractiveTaskCard(
                  key: ValueKey(task.id),
                  task: task,
                  index: index,
                  onToggle: () => _toggleTask(index),
                  onDelete: () => _deleteTask(index),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => TaskDetailScreen(task: task),
                      ),
                    );
                  },
                );
              }),
          ],
        ),
      ),
    );
  }
}

class _AnimatedStatCard extends StatefulWidget {
  final IconData icon;
  final Color accentColor;
  final int targetValue;
  final String label;
  final String subtitle;
  final int delayMs;

  const _AnimatedStatCard({
    required this.icon,
    required this.accentColor,
    required this.targetValue,
    required this.label,
    required this.subtitle,
    required this.delayMs,
  });

  @override
  State<_AnimatedStatCard> createState() => _AnimatedStatCardState();
}

class _AnimatedStatCardState extends State<_AnimatedStatCard> {
  bool _isHovered = false;
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: widget.delayMs), () {
      if (mounted) setState(() => _visible = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 450),
        opacity: _visible ? 1 : 0,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          transform: Matrix4.translationValues(0, _isHovered ? -4 : 0, 0),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: _isHovered
                  ? widget.accentColor.withValues(alpha: 0.45)
                  : AppTheme.cardBorder,
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: _isHovered
                    ? widget.accentColor.withValues(alpha: 0.12)
                    : Colors.black.withValues(alpha: 0.03),
                blurRadius: _isHovered ? 18 : 8,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: widget.accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(widget.icon, color: widget.accentColor, size: 24),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TweenAnimationBuilder<int>(
                    tween: IntTween(begin: 0, end: widget.targetValue),
                    duration: const Duration(milliseconds: 750),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, _) {
                      return Text(
                        '$value',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textDark,
                          height: 1.1,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.label,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textDark,
                    ),
                  ),
                  Text(
                    widget.subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textMuted,
                    ),
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

class _InteractiveTaskCard extends StatefulWidget {
  final Task task;
  final int index;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const _InteractiveTaskCard({
    super.key,
    required this.task,
    required this.index,
    required this.onToggle,
    required this.onDelete,
    required this.onTap,
  });

  @override
  State<_InteractiveTaskCard> createState() => _InteractiveTaskCardState();
}

class _InteractiveTaskCardState extends State<_InteractiveTaskCard> {
  bool _isHovered = false;
  bool _appeared = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 120 + (widget.index * 90)), () {
      if (mounted) setState(() => _appeared = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final completed = widget.task.isCompleted;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedSlide(
          duration: const Duration(milliseconds: 420),
          curve: Curves.easeOutCubic,
          offset: _appeared ? Offset.zero : const Offset(0, 0.18),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 420),
            opacity: _appeared ? 1 : 0,
            child: GestureDetector(
              onTap: widget.onTap,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                transform: Matrix4.translationValues(_isHovered ? 4 : 0, 0, 0),
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                decoration: BoxDecoration(
                  color: completed
                      ? Colors.white.withValues(alpha: 0.72)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _isHovered
                        ? AppTheme.primaryTeal.withValues(alpha: 0.5)
                        : AppTheme.cardBorder,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _isHovered
                          ? AppTheme.primaryTeal.withValues(alpha: 0.08)
                          : Colors.black.withValues(alpha: 0.02),
                      blurRadius: _isHovered ? 14 : 6,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Hero(
                      tag: 'task_icon_${widget.task.id}',
                      child: InkWell(
                        onTap: widget.onToggle,
                        borderRadius: BorderRadius.circular(24),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: completed
                                ? AppTheme.accentCyan
                                : AppTheme.primaryTeal.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            completed
                                ? Icons.check_rounded
                                : Icons.check_circle_outline_rounded,
                            color: completed
                                ? Colors.white
                                : AppTheme.primaryTeal,
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 200),
                            style: TextStyle(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w600,
                              color: completed
                                  ? AppTheme.textMuted
                                  : AppTheme.textDark,
                              decoration: completed
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                            ),
                            child: Text(widget.task.title),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            widget.task.description,
                            style: const TextStyle(
                              fontSize: 13.5,
                              color: AppTheme.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 180),
                      opacity: _isHovered ? 1.0 : 0.0,
                      child: IconButton(
                        onPressed: widget.onDelete,
                        tooltip: 'Delete task',
                        icon: const Icon(Icons.delete_outline_rounded,
                            size: 20, color: Colors.redAccent),
                      ),
                    ),
                    AnimatedSlide(
                      duration: const Duration(milliseconds: 200),
                      offset:
                          _isHovered ? const Offset(0.15, 0) : Offset.zero,
                      child: const Icon(
                        Icons.chevron_right_rounded,
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ExplorePlaceholderView extends StatelessWidget {
  const _ExplorePlaceholderView({super.key});

  @override
  Widget build(BuildContext context) {
    final courses = [
      ('CS-301', 'Mobile & Web App Development', 'Dr. Sarah Jenkins'),
      ('CS-215', 'Data Structures & Algorithms', 'Prof. Alan Brooks'),
      ('UX-104', 'Human-Computer Interaction', 'Dr. Maya Lin'),
    ];

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 960),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'Enrolled Courses',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 16),
            ...courses.map(
              (c) => Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  leading: CircleAvatar(
                    backgroundColor:
                        AppTheme.primaryTeal.withValues(alpha: 0.12),
                    child: Text(
                      c.$1.split('-').first,
                      style: const TextStyle(
                        color: AppTheme.primaryTeal,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  title: Text('${c.$1}: ${c.$2}',
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(c.$3),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}