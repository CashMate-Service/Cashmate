# Cash Mate - Flutter Loan Application

A mobile loan application built with Flutter that provides a seamless user experience for loan applications.

## Features

- **Login/Sign Up**: Mobile number authentication with OTP verification
- **User Details**: Comprehensive form for personal information
- **Employment Details**: Income and employment information collection
- **Progress Tracking**: Visual progress indicator throughout the application flow
- **Responsive Design**: Optimized for mobile devices

## Screens

1. **Login Screen** (`/`) - Mobile number entry with Google sign-in option
2. **OTP Verification** (`/verify`) - 6-digit OTP verification
3. **Details Form** (`/details`) - Personal information collection
4. **Employment Details** (`/employment`) - Income and employment data
5. **Thank You** (`/thank-you`) - Application success confirmation

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── utils/
│   └── app_colors.dart      # Color constants
├── widgets/
│   ├── custom_button.dart   # Reusable button component
│   ├── custom_text_field.dart # Reusable text field component
│   └── progress_indicator_widget.dart # Progress indicator
└── screens/
    ├── login_screen.dart    # Login/Sign up screen
    ├── verify_screen.dart   # OTP verification screen
    ├── details_screen.dart  # User details form
    ├── employment_screen.dart # Employment details
    └── thank_you_screen.dart # Success screen
```

## Dependencies

- `flutter`: SDK
- `google_fonts`: Custom fonts
- `flutter_otp_text_field`: OTP input field
- `font_awesome_flutter`: Social media icons

## Getting Started

1. Ensure Flutter is installed on your system
2. Clone this repository
3. Run `flutter pub get` to install dependencies
4. Run `flutter run` to start the application

## Design Features

- **Material Design**: Following Flutter's material design principles
- **Custom Colors**: Brand-specific color scheme
- **Responsive Layout**: Optimized for various screen sizes
- **Form Validation**: Input validation and error handling
- **Navigation**: Smooth transitions between screens

## Color Scheme

- Primary: #084B82 (Cash Mate Blue)
- Secondary: #D9D9D9 (Light Gray)
- Accent: #ECECEC (Very Light Gray)
- Success: #22C55E (Green)

The application maintains the exact design and functionality as specified in the original requirements.