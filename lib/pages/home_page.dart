import 'package:expense_tracker/components/expense_summary.dart';
import 'package:expense_tracker/components/expense_tile.dart';
import 'package:expense_tracker/models/expense_item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/expense_data.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // TEXT CONTROLLERS
  final newExpenseNameController = TextEditingController();
  final newExpenseDollarController = TextEditingController();
  final newExpenseCentsController = TextEditingController();

  @override
  void initState() {
    super.initState();

    //prepare data on startup
    Provider.of<ExpenseData>(context, listen: false).prepareData();
  }

  // At the top of your _HomePageState class, or in a separate widget file

  void _showExpenseFormModal(BuildContext context, {ExpenseItem? expense}) {
    // If 'expense' is not null, it's an edit operation
    final bool isEditing = expense != null;

    // Pre-fill controllers if editing
    if (isEditing) {
      newExpenseNameController.text = expense.name;
      // Assuming amount is stored as "dollars.cents" string
      List<String> amountParts = expense.amount.split('.');
      newExpenseDollarController.text = amountParts.isNotEmpty ? amountParts[0] : '';
      newExpenseCentsController.text = amountParts.length > 1 ? amountParts[1] : '';
    } else {
      // Clear controllers for new expense
      clear(); // Your existing clear method
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Important for keyboard handling
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext bc) {
        // It's good practice to make the modal content a StatefulWidget
        // if it has its own complex state or controllers not managed by the parent.
        // For this example, we'll keep it simple and use parent's controllers.
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(bc).viewInsets.bottom, // Adjust for keyboard
            top: 20,
            left: 20,
            right: 20,
          ),
          child: SingleChildScrollView( // To prevent overflow when keyboard appears
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  isEditing ? 'Edit Expense' : 'Add New Expense',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                // Expense Name
                TextField(
                  controller: newExpenseNameController,
                  autofocus: !isEditing, // Autofocus only for new expense
                  decoration: InputDecoration(
                    labelText: 'Expense Name',
                    hintText: 'e.g., Coffee, Lunch',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.drive_file_rename_outline),
                  ),
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 16),
                // Expense Amount
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
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
                      child: Text('.', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    ),
                    Expanded(
                      child: TextField(
                        controller: newExpenseCentsController,
                        decoration: InputDecoration(
                          labelText: 'Cents',
                          hintText: 'e.g., 50',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        keyboardType: TextInputType.number,
                        maxLength: 2, // Max 2 digits for cents
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
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                  onPressed: () {
                    if (isEditing) {
                      _performEdit(expense); // Modified save logic for edit
                    } else {
                      save(); // Your existing save method
                    }
                  },
                ),
                const SizedBox(height: 8),
                TextButton(
                  child: Text('Cancel', style: TextStyle(color: Theme.of(context).colorScheme.secondary)),
                  onPressed: () {
                    Navigator.pop(bc); // Close bottom sheet
                    clear(); // Clear controllers
                  },
                ),
                const SizedBox(height: 10), // Space for keyboard
              ],
            ),
          ),
        );
      },
    ).whenComplete(() {
      // Clear controllers when the sheet is dismissed,
      // especially if not explicitly saved or cancelled.
      clear();
    });
  }

// Modify your addNewExpense and editExpense methods to use this:
  void addNewExpense() {
    _showExpenseFormModal(context);
  }

  void editExpense(ExpenseItem expense) {
    _showExpenseFormModal(context, expense: expense);
  }

// New method for handling the edit logic from the modal
  void _performEdit(ExpenseItem? originalExpense) {
    if (originalExpense == null) return;

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
          ? newExpenseCentsController.text.padRight(2, '0') // Ensure two digits for cents
          : (originalExpense.amount.split('.').length > 1 ? originalExpense.amount.split('.')[1].padRight(2, '0') : "00");

      String amount = '$dollars.$cents';

      ExpenseItem updatedExpense = ExpenseItem(
        // Important: If your ExpenseItem has an ID, you need to preserve it for updates
        // id: originalExpense.id, // Assuming ExpenseItem has an ID
        name: name,
        amount: amount,
        dateTime: DateTime.now(), // Or originalExpense.dateTime if you don't want to update timestamp
      );

      Provider.of<ExpenseData>(context, listen: false)
          .updateExpense(updatedExpense, originalExpense); // You might need to pass the original to find it

      Navigator.pop(context); // Close modal
      clear();
    }
  }

