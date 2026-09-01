import 'package:flutter/material.dart';
import '../../features/categories/domain/entities/category.dart';
import '../../features/recipes/domain/entities/recipe.dart';

class RecipeTranslations {
  // Category Translations
  static const Map<String, Map<String, String>> categoryNames = {
    'Malnad Special': {
      'en': 'Malnad Special',
      'kn': 'ಮಲೆನಾಡು ವಿಶೇಷ',
      'hi': 'मलनाड विशेष',
    },
    'Breakfast': {
      'en': 'Breakfast',
      'kn': 'ಉಪಹಾರ',
      'hi': 'नाश्ता',
    },
    'Lunch & Dinner': {
      'en': 'Lunch & Dinner',
      'kn': 'ಊಟ ಮತ್ತು ಭೋಜನ',
      'hi': 'दोपहर व रात का खाना',
    },
    'Lunch': {
      'en': 'Lunch',
      'kn': 'ಮಧ್ಯಾಹ್ನದ ಊಟ',
      'hi': 'दोपहर का भोजन',
    },
    'Dinner': {
      'en': 'Dinner',
      'kn': 'ರಾತ್ರಿ ಊಟ',
      'hi': 'रात का खाना',
    },
    'Non-Vegetarian': {
      'en': 'Non-Vegetarian',
      'kn': 'ಮಾಂಸಾಹಾರಿ',
      'hi': 'मांसाहारी',
    },
    'Snacks': {
      'en': 'Snacks',
      'kn': 'ತಿಂಡಿಗಳು',
      'hi': 'नाश्ता / स्नैक्स',
    },
    'Desserts': {
      'en': 'Desserts',
      'kn': 'ಸಿಹಿತಿಂಡಿಗಳು',
      'hi': 'मिठाइयाँ',
    },
    'Drinks': {
      'en': 'Drinks',
      'kn': 'ಪಾನೀಯಗಳು',
      'hi': 'पेय',
    },
    'Healthy': {
      'en': 'Healthy',
      'kn': 'ಆರೋಗ್ಯಕರ',
      'hi': 'स्वास्थ्यवर्धक',
    },
    'Vegetarian': {
      'en': 'Vegetarian',
      'kn': 'ಸಸ್ಯಾಹಾರಿ',
      'hi': 'शाकाहारी',
    },
    'Non-Veg': {
      'en': 'Non-Veg',
      'kn': 'ಮಾಂಸಾಹಾರಿ',
      'hi': 'मांसाहारी',
    },
  };

