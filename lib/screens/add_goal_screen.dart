import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/goal.dart';
import '../models/category.dart';
import '../repositories/goal_repository.dart';
import '../repositories/category_repository.dart';

class AddGoalScreen extends StatefulWidget {
  const AddGoalScreen({super.key});

  @override
  State<AddGoalScreen> createState() => _AddGoalScreenState();
}

class _AddGoalScreenState extends State<AddGoalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _targetValueController = TextEditingController();

  final GoalRepository _goalRepo = GoalRepository();
  final CategoryRepository _categoryRepo = CategoryRepository();

  List<Category> _categories = [];
  Category? _selectedCategory;
  GoalType _selectedType = GoalType.daily;
  String? _selectedUnit;
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();

  bool _isLoading = true;

  final List<String> _units = [
    '회', '분', '시간', '개', 'km', 'kg', '페이지', '잔', '원'
  ];

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _updateEndDate();
  }

  Future<void> _loadCategories() async {
    final categories = await _categoryRepo.getAllCategories();
    setState(() {
      _categories = categories;
      _selectedCategory = categories.isNotEmpty ? categories[0] : null;
      _isLoading = false;
    });
  }

  void _updateEndDate() {
    setState(() {
      switch (_selectedType) {
        case GoalType.daily:
          _endDate = _startDate;
          break;
        case GoalType.weekly:
          _endDate = _startDate.add(const Duration(days: 6));
          break;
        case GoalType.monthly:
          _endDate = DateTime(_startDate.year, _startDate.month + 1, 0);
          break;
      }
    });
  }

  Future<void> _selectStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
        _updateEndDate();
      });
    }
  }

Future<void> _saveGoal() async {
  if (_formKey.currentState!.validate() && _selectedCategory != null) {
    final goal = Goal(
      userId: 1,
      categoryId: _selectedCategory!.id!,
      title: _titleController.text,
      type: _selectedType,
      targetValue: double.parse(_targetValueController.text),
      unit: _selectedUnit,
      startDate: _startDate,
      endDate: _endDate,
    );

    try {
      await _goalRepo.insertGoal(goal);

      if (!mounted) return;

      Navigator.pop(context, true); // true 반환 확인
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('목표가 추가되었습니다'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('저장 실패: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

  @override
  void dispose() {
    _titleController.dispose();
    _targetValueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFF6C5CE7),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('목표 추가'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveGoal,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '목표 유형',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              SegmentedButton<GoalType>(
                segments: const [
                  ButtonSegment(
                    value: GoalType.daily,
                    label: Text('일일'),
                    icon: Icon(Icons.today),
                  ),
                  ButtonSegment(
                    value: GoalType.weekly,
                    label: Text('주간'),
                    icon: Icon(Icons.view_week),
                  ),
                  ButtonSegment(
                    value: GoalType.monthly,
                    label: Text('월간'),
                    icon: Icon(Icons.calendar_month),
                  ),
                ],
                selected: {_selectedType},
                onSelectionChanged: (Set<GoalType> newSelection) {
                  setState(() {
                    _selectedType = newSelection.first;
                    _updateEndDate();
                  });
                },
              ),

              const SizedBox(height: 24),

              const Text(
                '카테고리',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _categories.map((category) {
                  final isSelected = _selectedCategory?.id == category.id;
                  return ChoiceChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          category.getIcon(),
                          size: 18,
                          color: isSelected ? Colors.white : category.getColor(),
                        ),
                        const SizedBox(width: 4),
                        Text(category.name),
                      ],
                    ),
                    selected: isSelected,
                    selectedColor: category.getColor(),
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: '목표 제목',
                  hintText: '예: 매일 30분 운동하기',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '제목을 입력하세요';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _targetValueController,
                      decoration: const InputDecoration(
                        labelText: '목표 수치',
                        hintText: '예: 30',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '목표 수치를 입력하세요';
                        }
                        if (double.tryParse(value) == null) {
                          return '숫자를 입력하세요';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 1,
                    child: DropdownButtonFormField<String>(
                      value: _selectedUnit,
                      decoration: const InputDecoration(
                        labelText: '단위',
                        border: OutlineInputBorder(),
                      ),
                      items: _units.map((unit) {
                        return DropdownMenuItem(
                          value: unit,
                          child: Text(unit),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedUnit = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '필수';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today, color: Color(0xFF6C5CE7)),
                title: const Text('시작 날짜'),
                subtitle: Text(DateFormat('yyyy년 MM월 dd일').format(_startDate)),
                trailing: const Icon(Icons.chevron_right),
                onTap: _selectStartDate,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
              ),

              const SizedBox(height: 12),

              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.event, color: Color(0xFF6C5CE7)),
                title: const Text('종료 날짜'),
                subtitle: Text(DateFormat('yyyy년 MM월 dd일').format(_endDate)),
                enabled: false,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
              ),

              const SizedBox(height: 32),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF6C5CE7).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF6C5CE7).withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: Color(0xFF6C5CE7),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _selectedType == GoalType.daily
                            ? '오늘 하루 동안 달성할 목표입니다'
                            : _selectedType == GoalType.weekly
                                ? '이번 주 동안 달성할 목표입니다 (7일)'
                                : '이번 달 동안 달성할 목표입니다',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF6C5CE7),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _saveGoal,
                  icon: const Icon(Icons.flag),
                  label: const Text(
                    '목표 추가',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C5CE7),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}