import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        AppLocalizations(const Locale('am'));
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('am'),
  ];

  bool get isAmharic => locale.languageCode == 'am';

  // ---------------------------------------------------------------------------
  // Translation Dictionaries
  // ---------------------------------------------------------------------------
  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      // App General
      'appName': "Afro Mens Beauty Salon",
      'appTagline': 'Style starts here.',
      'currency': 'ETB',
      'minutesShort': 'min',
      'loading': 'Loading...',
      'save': 'Save',
      'cancel': 'Cancel',
      'delete': 'Delete',
      'edit': 'Edit',
      'add': 'Add',
      'confirm': 'Confirm',
      'close': 'Close',
      'back': 'Back',
      'retry': 'Retry',
      'skip': 'Skip',
      'getStarted': 'GET STARTED',
      'continueBtn': 'CONTINUE',

      // Portals & Auth
      'portalSelectionTitle': 'Select Your Portal',
      'portalSelectionSubtitle': "Choose how you want to experience Afro Men's Beauty Salon today.",
      'customerPortal': 'Customer Portal',
      'customerPortalDesc': 'Book haircuts, customize styles, and view history.',
      'staffPortal': 'Staff Portal',
      'staffPortalDesc': 'Master Barbers and Shop Administrator access.',
      'welcomeBack': 'Welcome Back',
      'customerLoginSubtitle': 'Sign in to book haircuts, customize styles, and view appointment history.',
      'staffLoginSubtitle': "Authorized login for Afro Men's Beauty Salon Master Barbers and Shop Administrators.",
      'secureStaffAccess': 'SECURE STAFF ACCESS',
      'customerLogin': 'Customer Login',
      'staffLogin': 'Staff Portal Login',
      'emailOrPhone': 'Email or Phone Number',
      'emailOrPhoneHint': 'e.g. customer@afrobarber.com or +251911...',
      'staffEmail': 'Staff Email Address',
      'staffEmailHint': 'e.g. admin@afrobarber.com or mike@afrobarber.com',
      'password': 'Password',
      'passwordHint': 'Enter your password',
      'staffPasswordHint': 'Enter your staff password',
      'loginBtn': 'LOGIN',
      'staffLoginBtn': 'STAFF LOGIN',
      'createAccount': 'CREATE ACCOUNT',
      'dontHaveAccount': "Don't have an account? ",
      'alreadyHaveAccount': 'Already have an account? ',
      'signIn': 'Sign In',
      'registerTitle': 'Create Account',
      'registerSubtitle': "Join Afro Men's Beauty Salon to book appointments with Addis Ababa’s premier barbers.",
      'fullName': 'Full Name',
      'fullNameHint': 'e.g. Kidus Alemu',
      'emailAddress': 'Email Address',
      'emailAddressHint': 'e.g. kidus@example.com',
      'phoneNumber': 'Phone Number',
      'phoneNumberHint': '+251 91 123 4567',
      'createPasswordHint': 'At least 6 characters',
      'agreeTerms': "By signing up, you agree to Afro Men's Beauty Salon Terms & Privacy Policy.",
      'registerBtn': 'CREATE ACCOUNT',
      'quickFill': 'Fill',

      // Navigation
      'navHome': 'Home',
      'navStyles': 'Styles',
      'navBooking': 'Book',
      'navAppointments': 'Cuts',
      'navProfile': 'Profile',

      // Customer Home & Discovery
      'homeGreeting': 'Welcome back,',
      'homeTagline': 'Discover luxury haircuts & grooming in Ayat 49 Condominium, Addis Ababa.',
      'featuredStyles': 'Featured Styles',
      'ourServices': 'Our Services',
      'masterBarbers': 'Master Barbers',
      'viewAll': 'View All',
      'bookNow': 'Book Now',
      'experience': 'Experience',
      'rating': 'Rating',
      'specialties': 'Specialties',

      // Services & Hairstyles
      'servicesTitle': 'Services Menu',
      'stylesTitle': 'Hairstyle Gallery',
      'filterAll': 'All',
      'duration': 'Duration',
      'price': 'Price',
      'priceOnConsultation': 'Price on consultation',
      'styleDetails': 'Style Details',
      'barberDetails': 'Barber Profile',
      'gallery': 'Gallery',
      'reviews': 'Reviews',
      'leaveReview': 'Leave a Review',
      'writeReviewHint': 'Share your grooming experience...',
      'submitReview': 'Submit Review',
      'bookThisStyle': 'BOOK THIS STYLE',
      'styleOverview': 'Style Overview',
      'recommendedService': 'Recommended Service',
      'yearsExperience': 'Years Experience',
      'recentPortfolio': 'Recent Cuts & Portfolio',
      'customerReviews': 'Customer Reviews',
      'bookWith': 'BOOK WITH',
      'myFavorites': 'My Favorites',
      'savedStylesTab': 'SAVED STYLES',
      'favoriteBarbersTab': 'FAVORITE BARBERS',
      'noSavedStyles': 'No Saved Styles Yet',
      'notifications': 'Notifications',
      'markAllAsRead': 'Mark all as read',
      'noNotifications': 'No Notifications',
      'barbershopLocation': 'Barbershop Location',
      'operatingHours': 'Operating Hours',
      'directContact': 'Direct Contact',
      'getDirections': 'GET DIRECTIONS (MAP)',
      'howWasExperience': 'How was your experience?',
      'rateAppointmentWith': 'Rate your appointment with',
      'feedbackOptional': 'Feedback (Optional)',
      'allAppointments': 'All Appointments',
      'saveOperatingHours': 'SAVE OPERATING HOURS',
      'addMasterBarber': 'Add Master Barber',
      'editBarber': 'Edit Barber',
      'addNewService': 'Add New Service',
      'editService': 'Edit Service',
      'addHairstyle': 'Add Hairstyle',
      'editHairstyle': 'Edit Hairstyle',

      // Booking Flow
      'bookingWizardTitle': 'Book an Appointment',
      'stepService': 'Service',
      'stepBarber': 'Barber',
      'stepDateTime': 'Date & Time',
      'stepConfirm': 'Confirm',
      'selectServiceTitle': 'Select Grooming Service',
      'selectBarberTitle': 'Select Master Barber',
      'anyBarber': 'Any Available Barber',
      'selectDateTimeTitle': 'Select Appointment Time',
      'noSlotsAvailable': 'No slots available for this day. Please select another date.',
      'reviewBookingTitle': 'Review Your Booking',
      'appointmentSummary': 'Appointment Summary',
      'selectedService': 'Service',
      'selectedBarber': 'Barber',
      'appointmentDate': 'Date',
      'appointmentTime': 'Time',
      'location': 'Location',
      'shopAddress': 'Ayat 49 Condominium, Addis Ababa',
      'confirmAndBookBtn': 'CONFIRM BOOKING',
      'bookingSuccessTitle': 'Appointment Confirmed!',
      'bookingSuccessMsg': 'Your appointment has been reserved. Please arrive 10 minutes early.',
      'appointmentRef': 'Appointment Reference',
      'viewAppointmentsBtn': 'VIEW MY APPOINTMENTS',

      // Appointments Screen
      'myAppointmentsTitle': 'My Appointments',
      'tabUpcoming': 'Upcoming',
      'tabPast': 'Past History',
      'tabCancelled': 'Cancelled',
      'noUpcomingAppts': 'No upcoming appointments.',
      'noPastAppts': 'No past appointment history.',
      'noCancelledAppts': 'No cancelled appointments.',
      'cancelAppointment': 'Cancel Appointment',
      'cancelConfirmMsg': 'Are you sure you want to cancel this appointment?',
      'yesCancel': 'Yes, Cancel',
      'keepAppointment': 'Keep Appointment',
      'bookAgain': 'Book Again',
      'cancelledBadge': 'CANCELLED',

      // Status Badges
      'statusConfirmed': 'Confirmed',
      'statusCheckedIn': 'Checked In',
      'statusInProgress': 'In Progress',
      'statusCompleted': 'Completed',
      'statusCancelled': 'Cancelled',
      'statusNoShow': 'No Show',

      // Barber Portal
      'barberPortalTitle': 'Barber Work Dashboard',
      'todayQueue': "Today's Appointment Queue",
      'noAppointmentsToday': 'No appointments scheduled for today.',
      'client': 'Client',
      'contact': 'Contact',
      'actionCheckIn': 'Check In',
      'actionStart': 'Start Service',
      'actionComplete': 'Complete Cut',
      'actionNoShow': 'Mark No-Show',
      'actionCancel': 'Cancel',

      // Admin Portal
      'adminDashboardTitle': 'Admin Management Dashboard',
      'totalAppointments': 'Total Appointments',
      'activeBarbers': 'Active Barbers',
      'totalServices': 'Services',
      'totalStyles': 'Styles',
      'manageAppointments': 'Manage Appointments',
      'manageBarbers': 'Manage Barbers',
      'manageServices': 'Manage Services',
      'manageStyles': 'Manage Styles',
      'businessHours': 'Business Hours',
      'adminSettings': 'Shop Settings',
      'openTime': 'Open Time',
      'closeTime': 'Close Time',
      'isOpen': 'Open',
      'isClosed': 'Closed',
      'addNew': 'Add New',

      // Profile & Settings
      'profileAndSettings': 'Profile & Settings',
      'managementTools': 'Management Tools',
      'barberWorkTools': 'Barber Portal',
      'accountAndShop': 'Account & Shop',
      'preferencesSection': 'Preferences',
      'languageSetting': 'Language',
      'languageSubtitle': 'Choose English or Amharic (አማርኛ)',
      'appearanceSetting': 'Appearance & Theme',
      'appearanceSubtitle': 'Choose your preferred visual theme',
      'selectTheme': 'Select Theme',
      'shopLocationTitle': 'Shop Location & Hours',
      'shopLocationSubtitle': 'Ayat 49 Condominium, Addis Ababa',
      'savedFavoritesTitle': 'Saved Favorites',
      'savedFavoritesSubtitle': 'Your favorite styles & barbers',
      'notificationsTitle': 'Notifications Center',
      'notificationsSubtitle': 'Alerts, confirmations & reminders',
      'aboutSection': 'About',
      'appVersion': "Afro Mens Beauty Salon v1.0.0 (Luxury Edition)",
      'aboutText': 'Addis Ababa’s premier grooming destination.',
      'logOut': 'LOG OUT',
      'logOutConfirm': 'Are you sure you want to log out?',

      // Themes
      'themeLuxuryGold': 'Luxury Gold',
      'themeLuxuryGoldDesc': 'Signature obsidian black with rich gold accents.',
      'themeEthiopianHeritage': 'Ethiopian Heritage',
      'themeEthiopianHeritageDesc': 'Warm espresso base with Ethiopian emerald & gold accents.',
      'themeModernDark': 'Modern Dark',
      'themeModernDarkDesc': 'Minimal deep obsidian with crisp platinum silver.',
      'themeLightPremium': 'Light Premium',
      'themeLightPremiumDesc': 'Crisp pearl canvas with dark typography & bronze gold.',

      // Errors & Validation
      'errRequiredFields': 'Please fill all required fields.',
      'errInvalidEmail': 'Please enter a valid email address.',
      'errShortPassword': 'Password must be at least 6 characters.',
      'errInvalidCredentials': 'Invalid email or password.',
      'errStaffOnly': 'This account belongs to the staff portal. Please use Staff Login.',
      'errCustomerOnly': 'This account is registered as a customer.',
      'errNetwork': "Unable to connect to Afro Men's Beauty Salon server. Please check your connection.",
      'errSlotUnavailable': 'This time slot is no longer available. Please choose another time.',

      // Onboarding
      'onboardingTag1': 'DISCOVER',
      'onboardingTitle1': 'Find Your Style',
      'onboardingSubtitle1': "Discover Afro Men's Beauty Salon's haircut gallery with high-definition photos and style videos.",
      'onboardingTag2': 'EXPERTISE',
      'onboardingTitle2': 'Choose Your Barber',
      'onboardingSubtitle2': 'Explore master barber profiles, view real customer reviews, and check real-time availability.',
      'onboardingTag3': 'SEAMLESS',
      'onboardingTitle3': 'Book in Seconds',
      'onboardingSubtitle3': 'Select your service, choose your date and guaranteed available time slot, and get instant reminders.',

      // Home Banner & Extra
      'premierGrooming': 'PREMIER GROOMING',
      'lookGoodFeelGood': 'LOOK GOOD.\nFEEL GOOD.',
      'distinguishedGuest': 'Distinguished Guest',
      'newService': 'NEW SERVICE',
      'homeToHome': 'Home to Home',
      'homeToHomeDesc': 'Premium grooming — we come to you',
      'bookNowCta': 'BOOK NOW →',
      'couldNotLoadStyles': 'Could not load featured styles',
      'couldNotLoadServices': 'Could not load services',
      'couldNotLoadBarbers': 'Could not load barbers',

      // Styles & Extra
      'noStylesFound': 'No Styles Found',
      'noStylesFoundDesc': 'No hairstyles match the selected category right now.',
      'noReviewsYet': 'No customer reviews yet',
      'thankYouRating': 'Thank you for rating your experience! 💈',
      'yrsExpSuffix': 'yrs exp',
      'bookServiceAction': 'BOOK',
      'styleLabel': 'Style',

      // Booking
      'totalPrice': 'Total Price',
      'prePaymentNow': 'Pre-Payment (Now)',
      'balanceAfterService': 'Balance (After Service)',
      'prePaymentNotice1': 'Please transfer ',
      'prePaymentNotice2': ' as a pre-payment via Telebirr or CBE, then attach a screenshot of your payment receipt below. The remaining ',
      'prePaymentNotice3': ' is due after the service is completed.',
      'telebirrCbeRef': 'Telebirr / CBE Reference (1,000 ETB pre-payment) *',
      'telebirrHint': 'e.g. 7N34XQ...',
      'uploadPaymentScreenshot': 'Upload Payment Screenshot *',
      'uploadPaymentScreenshotSubtitle': 'Tap to attach Telebirr or CBE payment confirmation screenshot',
      'screenshotUploaded': 'Receipt screenshot attached',
      'changeScreenshot': 'Change',
      'screenshotRequired': 'Please upload your payment screenshot to confirm Home Service.',
      'optionalTxRef': 'Transaction Reference (Optional)',
      'optionalTxRefHint': 'e.g. 7N34XQ...',
      'specialNotes': 'Special Notes (Optional)',
      'specialNotesHint': 'e.g. Sharp razor line, natural taper',
      'txRefRequired': 'Payment screenshot is required for Home Service.',

      // Appointments
      'noUpcomingDesc': 'You have no appointments scheduled. Explore styles and book your session in seconds!',
      'noPastDesc': 'Your completed and past haircut appointments will appear here.',

      // Shop Info
      'monFriHours': 'Monday – Friday',
      'saturdayHours': 'Saturday',
      'sundayHours': 'Sunday',
      'tapToOpenMaps': 'Tap to open in Google Maps',
      'couldNotOpenMaps': 'Could not open Maps. Please try again.',
      'shopCityCountry': 'Addis Ababa, Ethiopia',
      'serverSetting': 'Server Connection',
      'serverSettingSubtitle': 'Configure API Base URL & IP',
      'serverSaved': 'Server URL saved',

      // Roles & Status
      'roleCustomer': 'Customer',
      'roleBarber': 'Master Barber',
      'roleAdmin': 'Administrator',
      'statusPending': 'Pending',

      // Hygiene Notice
      'hygieneNoticeTitle': '⚠️ Hygiene & Safety Notice',
      'hygieneNoticeBody': 'The clippers and machines we use for both children and adults are sterilized, and clipper guards and combs are washed right in front of you, so you have complete peace of mind!',
    },
    'am': {
      // App General
      'appName': 'አፍሮ የወንዶች ውበት ሳሎን',
      'appTagline': 'የውበትና የስታይል መነሻ።',
      'currency': 'ብር',
      'minutesShort': 'ደቂቃ',
      'loading': 'በመጫን ላይ...',
      'save': 'አስቀምጥ',
      'cancel': 'ይቅር',
      'delete': 'ሰርዝ',
      'edit': 'አስተካክል',
      'add': 'አዲስ ጨምር',
      'confirm': 'አረጋግጥ',
      'close': 'ዝጋ',
      'back': 'ተመለስ',
      'retry': 'እንደገና ሞክር',
      'skip': 'እለፍ',
      'getStarted': 'ጀምር',
      'continueBtn': 'ቀጥል',

      // Portals & Auth
      'portalSelectionTitle': 'የመግቢያ በር ይምረጡ',
      'portalSelectionSubtitle': 'የአፍሮ የወንዶች ውበት ሳሎንን አገልግሎት እንዴት ማግኘት እንደሚፈልጉ ይምረጡ።',
      'customerPortal': 'የደንበኞች መግቢያ',
      'customerPortalDesc': 'ቀጠሮ ይያዙ፣ የፀጉር ስታይሎችን ይመልከቱ፣ ታሪክዎን ይከታተሉ።',
      'staffPortal': 'የሰራተኞች መግቢያ',
      'staffPortalDesc': 'የባለሙያ ፀጉር ቆራጮች እና የአስተዳዳሪዎች መግቢያ።',
      'welcomeBack': 'እንኳን ደህና መጡ',
      'customerLoginSubtitle': 'ቀጠሮ ለመያዝ፣ ስታይሎችን ለመምረጥ እና የቀጠሮ ታሪክዎን ለማየት ይግቡ።',
      'staffLoginSubtitle': 'ለአፍሮ የወንዶች ውበት ሳሎን ባለሙያ ፀጉር ቆራጮች እና አስተዳዳሪዎች የተፈቀደ መግቢያ።',
      'secureStaffAccess': 'ደህንነቱ የተጠበቀ የሰራተኞች መግቢያ',
      'customerLogin': 'የደንበኛ መግቢያ',
      'staffLogin': 'የሰራተኞች መግቢያ',
      'emailOrPhone': 'ኢሜይል ወይም ስልክ ቁጥር',
      'emailOrPhoneHint': 'ለምሳሌ፡ customer@afrobarber.com ወይም +251911...',
      'staffEmail': 'የሰራተኛ ኢሜይል አድራሻ',
      'staffEmailHint': 'ለምሳሌ፡ admin@afrobarber.com ወይም mike@afrobarber.com',
      'password': 'የይለፍ ቃል',
      'passwordHint': 'የይለፍ ቃልዎን ያስገቡ',
      'staffPasswordHint': 'የሰራተኛ የይለፍ ቃልዎን ያስገቡ',
      'loginBtn': 'ግባ',
      'staffLoginBtn': 'እንደ ሰራተኛ ግባ',
      'createAccount': 'አዲስ አካውንት ክፈት',
      'dontHaveAccount': 'አካውንት የለዎትም? ',
      'alreadyHaveAccount': 'አካውንት አለዎት? ',
      'signIn': 'ይግቡ',
      'registerTitle': 'አካውንት ይፍጠሩ',
      'registerSubtitle': 'ከአዲስ አበባ ምርጥ ፀጉር ቆራጮች ጋር ቀጠሮ ለመያዝ አፍሮ የወንዶች ውበት ሳሎንን ይቀላቀሉ።',
      'fullName': 'ሙሉ ስም',
      'fullNameHint': 'ለምሳሌ፡ ኪዱስ አለሙ',
      'emailAddress': 'ኢሜይል አድራሻ',
      'emailAddressHint': 'ለምሳሌ፡ kidus@example.com',
      'phoneNumber': 'ስልክ ቁጥር',
      'phoneNumberHint': '+251 91 123 4567',
      'createPasswordHint': 'ቢያንስ 6 ቁምፊዎች',
      'agreeTerms': 'በመመዝገብዎ፣ በአፍሮ የወንዶች ውበት ሳሎን የአገልግሎት ደንቦች እና ፖሊሲዎች ተስማምተዋል።',
      'registerBtn': 'አካውንት ክፈት',
      'quickFill': 'ሙላ',

      // Navigation
      'navHome': 'ዋና ገጽ',
      'navStyles': 'ስታይሎች',
      'navBooking': 'ቀጠሮ',
      'navAppointments': 'ቀጠሮዎቼ',
      'navProfile': 'መገለጫ',

      // Customer Home & Discovery
      'homeGreeting': 'እንኳን ደህና መጡ፣',
      'homeTagline': 'አያት 49፣ አዲስ አበባ ዘመናዊና ምቹ የፀጉር አቆራረጥ አገልግሎት ያግኙ።',
      'featuredStyles': 'ተወዳጅ ስታይሎች',
      'ourServices': 'አገልግሎቶቻችን',
      'masterBarbers': 'ባለሙያ ቆራጮች',
      'viewAll': 'ሁሉንም እይ',
      'bookNow': 'ቀጠሮ ይያዙ',
      'experience': 'የስራ ልምድ',
      'rating': 'ደረጃ',
      'specialties': 'ልዩ ሙያዎች',

      // Services & Hairstyles
      'servicesTitle': 'የአገልግሎቶች ዝርዝር',
      'stylesTitle': 'የስታይሎች ማዕከል',
      'filterAll': 'ሁሉም',
      'duration': 'የሚፈጀው ጊዜ',
      'price': 'ዋጋ',
      'priceOnConsultation': 'በውይይት የሚወሰን',
      'styleDetails': 'የስታይል ዝርዝር',
      'barberDetails': 'የቆራጩ መገለጫ',
      'gallery': 'ፎቶዎች',
      'reviews': 'አስተያየቶች',
      'leaveReview': 'አስተያየት ይስጡ',
      'writeReviewHint': 'ስለተሰጠዎት አገልግሎት አስተያየትዎን ያጋሩ...',
      'submitReview': 'አስተያየት ላክ',
      'bookThisStyle': 'ይህን ስታይል ይያዙ',
      'styleOverview': 'የስታይሎች ዝርዝር መግለጫ',
      'recommendedService': 'የሚመከር አገልግሎት',
      'yearsExperience': 'ዓመታት የስራ ልምድ',
      'recentPortfolio': 'የቅርብ ጊዜ ስራዎች',
      'customerReviews': 'የደንበኞች አስተያየቶች',
      'bookWith': 'ቀጠሮ ይያዙ ከ',
      'myFavorites': 'የተወደዱ',
      'savedStylesTab': 'የተቀመጡ ስታይሎች',
      'favoriteBarbersTab': 'ተወዳጅ ቆራጮች',
      'noSavedStyles': 'ምንም የተቀመጠ ስታይል የለም',
      'notifications': 'ማሳወቂያዎች',
      'markAllAsRead': 'ሁሉንም የተነበቡ አድርግ',
      'noNotifications': 'ምንም ማሳወቂያ የለም',
      'barbershopLocation': 'የሱቅ አድራሻ',
      'operatingHours': 'የስራ ሰዓታት',
      'directContact': 'የቀጥታ አድራሻ',
      'getDirections': 'አቅጣጫ አሳይ (ካርታ)',
      'howWasExperience': 'አገልግሎቱ እንዴት ነበር?',
      'rateAppointmentWith': 'የቀጠሮዎን ደረጃ ይስጡ ለ',
      'feedbackOptional': 'አስተያየት (አስገዳጅ ያልሆነ)',
      'allAppointments': 'ሁሉም ቀጠሮዎች',
      'saveOperatingHours': 'የስራ ሰዓታትን አስቀምጥ',
      'addMasterBarber': 'አዲስ ቆራጭ ጨምር',
      'editBarber': 'ቆራጩን አስተካክል',
      'addNewService': 'አዲስ አገልግሎት ጨምር',
      'editService': 'አገልግሎቱን አስተካክል',
      'addHairstyle': 'አዲስ ስታይል ጨምር',
      'editHairstyle': 'ስታይሉን አስተካክል',

      // Booking Flow
      'bookingWizardTitle': 'ቀጠሮ መያዣ',
      'stepService': 'አገልግሎት',
      'stepBarber': 'ቆራጭ',
      'stepDateTime': 'ቀን እና ሰዓት',
      'stepConfirm': 'ማረጋገጫ',
      'selectServiceTitle': 'የሚፈልጉትን አገልግሎት ይምረጡ',
      'selectBarberTitle': 'የፀጉር ቆራጭዎን ይምረጡ',
      'anyBarber': 'ማንኛውም ክፍት ቆራጭ',
      'selectDateTimeTitle': 'የቀጠሮ ቀን እና ሰዓት ይምረጡ',
      'noSlotsAvailable': 'በዚህ ቀን ክፍት ሰዓት የለም። እባክዎ ሌላ ቀን ይምረጡ።',
      'reviewBookingTitle': 'የቀጠሮዎን ዝርዝር ያረጋግጡ',
      'appointmentSummary': 'የቀጠሮ ማጠቃለያ',
      'selectedService': 'አገልግሎት',
      'selectedBarber': 'ቆራጭ',
      'appointmentDate': 'ቀን',
      'appointmentTime': 'ሰዓት',
      'location': 'አድራሻ',
      'shopAddress': 'አያት 49፣ አዲስ አበባ',
      'confirmAndBookBtn': 'ቀጠሮውን አረጋግጥ',
      'bookingSuccessTitle': 'ቀጠሮዎ ተረጋግጧል!',
      'bookingSuccessMsg': 'ቀጠሮዎ በተሳካ ሁኔታ ተመዝግቧል። እባክዎ 10 ደቂቃ ቀድመው ይገኙ።',
      'appointmentRef': 'የቀጠሮ መለያ ቁጥር',
      'viewAppointmentsBtn': 'ቀጠሮዎቼን እይ',

      // Appointments Screen
      'myAppointmentsTitle': 'የእኔ ቀጠሮዎች',
      'tabUpcoming': 'የሚመጡ',
      'tabPast': 'ያለፉ ቀጠሮዎች',
      'tabCancelled': 'የተሰረዙ',
      'noUpcomingAppts': 'የሚመጣ ቀጠሮ የለዎትም።',
      'noPastAppts': 'ምንም ያለፈ የቀጠሮ ታሪክ የለም።',
      'noCancelledAppts': 'ምንም የተሰረዘ ቀጠሮ የለም።',
      'cancelAppointment': 'ቀጠሮውን ሰርዝ',
      'cancelConfirmMsg': 'ይህን ቀጠሮ መሰረዝ እንደሚፈልጉ እርግጠኛ ነዎት?',
      'yesCancel': 'አዎ፣ ሰርዝ',
      'keepAppointment': 'ቀጠሮው ይቆይ',
      'bookAgain': 'እንደገና ይያዙ',
      'cancelledBadge': 'ተሰርዟል',

      // Status Badges
      'statusConfirmed': 'ተረጋግጧል',
      'statusCheckedIn': 'ደርሰዋል',
      'statusInProgress': 'በሂደት ላይ',
      'statusCompleted': 'ተጠናቋል',
      'statusCancelled': 'ተሰርዟል',
      'statusNoShow': 'አልመጡም',

      // Barber Portal
      'barberPortalTitle': 'የቆራጭ የስራ ዳሽቦርድ',
      'todayQueue': 'የዛሬ የቀጠሮ ተራ',
      'noAppointmentsToday': 'ለዛሬ የተያዘ ቀጠሮ የለም።',
      'client': 'ደንበኛ',
      'contact': 'ስልክ',
      'actionCheckIn': 'መድረሳቸውን መዝግብ',
      'actionStart': 'ስራ ጀምር',
      'actionComplete': 'አጠናቅ',
      'actionNoShow': 'አልመጡም በል',
      'actionCancel': 'ሰርዝ',

      // Admin Portal
      'adminDashboardTitle': 'የአስተዳዳሪ ዳሽቦርድ',
      'totalAppointments': 'ጠቅላላ ቀጠሮዎች',
      'activeBarbers': 'ቆራጮች',
      'totalServices': 'አገልግሎቶች',
      'totalStyles': 'ቅጦች',
      'manageAppointments': 'ቀጠሮዎችን አስተዳድር',
      'manageBarbers': 'ቆራጮችን አስተዳድር',
      'manageServices': 'አገልግሎቶችን አስተዳድር',
      'manageStyles': 'ቅጦችን አስተዳድር',
      'businessHours': 'የስራ ሰዓታት',
      'adminSettings': 'የሱቅ ቅንብሮች',
      'openTime': 'መክፈቻ ሰዓት',
      'closeTime': 'መዝጊያ ሰዓት',
      'isOpen': 'ክፍት',
      'isClosed': 'ዝግ',
      'addNew': 'አዲስ ጨምር',

      // Profile & Settings
      'profileAndSettings': 'መገለጫ እና ቅንብሮች',
      'managementTools': 'የአስተዳዳሪ መሳሪያዎች',
      'barberWorkTools': 'የቆራጭ ፖርታል',
      'accountAndShop': 'አካውንት እና ሱቅ',
      'preferencesSection': 'ምርጫዎች',
      'languageSetting': 'ቋንቋ (Language)',
      'languageSubtitle': 'English ወይም አማርኛ ይምረጡ',
      'appearanceSetting': 'ገጽታ እና ቴም (Theme)',
      'appearanceSubtitle': 'የመተግበሪያውን የቀለም ገጽታ ይምረጡ',
      'selectTheme': 'ቴም ይምረጡ',
      'shopLocationTitle': 'የሱቅ አድራሻ እና ሰዓታት',
      'shopLocationSubtitle': 'የአያት 49  ዋና ቅርንጫፍ መረጃ',
      'savedFavoritesTitle': 'የተወደዱ ስታይሎች',
      'savedFavoritesSubtitle': 'ያስቀመጧቸው ስታይሎች እና ቆራጮች',
      'notificationsTitle': 'የማሳወቂያ ማዕከል',
      'notificationsSubtitle': 'ማሳሰቢያዎች፣ ማረጋገጫዎች እና መረጃዎች',
      'aboutSection': 'ስለ መተግበሪያው',
      'appVersion': 'አፍሮ የወንዶች ውበት ሳሎን v1.0.0 (ልዩ እትም)',
      'aboutText': 'በአዲስ አበባ ምርጥ የውበት እና የፀጉር አቆራረጥ ማዕከል።',
      'logOut': 'ውጣ',
      'logOutConfirm': 'ከመተግበሪያው መውጣት ይፈልጋሉ?',

      // Themes
      'themeLuxuryGold': 'የወርቅ ቅንጦት (Luxury Gold)',
      'themeLuxuryGoldDesc': 'የጥቁር ከሰል ዳራ ከወርቃማ ንክኪዎች ጋር።',
      'themeEthiopianHeritage': 'የኢትዮጵያ ቅርስ (Ethiopian Heritage)',
      'themeEthiopianHeritageDesc': 'የቡናማ እስፕሬሶ ዳራ ከአረንጓዴ እና ወርቃማ ቀለማት ጋር።',
      'themeModernDark': 'ዘመናዊ ጥቁር (Modern Dark)',
      'themeModernDarkDesc': 'ቀለል ያለ ጥቁር ዳራ ከብርማ ፕላቲነም ንክኪ ጋር።',
      'themeLightPremium': 'ብርሃናማ ፕሪሚየም (Light Premium)',
      'themeLightPremiumDesc': 'ንጹህ የዕንቁ ነጭ ዳራ ከደማቅ ፅሁፍ እና ወርቃማ ንክኪ ጋር።',

      // Errors & Validation
      'errRequiredFields': 'እባክዎ ሁሉንም አስፈላጊ ክፍሎች ይሙሉ!',
      'errInvalidEmail': 'እባክዎ ትክክለኛ የኢሜይል አድራሻ ያስገቡ።',
      'errShortPassword': 'የይለፍ ቃል ቢያንስ 6 ቁምፊዎች መሆን አለበት።',
      'errInvalidCredentials': 'ኢሜይል ወይም የይለፍ ቃል ትክክል አይደለም።',
      'errStaffOnly': 'ይህ አካውንት የሰራተኞች መግቢያ ነው። እባክዎ በሰራተኞች መግቢያ ይግቡ።',
      'errCustomerOnly': 'ይህ አካውንት እንደ ደንበኛ የተመዘገበ ነው።',
      'errNetwork': 'ከአፍሮ የወንዶች ውበት ሳሎን ሰርቨር ጋር መገናኘት አልተቻለም። እባክዎ ኢንተርኔትዎን ያረጋግጡ።',
      'errSlotUnavailable': 'ይህ የጊዜ ክፍተት ከአሁን በኋላ ክፍት አይደለም። እባክዎ ሌላ ጊዜ ይምረጡ።',

      // Onboarding
      'onboardingTag1': 'ያግኙ',
      'onboardingTitle1': 'የእርስዎን ስታይል ይምረጡ',
      'onboardingSubtitle1': 'የአፍሮ የወንዶች ውበት ሳሎን የፀጉር አቆራረጥ ማዕከልን በከፍተኛ ጥራት ፎቶዎች እና ቪዲዮዎች ያስሱ።',
      'onboardingTag2': 'ሙያዊ ብቃት',
      'onboardingTitle2': 'የፀጉር ቆራጭዎን ይምረጡ',
      'onboardingSubtitle2': 'የባለሙያ ቆራጮች መገለጫዎችን ይመልከቱ፣ የደንበኞች አስተያየቶችን ያንብቡ እና ክፍት ሰዓቶችን ያረጋግጡ።',
      'onboardingTag3': 'ፈጣንና ምቹ',
      'onboardingTitle3': 'በሰከንዶች ውስጥ ቀጠሮ ይያዙ',
      'onboardingSubtitle3': 'አገልግሎትዎን ይምረጡ፣ የቀጠሮ ቀን እና ሰዓትዎን ወስነው ፈጣን ማረጋገጫ ያግኙ።',

      // Home Banner & Extra
      'premierGrooming': 'ምርጥ የውበት አገልግሎት',
      'lookGoodFeelGood': 'ይመርብዎት።\nይደሰቱ።',
      'distinguishedGuest': 'የተከበሩ እንግዳ',
      'newService': 'አዲስ አገልግሎት',
      'homeToHome': 'ቤት ለቤት',
      'homeToHomeDesc': 'ምርጥ የውበት አገልግሎት — እርስዎ ያሉበት ድረስ',
      'bookNowCta': 'አሁን ይያዙ →',
      'couldNotLoadStyles': 'ተወዳጅ ስታይሎችን መጫን አልተቻለም',
      'couldNotLoadServices': 'አገልግሎቶችን መጫን አልተቻለም',
      'couldNotLoadBarbers': 'ቆራጮችን መጫን አልተቻለም',

      // Styles & Extra
      'noStylesFound': 'ምንም ስታይሎች አልተገኙም',
      'noStylesFoundDesc': 'በተመረጠው ክፍል ውስጥ ምንም የፀጉር ስታይሎች አልተገኙም።',
      'noReviewsYet': 'እስካሁን ምንም የደንበኛ አስተያየት አልተሰጠም',
      'thankYouRating': 'ስለሰጡን አስተያየት እናመሰግናለን! 💈',
      'yrsExpSuffix': 'ዓመት ልምድ',
      'bookServiceAction': 'ቀጠሮ ያዝ',
      'styleLabel': 'ስታይል',

      // Booking
      'totalPrice': 'ጠቅላላ ዋጋ',
      'prePaymentNow': 'ቅድመ ክፍያ (አሁን)',
      'balanceAfterService': 'ቀሪ ሂሳብ (ከአገልግሎቱ በኋላ)',
      'prePaymentNotice1': 'እባክዎ ',
      'prePaymentNotice2': ' በቴሌብር ወይም በኢትዮጵያ ንግድ ባንክ (CBE) እንደ ቅድመ ክፍያ ያስተላልፉ እና የከፈሉበትን ስክሪንሾት ከታች ያያይዙ። ቀሪው ',
      'prePaymentNotice3': ' አገልግሎቱ ከተጠናቀቀ በኋላ የሚከፈል ይሆናል።',
      'telebirrCbeRef': 'የቴሌብር / ንግድ ባንክ ማጣቀሻ ቁጥር (የ1,000 ብር ቅድመ ክፍያ) *',
      'telebirrHint': 'ለምሳሌ፡ 7N34XQ...',
      'uploadPaymentScreenshot': 'የክፍያ ስክሪንሾት (Screenshot) ያያይዙ *',
      'uploadPaymentScreenshotSubtitle': 'የቴሌብር ወይም የንግድ ባንክ ክፍያ ማረጋገጫ ስክሪንሾት ይምረጡ',
      'screenshotUploaded': 'የክፍያ ስክሪንሾት ተያይዟል',
      'changeScreenshot': 'ቀይር',
      'screenshotRequired': 'እባክዎ ለቤት ለቤት አገልግሎት የከፈሉበትን ስክሪንሾት ያያይዙ።',
      'optionalTxRef': 'የማጣቀሻ ቁጥር (አማራጭ)',
      'optionalTxRefHint': 'ለምሳሌ፡ 7N34XQ...',
      'specialNotes': 'ልዩ ማስታወሻ (አስገዳጅ ያልሆነ)',
      'specialNotesHint': 'ለምሳሌ፡ የላጭ መስመር፣ ተፈጥሯዊ ቴፐር',
      'txRefRequired': 'ለቤት ለቤት አገልግሎት የክፍያ ስክሪንሾት ማያያዝ ግዴታ ነው።',

      // Appointments
      'noUpcomingDesc': 'ምንም የተያዘ ቀጠሮ የለዎትም። ስታይሎችን በመምረጥ በሰከንዶች ውስጥ ቀጠሮ ይያዙ!',
      'noPastDesc': 'ያጠናቀቋቸው እና ያለፉ የቀጠሮ ታሪኮች እዚህ ይታያሉ።',

      // Shop Info
      'monFriHours': 'ከሰኞ – አርብ',
      'saturdayHours': 'ቅዳሜ',
      'sundayHours': 'እሁድ',
      'tapToOpenMaps': 'በGoogle Maps ለመክፈት ይጫኑ',
      'couldNotOpenMaps': 'ካርታውን መክፈት አልተቻለም። እባክዎ እንደገና ይሞክሩ።',
      'shopCityCountry': 'አዲስ አበባ፣ ኢትዮጵያ',
      'serverSetting': 'የሰርቨር ግንኙነት',
      'serverSettingSubtitle': 'የኤፒአይ አድራሻ እና አይፒ ያዘጋጁ',
      'serverSaved': 'የሰርቨር አድራሻ ተቀምጧል',

      // Roles & Status
      'roleCustomer': 'ደንበኛ',
      'roleBarber': 'ዋና ፀጉር ቆራጭ',
      'roleAdmin': 'አስተዳዳሪ',
      'statusPending': 'በመጠባበቅ ላይ',

      // Hygiene Notice
      'hygieneNoticeTitle': '⚠️ ማሳሰቢያ',
      'hygieneNoticeBody': 'ለህፃናትም ሆነ ለእርሶ የምንጠቀምባቸዉ ማሽኖች ስቴራላይዝ የሆኑ እና መገልገያ ቁጥሮች፣ ማበጠሪያዎች ወዲያዉኑ እርሶ ፊት የሚታጠቡ ስለሆነ ሀሳብ አይግባዎት!!!',
    },
  };

  String get(String key) {
    return _localizedValues[locale.languageCode]?[key] ??
        _localizedValues['en']?[key] ??
        key;
  }

  // Convenience getters
  String get appName => get('appName');
  String get appTagline => get('appTagline');
  String get currency => get('currency');
  String get minutesShort => get('minutesShort');
  String get loading => get('loading');
  String get save => get('save');
  String get cancel => get('cancel');
  String get delete => get('delete');
  String get edit => get('edit');
  String get add => get('add');
  String get confirm => get('confirm');
  String get close => get('close');
  String get back => get('back');
  String get retry => get('retry');
  String get skip => get('skip');
  String get getStarted => get('getStarted');
  String get continueBtn => get('continueBtn');

  String get portalSelectionTitle => get('portalSelectionTitle');
  String get portalSelectionSubtitle => get('portalSelectionSubtitle');
  String get customerPortal => get('customerPortal');
  String get customerPortalDesc => get('customerPortalDesc');
  String get staffPortal => get('staffPortal');
  String get staffPortalDesc => get('staffPortalDesc');

  String get welcomeBack => get('welcomeBack');
  String get customerLoginSubtitle => get('customerLoginSubtitle');
  String get staffLoginSubtitle => get('staffLoginSubtitle');
  String get secureStaffAccess => get('secureStaffAccess');
  String get customerLogin => get('customerLogin');
  String get staffLogin => get('staffLogin');
  String get emailOrPhone => get('emailOrPhone');
  String get emailOrPhoneHint => get('emailOrPhoneHint');
  String get staffEmail => get('staffEmail');
  String get staffEmailHint => get('staffEmailHint');
  String get password => get('password');
  String get passwordHint => get('passwordHint');
  String get staffPasswordHint => get('staffPasswordHint');
  String get loginBtn => get('loginBtn');
  String get staffLoginBtn => get('staffLoginBtn');
  String get createAccount => get('createAccount');
  String get dontHaveAccount => get('dontHaveAccount');
  String get alreadyHaveAccount => get('alreadyHaveAccount');
  String get signIn => get('signIn');
  String get registerTitle => get('registerTitle');
  String get registerSubtitle => get('registerSubtitle');
  String get fullName => get('fullName');
  String get fullNameHint => get('fullNameHint');
  String get emailAddress => get('emailAddress');
  String get emailAddressHint => get('emailAddressHint');
  String get phoneNumber => get('phoneNumber');
  String get phoneNumberHint => get('phoneNumberHint');
  String get createPasswordHint => get('createPasswordHint');
  String get agreeTerms => get('agreeTerms');
  String get registerBtn => get('registerBtn');
  String get quickFill => get('quickFill');

  String get navHome => get('navHome');
  String get navStyles => get('navStyles');
  String get navBooking => get('navBooking');
  String get navAppointments => get('navAppointments');
  String get navProfile => get('navProfile');

  String get homeGreeting => get('homeGreeting');
  String get homeTagline => get('homeTagline');
  String get featuredStyles => get('featuredStyles');
  String get ourServices => get('ourServices');
  String get masterBarbers => get('masterBarbers');
  String get viewAll => get('viewAll');
  String get bookNow => get('bookNow');
  String get experience => get('experience');
  String get rating => get('rating');
  String get specialties => get('specialties');

  String get servicesTitle => get('servicesTitle');
  String get stylesTitle => get('stylesTitle');
  String get filterAll => get('filterAll');
  String get duration => get('duration');
  String get price => get('price');
  String get priceOnConsultation => get('priceOnConsultation');
  String get styleDetails => get('styleDetails');
  String get barberDetails => get('barberDetails');
  String get gallery => get('gallery');
  String get reviews => get('reviews');
  String get leaveReview => get('leaveReview');
  String get writeReviewHint => get('writeReviewHint');
  String get submitReview => get('submitReview');
  String get bookThisStyle => get('bookThisStyle');
  String get styleOverview => get('styleOverview');
  String get recommendedService => get('recommendedService');
  String get yearsExperience => get('yearsExperience');
  String get recentPortfolio => get('recentPortfolio');
  String get customerReviews => get('customerReviews');
  String get bookWith => get('bookWith');
  String get myFavorites => get('myFavorites');
  String get savedStylesTab => get('savedStylesTab');
  String get favoriteBarbersTab => get('favoriteBarbersTab');
  String get noSavedStyles => get('noSavedStyles');
  String get notifications => get('notifications');
  String get markAllAsRead => get('markAllAsRead');
  String get noNotifications => get('noNotifications');
  String get barbershopLocation => get('barbershopLocation');
  String get operatingHours => get('operatingHours');
  String get directContact => get('directContact');
  String get getDirections => get('getDirections');
  String get howWasExperience => get('howWasExperience');
  String get rateAppointmentWith => get('rateAppointmentWith');
  String get feedbackOptional => get('feedbackOptional');
  String get allAppointments => get('allAppointments');
  String get saveOperatingHours => get('saveOperatingHours');
  String get addMasterBarber => get('addMasterBarber');
  String get editBarber => get('editBarber');
  String get addNewService => get('addNewService');
  String get editService => get('editService');
  String get addHairstyle => get('addHairstyle');
  String get editHairstyle => get('editHairstyle');

  String get bookingWizardTitle => get('bookingWizardTitle');
  String get stepService => get('stepService');
  String get stepBarber => get('stepBarber');
  String get stepDateTime => get('stepDateTime');
  String get stepConfirm => get('stepConfirm');
  String get selectServiceTitle => get('selectServiceTitle');
  String get selectBarberTitle => get('selectBarberTitle');
  String get anyBarber => get('anyBarber');
  String get selectDateTimeTitle => get('selectDateTimeTitle');
  String get noSlotsAvailable => get('noSlotsAvailable');
  String get selectTime => get('appointmentTime');
  String get selectDate => get('appointmentDate');
  String get confirmAppointment => get('stepConfirm');
  String get bookAppointment => get('bookNow');
  String get reviewBookingTitle => get('reviewBookingTitle');
  String get appointmentSummary => get('appointmentSummary');
  String get selectedService => get('selectedService');
  String get selectedBarber => get('selectedBarber');
  String get appointmentDate => get('appointmentDate');
  String get appointmentTime => get('appointmentTime');
  String get location => get('location');
  String get shopAddress => get('shopAddress');
  String get confirmAndBookBtn => get('confirmAndBookBtn');
  String get bookingSuccessTitle => get('bookingSuccessTitle');
  String get bookingSuccessMsg => get('bookingSuccessMsg');
  String get appointmentRef => get('appointmentRef');
  String get viewAppointmentsBtn => get('viewAppointmentsBtn');

  String get myAppointmentsTitle => get('myAppointmentsTitle');
  String get tabUpcoming => get('tabUpcoming');
  String get tabPast => get('tabPast');
  String get tabCancelled => get('tabCancelled');
  String get noUpcomingAppts => get('noUpcomingAppts');
  String get noPastAppts => get('noPastAppts');
  String get noCancelledAppts => get('noCancelledAppts');
  String get cancelAppointment => get('cancelAppointment');
  String get cancelConfirmMsg => get('cancelConfirmMsg');
  String get yesCancel => get('yesCancel');
  String get keepAppointment => get('keepAppointment');
  String get bookAgain => get('bookAgain');
  String get cancelledBadge => get('cancelledBadge');

  String get statusConfirmed => get('statusConfirmed');
  String get statusCheckedIn => get('statusCheckedIn');
  String get statusInProgress => get('statusInProgress');
  String get statusCompleted => get('statusCompleted');
  String get statusCancelled => get('statusCancelled');
  String get statusNoShow => get('statusNoShow');

  String get barberPortalTitle => get('barberPortalTitle');
  String get todayQueue => get('todayQueue');
  String get noAppointmentsToday => get('noAppointmentsToday');
  String get client => get('client');
  String get contact => get('contact');
  String get actionCheckIn => get('actionCheckIn');
  String get actionStart => get('actionStart');
  String get actionComplete => get('actionComplete');
  String get actionNoShow => get('actionNoShow');
  String get actionCancel => get('actionCancel');

  String get adminDashboardTitle => get('adminDashboardTitle');
  String get totalAppointments => get('totalAppointments');
  String get activeBarbers => get('activeBarbers');
  String get totalServices => get('totalServices');
  String get totalStyles => get('totalStyles');
  String get manageAppointments => get('manageAppointments');
  String get manageBarbers => get('manageBarbers');
  String get manageServices => get('manageServices');
  String get manageStyles => get('manageStyles');
  String get businessHours => get('businessHours');
  String get adminSettings => get('adminSettings');
  String get openTime => get('openTime');
  String get closeTime => get('closeTime');
  String get isOpen => get('isOpen');
  String get isClosed => get('isClosed');
  String get addNew => get('addNew');

  String get profileAndSettings => get('profileAndSettings');
  String get managementTools => get('managementTools');
  String get barberWorkTools => get('barberWorkTools');
  String get accountAndShop => get('accountAndShop');
  String get preferencesSection => get('preferencesSection');
  String get languageSetting => get('languageSetting');
  String get languageSubtitle => get('languageSubtitle');
  String get appearanceSetting => get('appearanceSetting');
  String get appearanceSubtitle => get('appearanceSubtitle');
  String get selectTheme => get('selectTheme');
  String get shopLocationTitle => get('shopLocationTitle');
  String get shopLocationSubtitle => get('shopLocationSubtitle');
  String get savedFavoritesTitle => get('savedFavoritesTitle');
  String get savedFavoritesSubtitle => get('savedFavoritesSubtitle');
  String get notificationsTitle => get('notificationsTitle');
  String get notificationsSubtitle => get('notificationsSubtitle');
  String get aboutSection => get('aboutSection');
  String get appVersion => get('appVersion');
  String get aboutText => get('aboutText');
  String get logOut => get('logOut');
  String get logOutConfirm => get('logOutConfirm');

  String get themeLuxuryGold => get('themeLuxuryGold');
  String get themeLuxuryGoldDesc => get('themeLuxuryGoldDesc');
  String get themeEthiopianHeritage => get('themeEthiopianHeritage');
  String get themeEthiopianHeritageDesc => get('themeEthiopianHeritageDesc');
  String get themeModernDark => get('themeModernDark');
  String get themeModernDarkDesc => get('themeModernDarkDesc');
  String get themeLightPremium => get('themeLightPremium');
  String get themeLightPremiumDesc => get('themeLightPremiumDesc');

  String get errRequiredFields => get('errRequiredFields');
  String get errInvalidEmail => get('errInvalidEmail');
  String get errShortPassword => get('errShortPassword');
  String get errInvalidCredentials => get('errInvalidCredentials');
  String get errStaffOnly => get('errStaffOnly');
  String get errCustomerOnly => get('errCustomerOnly');
  String get errNetwork => get('errNetwork');
  String get errSlotUnavailable => get('errSlotUnavailable');

  // Onboarding getters
  String get onboardingTag1 => get('onboardingTag1');
  String get onboardingTitle1 => get('onboardingTitle1');
  String get onboardingSubtitle1 => get('onboardingSubtitle1');
  String get onboardingTag2 => get('onboardingTag2');
  String get onboardingTitle2 => get('onboardingTitle2');
  String get onboardingSubtitle2 => get('onboardingSubtitle2');
  String get onboardingTag3 => get('onboardingTag3');
  String get onboardingTitle3 => get('onboardingTitle3');
  String get onboardingSubtitle3 => get('onboardingSubtitle3');

  // Home banner & extra
  String get premierGrooming => get('premierGrooming');
  String get lookGoodFeelGood => get('lookGoodFeelGood');
  String get distinguishedGuest => get('distinguishedGuest');
  String get newService => get('newService');
  String get homeToHome => get('homeToHome');
  String get homeToHomeDesc => get('homeToHomeDesc');
  String get bookNowCta => get('bookNowCta');
  String get couldNotLoadStyles => get('couldNotLoadStyles');
  String get couldNotLoadServices => get('couldNotLoadServices');
  String get couldNotLoadBarbers => get('couldNotLoadBarbers');

  // Styles & extra
  String get noStylesFound => get('noStylesFound');
  String get noStylesFoundDesc => get('noStylesFoundDesc');
  String get noReviewsYet => get('noReviewsYet');
  String get thankYouRating => get('thankYouRating');
  String get yrsExpSuffix => get('yrsExpSuffix');
  String get bookServiceAction => get('bookServiceAction');
  String get styleLabel => get('styleLabel');

  // Booking
  String get totalPrice => get('totalPrice');
  String get prePaymentNow => get('prePaymentNow');
  String get balanceAfterService => get('balanceAfterService');
  String get prePaymentNotice1 => get('prePaymentNotice1');
  String get prePaymentNotice2 => get('prePaymentNotice2');
  String get prePaymentNotice3 => get('prePaymentNotice3');
  String get telebirrCbeRef => get('telebirrCbeRef');
  String get telebirrHint => get('telebirrHint');
  String get uploadPaymentScreenshot => get('uploadPaymentScreenshot');
  String get uploadPaymentScreenshotSubtitle => get('uploadPaymentScreenshotSubtitle');
  String get screenshotUploaded => get('screenshotUploaded');
  String get changeScreenshot => get('changeScreenshot');
  String get screenshotRequired => get('screenshotRequired');
  String get optionalTxRef => get('optionalTxRef');
  String get optionalTxRefHint => get('optionalTxRefHint');
  String get specialNotes => get('specialNotes');
  String get specialNotesHint => get('specialNotesHint');
  String get txRefRequired => get('txRefRequired');

  // Appointments
  String get noUpcomingDesc => get('noUpcomingDesc');
  String get noPastDesc => get('noPastDesc');

  // Shop info
  String get monFriHours => get('monFriHours');
  String get saturdayHours => get('saturdayHours');
  String get sundayHours => get('sundayHours');
  String get tapToOpenMaps => get('tapToOpenMaps');
  String get couldNotOpenMaps => get('couldNotOpenMaps');
  String get shopCityCountry => get('shopCityCountry');
  String get serverSetting => get('serverSetting');
  String get serverSettingSubtitle => get('serverSettingSubtitle');
  String get serverSaved => get('serverSaved');

  // Roles & Status
  String get roleCustomer => get('roleCustomer');
  String get roleBarber => get('roleBarber');
  String get roleAdmin => get('roleAdmin');
  String get statusPending => get('statusPending');

  // Hygiene Notice
  String get hygieneNoticeTitle => get('hygieneNoticeTitle');
  String get hygieneNoticeBody => get('hygieneNoticeBody');

  // Dynamic translators for data from server
  String localizeServiceName(String name) {
    final lower = name.toLowerCase().trim();

    if (isAmharic) {
      if (lower.contains('vip') || lower.contains('ቪአይፒ')) {
        return 'ቪአይፒ (VIP)';
      }
      if (lower.contains('home to home') || lower.contains('home service') || lower.contains('ቤት ለቤት')) {
        return 'ቤት ለቤት አገልግሎት';
      }
      // Check full beard + hair package before haircut alone
      if (lower.contains('ፂም-ፀጉር') ||
          (lower.contains('beard') && lower.contains('hair')) ||
          lower.contains('full service') ||
          lower.contains('haircut with hair wash') ||
          lower.contains('hair cut with hair wash') ||
          lower.contains('haircut & beard')) {
        return 'ፂም-ፀጉር (ሙሉ ስራ)';
      }
      if (lower.contains('kid') || lower.contains('child') || lower.contains('ህፃናት') || lower.contains('finger coils')) {
        return 'የህፃናት ፀጉር';
      }
      if (lower.contains('massage') || lower.contains('scalp') || lower.contains('head massage') || lower.contains('ማሳጅ') || lower.contains('ጭንቅላት')) {
        return 'የጭንቅላት ማሳጅ';
      }
      if (lower.contains('facial') || lower.contains('face steam') || lower.contains('እርድ') || lower.contains('ቀሲል') || lower.contains('ፊት ስቲም') || lower.contains('scrub') || lower == 'hair wash') {
        return 'የፊት ስቲም (ተፈጥሯዊ በሆነ በእርድ፣ በቀሲል፣ በማር ውህድ ወይም በእስክራብ)';
      }
      if (lower.contains('hair steam') || lower.contains('butter') || lower.contains('ቅቤ') || lower.contains('ቂቤ') || lower.contains('ፀጉር ስቲም') || lower.contains('hair cut + finger coils') || lower.contains('haircut + finger coils')) {
        return 'የፀጉር ስቲም (ከኦርጋኒክ የፀጉር ቅቤ ውህድ ጋር)';
      }
      if (lower.contains('beard') || lower.contains('ፂም')) {
        return 'የፂም ቅርጽና ቁርጥ';
      }
      if (lower.contains('haircut') || lower.contains('የፀጉር ቁርጥ') || lower == 'hair' || lower.contains('cut')) {
        return 'የፀጉር ቁርጥ';
      }
      return name;
    } else {
      // English Mode
      if (lower.contains('vip') || lower.contains('ቪአይፒ')) {
        return 'VIP Grooming';
      }
      if (lower.contains('home to home') || lower.contains('home service') || lower.contains('ቤት ለቤት')) {
        return 'Home to Home Service';
      }
      if (lower.contains('ፂም-ፀጉር') ||
          (lower.contains('beard') && lower.contains('hair')) ||
          lower.contains('full service') ||
          lower.contains('haircut with hair wash') ||
          lower.contains('hair cut with hair wash') ||
          lower.contains('haircut & beard')) {
        return 'Haircut & Beard (Full Service)';
      }
      if (lower.contains('kid') || lower.contains('child') || lower.contains('ህፃናት') || lower.contains('finger coils')) {
        return 'Kids Haircut';
      }
      if (lower.contains('massage') || lower.contains('scalp') || lower.contains('head massage') || lower.contains('ማሳጅ') || lower.contains('ጭንቅላት')) {
        return 'Scalp & Head Massage';
      }
      if (lower.contains('facial') || lower.contains('face steam') || lower.contains('እርድ') || lower.contains('ቀሲል') || lower.contains('ፊት ስቲም') || lower.contains('scrub') || lower == 'hair wash') {
        return 'Facial Steam (Natural Herbal & Scrub)';
      }
      if (lower.contains('hair steam') || lower.contains('butter') || lower.contains('ቅቤ') || lower.contains('ቂቤ') || lower.contains('ፀጉር ስቲም') || lower.contains('hair cut + finger coils') || lower.contains('haircut + finger coils')) {
        return 'Hair Steam (Organic Butter Treatment)';
      }
      if (lower.contains('beard') || lower.contains('ፂም')) {
        return 'Beard Sculpt & Razor Shape';
      }
      if (lower.contains('haircut') || lower.contains('የፀጉር ቁርጥ') || lower == 'hair') {
        return 'Signature Haircut';
      }
      return name;
    }
  }

  String localizeServiceDesc(String? desc) {
    if (desc == null || desc.isEmpty) return '';
    final lower = desc.toLowerCase().trim();

    if (isAmharic) {
      if ((lower.contains('beard') && lower.contains('hair')) || lower.contains('full signature')) {
        return 'ሙሉ የፀጉር ቁርጥ ከፂም ማስተካከል፣ የዘይት ህክምና እና የላጭ መስመር ጋር።';
      }
      if (lower.contains('facial') || lower.contains('turmeric') || lower.contains('qasil') || lower.contains('scrub') || lower.contains('ፊት ስቲም')) {
        return 'በተፈጥሯዊ የእርድ፣ የቀሲል፣ የማር ውህድ ወይም እስክራብ የሚደረግ ጥልቅ የፊት እንክብካቤ እና ስቲም።';
      }
      if (lower.contains('hair steam') || lower.contains('butter') || lower.contains('ፀጉር ስቲም')) {
        return 'ጥልቅ የፀጉር እንክብካቤ በኦርጋኒክ የፀጉር ቅቤ ውህድ እና ስቲም።';
      }
      if (lower.contains('scalp') || lower.contains('massage') || lower.contains('tea tree') || lower.contains('ማሳጅ')) {
        return 'መንፈስን የሚያድስ ዕጥበት፣ የራስ ቅል ማሳጅ እና ፎጣ ማድረቂያ።';
      }
      if (lower.contains('kid') || lower.contains('youngster') || lower.contains('child') || lower.contains('ህፃናት')) {
        return 'ለህፃናት ምቹ፣ ፅዱ እና ዘመናዊ የፀጉር አቆራረጥ።';
      }
      if (lower.contains('home to home') || lower.contains('at your home') || lower.contains('ቤት ለቤት')) {
        return 'ልዩ የቪአይፒ አገልግሎት በባለሙያችን አማካኝነት እርስዎ ያሉበት ድረስ።';
      }
      if (lower.contains('tailored haircut') || lower.contains('precision') || lower.contains('for all hair cut')) {
        return 'ትክክለኛ የተስተካከለ የፀጉር ቁርጥ፣ የላጭ መስመር እና የሙቅ ፎጣ አጨራረስ።';
      }
      if (lower.contains('beard') || lower.contains('straight razor')) {
        return 'የተሟላ የፂም ቅርጽ ማስተካከል ከላጭ መስመር እና ከተፈጥሮ ዘይት ጋር።';
      }
      return desc;
    } else {
      if (lower.contains('ፂም') && lower.contains('ፀጉር')) {
        return 'Full signature haircut combined with precision beard trim, oil treatment & razor line.';
      }
      if (lower.contains('ፊት ስቲም') || lower.contains('እርድ') || lower.contains('ቀሲል')) {
        return 'Deep facial steam & treatment using natural turmeric, qasil, honey blend or scrub.';
      }
      if (lower.contains('ፀጉር ስቲም') || lower.contains('ቅቤ') || lower.contains('ቂቤ')) {
        return 'Deep hair conditioning with steam and organic hair butter blend.';
      }
      if (lower.contains('ማሳጅ') || lower.contains('ጭንቅላት')) {
        return 'Invigorating wash, relaxing scalp massage, and hot towel finish.';
      }
      if (lower.contains('ህፃናት')) {
        return 'Gentle, modern, crisp styling for youngsters.';
      }
      if (lower.contains('ቤት ለቤት')) {
        return 'Exclusive VIP service delivered at your home or location.';
      }
      if (lower.contains('ቁርጥ')) {
        return 'Precision tailored haircut, razor-sharp edge up, and hot towel finish.';
      }
      return desc;
    }
  }

  String localizeCategory(String category) {
    if (!isAmharic) return category;
    final lower = category.toLowerCase().trim();
    if (lower == 'all') return 'ሁሉም';
    if (lower.contains('low fade')) return 'ሎው ፌድ';
    if (lower.contains('mid fade')) return 'ሚድ ፌድ';
    if (lower.contains('taper')) return 'ቴፐር';
    if (lower.contains('afro')) return 'አፍሮ';
    if (lower.contains('dreads')) return 'ድሬድ';
    if (lower.contains('beard')) return 'ፂም';
    if (lower.contains('classic')) return 'ክላሲክ';
    if (lower == 'premium') return 'ፕሪሚየም';
    if (lower == 'hair') return 'ፀጉር';
    if (lower == 'haircare') return 'የፀጉር እንክብካቤ';
    if (lower == 'hair style') return 'የፀጉር ቅጥ';
    return category;
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'am'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

extension LocalizationExtension on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
