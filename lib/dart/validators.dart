class Validators {

  bool onlyLetters(String input){    
    final regex = RegExp(r'^[\u0600-\u06FF\s]+$', unicode: true);
    if (!regex.hasMatch(input)){
      return false;
    } else {
      return true;
    }
  }

  String convertToEasternArabicNumbers(String input) {
  const englishDigits = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
  const arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
  
  String result = input;
  for (int i = 0; i < englishDigits.length; i++) {
    result = result.replaceAll(englishDigits[i], arabicDigits[i]);
  }
  return result;
  }

}