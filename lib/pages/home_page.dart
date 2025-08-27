import 'package:expense_tracker/components/expense_summary.dart';
import 'package:expense_tracker/components/expense_tile.dart';
import 'package:expense_tracker/models/expense_item.dart';
import 'package:expense_tracker/theme_provider.dart'; // Import ThemeProvider
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../auth/auth_service.dart';
import '../data/expense_data.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final newExpenseNameController = TextEditingController();
  final newExpenseDollarController = TextEditingController();
  final newExpenseCentsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Access providers using Provider.of within initState or didChangeDependencies
    // It's generally safer to do this in didChangeDependencies if you need context extensively,
    // but for one-off calls like this, initState is fine as long as listen: false.
    Provider.of<ExpenseData>(context, listen: false).prepareData();
  }

  void _showExpenseFormModal(BuildContext context, {ExpenseItem? expense}) {
    final theme = Theme.of(context); // Get theme for modal styling
    final bool isEditing = expense != null;

    if (isEditing) {
      newExpenseNameController.text = expense!.name;
      List<String> amountParts = expense.amount.split('.');
      newExpenseDollarController.text = amountParts.isNotEmpty ? amountParts[0] : '';
      newExpenseCentsController.text = amountParts.length > 1 ? amountParts[1] : '';
    } else {
      clear();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.cardColor, // Use theme card color for modal background
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext bc) {
        // Use the context 'bc' from the builder for Theme.of(bc) if needed inside
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(bc).viewInsets.bottom,
            top: 20,
            left: 20,
            right: 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  isEditing ? 'Edit Expense' : 'Add New Expense',
                  textAlign: TextAlign.center,
                  style: Theme.of(bc).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: newExpenseNameController,
                  autofocus: !isEditing,
                  decoration: InputDecoration(
                    labelText: 'Expense Name',
                    hintText: 'e.g., Coffee, Lunch',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.drive_file_rename_outline),
                    // Consider theming for InputDecoration as well if needed
                  ),
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: newExpenseDollarController,
                        decoration: InputDecoration(
                          labelText: 'Amount (KES)',
                          hintText: 'e.g., 500',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          prefixIcon: const Icon(Icons.attach_money),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
                      // Ensure this text color adapts if necessary, though it's usually neutral
                      child: Text('.', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Theme.of(bc).colorScheme.onSurface)),
                    ),
                    Expanded(
                      child: TextField(
                        controller: newExpenseCentsController,
                        decoration: InputDecoration(
                          labelText: 'Cents',
                          hintText: 'e.g., 50',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          // counterText: "", // To hide the counter if not desired
                        ),
                        keyboardType: TextInputType.number,
                        maxLength: 2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  icon: Icon(isEditing ? Icons.save_alt_rounded : Icons.add_task_rounded),
                  label: Text(isEditing ? 'Save Changes' : 'Add Expense'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    backgroundColor: Theme.of(bc).colorScheme.primary, // Use theme
                    foregroundColor: Theme.of(bc).colorScheme.onPrimary, // Use theme
                  ),
                  onPressed: () {
                    if (isEditing) {
                      _performEdit(expense);
                    } else {
                      save();
                    }
                  },
                ),
                const SizedBox(height: 8),
                TextButton(
                  child: Text('Cancel', style: TextStyle(color: Theme.of(bc).colorScheme.secondary)), // Use theme
                  onPressed: () {
                    Navigator.pop(bc);
                    clear();
                  },
                ),
                const SizedBox(height: 10), // For keyboard spacing
              ],
            ),
          ),
        );
      },
    ).whenComplete(() {
      clear();
    });
  }

  void addNewExpense() {
    _showExpenseFormModal(context);
  }

  void editExpense(ExpenseItem expense) {
    _showExpenseFormModal(context, expense: expense);
  }

  void _performEdit(ExpenseItem? originalExpense) {
    if (originalExpense == null) return;

    // Use Provider.of with listen:false for one-time actions in methods
    final expenseDataProvider = Provider.of<ExpenseData>(context, listen: false);

    if (newExpenseNameController.text.isNotEmpty ||
        newExpenseDollarController.text.isNotEmpty ||
        newExpenseCentsController.text.isNotEmpty) {
      String name = newExpenseNameController.text.isNotEmpty
          ? newExpenseNameController.text
          : originalExpense.name;

      String dollars = newExpenseDollarController.text.isNotEmpty
          ? newExpenseDollarController.text
          : originalExpense.amount.split('.').first;
      String cents = newExpenseCentsController.text.isNotEmpty
          ? newExpenseCentsController.text.padRight(2, '0')
          : (originalExpense.amount.split('.').length > 1 ? originalExpense.amount.split('.')[1].padRight(2, '0') : "00");

      String amount = '$dollars.$cents';

      ExpenseItem updatedExpense = ExpenseItem(
        name: name,
        amount: amount,
        dateTime: DateTime.now(), // Or originalExpense.dateTime if not updating timestamp
      );

      expenseDataProvider.updateExpense(updatedExpense, originalExpense);

      if (mounted) { // Check if the widget is still in the tree
        Navigator.pop(context);
        clear();
      }
    }
  }

  void save() {
    final expenseDataProvider = Provider.of<ExpenseData>(context, listen: false);

    if (newExpenseNameController.text.isNotEmpty &&
        newExpenseDollarController.text.isNotEmpty) {
      String cents = newExpenseCentsController.text.isEmpty
          ? "00"
          : newExpenseCentsController.text.padLeft(2, '0');
      cents = cents.length > 2 ? cents.substring(0, 2) : cents;

      String amount = '${newExpenseDollarController.text}.$cents';

      ExpenseItem newExpense = ExpenseItem(
        name: newExpenseNameController.text,
        amount: amount,
        dateTime: DateTime.now(),
      );
      expenseDataProvider.addNewExpense(newExpense);

      if (mounted) {
        Navigator.pop(context); // Close modal
        clear();
      }
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please fill in at least name and amount.'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void deleteExpense(ExpenseItem expense) {
    Provider.of<ExpenseData>(context, listen: false).deleteExpense(expense);
  }

  // cancel() and clear() methods remain the same

  void cancel() {
    if (mounted) Navigator.pop(context);
    clear();
  }

  void clear() {
    newExpenseNameController.clear();
    newExpenseDollarController.clear();
    newExpenseCentsController.clear();
  }


  @override
  Widget build(BuildContext context) {
    // Access the current theme and providers
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context); // For toggling
    // No need to explicitly call Provider.of<ExpenseData> here if using Consumer below

    return Consumer<ExpenseData>(
      builder: (BuildContext context, expenseDataValue, child) {
        bool hasExpenses = expenseDataValue.getAllExpenseList().isNotEmpty;

        return Scaffold(
          backgroundColor: theme.colorScheme.surface, // Uses theme
          appBar: AppBar(
            title: const Text('Expense Tracker', style: TextStyle(fontWeight: FontWeight.bold)),
            centerTitle: true,
            // AppBar backgroundColor and foregroundColor are now primarily controlled by
            // ThemeData's appBarTheme in main.dart (via ThemeProvider)
            // backgroundColor: theme.colorScheme.primary, // Keep if you need specific override
            // foregroundColor: theme.colorScheme.onPrimary, // Keep if you need specific override
            elevation: 2.0, // This is fine
            shape: const RoundedRectangleBorder( // This is fine
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(20),
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  themeProvider.isDarkMode ? Icons.nightlight_round : Icons.wb_sunny_rounded,
                  // Color can be explicitly set or rely on AppBar's foregroundColor/iconTheme
                  // color: theme.colorScheme.onPrimary, // Already handled by AppBar's foreground
                ),
                tooltip: themeProvider.isDarkMode ? 'Switch to Light Mode' : 'Switch to Dark Mode',
                onPressed: () {
                  themeProvider.toggleTheme(!themeProvider.isDarkMode);
                },
              ),
              // IconButton( // ADD SIGN OUT BUTTON
              //   icon: const Icon(Icons.logout),
              //   tooltip: 'Sign Out',
              //   onPressed: () async {
              //     final authService = Provider.of<AuthService>(context, listen: false);
              //     await authService.signOut();
              //     // AuthWrapper will handle navigation
              //   },
              // ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: addNewExpense,
            // backgroundColor and foregroundColor are handled by the theme's colorScheme
            // backgroundColor: theme.colorScheme.secondary,
            // foregroundColor: theme.colorScheme.onSecondary,
            icon: const Icon(Icons.add_shopping_cart_rounded),
            label: const Text('Add Expense'),
            elevation: 4.0,
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Card(
                    // Card color is theme.cardColor or theme.colorScheme.surface
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      // Pass the expenseDataValue from the Consumer
                      child: ExpenseSummary(startOfWeek: expenseDataValue.startOfWeekDate()),
                    ),
                  ),
                ),
                if (hasExpenses)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Text(
                      'Recent Expenses',
                      style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onBackground.withOpacity(0.8)), // Example: Slightly subdued onBackground
                    ),
                  ),
                if (hasExpenses)
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 80), // For FAB overlap
                    itemCount: expenseDataValue.getAllExpenseList().length,
                    itemBuilder: (context, index) {
                      final expense = expenseDataValue.getAllExpenseList()[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                        child: ExpenseTile( // ExpenseTile should internally use Theme.of(context)
                          name: expense.name,
                          amount: expense.amount,
                          dateTime: expense.dateTime,
                          deleteTapped: (p0) => deleteExpense(expense),
                          editTapped: (p0) => editExpense(expense),
                        ),
                      );
                    },
                  )
                else
                // Pass the current theme to _buildEmptyState
                  _buildEmptyState(theme),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(ThemeData theme) { // Accept ThemeData
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0).copyWith(top: 50),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 80,
              color: theme.colorScheme.secondary.withOpacity(0.7), // Use theme color
            ),
            const SizedBox(height: 20),
            Text(
              'No expenses yet!',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.onBackground.withOpacity(0.9), // Use theme color
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Tap the 'Add Expense' button below to get started.",
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onBackground.withOpacity(0.7), // Use theme color
              ),
            ),
          ],
        ),
      ),
    );
  }
}