  // Recipe Titles Translations (English -> Kannada / Hindi)
  static const Map<String, Map<String, String>> recipeTitles = {
    'Akki Rotti': {'en': 'Akki Rotti', 'kn': 'ಅಕ್ಕಿ ರೊಟ್ಟಿ', 'hi': 'अक्की रोटी'},
    'Kadubu (Moode)': {'en': 'Kadubu (Moode)', 'kn': 'ಕಡುಬು (ಮೂಡೆ)', 'hi': 'कडुबू (मूडे)'},
    'Halasina Hannina Kadubu': {'en': 'Halasina Hannina Kadubu', 'kn': 'ಹಲಸಿನ ಹಣ್ಣಿನ ಕಡುಬು', 'hi': 'कटहल का कडुबू'},
    'Kotte Kadubu': {'en': 'Kotte Kadubu', 'kn': 'ಕೊಟ್ಟೆ ಕಡುಬು', 'hi': 'कोट्टे कडुबू'},
    'Benne Dosa': {'en': 'Benne Dosa', 'kn': 'ಬೆಣ್ಣೆ ದೋಸೆ', 'hi': 'बटर डोसा'},
    'Neer Dosa': {'en': 'Neer Dosa', 'kn': 'ನೀರ್ ದೋಸೆ', 'hi': 'नीर डोसा'},
    'Ragi Rotti': {'en': 'Ragi Rotti', 'kn': 'ರಾಗಿ ರೊಟ್ಟಿ', 'hi': 'रागी रोटी'},
    'Jolada Rotti': {'en': 'Jolada Rotti', 'kn': 'ಜೋಳದ ರೊಟ್ಟಿ', 'hi': 'ज्वार की रोटी'},
    'Uppittu (Malnad Style Upma)': {'en': 'Uppittu (Malnad Style Upma)', 'kn': 'ಮಲೆನಾಡು ಉಪ್ಪಿಟ್ಟು', 'hi': 'मलनाड उपमा'},
    'Shavige Uppittu': {'en': 'Shavige Uppittu', 'kn': 'ಶಾವಿಗೆ ಉಪ್ಪಿಟ್ಟು', 'hi': 'सेवई उपमा'},
    'Avalakki Vangibath': {'en': 'Avalakki Vangibath', 'kn': 'ಅವಲಕ್ಕಿ ವಾಂಗಿಬಾತ್', 'hi': 'पोहा वांगीभात'},
    'Bisi Bele Bath': {'en': 'Bisi Bele Bath', 'kn': 'ಬಿಸಿಬೇಳೆ ಬಾತ್', 'hi': 'बिसी बेले भात'},
    'Vangi Bath': {'en': 'Vangi Bath', 'kn': 'ವಾಂಗಿ ಬಾತ್', 'hi': 'वांगी भात'},
    'Chitranna (Lemon Rice)': {'en': 'Chitranna (Lemon Rice)', 'kn': 'ಚಿತ್ರಾನ್ನ (ನಿಂಬೆಹಣ್ಣಿನ ಅನ್ನ)', 'hi': 'चित्रांना (लेमन राइस)'},
    'Mavinakayi Chitranna': {'en': 'Mavinakayi Chitranna', 'kn': 'ಮಾವಿನಕಾಯಿ ಚಿತ್ರಾನ್ನ', 'hi': 'कच्चे आम का चित्रांना'},
    'Puliyogare (Tamarind Rice)': {'en': 'Puliyogare (Tamarind Rice)', 'kn': 'ಪುಳಿಯೋಗರೆ', 'hi': 'पुलियोगरे (इमली चावल)'},
    'Kashaya': {'en': 'Kashaya', 'kn': 'ಮಲೆನಾಡು ಕಷಾಯ', 'hi': 'मलनाड कषाय (हर्बल टी)'},
    'Tambli (Brahmi / Ondelaga)': {'en': 'Tambli (Brahmi / Ondelaga)', 'kn': 'ಒಂದೆಲಗ ತಂಬುಳಿ', 'hi': 'ब्राह्मी तंबुली'},
    'Majjige Huli': {'en': 'Majjige Huli', 'kn': 'ಮಜ್ಜಿಗೆ ಹುಳಿ', 'hi': 'मज्जिगे हुली (छाछ कढ़ी)'},
    'Saaru (Rasam)': {'en': 'Saaru (Rasam)', 'kn': 'ಮಲೆನಾಡು ಸಾರು', 'hi': 'मलनाड रसम'},
    'Menasina Saaru (Pepper Rasam)': {'en': 'Menasina Saaru (Pepper Rasam)', 'kn': 'ಮೆಣಸಿನ ಸಾರು', 'hi': 'काली मिर्च रसम'},
    'Huruli Saaru (Horse Gram Rasam)': {'en': 'Huruli Saaru (Horse Gram Rasam)', 'kn': 'ಹುರುಳಿ ಸಾರು', 'hi': 'कुलथी रसम'},
    'Kootu': {'en': 'Kootu', 'kn': 'ಕೂಟು', 'hi': 'कूटू'},
    'Huli (Sambar)': {'en': 'Huli (Sambar)', 'kn': 'ಹುಳಿ (ಸಾಂಬಾರ್)', 'hi': 'सांभर'},
    'Malnad Chicken Curry': {'en': 'Malnad Chicken Curry', 'kn': 'ಮಲೆನಾಡು ಚಿಕನ್ ಸಾರು', 'hi': 'मलनाड चिकन करी'},
    'Kundapura Chicken Ghee Roast': {'en': 'Kundapura Chicken Ghee Roast', 'kn': 'ಕುಂದಾಪುರ ಚಿಕನ್ ತುಪ್ಪ ರೋಸ್ಟ್', 'hi': 'कुंदापुरा चिकन घी रोस्ट'},
    'Mutton Sukka': {'en': 'Mutton Sukka', 'kn': 'ಮಟನ್ ಸುಕ್ಕಾ', 'hi': 'मटन सुक्का'},
    'Koli Saaru': {'en': 'Koli Saaru', 'kn': 'ನಾಟಿ ಕೋಳಿ ಸಾರು', 'hi': 'देसी मुर्गा करी'},
    'Masala Dosa': {'en': 'Masala Dosa', 'kn': 'ಮಸಾಲೆ ದೋಸೆ', 'hi': 'मसाला डोसा'},
    'Mysore Masala Dosa': {'en': 'Mysore Masala Dosa', 'kn': 'ಮೈಸೂರು ಮಸಾಲೆ ದೋಸೆ', 'hi': 'मैसूर मसाला डोसा'},
    'Rava Dosa': {'en': 'Rava Dosa', 'kn': 'ರವಾ ದೋಸೆ', 'hi': 'रवा डोसा'},
    'Set Dosa': {'en': 'Set Dosa', 'kn': 'ಸೆಟ್ ದೋಸೆ', 'hi': 'सेट डोसा'},
    'Podi Dosa': {'en': 'Podi Dosa', 'kn': 'ಪೊಡಿ ದೋಸೆ', 'hi': 'पोड़ी डोसा'},
    'Idli Vada': {'en': 'Idli Vada', 'kn': 'ಇಡ್ಲಿ ವಡೆ', 'hi': 'इडली वड़ा'},
    'Rava Idli': {'en': 'Rava Idli', 'kn': 'ರವಾ ಇಡ್ಲಿ', 'hi': 'रवा इडली'},
    'Medu Vada': {'en': 'Medu Vada', 'kn': 'ಮೇದು ವಡೆ', 'hi': 'मेदु वड़ा'},
    'Poori Saagu': {'en': 'Poori Saagu', 'kn': 'ಪೂರಿ ಸಾಗು', 'hi': 'पूरी सागू'},
    'Aloo Paratha': {'en': 'Aloo Paratha', 'kn': 'ಆಲೂ ಪರೋಟ', 'hi': 'आलू पराठा'},
    'Paneer Butter Masala': {'en': 'Paneer Butter Masala', 'kn': 'ಪನೀರ್ ಬಟರ್ ಮಸಾಲಾ', 'hi': 'पनीर बटर मसाला'},
    'Palak Paneer': {'en': 'Palak Paneer', 'kn': 'ಪಾಲಕ್ ಪನೀರ್', 'hi': 'पालक पनीर'},
    'Dal Tadka': {'en': 'Dal Tadka', 'kn': 'ದಾಲ್ ತಡ್ಕಾ', 'hi': 'दाल तड़का'},
    'Dal Makhani': {'en': 'Dal Makhani', 'kn': 'ದಾಲ್ ಮಖನಿ', 'hi': 'दाल मखनी'},
    'Hyderabadi Chicken Biryani': {'en': 'Hyderabadi Chicken Biryani', 'kn': 'ಹೈದರಾಬಾದಿ ಚಿಕನ್ ಬಿರಿಯಾನಿ', 'hi': 'हैदराबादी चिकन बिरयानी'},
    'Veg Dum Biryani': {'en': 'Veg Dum Biryani', 'kn': 'ವೆಜ್ ದಮ್ ಬಿರಿಯಾನಿ', 'hi': 'वेज दम बिरयानी'},
    'Butter Chicken': {'en': 'Butter Chicken', 'kn': 'ಬಟರ್ ಚಿಕನ್', 'hi': 'बटर चिकन'},
    'Chicken Tikka': {'en': 'Chicken Tikka', 'kn': 'ಚಿಕನ್ ಟಿಕ್ಕಾ', 'hi': 'चिकन टिक्का'},
    'Samosa': {'en': 'Samosa', 'kn': 'ಸಮೋಸಾ', 'hi': 'समोसा'},
    'Onion Pakoda': {'en': 'Onion Pakoda', 'kn': 'ಈರುಳ್ಳಿ ಪಕೋಡ', 'hi': 'प्याज पकौड़ा'},
    'Pani Puri': {'en': 'Pani Puri', 'kn': 'ಪಾನಿ ಪುರಿ', 'hi': 'पानी पूरी'},
    'Masala Chai': {'en': 'Masala Chai', 'kn': 'ಮಸಾಲಾ ಚಹಾ', 'hi': 'मसाला चाय'},
    'Filter Coffee': {'en': 'Filter Coffee', 'kn': 'ಫಿಲ್ಟರ್ ಕಾಫಿ', 'hi': 'फिल्टर कॉफी'},
    'Mango Lassi': {'en': 'Mango Lassi', 'kn': 'ಮಾವಿನ ಲಸ್ಸಿ', 'hi': 'मैंगो लस्सी'},
    'Gulab Jamun': {'en': 'Gulab Jamun', 'kn': 'ಗುಲಾಬ್ ಜಾಮೂನ್', 'hi': 'गुलाब जामुन'},
    'Mysore Pak': {'en': 'Mysore Pak', 'kn': 'ಮೈಸೂರು ಪಾಕ್', 'hi': 'मैसूर पाक'},
    'Gajar Ka Halwa': {'en': 'Gajar Ka Halwa', 'kn': 'ಕ್ಯಾರೆಟ್ ಹಲ್ವಾ', 'hi': 'गाजर का हलवा'},
    'Payasa / Kheer': {'en': 'Payasa / Kheer', 'kn': 'ಪಾಯಸ / ಖೀರ್', 'hi': 'खीर'},
    'Ragi Mudde': {'en': 'Ragi Mudde', 'kn': 'ರಾಗಿ ಮುದ್ದೆ', 'hi': 'रागी मुड्डे'},
    'Masala Omelette': {'en': 'Masala Omelette', 'kn': 'ಮಸಾಲಾ ಆಮ್ಲೆಟ್', 'hi': 'मसाला ऑमलेट'},
  };

