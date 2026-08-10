using System;
using Cryptlex;

namespace Sample
{
    class Program
    {
        static void Init()
        {
            LexActivator.SetProductData("PASTE_CONTENT_OF_PRODUCT.DAT_FILE");
            LexActivator.SetProductId("PASTE_PRODUCT_ID", LexActivator.PermissionFlags.LA_USER);
            LexActivator.SetReleaseVersion("1.0.0");  // Set this to the release version of your app
        }

        static void Activate()
        {
            LexActivator.SetLicenseKey("PASTE_LICENSE_KEY");
            LexActivator.SetActivationMetadata("key1", "value1");
            int status = LexActivator.ActivateLicense();
            if (LexStatusCodes.LA_OK == status || LexStatusCodes.LA_EXPIRED == status || LexStatusCodes.LA_SUSPENDED == status)
            {
                Console.WriteLine("License activated successfully: {0}", status);
            }
            else
            {
                Console.WriteLine("License activation failed: {0}", status);
            }
        }
        static void Main(string[] args)
        {
            try
            {
                Init();
                LexActivator.SetLicenseCallback(LicenseCallback);
                int status = LexActivator.IsLicenseGenuine();
                if (LexStatusCodes.LA_OK == status)
                {
                    Console.WriteLine("License is genuinely activated!");
                    uint expiryDate = LexActivator.GetLicenseExpiryDate();
                    int daysLeft = (int)(expiryDate - DateTimeOffset.Now.ToUnixTimeSeconds()) / 86400;
                    Console.WriteLine("Days left:" + daysLeft);
                }
                else if (LexStatusCodes.LA_EXPIRED == status)
                {
                    Console.WriteLine("License is genuinely activated but has expired!");
                }
                else if (LexStatusCodes.LA_GRACE_PERIOD_OVER == status)
                {
                    Console.WriteLine("License is genuinely activated but grace period is over!");
                }
                else if (LexStatusCodes.LA_SUSPENDED == status)
                {
                    Console.WriteLine("License is genuinely activated but has been suspended!");
                }
                else
                {
                    int trialStatus;
                    trialStatus = LexActivator.IsTrialGenuine();
                    if (LexStatusCodes.LA_OK == trialStatus)
                    {
                        uint trialExpiryDate = LexActivator.GetTrialExpiryDate();
                        int daysLeft = (int)(trialExpiryDate - DateTimeOffset.Now.ToUnixTimeSeconds()) / 86400;
                        Console.WriteLine("Trial days left: " + daysLeft);
                    }
                    else if (LexStatusCodes.LA_TRIAL_EXPIRED == trialStatus)
                    {
                        Console.WriteLine("Trial has expired!");

                        // Time to buy the product key and activate the app
                        Activate();
                    }
                    else
                    {
                        Console.WriteLine("Either trial has not started or has been tampered!");
                        // Activating the trial
                        trialStatus = LexActivator.ActivateTrial(); // Ideally on a button click inside a dialog
                        if (LexStatusCodes.LA_OK == trialStatus)
                        {
                            uint trialExpiryDate = LexActivator.GetTrialExpiryDate();
                            int daysLeft = (int)(trialExpiryDate - DateTimeOffset.Now.ToUnixTimeSeconds()) / 86400;
                            Console.WriteLine("Trial days left: " + daysLeft);
                        }
                        else
                        {
                            // Trial was tampered or has expired
                            Console.WriteLine("Trial activation failed: " + trialStatus);
                        }
                    }
                }

                // Checking for software release update
                // Call SetReleaseVersion(), SetReleasePlatform() and SetReleaseChannel() before calling CheckReleaseUpdate()
                // Release version, platform and channel must be set before checking for an update
                // LexActivator.SetReleasePlatform("RELEASE_PLATFORM");
                // LexActivator.SetReleaseChannel("RELEASE_CHANNEL");
                // LexActivator.CheckReleaseUpdate(SoftwareReleaseUpdateCallback, LexActivator.ReleaseFlags.LA_RELEASES_ALL, null);
            }
            catch (LexActivatorException ex)
            {
                Console.WriteLine("Error code: " + ex.Code.ToString() + " Error message: " + ex.Message);
            }
            Console.WriteLine("Press any key to exit");
            Console.ReadKey();
        }

        // License callback is invoked when LexActivator.IsLicenseGenuine() completes a server sync
        static void LicenseCallback(uint status)
        {
            // NOTE: Don't invoke IsLicenseGenuine(), ActivateLicense() or ActivateTrial() API functions in this callback
            switch (status)
            {
                case LexStatusCodes.LA_OK:
                    Console.WriteLine("The license is genuinely activated.");
                    break;
                case LexStatusCodes.LA_EXPIRED:
                    Console.WriteLine("The license has expired.");
                    break;
                case LexStatusCodes.LA_SUSPENDED:
                    Console.WriteLine("The license has been suspended.");
                    break;
                case LexStatusCodes.LA_GRACE_PERIOD_OVER:
                    Console.WriteLine("The license grace period is over.");
                    break;
                case LexStatusCodes.LA_E_REVOKED:
                    Console.WriteLine("The license has been revoked.");
                    break;
                default:
                    Console.WriteLine("License status code: " + status.ToString());
                    break;
            }
        }

        // Software release update callback is invoked when CheckReleaseUpdate() gets a response from the server
        static void SoftwareReleaseUpdateCallback(uint status, Release release, object userData)
        {
            switch (status)
            {
                case LexStatusCodes.LA_RELEASE_UPDATE_AVAILABLE:
                    Console.WriteLine("A new update is available for the app!");
                    Console.WriteLine("Release Notes: "+ release.Notes);
                    break;
                case LexStatusCodes.LA_RELEASE_UPDATE_AVAILABLE_NOT_ALLOWED:
                    Console.WriteLine("A new update is available for the app but it's not allowed!");
                    Console.WriteLine("Release: "+ release.Notes);
                    break;
                case LexStatusCodes.LA_RELEASE_UPDATE_NOT_AVAILABLE:
                    Console.WriteLine("Current version is already latest!");
                    break;
                default:
                    Console.WriteLine("Error code: " + status.ToString());
                    break;
            }
        }
    }
}
