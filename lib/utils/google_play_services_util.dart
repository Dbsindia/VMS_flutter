import 'package:flutter/material.dart';
import 'package:google_api_availability/google_api_availability.dart';

Future<void> ensureGooglePlayServices(BuildContext context) async {
  try {
    // Check Google Play Services availability
    GooglePlayServicesAvailability availability =
        await GoogleApiAvailability.instance.checkGooglePlayServicesAvailability();

    // Handle if Google Play Services is not available
    if (availability != GooglePlayServicesAvailability.success) {
      await GoogleApiAvailability.instance.makeGooglePlayServicesAvailable();
    }
  } catch (e) {
    debugPrint("Google Play services error: $e");
  }
}
