import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/activity.dart';
import '../models/category.dart';
import '../repositories/activity_repository.dart';
import '../repositories/category_repository.dart';
import 'add_activity_screen.dart';
import 'edit_activity_screen.dart';
import 'category_management_screen.dart';
import '../models/statistics.dart';
import '../repositories/statistics_repository.dart';
import 'calendar_screen.dart';
import 'goal_screen.dart';
import 'search_screen.dart';
import '../config/theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final GlobalKey<_HomePageState> _homePageKey = GlobalKey<_HomePageState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          HomePage(key: _homePageKey),
          const CalendarScreen(),
          const StatisticsPage(),
          const GoalScreen(),
          const ReportPage(),
          const SettingsPage(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_rounded), label: '홈'),
          NavigationDestination(icon: Icon(Icons.calendar_month_rounded), label: '달력'),
          NavigationDestination(icon: Icon(Icons.bar_chart_rounded), label: '통계'),
          NavigationDestination(icon: Icon(Icons.flag_rounded), label: '목표'),
          NavigationDestination(icon: Icon(Icons.description_rounded), label: '리포트'),
          NavigationDestination(icon: Icon(Icons.settings_rounded), label: '설정'),
        ],
      ),
      floatingActionButton: _selectedIndex == 0 || _selectedIndex == 1
          ? FloatingActionButton.extended(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddActivityScreen(
                      userId: 1,
                      currentDate: DateFormat('yyyy-MM-dd').format(DateTime.now()),
                    ),
                  ),
                );
                if (result == true) {
                  _homePageKey.currentState?._loadData();
                }
              },
              icon: const Icon(Icons.add_rounded),
              label: const Text('기록 추가'),
              elevation: 8,
            )
          : null,
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ActivityRepository _activityRepo = ActivityRepository();
  final CategoryRepository _categoryRepo = CategoryRepository();
  
  List<Activity> _activities = [];
  Map<int, Category> _categoryMap = {};
  bool _isLoading = true;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    
    setState(() => _isLoading = true);
    
    final categories = await _categoryRepo.getAllCategories();
    _categoryMap = {for (var cat in categories) cat.id!: cat};
    
    final activities = await _activityRepo.getActivitiesByDate(
      1,
      DateFormat('yyyy-MM-dd').format(_selectedDate),
    );
    
    if (!mounted) return;
    
    setState(() {
      _activities = activities;
      _isLoading = false;
    });
  }

  Future<void> _deleteActivity(int id) async {
    await _activityRepo.deleteActivity(id);
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          DateFormat('MM월 dd일 (E)', 'ko_KR').format(_selectedDate),
          style: AppTheme.heading2,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today_rounded),
            onPressed: () async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime(2020),
                lastDate: DateTime(2030),
              );
              if (picked != null) {
                setState(() {
                  _selectedDate = picked;
                });
                _loadData();
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _activities.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF667EEA).withOpacity(0.2),
                              const Color(0xFF764BA2).withOpacity(0.2),
                            ],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.event_note_rounded,
                          size: 60,
                          color: Colors.grey.shade400,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text('아직 기록된 활동이 없습니다', style: AppTheme.heading3),
                      const SizedBox(height: 12),
                      Text(
                        '하단의 "기록 추가" 버튼을 눌러\n오늘의 활동을 기록해보세요!',
                        textAlign: TextAlign.center,
                        style: AppTheme.bodyMedium,
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _activities.length,
                    itemBuilder: (context, index) {
                      final activity = _activities[index];
                      final category = _categoryMap[activity.categoryId];
                      return _buildActivityCard(activity, category);
                    },
                  ),
                ),
    );
  }

  Widget _buildActivityCard(Activity activity, Category? category) {
    final gradientColors = AppTheme.categoryGradients[category?.name] ?? 
        [const Color(0xFF667EEA), const Color(0xFF764BA2)];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: gradientColors[0].withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              left: BorderSide(
                color: gradientColors[0],
                width: 4,
              ),
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -30,
                top: -30,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: gradientColors.map((c) => c.withOpacity(0.05)).toList(),
                    ),
                  ),
                ),
              ),
              
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: gradientColors,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: gradientColors[0].withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(
                            category?.getIcon() ?? Icons.circle,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        
                        const SizedBox(width: 16),
                        
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(activity.title, style: AppTheme.heading3),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: gradientColors.map((c) => c.withOpacity(0.15)).toList(),
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  category?.name ?? '기타',
                                  style: AppTheme.bodyMedium.copyWith(
                                    color: gradientColors[0],
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        PopupMenuButton(
                          icon: Icon(Icons.more_vert_rounded, color: Colors.grey.shade600),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              child: Row(
                                children: [
                                  Icon(Icons.edit_rounded, size: 20, color: Colors.blue.shade400),
                                  const SizedBox(width: 12),
                                  const Text('수정'),
                                ],
                              ),
                              onTap: () async {
                                await Future.delayed(Duration.zero);
                                if (context.mounted) {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EditActivityScreen(activity: activity),
                                    ),
                                  );
                                  if (result == true) _loadData();
                                }
                              },
                            ),
                            PopupMenuItem(
                              child: Row(
                                children: [
                                  Icon(Icons.delete_rounded, size: 20, color: Colors.red.shade400),
                                  const SizedBox(width: 12),
                                  const Text('삭제'),
                                ],
                              ),
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (dialogContext) => AlertDialog(
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                    title: const Text('삭제 확인'),
                                    content: const Text('이 활동을 삭제하시겠습니까?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(dialogContext),
                                        child: const Text('취소'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(dialogContext);
                                          if (activity.id != null) _deleteActivity(activity.id!);
                                        },
                                        child: const Text('삭제', style: TextStyle(color: Colors.red)),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    
                    if (activity.description != null && activity.description!.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Text(
                        activity.description!,
                        style: AppTheme.bodyMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    
                    const SizedBox(height: 16),
                    
                    Row(
                      children: [
                        Icon(Icons.access_time_rounded, size: 16, color: Colors.grey.shade600),
                        const SizedBox(width: 6),
                        Text(activity.time ?? '시간 미정', style: AppTheme.caption),
                        
                        if (activity.value != null) ...[
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: gradientColors),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: gradientColors[0].withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Text(
                              '${activity.value} ${activity.unit ?? ''}',
                              style: AppTheme.bodyMedium.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 나머지 클래스들은 동일...
class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  final StatisticsRepository _statsRepo = StatisticsRepository();
  ActivityStatistics? _statistics;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    setState(() => _isLoading = true);
    final stats = await _statsRepo.getStatistics(1);
    setState(() {
      _statistics = stats;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('통계'),
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _loadStatistics)],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _statistics == null
              ? const Center(child: Text('통계 데이터를 불러올 수 없습니다'))
              : RefreshIndicator(
                  onRefresh: _loadStatistics,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSummaryCards(),
                        const SizedBox(height: 24),
                        _buildWeeklyChart(),
                        const SizedBox(height: 24),
                        _buildCategoryStats(),
                        const SizedBox(height: 24),
                        _buildTopActivities(),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildSummaryCards() {
    return Row(
      children: [
        Expanded(child: _buildStatCard('총 활동', '${_statistics!.totalActivities}', Icons.event_note, const Color(0xFF6C5CE7))),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard('연속 기록', '${_statistics!.streakDays}일', Icons.local_fire_department, const Color(0xFFFF6348))),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 12),
          Text(title, style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(color: color, fontSize: 28, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildWeeklyChart() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('최근 7일 활동', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: _statistics!.weeklyData.entries.map((entry) {
                  final maxCount = _statistics!.weeklyData.values.reduce((a, b) => a > b ? a : b);
                  final height = maxCount > 0 ? (entry.value / maxCount * 150).clamp(20.0, 150.0) : 20.0;
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text('${entry.value}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Container(
                        width: 32,
                        height: height,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Color(0xFF6C5CE7), Color(0xFF9B59B6)],
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(entry.key, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryStats() {
    if (_statistics!.categoryCount.isEmpty) return const SizedBox.shrink();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('카테고리별 활동', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ..._statistics!.categoryCount.entries.map((entry) {
              final total = _statistics!.totalActivities;
              final percentage = (entry.value / total * 100).toStringAsFixed(1);
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(entry.key, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                        Text('${entry.value}회 ($percentage%)', style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: entry.value / total,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6C5CE7)),
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildTopActivities() {
    if (_statistics!.topActivities.isEmpty) return const SizedBox.shrink();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('TOP 활동', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ..._statistics!.topActivities.asMap().entries.map((entry) {
              final index = entry.key;
              final activity = entry.value;
              final medals = ['🥇', '🥈', '🥉'];
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Text(medals[index], style: const TextStyle(fontSize: 32)),
                title: Text(activity.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                trailing: Text('${activity.count}회', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF6C5CE7))),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class ReportPage extends StatelessWidget {
  const ReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('리포트')),
      body: const Center(child: Text('리포트 화면 (곧 구현)')),
    );
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('설정')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.search),
            title: const Text('검색'),
            subtitle: const Text('활동 검색 및 필터'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SearchScreen())),
          ),
          ListTile(
            leading: const Icon(Icons.category),
            title: const Text('카테고리 관리'),
            subtitle: const Text('카테고리 추가, 수정, 삭제'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CategoryManagementScreen())),
          ),
        ],
      ),
    );
  }
}