void main() {
 String name = 'Shamil';
 double balance = 500;

 checkBalance(name: name, balance: balance);
 print(' ');

 balance = deposit(balance: balance, amount: -100);
 balance = deposit(balance: balance, amount: 150);
 balance = deposit(balance: balance);
 balance = deposit(balance: balance, amount: 1000.5);
 checkBalance(name: name, balance: balance);
 print(' ');

 balance = withdraw(name: name, balance: balance);
 balance = withdraw(name: name, balance: balance, amount: 752.1);
 balance = withdraw(name: name, balance: balance, amount: 752.1, pin: 1111);
 balance = withdraw(name: name, balance: balance, amount: 752.1, pin: 1234);
 checkBalance(name: name, balance: balance);
}

const int correctPin = 1234;

void checkBalance({required String name, required double balance}) => print('$name, your current balance: $balance');

double deposit({required double balance, double? amount}) {
  double depositAmount = amount ?? 0.0;

  if (depositAmount <= 0) {
    print('Unacceptable amount');
    return balance;
  } else {
    double finalBalance = balance + depositAmount;
    print('$depositAmount was added to your balance. Total: $finalBalance');
    return finalBalance;
  }
}

double withdraw({
  required String name,
  required double balance,
  double? amount,
  int? pin
}) {
  int pinCode = pin ?? 0000;
  if (pinCode != correctPin) {
    print('Incorrect PIN');
    return balance;
  }

  double withdrawAmount = amount ?? 0;
  if (withdrawAmount <= 0) {
    print('Incorrect sum for withdrawing');
    return balance;
  }

  if (withdrawAmount > balance) {
    print('Insufficient funds');
    return balance;
  }

  double finalBalance = balance - withdrawAmount;
  print('Withdraw of $withdrawAmount was succesful. Remaining amount: $finalBalance');
  return finalBalance;
}