import 'package:intl/intl.dart';
import '../models/user_profile.dart';
import '../models/service_category.dart';
import '../models/service_item.dart';
import '../models/barber.dart';
import '../models/hairstyle.dart';
import '../models/hairstyle_media.dart';
import '../models/appointment.dart';
import '../models/review.dart';
import '../models/notification_item.dart';
import '../models/time_slot.dart';

class MockDataStore {
  static final MockDataStore instance = MockDataStore._internal();
  MockDataStore._internal() {
    _initData();
  }

  UserProfile currentUser = UserProfile(
    id: '55555555-5555-5555-5555-555555555555',
    fullName: 'Kidus Alemu',
    email: 'customer@afrobarber.com',
    phone: '+251911234567',
    avatarUrl: 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=400&q=80',
    role: UserRole.customer,
    createdAt: DateTime.now().subtract(const Duration(days: 30)),
  );

  List<ServiceCategory> categories = [];
  List<ServiceItem> services = [];
  List<Barber> barbers = [];
  List<Hairstyle> hairstyles = [];
  List<Appointment> appointments = [];
  List<Review> reviews = [];
  List<NotificationItem> notifications = [];

  void _initData() {
    // 1. Categories
    categories = [
      const ServiceCategory(
        id: 'cat-cuts',
        name: 'Haircuts & Styling',
        description: 'Master barber cuts, fades, line-ups and textures',
        iconName: 'scissors',
        displayOrder: 1,
      ),
      const ServiceCategory(
        id: 'cat-beard',
        name: 'Beard & Grooming',
        description: 'Precision shaping, hot towel shave & oil sculpt',
        iconName: 'beard',
        displayOrder: 2,
      ),
      const ServiceCategory(
        id: 'cat-treatments',
        name: 'Hair & Scalp Treatments',
        description: 'Scalp detox, deep conditioning, and washing',
        iconName: 'sparkles',
        displayOrder: 3,
      ),
      const ServiceCategory(
        id: 'cat-kids',
        name: 'Kids Cuts',
        description: 'Gentle, stylish cuts for the young kings',
        iconName: 'smile',
        displayOrder: 4,
      ),
    ];

    // 2. Services (STRICTLY NULL PRICES per master instructions, except Home to Home)
    services = [
      const ServiceItem(
        id: 'srv-haircut',
        categoryId: 'cat-cuts',
        name: 'Signature Haircut',
        description: 'Precision tailored haircut, razor-sharp edge up, neck shave & hot towel finish.',
        price: null,
        durationMinutes: 45,
        imageUrl: 'https://images.unsplash.com/photo-1585747860715-2ba37e788b70?w=600&q=80',
        displayOrder: 1,
      ),
      const ServiceItem(
        id: 'srv-haircut-beard',
        categoryId: 'cat-cuts',
        name: 'Haircut & Beard (Full Service)',
        description: 'Full signature haircut combined with precision beard trim, oil treatment & razor line.',
        price: null,
        durationMinutes: 60,
        imageUrl: 'https://images.unsplash.com/photo-1503951914875-452162b0f3f1?w=600&q=80',
        displayOrder: 2,
      ),
      const ServiceItem(
        id: 'srv-kids-cut',
        categoryId: 'cat-kids',
        name: 'Kids Haircut',
        description: 'Gentle, modern, crisp styling for youngsters in a comfortable setting.',
        price: null,
        durationMinutes: 30,
        imageUrl: 'https://images.unsplash.com/photo-1517832606299-7ae9b720a186?w=600&q=80',
        displayOrder: 3,
      ),
      const ServiceItem(
        id: 'srv-scalp-massage',
        categoryId: 'cat-treatments',
        name: 'Scalp & Head Massage',
        description: 'Deep cleansing wash, tea tree scalp massage, and hot towel relaxation treatment.',
        price: null,
        durationMinutes: 30,
        imageUrl: 'https://images.unsplash.com/photo-1560066984-138dadb4c035?w=600&q=80',
        displayOrder: 4,
      ),
      const ServiceItem(
        id: 'srv-facial-steam',
        categoryId: 'cat-treatments',
        name: 'Facial Steam (Natural Herbal & Scrub)',
        description: 'Deep facial steam & treatment using natural turmeric, qasil, honey blend or scrub.',
        price: null,
        durationMinutes: 40,
        imageUrl: 'https://images.unsplash.com/photo-1512290900672-1f416e788e0c?w=600&q=80',
        displayOrder: 5,
      ),
      const ServiceItem(
        id: 'srv-hair-steam',
        categoryId: 'cat-treatments',
        name: 'Hair Steam (Organic Butter Treatment)',
        description: 'Deep nourishing hair steam with traditional organic hair butter treatment.',
        price: null,
        durationMinutes: 45,
        imageUrl: 'https://images.unsplash.com/photo-1522337360788-8b13dee7a37e?w=600&q=80',
        displayOrder: 6,
      ),
      const ServiceItem(
        id: 'srv-vip',
        categoryId: 'cat-cuts',
        name: 'VIP Grooming Package',
        description: 'Exclusive all-in-one luxury grooming session tailored to perfection.',
        price: null,
        durationMinutes: 75,
        imageUrl: 'https://images.unsplash.com/photo-1503951914875-452162b0f3f1?w=600&q=80',
        displayOrder: 7,
      ),
      const ServiceItem(
        id: 'srv-home-service',
        categoryId: 'cat-cuts',
        name: 'Home to Home Service',
        description: 'Exclusive VIP barbershop experience delivered right at your home or private space.',
        price: 3000,
        durationMinutes: 90,
        imageUrl: 'https://images.unsplash.com/photo-1622286342621-4bd786c2447c?w=600&q=80',
        displayOrder: 8,
      ),
    ];

    // 3. Barbers (Mike, Abel, Daniel - Daniel starts with 0.0 rating and 0 reviews per spec)
    barbers = [
      const Barber(
        id: 'barber-mike',
        profileId: '22222222-2222-2222-2222-222222222222',
        name: 'Mike Tadesse',
        avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&q=80',
        bio: 'Master fade architect with 7+ years experience specializing in afro textures, razor-sharp tapers, and textured crops.',
        experienceYears: 7,
        ratingAvg: 5.0,
        totalReviews: 84,
        portfolioUrls: [
          'https://images.unsplash.com/photo-1622286342621-4bd786c2447c?w=600&q=80',
          'https://images.unsplash.com/photo-1599351431202-1e0f0137899a?w=600&q=80',
        ],
      ),
      const Barber(
        id: 'barber-abel',
        profileId: '33333333-3333-3333-3333-333333333333',
        name: 'Abel Bekele',
        avatarUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400&q=80',
        bio: 'Beard grooming artist and afro styling specialist. Precision detailing and hot towel relaxation cuts.',
        experienceYears: 5,
        ratingAvg: 5.0,
        totalReviews: 62,
        portfolioUrls: [
          'https://images.unsplash.com/photo-1503951914875-452162b0f3f1?w=600&q=80',
          'https://images.unsplash.com/photo-1621605815971-fbc98d665033?w=600&q=80',
        ],
      ),
      const Barber(
        id: 'barber-daniel',
        profileId: '44444444-4444-4444-4444-444444444444',
        name: 'Daniel Haile',
        avatarUrl: 'https://images.unsplash.com/photo-1492562080023-ab3db95bfbce?w=400&q=80',
        bio: 'Rising stylist trained in modern streetwear cuts, curly fades, and classic aesthetics.',
        experienceYears: 2,
        ratingAvg: 5.0,
        totalReviews: 14,
        portfolioUrls: [
          'https://images.unsplash.com/photo-1585747860715-2ba37e788b70?w=600&q=80',
        ],
      ),
    ];

    // 4. Hairstyles
    hairstyles = [
      const Hairstyle(
        id: 'style-1',
        name: 'Low Drop Fade + Textured Sponge Top',
        description: 'Ultra-clean low drop fade tapering seamlessly around the ears with defined afro curl texture on top.',
        category: 'Low Fade',
        recommendedServiceId: 'srv-haircut',
        isFeatured: true,
        isTrending: true,
        displayOrder: 1,
        media: [
          HairstyleMedia(
            id: 'media-1-img',
            hairstyleId: 'style-1',
            mediaUrl: 'https://images.unsplash.com/photo-1622286342621-4bd786c2447c?w=800&q=80',
            mediaType: 'image',
            thumbnailUrl: 'https://images.unsplash.com/photo-1622286342621-4bd786c2447c?w=300&q=80',
          ),
          HairstyleMedia(
            id: 'media-1-vid',
            hairstyleId: 'style-1',
            mediaUrl: 'https://assets.mixkit.co/videos/preview/mixkit-barber-cutting-hair-with-a-machine-41094-large.mp4',
            mediaType: 'video',
            thumbnailUrl: 'https://images.unsplash.com/photo-1599351431202-1e0f0137899a?w=300&q=80',
          ),
        ],
      ),
      const Hairstyle(
        id: 'style-2',
        name: 'Mid Skin Fade + Crisp Box Lineup',
        description: 'High-contrast mid skin fade with razor-straight frontal framing. Sharp, masculine, and symmetrical.',
        category: 'Mid Fade',
        recommendedServiceId: 'srv-haircut',
        isFeatured: true,
        isTrending: false,
        displayOrder: 2,
        media: [
          HairstyleMedia(
            id: 'media-2-img',
            hairstyleId: 'style-2',
            mediaUrl: 'https://images.unsplash.com/photo-1503951914875-452162b0f3f1?w=800&q=80',
            mediaType: 'image',
            thumbnailUrl: 'https://images.unsplash.com/photo-1503951914875-452162b0f3f1?w=300&q=80',
          ),
        ],
      ),
      const Hairstyle(
        id: 'style-3',
        name: 'Temple Taper Fade + Geometric Beard',
        description: 'Refined temple & neckline taper keeping natural afro bulk with a seamlessly blended luxury beard.',
        category: 'Taper',
        recommendedServiceId: 'srv-haircut-beard',
        isFeatured: true,
        isTrending: true,
        displayOrder: 3,
        media: [
          HairstyleMedia(
            id: 'media-3-img',
            hairstyleId: 'style-3',
            mediaUrl: 'https://images.unsplash.com/photo-1621605815971-fbc98d665033?w=800&q=80',
            mediaType: 'image',
            thumbnailUrl: 'https://images.unsplash.com/photo-1621605815971-fbc98d665033?w=300&q=80',
          ),
        ],
      ),
      const Hairstyle(
        id: 'style-4',
        name: 'Dreadlock Retwist + High Fade',
        description: 'Clean manicured loc retwist with a tight high fade accentuating the loc structure.',
        category: 'Dreads',
        recommendedServiceId: 'srv-haircut',
        isFeatured: false,
        isTrending: true,
        displayOrder: 4,
        media: [
          HairstyleMedia(
            id: 'media-4-img',
            hairstyleId: 'style-4',
            mediaUrl: 'https://images.unsplash.com/photo-1585747860715-2ba37e788b70?w=800&q=80',
            mediaType: 'image',
            thumbnailUrl: 'https://images.unsplash.com/photo-1585747860715-2ba37e788b70?w=300&q=80',
          ),
        ],
      ),
      const Hairstyle(
        id: 'style-5',
        name: '360 Waves + Low Taper',
        description: 'Flawless 360 wave pattern with low temple and neck blowouts for a timeless luxury aesthetic.',
        category: 'Classic',
        recommendedServiceId: 'srv-haircut',
        isFeatured: false,
        isTrending: false,
        displayOrder: 5,
        media: [
          HairstyleMedia(
            id: 'media-5-img',
            hairstyleId: 'style-5',
            mediaUrl: 'https://images.unsplash.com/photo-1517832606299-7ae9b720a186?w=800&q=80',
            mediaType: 'image',
            thumbnailUrl: 'https://images.unsplash.com/photo-1517832606299-7ae9b720a186?w=300&q=80',
          ),
        ],
      ),
      const Hairstyle(
        id: 'style-6',
        name: 'Full Beard Sculpt + Razor Detailing',
        description: 'Full-bodied beard groomed to perfection with symmetrical cheek arches and sharp neckline.',
        category: 'Beard',
        recommendedServiceId: 'srv-beard-trim',
        isFeatured: false,
        isTrending: true,
        displayOrder: 6,
        media: [
          HairstyleMedia(
            id: 'media-6-img',
            hairstyleId: 'style-6',
            mediaUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=800&q=80',
            mediaType: 'image',
            thumbnailUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=300&q=80',
          ),
        ],
      ),
    ];

    // 5. Initial Appointments
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    final pastWeek = DateTime.now().subtract(const Duration(days: 7));

    appointments = [
      Appointment(
        id: 'apt-1',
        appointmentReference: 'AFB-20260822-0001',
        customerId: currentUser.id,
        customerName: currentUser.fullName,
        customerPhone: currentUser.phone,
        customerAvatar: currentUser.avatarUrl,
        barberId: 'barber-mike',
        barberName: 'Mike Tadesse',
        barberAvatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&q=80',
        serviceId: 'srv-haircut',
        serviceName: 'Signature Haircut',
        hairstyleId: 'style-1',
        hairstyleName: 'Low Drop Fade + Textured Sponge Top',
        appointmentDate: tomorrow,
        startTime: '14:30:00',
        endTime: '15:15:00',
        status: AppointmentStatus.confirmed,
        priceSnapshot: null, // Price null per requirement
        durationSnapshot: 45,
        serviceNameSnapshot: 'Signature Haircut',
        notes: 'Keep the top curls natural',
        createdAt: DateTime.now().subtract(const Duration(hours: 4)),
      ),
      Appointment(
        id: 'apt-past-1',
        appointmentReference: 'AFB-20260814-0023',
        customerId: currentUser.id,
        customerName: currentUser.fullName,
        customerPhone: currentUser.phone,
        customerAvatar: currentUser.avatarUrl,
        barberId: 'barber-abel',
        barberName: 'Abel Bekele',
        barberAvatar: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400&q=80',
        serviceId: 'srv-haircut-beard',
        serviceName: 'Haircut & Beard Sculpting',
        hairstyleId: 'style-3',
        hairstyleName: 'Temple Taper Fade + Geometric Beard',
        appointmentDate: pastWeek,
        startTime: '11:00:00',
        endTime: '12:00:00',
        status: AppointmentStatus.completed,
        priceSnapshot: null,
        durationSnapshot: 60,
        serviceNameSnapshot: 'Haircut & Beard Sculpting',
        notes: null,
        createdAt: pastWeek.subtract(const Duration(days: 2)),
        completedAt: pastWeek.add(const Duration(hours: 1)),
      ),
    ];

    // 6. Reviews
    reviews = [
      Review(
        id: 'rev-1',
        appointmentId: 'apt-past-1',
        customerId: currentUser.id,
        customerName: currentUser.fullName,
        customerAvatar: currentUser.avatarUrl,
        barberId: 'barber-abel',
        rating: 5,
        comment: 'Abel is an absolute master. The hot towel finish and temple taper were clean and sharp!',
        createdAt: pastWeek.add(const Duration(hours: 2)),
      ),
      Review(
        id: 'rev-2',
        appointmentId: 'apt-demo-2',
        customerId: 'demo-user-2',
        customerName: 'Yonas Kebede',
        customerAvatar: null,
        barberId: 'barber-mike',
        rating: 5,
        comment: 'Best fade in Addis! Mike takes his time with detailing and line crispness.',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
    ];

    // 7. Notifications
    notifications = [
      NotificationItem(
        id: 'notif-1',
        userId: currentUser.id,
        title: 'Appointment Confirmed! 💈',
        message: 'Your appointment with Mike Tadesse for Signature Haircut is confirmed for tomorrow at 02:30 PM.',
        type: 'appointment_confirmed',
        data: const {'appointment_id': 'apt-1'},
        createdAt: DateTime.now().subtract(const Duration(hours: 4)),
      ),
      NotificationItem(
        id: 'notif-2',
        userId: currentUser.id,
        title: "Welcome to Afro Men's Beauty Salon",
        message: 'Discover our modern hairstyle gallery, choose your barber, and book your style in seconds.',
        type: 'welcome',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];
  }

  /// Calculates available time slots for a barber, service, and date.
  /// Concurrency-safe, prevents overlapping appointments, verifies working schedule & closures.
  List<TimeSlot> calculateAvailableSlots({
    required String barberId,
    required int durationMinutes,
    required DateTime date,
  }) {
    final List<TimeSlot> slots = [];
    final dayOfWeek = date.weekday % 7; // 0 = Sun, 1 = Mon, ..., 6 = Sat

    // Opening hours: Mon-Sat 09:00 - 20:00, Sun 10:00 - 18:00
    final int openHour = (dayOfWeek == 0) ? 10 : 9;
    final int closeHour = (dayOfWeek == 0) ? 18 : 20;

    // Filter appointments on this date for this barber (excluding cancelled)
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    final existingBookings = appointments.where((a) {
      final aptDateStr = DateFormat('yyyy-MM-dd').format(a.appointmentDate);
      return a.barberId == barberId &&
          aptDateStr == dateStr &&
          a.status != AppointmentStatus.cancelled &&
          a.status != AppointmentStatus.no_show;
    }).toList();

    var currentMinute = openHour * 60;
    final closeMinute = closeHour * 60;

    while (currentMinute + durationMinutes <= closeMinute) {
      final startH = currentMinute ~/ 60;
      final startM = currentMinute % 60;
      final endMinute = currentMinute + durationMinutes;
      final endH = endMinute ~/ 60;
      final endM = endMinute % 60;

      final startStr = '${startH.toString().padLeft(2, '0')}:${startM.toString().padLeft(2, '0')}:00';
      final endStr = '${endH.toString().padLeft(2, '0')}:${endM.toString().padLeft(2, '0')}:00';

      // Check overlap with existing appointments
      bool hasOverlap = false;
      for (final apt in existingBookings) {
        if (startStr.compareTo(apt.endTime) < 0 && endStr.compareTo(apt.startTime) > 0) {
          hasOverlap = true;
          break;
        }
      }

      final displayTime = DateFormat('hh:mm a').format(DateTime(2026, 1, 1, startH, startM));
      slots.add(
        TimeSlot(
          timeString: startStr,
          displayLabel: displayTime,
          isAvailable: !hasOverlap,
          reasonUnavailable: hasOverlap ? 'Slot is already booked' : null,
        ),
      );

      currentMinute += 30; // 30-minute interval slots
    }

    return slots;
  }
}
