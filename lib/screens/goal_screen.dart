import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/goal.dart';
import '../models/category.dart';
import '../repositories/goal_repository.dart';
import '../repositories/category_repository.dart';
import 'add_goal_screen.dart';
class GoalScreen extends StatefulWidget {
  const GoalScreen({super.key});

  @override
  State<GoalScreen> createState() => _GoalScreenState();
}

class _GoalScreenState extends State<GoalScreen> {
  final GoalRepository _goalRepo = GoalRepository();
  final CategoryRepository _categoryRepo = CategoryRepository();

  List<Goal> _goals = [];
  Map<int, Category> _categoryMap = {};
  Map<int, double> _progressMap = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final categories = await _categoryRepo.getAllCategories();
    _categoryMap = {for (var cat in categories) cat.id!: cat};

    final goals = await _goalRepo.getActiveGoals(1);
    _goals = goals;

    // 각 목표의 달성률 계산
    for (var goal in goals) {
      final progress = await _goalRepo.calculateProgress(goal);
      _progressMap[goal.id!] = progress;
    }

    setState(() => _isLoading = false);
  }

  Future<void> _deleteGoal(int id) async {
    await _goalRepo.deleteGoal(id);
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('목표'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              // 전체 목표 보기
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _goals.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.flag_outlined,
                        size: 80,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '설정된 목표가 없습니다',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '+ 버튼을 눌러 목표를 추가해보세요!',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _goals.length,
                    itemBuilder: (context, index) {
                      final goal = _goals[index];
                      final category = _categoryMap[goal.categoryId];
                      final progress = _progressMap[goal.id] ?? 0.0;

                      return _buildGoalCard(goal, category, progress);
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddGoalScreen(),
            ),
          );
          if (result == true) {
            _loadData();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('목표 추가'),
        backgroundColor: const Color(0xFF6C5CE7),
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildGoalCard(Goal goal, Category? category, double progress) {
    String typeLabel = '';
    switch (goal.type) {
      case GoalType.daily:
        typeLabel = '일일';
        break;
      case GoalType.weekly:
        typeLabel = '주간';
        break;
      case GoalType.monthly:
        typeLabel = '월간';
        break;
    }

    final isCompleted = progress >= 100;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: category?.getColor() ?? Colors.grey,
                  radius: 20,
                  child: Icon(
                    category?.getIcon() ?? Icons.flag,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: category?.getColor().withValues(alpha: 0.1) ??
                                  Colors.grey.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              typeLabel,
                              style: TextStyle(
                                color: category?.getColor() ?? Colors.grey,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (isCompleted)
                            const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 20,
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        goal.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  color: Colors.red.shade300,
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('목표 삭제'),
                        content: const Text('이 목표를 삭제하시겠습니까?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('취소'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              if (goal.id != null) {
                                _deleteGoal(goal.id!);
                              }
                            },
                            child: const Text(
                              '삭제',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '목표: ${goal.targetValue.toStringAsFixed(0)} ${goal.unit ?? '회'}',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  '${progress.toStringAsFixed(1)}%',
                  style: TextStyle(
                    color: isCompleted ? Colors.green : const Color(0xFF6C5CE7),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress / 100,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(
                isCompleted ? Colors.green : const Color(0xFF6C5CE7),
              ),
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 8),
            Text(
              '${DateFormat('yyyy.MM.dd').format(goal.startDate)} ~ ${DateFormat('yyyy.MM.dd').format(goal.endDate)}',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
