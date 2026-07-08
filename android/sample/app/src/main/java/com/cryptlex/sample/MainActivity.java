package com.cryptlex.sample;

import com.cryptlex.android.lexactivator.LexActivator;
import com.cryptlex.android.lexactivator.LexActivatorException;
import androidx.appcompat.app.AppCompatActivity;
import android.os.Bundle;
import android.view.View;
import android.widget.TextView;
import com.google.android.material.textfield.TextInputEditText;

public class MainActivity extends AppCompatActivity {
    private TextView statusTextView;
    private TextInputEditText licenseKeyEditBox;

    private void initLexActivator() throws LexActivatorException {
        LexActivator.SetProductData("PASTE_PRODUCT_DATA_HERE");
        LexActivator.SetProductId("PASTE_PRODUCT_ID_HERE", LexActivator.LA_USER);
    }

    public void activateLicense(View view) {
        try {
            String licenseKey = licenseKeyEditBox.getText() == null ? "" : licenseKeyEditBox.getText().toString().trim();
            if (licenseKey.isEmpty()) {
                statusTextView.setText("Please enter a license key.");
                return;
            }
            LexActivator.SetLicenseKey(licenseKey);
            LexActivator.SetActivationMetadata("key1", "value1");
            LexActivator.SetActivationMetadata("key2", "value2");
            int status = LexActivator.ActivateLicense();
            if (LexActivator.LA_OK == status || LexActivator.LA_EXPIRED == status || LexActivator.LA_SUSPENDED == status) {
                statusTextView.setText("License activated successfully: " + status);
            } else {
                statusTextView.setText("License activation failed: " + status);
            }
        } catch (LexActivatorException ex) {
            statusTextView.setText("License activation failed! Error code: " + ex.getCode() + " Error message: " + ex.getMessage());
        } catch (Exception ex) {
            statusTextView.setText("License activation failed! Error message: " + ex.getMessage());
        }
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        statusTextView = (TextView) findViewById(R.id.statusTextView);
        licenseKeyEditBox = (TextInputEditText) findViewById(R.id.licenseInput);
        try {
            initLexActivator();
            int status = LexActivator.IsLicenseGenuine();
            if (LexActivator.LA_OK == status) {
                statusTextView.setText("License is genuinely activated!");
            } else if (LexActivator.LA_EXPIRED == status) {
                statusTextView.setText("License is genuinely activated but has expired!");
            } else if (LexActivator.LA_GRACE_PERIOD_OVER == status) {
                statusTextView.setText("License is genuinely activated but grace period is over!");
            } else if (LexActivator.LA_SUSPENDED == status) {
                statusTextView.setText("License is genuinely activated but has been suspended!");
            } else {
                statusTextView.setText("License is not activated. Error code: " + status);
            }

            // Checking for software release update
            // Call SetReleaseVersion(), SetReleasePlatform() and SetReleaseChannel() before calling CheckReleaseUpdate()
            // Release version, platform and channel must be set before checking for an update
            // LexActivator.SetReleasePlatform("RELEASE_PLATFORM");
            // LexActivator.SetReleaseChannel("RELEASE_CHANNEL");
            // LexActivator.CheckReleaseUpdate(releaseUpdateCallback, LexActivator.LA_RELEASES_ALL, null);
        } catch (LexActivatorException ex) {
            statusTextView.setText("Error code: " + ex.getCode() + " Error message: " + ex.getMessage());
        } catch (Exception ex) {
            statusTextView.setText("Error message: " + ex.getMessage());
        }
    }
}
