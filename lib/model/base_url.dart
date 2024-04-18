class BaseUrl {
  final String hostUrl;
  final String personalExpense;
  final String groupExpense;
  final String groupExpenseDate;

  BaseUrl()
      : hostUrl = "http://localhost:8080",
        personalExpense =
            "http://localhost:8080/v1/api/pocket_buddy/personal/expense",
        groupExpense =
            "http://localhost:8080/v1/api/pocket_buddy/group/expense",
        groupExpenseDate =
            "http://localhost:8080/v1/api/pocket_buddy/group/expense/data";
}
