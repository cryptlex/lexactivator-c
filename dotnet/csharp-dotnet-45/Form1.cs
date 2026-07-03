using System;
using System.Text;
using System.Windows.Forms;
using Cryptlex;

namespace Sample
{
    public partial class ActivationForm : Form
    {
        public ActivationForm()
        {
            InitializeComponent();
            try
            {
                // LexActivator.SetProductFile ("ABSOLUTE_PATH_OF_PRODUCT.DAT_FILE");
                LexActivator.SetProductData("PASTE_CONTENT_OF_PRODUCT.DAT_FILE");
                LexActivator.SetProductId("PASTE_PRODUCT_ID", LexActivator.PermissionFlags.LA_USER);
                // LexActivator.SetLicenseCallback(LicenseCallback);

                int status = LexActivator.IsLicenseGenuine();
                if (status == LexStatusCodes.LA_OK || status == LexStatusCodes.LA_EXPIRED || status == LexStatusCodes.LA_SUSPENDED || status == LexStatusCodes.LA_GRACE_PERIOD_OVER)
                {
                    uint expiryDate = LexActivator.GetLicenseExpiryDate();
                    int daysLeft = (int)(expiryDate - unixTimestamp()) / 86400;
                    this.statusLabel.Text = "License genuinely activated! Activation Status: " + status.ToString();
                    this.activateBtn.Text = "Deactivate";
                    this.activateTrialBtn.Enabled = false;
                    return;
                }
                status = LexActivator.IsTrialGenuine();
                if (status == LexStatusCodes.LA_OK)
                {
                    uint trialExpiryDate = LexActivator.GetTrialExpiryDate();
                    int daysLeft = (int)(trialExpiryDate - unixTimestamp()) / 86400;
                    this.statusLabel.Text = "Trial period! Days left:" + daysLeft.ToString();
                    this.activateTrialBtn.Enabled = false;
                }
                else if (status == LexStatusCodes.LA_TRIAL_EXPIRED)
                {
                    this.statusLabel.Text = "Trial has expired!";
                }
                else
                {
                    this.statusLabel.Text = "Trial has not started or has been tampered: " + status.ToString();
                }

                // Checking for software release update
                // Call SetReleasePlatform() and SetReleaseChannel() before calling CheckForReleaseUpdate()
                // Release platform and channel must be set before checking for an update
                // LexActivator.SetReleasePlatform("RELEASE_PLATFORM");
                // LexActivator.SetReleaseChannel("RELEASE_CHANNEL");
                // LexActivator.CheckForReleaseUpdate("windows", "1.0.0", "stable", SoftwareReleaseUpdateCallback);
            }
            catch (LexActivatorException ex)
            {
                this.statusLabel.Text = "Error code: " + ex.Code.ToString() + " Error message: " + ex.Message;
            }
        }

        private void activateBtn_Click(object sender, EventArgs e)
        {
            try
            {
                int status;
                if (this.activateBtn.Text == "Deactivate")
                {
                    status = LexActivator.DeactivateLicense();
                    if (status == LexStatusCodes.LA_OK)
                    {
                        this.statusLabel.Text = "License deactivated successfully";
                        this.activateBtn.Text = "Activate";
                        this.activateTrialBtn.Enabled = true;
                        return;
                    }
                    this.statusLabel.Text = "Error deactivating license: " + status.ToString();
                    return;
                }
                LexActivator.SetLicenseKey(productKeyBox.Text);
                LexActivator.SetActivationMetadata("key1", "value1");
                status = LexActivator.ActivateLicense();
                if (status == LexStatusCodes.LA_OK || status == LexStatusCodes.LA_EXPIRED || status == LexStatusCodes.LA_SUSPENDED)
                {
                    this.statusLabel.Text = "Activation Successful :" + status.ToString();
                    this.activateBtn.Text = "Deactivate";
                    this.activateTrialBtn.Enabled = false;
                }
                else
                {
                    this.statusLabel.Text = "Error activating the license: " + status.ToString();
                    return;
                }
            }
            catch (LexActivatorException ex)
            {
                this.statusLabel.Text = "Error code: " + ex.Code.ToString() + " Error message: " + ex.Message;
            }
        }

        private void activateTrialBtn_Click(object sender, EventArgs e)
        {
            try
            {
                LexActivator.SetTrialActivationMetadata("key2", "value2");
                int status = LexActivator.ActivateTrial();
                if (status != LexStatusCodes.LA_OK)
                {
                    this.statusLabel.Text = "Error activating the trial: " + status.ToString();
                    return;
                }
                else
                {
                    this.statusLabel.Text = "Trial started Successful";
                }
            }
            catch (LexActivatorException ex)
            {
                this.statusLabel.Text = "Error code: " + ex.Code.ToString() + " Error message: " + ex.Message;
            }
            
        }

        // License callback is invoked when LexActivator.IsLicenseGenuine() completes a server sync
        private void LicenseCallback(uint status)
        {
            // NOTE: Don't invoke IsLicenseGenuine(), ActivateLicense() or ActivateTrial() API functions in this callback
            switch (status)
            {
                case LexStatusCodes.LA_SUSPENDED:
                    this.statusLabel.Text = "The license has been suspended.";
                    break;
                default:
                    this.statusLabel.Text = "License status code: " + status.ToString();
                    break;
            }
        }

        // Software release update callback is invoked when CheckForReleaseUpdate() gets a response from the server
        private void SoftwareReleaseUpdateCallback(uint status)
        {
            switch (status)
            {
                case LexStatusCodes.LA_RELEASE_UPDATE_AVAILABLE:
                    this.statusLabel.Text = "An update is available for the app.";
                    break;
                case LexStatusCodes.LA_RELEASE_NO_UPDATE_AVAILABLE:
                    // Current version is already latest.
                    break;
                default:
                    this.statusLabel.Text = "Release status code: " + status.ToString();
                    break;
            }
        }

        private uint unixTimestamp()
        {
            return (uint)(DateTime.UtcNow.Subtract(new DateTime(1970, 1, 1))).TotalSeconds;
        }
    }
}
