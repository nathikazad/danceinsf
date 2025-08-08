String site = "mx";
const String environment = "production";
const double mobileWidth = 600;
String get currency => site == 'mx' ? 'MXN' : 'USD';
int get coursePrice => site == 'mx' ? 999 : 49;

String get publishableKey {
  if (environment == 'production') {
    return 'pk_live_51RgHPRLJnsZs2OSOPjhgLbesRrDx7LDzEdVuJnOOmAyo8LpyP0KvCHyLyOsmxBJlmgD9Z5VUtAi9OOdkCNegilRT00HRsZ6jNH';
  } else {
    return 'pk_test_51RgHPYQ3gDIZndwWrWx1aNclnFjsh6E3v01vBdNZAfqMEw1ZEAshkauhbtObKB7F3U9OVp7RNpgMhJy7uT2NcV6U00KQIWykjt';
  }
}
// const String stripeAccountId = 'acct_1Ro1fcQ3gDiXwojs';
const Map<String, String> courseMetadata = {
  'course_name': 'Bachata Course',
  'course_id': '1',
  'payment_type': 'course',
};