package com.cryptlex.sample;

import com.cryptlex.lexactivator.LexActivator;
import com.cryptlex.lexactivator.LicenseCallbackEvent;
import com.cryptlex.lexactivator.ReleaseUpdateCallbackEvent;
import com.cryptlex.lexactivator.Release;
import com.cryptlex.lexactivator.LexActivatorException;
import java.time.Instant;

public class Sample {

    static void init() throws LexActivatorException {
        LexActivator.SetProductData("PASTE_CONTENT_OF_PRODUCT.DAT_FILE");
        LexActivator.SetProductId("PASTE_PRODUCT_ID", LexActivator.LA_USER);
        LexActivator.SetReleaseVersion("1.0.0");  // Set this to the release version of your app
    }

    static void activate() throws LexActivatorException {
        LexActivator.SetLicenseKey("PASTE_LICENSE_KEY");
        LexActivator.SetActivationMetadata("key1", "value1");
        int status = LexActivator.ActivateLicense();
        if (LexActivator.LA_OK == status || LexActivator.LA_EXPIRED == status
                || LexActivator.LA_SUSPENDED == status) {
            System.out.println("License activated successfully: " + status);
        } else {
            System.out.println("License activation failed: " + status);
        }
    }

    public static void main(String[] args) {
        int status;
        try {
            init();
            // Setting license callback is recommended for floating licenses
            // LicenseCallbackEventListener licenseEventListener = new LicenseCallbackEventListener();
            // LexActivator.SetLicenseCallbackListener(licenseEventListener);
            status = LexActivator.IsLicenseGenuine();
            if (LexActivator.LA_OK == status) {
                System.out.println("License is genuinely activated!");
            } else if (LexActivator.LA_EXPIRED == status) {
                System.out.println("License is genuinely activated but has expired!");
            } else if (LexActivator.LA_GRACE_PERIOD_OVER == status) {
                System.out.println("License is genuinely activated but grace period is over!");
            } else if (LexActivator.LA_SUSPENDED == status) {
                System.out.println("License is genuinely activated but has been suspended!");
            } else {
                int trialStatus;
                trialStatus = LexActivator.IsTrialGenuine();
                if (LexActivator.LA_OK == trialStatus) {
                    int trialExpiryDate = LexActivator.GetTrialExpiryDate();
                    long daysLeft = (trialExpiryDate - Instant.now().getEpochSecond()) / 86400;
                    System.out.println("Trial days left: " + daysLeft);
                } else if (LexActivator.LA_TRIAL_EXPIRED == trialStatus) {
                    System.out.println("Trial has expired!");
                    // Time to buy the product key and activate the app
                    activate();
                } else {
                    System.out.println("Either trial has not started or has been tampered!");
                    // Activating the trial
                    trialStatus = LexActivator.ActivateTrial(); // Ideally on a button click inside a dialog
                    if (LexActivator.LA_OK == trialStatus) {
                        int trialExpiryDate = LexActivator.GetTrialExpiryDate();
                        long daysLeft = (trialExpiryDate - Instant.now().getEpochSecond()) / 86400;
                        System.out.println("Trial days left: " + daysLeft);
                    } else {
                        // Trial was tampered or has expired
                        System.out.println("Trial activation failed: " + trialStatus);
                    }
                }
            }

            // Checking for software release update
            // Call SetReleaseVersion(), SetReleasePlatform() and SetReleaseChannel() before calling CheckReleaseUpdate()
            // Release version, platform and channel must be set before checking for an update
            // LexActivator.SetReleasePlatform("RELEASE_PLATFORM");
            // LexActivator.SetReleaseChannel("RELEASE_CHANNEL");
            // ReleaseUpdateCallbackEventListener releaseUpdateEventListener = new ReleaseUpdateCallbackEventListener();
            // LexActivator.CheckReleaseUpdate(releaseUpdateEventListener, LexActivator.LA_RELEASES_ALL, null);

        } catch (LexActivatorException ex) {
            System.out.println(ex.getCode() + ": " + ex.getMessage());
        }
    }

}

class LicenseCallbackEventListener implements LicenseCallbackEvent {

    // License callback is invoked when IsLicenseGenuine() completes a server sync
    @Override
    public void LicenseCallback(int status) {
        switch (status) {
            case LexActivator.LA_OK:
                System.out.println("The license is genuinely activated.");
                break;
            case LexActivator.LA_EXPIRED:
                System.out.println("The license has expired.");
                break;
            case LexActivator.LA_SUSPENDED:
                System.out.println("The license has been suspended.");
                break;
            case LexActivator.LA_GRACE_PERIOD_OVER:
                System.out.println("The license grace period is over.");
                break;
            case LexActivatorException.LA_E_REVOKED:
                System.out.println("The license has been revoked.");
                break;
            case LexActivatorException.LA_E_INET:
                System.out.println("Network connection failure.");
                break;
            default:
                System.out.println("License status: " + status);
                break;
        }
    }
}

class ReleaseUpdateCallbackEventListener implements ReleaseUpdateCallbackEvent {
    // Release update callback is invoked when CheckReleaseUpdate() gets a response from the server
    @Override
    public void ReleaseUpdateCallback(int status, Release release, Object userData) {
        switch (status) {
            case LexActivator.LA_RELEASE_UPDATE_AVAILABLE:
                System.out.println("A new update is available for the app!\n");
                System.out.println("Release notes: " + release.notes);
                break;
            case LexActivator.LA_RELEASE_UPDATE_AVAILABLE_NOT_ALLOWED:
                System.out.println("A new update is available for the app but it's not allowed!\n");
                System.out.println("Release notes: " + release.notes);
                break;
            case LexActivator.LA_RELEASE_UPDATE_NOT_AVAILABLE:
                System.out.println("Current version is already the latest!\n");
                break;
            default:
                System.out.println("Error code: " + status);
        }
    }
}

