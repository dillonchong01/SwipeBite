# Food Chooser Flutter Web App

A mobile-friendly Flutter web application that helps users decide what to eat using weighted random selection based on their preferences and frequency of choices.

## Features

### 🔐 Authentication
- Google Sign-In only
- Secure user authentication with Firebase
- Each user sees only their own data

### 🎲 Main Food Chooser
- Multi-select locations for food selection
- Weighted random selection based on choice frequency
- **Lock It In** button: Confirms choice and increments frequency counter
- **Nah** button: Spins again without updating frequency
- Visual toggles that affect probability:
  - **"I'm feeling Rich"** 💰 - Increases probability of high-budget options (3x multiplier)
  - **"I'm feeling New"** ✨ - Inverses probabilities (lower frequency = higher chance)
- Animated card flips and confetti celebration on lock-in
- Smooth spinning animations

### ➕ Add Food Choice
- Input food name
- Multi-select locations (creates multiple documents if multiple locations selected)
- Budget selection (High/Low)
- Automatically initializes frequency counter to 1
- Add new locations on the fly

### ⚙️ Settings Tab
- View all locations
- Click location to see all food choices at that location
- Edit food choice budget
- Delete individual food choices
- Delete entire locations (removes all associated food)
- Clean, organized interface

### 🎨 UI/UX Features
- Mobile-first responsive design
- Bold gradient colors and cards
- Smooth animations throughout
- Confetti celebration on successful lock-in
- Material Design 3 components
- Intuitive tab navigation

## Architecture

### Firebase Structure

#### Users Collection (Firestore)
```
users/
  {userId}/
    food_choices/
      {foodChoiceId}/
        - name: string
        - locationId: string
        - locationName: string (denormalized)
        - budget: string ("High" | "Low")
        - freq: number (frequency counter)
    
    locations/
      {locationId}/
        - name: string
```

**Note**: Each food-location combination is stored as a separate document. If a food belongs to multiple locations, multiple documents are created.

### Project Structure
```
lib/
├── main.dart                          # App entry point with Firebase init
├── models/
│   ├── food_choice.dart              # FoodChoice data model
│   └── location.dart                 # Location data model
├── services/
│   ├── auth_service.dart             # Firebase Authentication service
│   └── firestore_service.dart        # Firestore CRUD operations
├── providers/
│   └── food_chooser_provider.dart    # State management with Provider
├── utils/
│   └── random_selector.dart          # Weighted random selection logic
├── screens/
│   ├── login_screen.dart             # Google Sign-In screen
│   ├── home_screen.dart              # Main screen with tabs
│   ├── food_chooser_tab.dart         # Food selection tab
│   ├── add_food_tab.dart             # Add new food choices
│   └── settings_tab.dart             # Manage locations and foods
└── widgets/
    ├── location_selector.dart        # Location multi-select widget
    ├── food_result_card.dart         # Animated result display
    └── toggle_chip.dart              # Toggle chips for Rich/New
```

## Setup Instructions

### Prerequisites
- Flutter SDK (3.0.0 or higher)
- Firebase project
- Google Cloud project (for Google Sign-In)

### 1. Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project" and follow the setup wizard
3. Enable Google Analytics (optional)

### 2. Enable Firebase Authentication

1. In Firebase Console, go to **Authentication** > **Sign-in method**
2. Enable **Google** provider
3. Add your authorized domains (for web: localhost, your-domain.com)

### 3. Create Firestore Database

1. In Firebase Console, go to **Firestore Database**
2. Click "Create database"
3. Start in **production mode** (we'll set up rules next)
4. Choose a location close to your users

### 4. Set Up Firestore Security Rules

In Firebase Console > Firestore Database > Rules, paste:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Helper function to check if user is authenticated
    function isAuthenticated() {
      return request.auth != null;
    }
    
    // Helper function to check if user owns the document
    function isOwner(userId) {
      return isAuthenticated() && request.auth.uid == userId;
    }
    
    // Users collection - users can only access their own data
    match /users/{userId} {
      allow read, write: if isOwner(userId);
      
      // Food choices subcollection
      match /food_choices/{foodChoiceId} {
        allow read, write: if isOwner(userId);
      }
      
      // Locations subcollection
      match /locations/{locationId} {
        allow read, write: if isOwner(userId);
      }
    }
  }
}
```

### 5. Configure Firebase for Web

1. In Firebase Console, go to **Project Settings** (gear icon)
2. Scroll to "Your apps" section
3. Click the web icon (`</>`) to add a web app
4. Register your app with a nickname
5. Copy the Firebase configuration object

### 6. Update `main.dart` with Firebase Config

Replace the placeholder values in `lib/main.dart`:

```dart
await Firebase.initializeApp(
  options: const FirebaseOptions(
    apiKey: "YOUR_API_KEY",
    authDomain: "YOUR_AUTH_DOMAIN",
    projectId: "YOUR_PROJECT_ID",
    storageBucket: "YOUR_STORAGE_BUCKET",
    messagingSenderId: "YOUR_MESSAGING_SENDER_ID",
    appId: "YOUR_APP_ID",
  ),
);
```

### 7. Configure Google Sign-In

#### For Web:
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Select your Firebase project
3. Go to **APIs & Services** > **Credentials**
4. Configure OAuth consent screen
5. Create OAuth 2.0 Client ID for Web application
6. Add authorized JavaScript origins (e.g., `http://localhost:5000`)
7. Add authorized redirect URIs (e.g., `http://localhost:5000/__/auth/handler`)

