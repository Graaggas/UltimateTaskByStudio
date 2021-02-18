class APIpath {
  static String task(String uid, String taskId) => '/users/$uid/tasks/$taskId';
  static String tasks(String uid) => '/users/$uid/tasks';
}
