// ignore_for_file: avoid_print
import 'package:lexactivator/lexactivator.dart';

void main() {
  try {
    initializeLexActivator();
    LexActivator.SetLicenseCallback(callback: licenseCallback);
    final status = LexActivator.IsLicenseGenuine();
    if (LexStatusCodes.LA_OK == status) {
      print('License is genuinely activated!');

      final expiryDate = LexActivator.GetLicenseExpiryDate();
      final daysLeft = (DateTime.fromMillisecondsSinceEpoch(expiryDate * 1000))
          .difference(DateTime.now())
          .inDays;
      print('Days left: $daysLeft');

      final userName = LexActivator.GetLicenseUserName();
      print('License user name: $userName');
    } else if (LexStatusCodes.LA_EXPIRED == status) {
      print('License is genuinely activated but has expired!');
    } else if (LexStatusCodes.LA_SUSPENDED == status) {
      print('License is genuinely activated but has been suspended!');
    } else if (LexStatusCodes.LA_GRACE_PERIOD_OVER == status) {
      print('License is genuinely activated but grace period is over!');
    } else {
      final trialStatus = LexActivator.IsTrialGenuine();
      if (LexStatusCodes.LA_OK == trialStatus) {
        final expiryDate = LexActivator.GetTrialExpiryDate();
        final daysLeft =
            (DateTime.fromMillisecondsSinceEpoch(expiryDate * 1000))
                .difference(DateTime.now())
                .inDays;
        print('Trial days left: $daysLeft');
      } else if (LexStatusCodes.LA_TRIAL_EXPIRED == trialStatus) {
        print('Trial has expired!');
        // Time to buy the license and activate the app
        activateLicense();
      } else {
        print('Either trial has not started or has been tampered!');
        // Activating the trial
        activateTrial();
      }
    }

    // Checking for software release update
    // Call SetReleasePlatform() and SetReleaseChannel() before calling CheckReleaseUpdate()
    // Release platform and channel must be set before checking for an update
    LexActivator.SetReleasePlatform(releasePlatform: 'RELEASE_PLATFORM');
    LexActivator.SetReleaseChannel(releaseChannel: 'RELEASE_CHANNEL');
    // LexActivator.CheckReleaseUpdate(releaseUpdateCallback: releaseUpdateCallback, flag: LexActivator.LA_RELEASES_ALL, userData: null);
  } on LexActivatorException catch (e) {
    print(e);
  }
}

///Initialize function is always called at the start of your application or within
///the scope of use of LexActivator
void initializeLexActivator() {
  LexActivator.SetProductData(productData: "PASTE_CONTENT_OF_PRODUCT.DAT_FILE");

  LexActivator.SetProductId(
      productId: "SET_PRODUCT_ID", flags: LexActivator.LA_USER);

  LexActivator.SetReleaseVersion(releaseVersion: 'PASTE_YOUR_RELEASE_VERSION');
}

///Activation function is called once when license is to be activated. Calling this function
///again is not required.
void activateLicense() {
  LexActivator.SetLicenseKey(licenseKey: 'SET_LICENSE_KEY');
  final status = LexActivator.ActivateLicense();
  print('License activation status: $status');
  if (LexStatusCodes.LA_OK == status) {
    print('License activated successfully!');
  } else if (LexStatusCodes.LA_EXPIRED == status) {
    print('License activated successfully but has expired!');
  } else if (LexStatusCodes.LA_SUSPENDED == status) {
    print('License activated successfully but has been suspended!');
  }
}

void activateTrial() {
  LexActivator.SetTrialActivationMetadata(
      key: 'Trial Metadata 1', value: 'Value 1');
  final status = LexActivator.ActivateTrial();
  if (LexStatusCodes.LA_OK == status) {
    print('Product trial activated successfully!');
  } else if (LexStatusCodes.LA_TRIAL_EXPIRED == status) {
    print('Product trial has expired!');
  } else {
    print('Product trial activation failed: $status');
  }
}

void licenseCallback(int status) {
  try {
    switch (status) {
      case LexStatusCodes.LA_OK:
        print('License is genuinely activated!');
        break;
      case LexStatusCodes.LA_EXPIRED:
        print('License is genuinely activated but has expired!');
        break;
      case LexStatusCodes.LA_SUSPENDED:
        print('License is genuinely activated but has been suspended!');
        break;
      case LexStatusCodes.LA_GRACE_PERIOD_OVER:
        print('License is genuinely activated but grace period is over!');
        break;
      default:
        throw LexActivatorException(status);
    }
  } catch (error) {
    print(error.toString());
  }
}