#### For Android:
1. Add SHA-1 fingerprint to Firebase project settings
2. Download `google-services.json` and place in `android/app/`

#### For iOS:
1. Download `GoogleService-Info.plist` and place in `ios/Runner/`
2. Add URL schemes to `ios/Runner/Info.plist`

### 8. Install Dependencies

```bash
cd food_chooser
flutter pub get
```

### 9. Run the App

#### For Web:
```bash
flutter run -d chrome
```

#### For Mobile (with device/emulator connected):
```bash
flutter run
```

## How the Weighted Random Selection Works

### Base Frequency Weighting
- Each food choice has a `freq` counter (starts at 1)
- Higher frequency = higher probability of being selected
- When a choice is "locked in", its frequency increments

### Modifiers

#### "I'm feeling Rich" 💰
- Multiplies weight of High-budget items by 3x
- Low-budget items keep their original weight
- Example: High-budget item with freq=5 becomes weight=15

#### "I'm feeling New" ✨
- Inverses the frequency weights
- Lower frequency = higher probability
- Formula: `weight = maxFreq - currentFreq + 1`
- Example: If max freq is 10, item with freq=2 gets weight=9

### Combined Modifiers
Both modifiers can be active simultaneously:
1. First apply "Feeling New" inversion
2. Then apply "Feeling Rich" multiplier to High-budget items

### Selection Algorithm
```
1. Calculate weight for each food choice
2. Sum all weights (totalWeight)
3. Generate random number: 0 to totalWeight
4. Iterate through choices, accumulating weights
5. Select the choice where random number falls within its weight range
```

## Usage Tips

1. **First Time Setup**:
   - Add locations in the "Add Food" or "Settings" tab
   - Add food choices for each location
   - Start spinning!

2. **Location Strategy**:
   - Use locations like "Campus", "Downtown", "Home", "Work"
   - Or use them for meal types: "Breakfast", "Lunch", "Dinner"

3. **Budget System**:
   - Use "Low" for everyday affordable options
   - Use "High" for special treats or splurges
   - Toggle "Feeling Rich" when you want to treat yourself

4. **Building Variety**:
   - Use "Feeling New" to explore less-frequented choices
   - The algorithm naturally adapts to your preferences over time

5. **Managing Choices**:
   - Edit budgets if your financial situation changes
   - Delete old favorites you no longer enjoy
   - Delete locations you no longer visit

## Troubleshooting

### Firebase Errors
- **"No Firebase App"**: Make sure Firebase.initializeApp() completes before app starts
- **"Permission Denied"**: Check Firestore security rules
- **"Invalid API Key"**: Verify Firebase configuration in main.dart

### Google Sign-In Issues
- **Web**: Ensure authorized domains are configured in Firebase Console
- **Android**: Add SHA-1 fingerprint to Firebase project
- **iOS**: Check URL schemes in Info.plist

### Build Errors
- Run `flutter clean` and `flutter pub get`
- Check Flutter SDK version: `flutter doctor`
- Ensure all dependencies are compatible

## Dependencies

- `firebase_core: ^2.24.2` - Firebase initialization
- `firebase_auth: ^4.16.0` - Authentication
- `cloud_firestore: ^4.14.0` - Database
- `google_sign_in: ^6.2.1` - Google authentication
- `provider: ^6.1.1` - State management
- `confetti: ^0.7.0` - Celebration animations

## Future Enhancements

- [ ] Add food categories/tags
- [ ] Import/export food lists
- [ ] Share lists with friends
- [ ] Custom frequency adjustment
- [ ] Statistics and insights
- [ ] Dark mode support
- [ ] Multi-language support

## License

MIT License - Feel free to use and modify for your needs!

## Support

For issues or questions:
1. Check Firebase Console for errors
2. Review Firestore security rules
3. Verify all configuration steps
4. Check Flutter console for detailed error messages
