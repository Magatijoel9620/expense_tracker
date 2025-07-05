# Flutter Expense Tracker

A mobile application built with Flutter to help you track your daily expenses efficiently. Features include adding, editing, and deleting expenses, viewing a weekly summary, and visualizing spending patterns with an interactive bar graph.

## Features

*   **Expense Tracking:** Easily add, view, edit, and delete your expenses.
*   **Intuitive Input:** Modern modal bottom sheet for quick expense entry (KES and cents).
*   **Weekly Summary:** At-a-glance overview of your spending for the current week using a bar graph.
*   **Visual Insights:** Interactive bar graph (`fl_chart`) displaying daily expenses for the week.
*   **Data Persistence:** (Mention your persistence method here, e.g., "Expenses are stored locally using `shared_preferences`/`sqflite`/`hive`" - *If not yet implemented, you can list this under "Future Enhancements"*)
*   **Clear UI:** Clean and user-friendly interface with light theme support.
*   **State Management:** Efficient state management using the `provider` package.


| Home Page (Expenses & Graph)                                     | Add/Edit Expense Modal                                          | Weekly Summary Detail (if applicable)                            |
| :--------------------------------------------------------------- | :-------------------------------------------------------------- | :--------------------------------------------------------------- |
| ![Home Page](screenshots/home_page.png "Home Page with Expenses") | ![Add Expense Modal](screenshots/add_expense_modal.png "Add/Edit Expense") | ![Summary Detail](screenshots/summary_detail.png "Weekly Summary") |
| *Main view showing the expense list and weekly bar graph.*        | *Modal for adding or editing an expense item.*                   | *(Optional: If you have a dedicated summary view)*                |


## Future Enhancements / To-Do

*(Optional: List features you plan to add or areas for improvement)*

*   [ ] Data Persistence (e.g., using `sqflite` for robust local storage).
*   [ ] User Authentication (if planning for cloud sync).
*   [ ] Cloud Sync/Backup.
*   [ ] Monthly/Custom Date Range Summaries and Filtering.
*   [ ] Expense Categories and Filtering by Category.
*   [ ] Export Data (e.g., to CSV).
*   [ ] Dark Mode Theme.
*   [ ] More Advanced Reporting and Charts.
*   [ ] Unit and Integration Tests.