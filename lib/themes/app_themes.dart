import 'package:flutter/material.dart';

class AppColors {
  // Light Mode Colors
  static const lightPrimaryColor = Colors.blue; // Purple
  static const lightBackgroundColor = Color(0xFFFFFFFF); // White
  static const lightTextColor = Color(0xFF000000); // Black
  static const lightblurColor = Color(0xFF040f13); //Dark Blue
  static const lightCardColor = Color(0xFFFCFCF7); //Light Grey
  // Light Mode
  static const lightBorderColor =
      Color.fromARGB(255, 250, 249, 249); // Light Grey Border


  

  // Dark Mode Colors
  static const darkPrimaryColor = Colors.blue; // Light Purple
  static const darkBackgroundColor = Color(0xFF121212); // Dark Grey
  static const darkTextColor = Color(0xFFFFFFFF); // White

  static const darkCardColor = Color.fromARGB(255, 69, 68, 68); //Light Grey
  // Dark Mode
  static const darkBorderColor = Color(0xFF444444); // Dark Grey Border
  
}

class AppThemes {

static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: AppColors.lightPrimaryColor,
    colorScheme: ColorScheme.light(
      primary: AppColors.lightPrimaryColor,
      secondary: AppColors.darkBackgroundColor,
      background: AppColors.lightBackgroundColor,
        surface: AppColors.lightCardColor
    ),
    scaffoldBackgroundColor: AppColors.lightBackgroundColor,
    textTheme: TextTheme(
      bodyText1: TextStyle(color: AppColors.lightTextColor),
      bodyText2: TextStyle(color: AppColors.lightTextColor),
    ),
    appBarTheme: AppBarTheme(
      color: AppColors.lightPrimaryColor,
      iconTheme: IconThemeData(color: Colors.white),
    ),
    cardTheme: CardTheme(
      color: AppColors.lightCardColor,
     
    ),

  );

static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: AppColors.darkPrimaryColor,
    colorScheme: ColorScheme.dark(
      primary: AppColors.darkPrimaryColor,
      secondary: AppColors.lightBackgroundColor,
      background: AppColors.darkBackgroundColor,
        surface: const Color.fromRGBO(69, 68, 68, 1)
    ),
    scaffoldBackgroundColor: AppColors.darkBackgroundColor,
    textTheme: TextTheme(
      bodyText1: TextStyle(color: AppColors.darkTextColor),
      bodyText2: TextStyle(color: AppColors.darkTextColor),
    ),
    appBarTheme: AppBarTheme(
      color: AppColors.darkPrimaryColor,
      iconTheme: IconThemeData(color: AppColors.darkTextColor),
    ),
    cardTheme: CardTheme(
      color: AppColors.darkCardColor,
     
    ),
    
 
  );
}