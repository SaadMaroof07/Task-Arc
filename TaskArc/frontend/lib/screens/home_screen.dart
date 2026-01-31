import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Screen load hotay hi tasks fetch karne ke liye
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final p = Provider.of<UserProvider>(context, listen: false);
      p.fetchTasks();
      p.fetchCategories();
    });
  }

  Future<void> _showAddTaskSheet(BuildContext context) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    // Ensure categories are loaded before showing sheet
    await userProvider.fetchCategories();

    final titleController = TextEditingController();
    final descController = TextEditingController();
    String selectedPriority = 'M';
    int? selectedCategoryId;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Keyboard ke liye zaroori hai
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => StatefulBuilder( // Modal ke andar state change karne ke liye
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom, // Keyboard ke upar rahega
            left: 20, right: 20, top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Add New Task", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: "Task Title", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: descController,
                decoration: const InputDecoration(labelText: "Description", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 15),
              
              // Category Dropdown
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(labelText: "Select Category", border: OutlineInputBorder()),
                value: selectedCategoryId,
                hint: userProvider.categories.isEmpty ? const Text('No categories available') : null,
                items: userProvider.categories.map((cat) {
                  return DropdownMenuItem<int>(
                    value: cat['id'],
                    child: Text(cat['name'].toString()),
                  );
                }).toList(),
                onChanged: (val) => setModalState(() => selectedCategoryId = val),
              ),
              const SizedBox(height: 15),

              // Priority Selection
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _priorityChip(setModalState, "Low", "L", Colors.green, selectedPriority == "L", (val) => selectedPriority = val),
                  _priorityChip(setModalState, "Medium", "M", Colors.orange, selectedPriority == "M", (val) => selectedPriority = val),
                  _priorityChip(setModalState, "High", "H", Colors.red, selectedPriority == "H", (val) => selectedPriority = val),
                ],
              ),
              
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(15), backgroundColor: Colors.blue),
                  onPressed: () async {
                    if (titleController.text.isNotEmpty) {
                      final success = await userProvider.addTask({
                        "title": titleController.text,
                        "description": descController.text,
                        "priority": selectedPriority,
                        "category": selectedCategoryId,
                      });
                      if (success) {
                        Navigator.pop(context);
                        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Task saved")));
                      } else {
                        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Failed to save task")));
                      }
                    }
                  },
                  child: const Text("Save Task", style: TextStyle(color: Colors.white)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // Priority Chip Helper
  Widget _priorityChip(StateSetter setState, String label, String value, Color color, bool isSelected, Function(String) onSelect) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: color.withOpacity(0.3),
      onSelected: (selected) {
        setState(() => onSelect(value));
      },
    );
  }

  Color getPriorityColor(String priority) {
    switch (priority) {
      case 'H':
        return Colors.redAccent;
      case 'M':
        return Colors.orangeAccent;
      case 'L':
        return Colors.greenAccent;
      default:
        return Colors.grey;
    }

    
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          "TaskArc",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => userProvider.fetchTasks(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Categories Section
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                "Categories",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),

            SizedBox(
              height: 50,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: (userProvider.categories.isNotEmpty
                        ? userProvider.categories.map((c) => c['name'].toString())
                        : ["Work", "Personal", "Health", "Study"])
                    .map(
                      (cat) => Container(
                        margin: const EdgeInsets.only(right: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          color: Colors.blue[100],
                          borderRadius: BorderRadius.circular(25),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          cat,
                          style: const TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),

            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                "My Tasks",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),

            // Tasks List
            Expanded(
              child: userProvider.tasks.isEmpty
                  ? const Center(child: Text("No tasks yet! Pull to refresh."))
                  : ListView.builder(
                      itemCount: userProvider.tasks.length,
                      itemBuilder: (context, index) {
                        final task = userProvider.tasks[index];
                        return Dismissible(
                          key: Key(task['id'].toString()),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            color: Colors.red,
                            child: const Icon(Icons.delete, color: Colors.white),
                          ),
                          onDismissed: (direction) async {
                            final idVal = task['id'];
                            int? parsedId;
                            if (idVal is int) parsedId = idVal;
                            else parsedId = int.tryParse(idVal?.toString() ?? '');

                            if (parsedId != null) {
                              await userProvider.deleteTask(parsedId);
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Task deleted")),
                                );
                              }
                            }
                          },
                          child: Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: ListTile(
                              leading: Container(
                                width: 5,
                                height: 30,
                                decoration: BoxDecoration(
                                  color: getPriorityColor(
                                    task['priority'] ?? 'M',
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              title: Text(
                                task['title'],
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  decoration: task['is_completed'] == true
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                              ),
                              subtitle: Text(
                                task['description'] ?? 'No description',
                              ),
                              trailing: SizedBox(
                                width: 110,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Checkbox(
                                      value: task['is_completed'] ?? false,
                                      onChanged: (val) async {
                                        if (val == null) return;
                                        final id = task['id'];
                                        if (id is int) {
                                          await userProvider.toggleTaskCompletion(
                                            id,
                                            val,
                                          );
                                        } else if (id is String) {
                                          final parsed = int.tryParse(id);
                                          if (parsed != null)
                                            await userProvider.toggleTaskCompletion(
                                              parsed,
                                              val,
                                            );
                                        }
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete),
                                      color: Colors.red,
                                      onPressed: () async {
                                        // Confirm delete
                                        final confirmed = await showDialog<bool>(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: const Text('Delete Task'),
                                            content: const Text('Are you sure you want to delete this task?'),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.of(context).pop(false),
                                                child: const Text('Cancel'),
                                              ),
                                              TextButton(
                                                onPressed: () => Navigator.of(context).pop(true),
                                                child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                              ),
                                            ],
                                          ),
                                        );

                                        if (confirmed == true) {
                                          final idVal = task['id'];
                                          int? parsedId;
                                          if (idVal is int) parsedId = idVal;
                                          else parsedId = int.tryParse(idVal?.toString() ?? '');

                                          if (parsedId != null) {
                                            await userProvider.deleteTask(parsedId);
                                            if (mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(content: Text('Task deleted')),
                                              );
                                            }
                                          }
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(

        backgroundColor: Colors.blue,
        onPressed: () =>_showAddTaskSheet(context),
        child: const Icon(Icons.add,color: Colors.white),
      ),
    );
  }
}
