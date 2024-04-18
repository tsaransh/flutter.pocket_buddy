class BaseUrl {
  final String hostUrl;
  final String personalExpense;
  final String groupExpense;
  final String groupExpenseDate;

  BaseUrl()
      : hostUrl = "http://192.168.29.111:8080",
        personalExpense =
            "http://192.168.29.111:8080/v1/api/pocket_buddy/personal/expense",
        groupExpense =
            "http://192.168.29.111/v1/api/pocket_buddy/group/expense",
        groupExpenseDate =
            "http://192.168.29.111:8080/v1/api/pocket_buddy/group/expense/data";
}