  /// Get localized category name
  static String getCategoryName(String originalName, String langCode) {
    final entry = categoryNames[originalName];
    if (entry != null && entry.containsKey(langCode)) {
      return entry[langCode]!;
    }
    return originalName;
  }

  /// Get localized recipe title
  static String getRecipeTitle(String originalTitle, String langCode) {
    final entry = recipeTitles[originalTitle];
    if (entry != null && entry.containsKey(langCode)) {
      return entry[langCode]!;
    }
    for (final e in recipeTitles.entries) {
      if (originalTitle.toLowerCase().contains(e.key.toLowerCase()) && e.value.containsKey(langCode)) {
        return e.value[langCode]!;
      }
    }
    return originalTitle;
  }

  /// Multilingual search matcher
  static bool matchesQuery(Recipe recipe, String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return true;

    // Check title in English
    if (recipe.title.toLowerCase().contains(q)) return true;

    // Check localized titles
    for (final langCode in ['kn', 'hi']) {
      final locTitle = getRecipeTitle(recipe.title, langCode).toLowerCase();
      if (locTitle.contains(q)) return true;
    }

    // Check any dictionary entry matching recipe title
    for (final entry in recipeTitles.entries) {
      if (recipe.title.toLowerCase().contains(entry.key.toLowerCase())) {
        for (final langCode in ['kn', 'hi']) {
          final translated = entry.value[langCode];
          if (translated != null && translated.toLowerCase().contains(q)) {
            return true;
          }
        }
      }
    }

    // Check tags
    if (recipe.tags.any((t) => t.toLowerCase().contains(q))) return true;

    // Check cuisine & region
    if (recipe.cuisine.toLowerCase().contains(q)) return true;
    if (recipe.region.toLowerCase().contains(q)) return true;

    // Check ingredients
    if (recipe.ingredients.any((i) => i.name.toLowerCase().contains(q))) return true;

    return false;
  }
}

extension LocalizedRecipeExtension on Recipe {
  String localizedTitle(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return RecipeTranslations.getRecipeTitle(title, locale.languageCode);
  }

  String localizedTitleByCode(String langCode) {
    return RecipeTranslations.getRecipeTitle(title, langCode);
  }
}

extension LocalizedCategoryExtension on Category {
  String localizedName(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return RecipeTranslations.getCategoryName(name, locale.languageCode);
  }

  String localizedNameByCode(String langCode) {
    return RecipeTranslations.getCategoryName(name, langCode);
  }
}
