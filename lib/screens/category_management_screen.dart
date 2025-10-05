import 'package:flutter/material.dart';
import '../models/category.dart';
import '../repositories/category_repository.dart';

class CategoryManagementScreen extends StatefulWidget {
  const CategoryManagementScreen({super.key});

  @override
  State<CategoryManagementScreen> createState() => _CategoryManagementScreenState();
}

class _CategoryManagementScreenState extends State<CategoryManagementScreen> {
  final CategoryRepository _categoryRepo = CategoryRepository();
  List<Category> _categories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() => _isLoading = true);
    final categories = await _categoryRepo.getAllCategories();
    setState(() {
      _categories = categories;
      _isLoading = false;
    });
  }

  void _showAddCategoryDialog() {
    showDialog(
      context: context,
      builder: (context) => AddCategoryDialog(
        onSave: () => _loadCategories(),
      ),
    );
  }

  void _showEditCategoryDialog(Category category) {
    showDialog(
      context: context,
      builder: (context) => EditCategoryDialog(
        category: category,
        onSave: () => _loadCategories(),
      ),
    );
  }

  Future<void> _deleteCategory(int id) async {
    await _categoryRepo.deleteCategory(id);
    _loadCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('카테고리 관리'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddCategoryDialog,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: category.getColor(),
                      child: Icon(
                        category.getIcon(),
                        color: Colors.white,
                      ),
                    ),
                    title: Text(
                      category.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text(
                      category.isDefault ? '기본 카테고리' : '사용자 정의',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_outlined),
                          color: Colors.blue.shade300,
                          onPressed: () => _showEditCategoryDialog(category),
                        ),
                        if (!category.isDefault)
                          IconButton(
                            icon: const Icon(Icons.delete_outline),
                            color: Colors.red.shade300,
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('삭제 확인'),
                                  content: const Text('이 카테고리를 삭제하시겠습니까?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('취소'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        _deleteCategory(category.id!);
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
                  ),
                );
              },
            ),
    );
  }
}

// 카테고리 추가 다이얼로그
class AddCategoryDialog extends StatefulWidget {
  final VoidCallback onSave;

  const AddCategoryDialog({super.key, required this.onSave});

  @override
  State<AddCategoryDialog> createState() => _AddCategoryDialogState();
}

class _AddCategoryDialogState extends State<AddCategoryDialog> {
  final _nameController = TextEditingController();
  final CategoryRepository _categoryRepo = CategoryRepository();
  
  String _selectedIcon = 'circle';
  int _selectedColorIndex = 0;

  final Map<String, IconData> _availableIcons = {
    'favorite': Icons.favorite,
    'fitness_center': Icons.fitness_center,
    'account_balance_wallet': Icons.account_balance_wallet,
    'school': Icons.school,
    'palette': Icons.palette,
    'bedtime': Icons.bedtime,
    'restaurant': Icons.restaurant,
    'work': Icons.work,
    'music_note': Icons.music_note,
    'sports_soccer': Icons.sports_soccer,
    'book': Icons.book,
    'camera_alt': Icons.camera_alt,
    'coffee': Icons.coffee,
    'shopping_cart': Icons.shopping_cart,
    'pets': Icons.pets,
    'flight': Icons.flight,
    'circle': Icons.circle,
  };

  final List<String> _colorHexCodes = [
    'FFE57373',
    'FF81C784',
    'FF64B5F6',
    'FFFFB74D',
    'FFBA68C8',
    'FF4FC3F7',
    'FFAED581',
    'FFFFD54F',
  ];

  Color _getColorFromIndex(int index) {
    return Color(int.parse('0x${_colorHexCodes[index]}'));
  }

