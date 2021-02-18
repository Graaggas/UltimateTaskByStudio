String errorsCheck(String error) {
  if (error.contains("The email address is badly formatted")) {
    print("=> $error");
    return "Неверный формат почтового адреса";
  }

  if (error.contains(
      "The password is invalid or the user does not have a password")) {
    print("=> $error");
    return "Неверный пароль";
  }
  if (error.contains("The user may have been deleted")) {
    print("=> $error");
    return "Пользователь не найден";
  }
  if (error.contains('user account has been disabled by an administrator')) {
    print("=> $error");
    return "Пользователь был отключен администратором";
  }
  if (error.contains('Password should be at least 6')) {
    print("=> $error");
    return "Пароль должен быть больше 5 символов";
  }
  if (error.contains('network_error')) {
    print("=> $error");
    return "Нет доступа к сети Интернет";
  }
  if (error.contains('address is already in use by another')) {
    print("=> $error");
    return "Такой адрес уже используется другой учетной записью";
  }
  if (error.contains('Sign in is aborted by user')) {
    print("=> $error");
    return "Регистрация отменена пользователем";
  }
  print("=> $error");
  return "NULL";
}
