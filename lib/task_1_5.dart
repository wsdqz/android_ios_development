void main() {
  print('=== TASK 1 ===');
  Task1();

  print('\n=== TASK 2 ===');
  Task2("28.02.2024");

  print('\n=== TASK 3 ===');
  Task3("flutter mobile development");

  print('\n=== TASK 4 ===');
  Task4([14, 88, 3, 42, 99, 12, 67]);

  print('\n=== TASK 5 ===');
  Task5(3);
}

// TASK 1
// OUTPUT MULTIPLICATION TABLE  1-10
void Task1() {
  for (var i = 1; i <= 10; i++) {
    for (var j = 1; j <= 10; j++) {
      print('$i * $j = ${i * j}');
    }
  }
}

// TASK 2
// next day : examples:
// 05.09.2026 -> 06.09.2026
// 28.02.2024 -> 29.02.2024
// 28.02.2026 -> 01.03.2026
// 29.02.2026 -> invalid date
// 28.02.2100 -> 01.03.2100
// 28.02.2100 -> 29.02.2000
// 31.12.2025 -> 01.01.2026
// 2000,2400 leap year
// 2100,2200,2300 isn`t leap year
void Task2(String date) {
  var parts = date.split('.');
  var day = int.parse(parts[0]);
  var month = int.parse(parts[1]);
  var year = int.parse(parts[2]);

  var daysInMonth = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
  var isLeap = (year % 400 == 0) || (year % 4 == 0 && year % 100 != 0);
  if (month == 2 && isLeap) daysInMonth[1] = 29;

  if (month < 1 || month > 12 || day < 1 || day > daysInMonth[month - 1]) {
    print('Invalid date');
    return;
  }

  day++;
  if (day > daysInMonth[month - 1]) {
    day = 1;
    month++;
    if (month > 12) {
      month = 1;
      year++;
    }
  }

  var dayStr = day < 10 ? '0$day' : day.toString();
  var monthStr = month < 10 ? '0$month' : month.toString();

  print('$dayStr.$monthStr.$year');
}

// TASK3
// Vowel Counter in a String -> "flutter mobile development" -> 8
void Task3(String text) {
  var vowels = ['a', 'e', 'i', 'o', 'u'];
  var count = 0;

  for (var i = 0; i < text.length; i++) {
    var char = text[i].toLowerCase();
    if (vowels.contains(char)) {
      count++;
    }
  }

  print(count);
}

// TASK4
// Manual min & max finder
void Task4(List<int> numbers) {
  var max = numbers[0];
  var min = numbers[0];

  for (var i = 1; i < numbers.length; i++) {
    if (numbers[i] > max) max = numbers[i];
    if (numbers[i] < min) min = numbers[i];
  }

  print('Max: $max, Min: $min');
}

// TASK 5
// Prime Number Checker
// 3 -> prime number
// 6 -> not prime number
void Task5(int number) {
  if (number < 2) {
    print('$number - not prime number');
    return;
  }

  var isPrime = true;

  for (var i = 2; i < number; i++) {
    if (number % i == 0) {
      isPrime = false;
      break;
    }
  }

  if (isPrime) {
    print('$number - prime');
  } else {
    print('$number - not prime');
  }
}