  Future<void> _save() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('카테고리 이름을 입력하세요')),
      );
      return;
    }

    final category = Category(
      name: _nameController.text,
      icon: _selectedIcon,
      color: _colorHexCodes[_selectedColorIndex],
      isDefault: false,
      userId: 1,
    );

    await _categoryRepo.insertCategory(category);
    widget.onSave();
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('새 카테고리 추가'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: '카테고리 이름',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const Text('아이콘 선택', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _availableIcons.entries.map((entry) {
                final isSelected = _selectedIcon == entry.key;
                return InkWell(
                  onTap: () {
                    setState(() => _selectedIcon = entry.key);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? _getColorFromIndex(_selectedColorIndex) 
                          : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected 
                            ? _getColorFromIndex(_selectedColorIndex) 
                            : Colors.grey.shade300,
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      entry.value,
                      color: isSelected ? Colors.white : Colors.grey.shade700,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            const Text('색상 선택', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(_colorHexCodes.length, (index) {
                final color = _getColorFromIndex(index);
                final isSelected = _selectedColorIndex == index;
                return InkWell(
                  onTap: () {
                    setState(() => _selectedColorIndex = index);
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? Colors.black : Colors.transparent,
                        width: 3,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white)
                        : null,
                  ),
                );
              }),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('취소'),
        ),
        ElevatedButton(
          onPressed: _save,
          child: const Text('추가'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}

// 카테고리 수정 다이얼로그
class EditCategoryDialog extends StatefulWidget {
  final Category category;
  final VoidCallback onSave;

  const EditCategoryDialog({
    super.key,
    required this.category,
    required this.onSave,
  });

  @override
  State<EditCategoryDialog> createState() => _EditCategoryDialogState();
}

class _EditCategoryDialogState extends State<EditCategoryDialog> {
  late TextEditingController _nameController;
  final CategoryRepository _categoryRepo = CategoryRepository();
  
  late String _selectedIcon;
  late int _selectedColorIndex;

  final Map<String, IconData> _availableIcons = {
    'favorite': Icons.favorite,
    'fitness_center': Icons.fitness_center,
    'account_balance_wallet': Icons.account_balance_wallet,
    'school': Icons.school,
    'palette': Icons.palette,
    'bedtime': Icons.bedtime,
    'restaurant': Icons.restaurant,
    'work': Icons.work,
    'music_note': Icons.music_note,
    'sports_soccer': Icons.sports_soccer,
    'book': Icons.book,
    'camera_alt': Icons.camera_alt,
    'coffee': Icons.coffee,
    'shopping_cart': Icons.shopping_cart,
    'pets': Icons.pets,
    'flight': Icons.flight,
    'circle': Icons.circle,
  };

  final List<String> _colorHexCodes = [
    'FFE57373',
    'FF81C784',
    'FF64B5F6',
    'FFFFB74D',
    'FFBA68C8',
    'FF4FC3F7',
    'FFAED581',
    'FFFFD54F',
  ];

  Color _getColorFromIndex(int index) {
    return Color(int.parse('0x${_colorHexCodes[index]}'));
  }

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category.name);
    _selectedIcon = widget.category.icon;
    _selectedColorIndex = _colorHexCodes.indexOf(widget.category.color);
    if (_selectedColorIndex == -1) _selectedColorIndex = 0;
  }

  Future<void> _save() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('카테고리 이름을 입력하세요')),
      );
      return;
    }

    final category = Category(
      id: widget.category.id,
      name: _nameController.text,
      icon: _selectedIcon,
      color: _colorHexCodes[_selectedColorIndex],
      isDefault: widget.category.isDefault,
      userId: widget.category.userId,
    );

    await _categoryRepo.updateCategory(category);
    widget.onSave();
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('카테고리 수정'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: '카테고리 이름',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const Text('아이콘 선택', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _availableIcons.entries.map((entry) {
                final isSelected = _selectedIcon == entry.key;
                return InkWell(
                  onTap: () {
                    setState(() => _selectedIcon = entry.key);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? _getColorFromIndex(_selectedColorIndex) 
                          : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected 
                            ? _getColorFromIndex(_selectedColorIndex) 
                            : Colors.grey.shade300,
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      entry.value,
                      color: isSelected ? Colors.white : Colors.grey.shade700,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            const Text('색상 선택', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(_colorHexCodes.length, (index) {
                final color = _getColorFromIndex(index);
                final isSelected = _selectedColorIndex == index;
                return InkWell(
                  onTap: () {
                    setState(() => _selectedColorIndex = index);
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? Colors.black : Colors.transparent,
                        width: 3,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white)
                        : null,
                  ),
                );
              }),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('취소'),
        ),
        ElevatedButton(
          onPressed: _save,
          child: const Text('저장'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}