// Modify save (for new expenses) to also check for non-empty cents, or default to .00
  void save() {
    if (newExpenseNameController.text.isNotEmpty &&
        newExpenseDollarController.text.isNotEmpty) {
      String cents = newExpenseCentsController.text.isEmpty
          ? "00"
          : newExpenseCentsController.text.padLeft(2, '0'); // Ensure two digits
      cents = cents.length > 2 ? cents.substring(0, 2) : cents; // Max 2 digits

      String amount = '${newExpenseDollarController.text}.$cents';

      ExpenseItem newExpense = ExpenseItem(
        name: newExpenseNameController.text,
        amount: amount,
        dateTime: DateTime.now(),
      );
      Provider.of<ExpenseData>(context, listen: false)
          .addNewExpense(newExpense);

      Navigator.pop(context); // Close modal
      clear();
    } else {
      // Optional: Show a snackbar or some feedback if fields are missing
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in at least name and amount.')),
      );
    }
  }

// Remove _editExpenseButton method as its logic is now in _performEdit


  //delete expense
  void deleteExpense(ExpenseItem expense) {
    Provider.of<ExpenseData>(context, listen: false).deleteExpense(expense);
  }

  //cancel
  void cancel() {
    Navigator.pop(context);
    clear();
  }

  // clear controllers
  void clear() {
    newExpenseNameController.clear();
    newExpenseDollarController.clear();
    newExpenseCentsController.clear();
  }

  @override

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Use theme for colors

    return Consumer<ExpenseData>(
      builder: (BuildContext context, value, child) {
        bool hasExpenses = value.getAllExpenseList().isNotEmpty;

        return Scaffold(
          backgroundColor: theme.colorScheme.surfaceVariant.withOpacity(0.5), // Slightly off-white or themed background
          appBar: AppBar(
            title: const Text('Expense Tracker', style: TextStyle(fontWeight: FontWeight.bold)),
            centerTitle: true,
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
            elevation: 2.0,
            shape: const RoundedRectangleBorder( // <--- Add this
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(20),
              ),
            ),
            // actions: [ // Optional: Add actions like filter or settings
            //   IconButton(icon: Icon(Icons.filter_list), onPressed: () {}),
            // ],
          ),
          floatingActionButton: FloatingActionButton.extended( // Use extended FAB for better label
            onPressed: addNewExpense,
            backgroundColor: theme.colorScheme.secondary,
            foregroundColor: theme.colorScheme.onSecondary,
            icon: const Icon(Icons.add_shopping_cart_rounded),
            label: const Text('Add Expense'),
            elevation: 4.0,
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat, // Or .endFloat
          body: Column( // Use Column for better structure if AppBar is present
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Weekly summary - Consider giving it more visual prominence
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Card( // Wrap summary in a Card
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0), // Inner padding for card content
                    child: ExpenseSummary(startOfWeek: value.startOfWeekDate()),
                  ),
                ),
              ),

              // Separator or Title for the list
              if (hasExpenses)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Text(
                    'Recent Expenses',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: theme.colorScheme.onSurfaceVariant),
                  ),
                ),

              // Expense list or Empty State
              Expanded( // Important: Make ListView take remaining space
                child: hasExpenses
                    ? ListView.builder(
                  padding: const EdgeInsets.only(bottom: 80), // Padding for FAB overlap
                  itemCount: value.getAllExpenseList().length,
                  itemBuilder: (context, index) {
                    final expense = value.getAllExpenseList()[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                      child: ExpenseTile( // Ensure ExpenseTile is well-designed
                        name: expense.name,
                        amount: expense.amount,
                        dateTime: expense.dateTime,
                        deleteTapped: (p0) => deleteExpense(expense),
                        editTapped: (p0) => editExpense(expense),
                        // Consider passing the whole expense object to ExpenseTile
                        // expense: expense,
                      ),
                    );
                  },
                )
                    : _buildEmptyState(theme), // Show a nice empty state
              ),
            ],
          ),
        );
      },
    );
  }

// Helper widget for empty state
  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long_outlined, size: 80, color: theme.colorScheme.secondary.withOpacity(0.7)),
            const SizedBox(height: 20),
            Text(
              'No expenses yet!',
              style: theme.textTheme.headlineSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 10),
            Text(
              "Tap the 'Add Expense' button below to get started.",
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant.withOpacity(0.8)),
            ),
          ],
        ),
      ),
    );
  }
}