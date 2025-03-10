extension ToSnakeCase on String {
  String toSnakeCase() {
    String input = this;
    if (input.isEmpty) return input;

    StringBuffer result = StringBuffer();

    // Add the first character as lowercase
    result.write(input[0].toLowerCase());

    // Iterate through the rest of the characters
    for (int i = 1; i < input.length; i++) {
      if (input[i] == input[i].toUpperCase() && input[i] != '_') {
        // Add an underscore before uppercase letters
        result.write('_');
      }
      // Add the lowercase version of the character
      result.write(input[i].toLowerCase());
    }

    return result.toString();
  }
}
