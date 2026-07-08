package main

import (
	"bufio"
	"fmt"
	"os"

	"github.com/cryptlex/lexactivator-go"
)

// server sync license callback
func licenseCallback(status int) {
	if status == lexactivator.LA_OK {
		fmt.Println("License is genuinely activated.")
	} else if status == lexactivator.LA_EXPIRED {
		fmt.Println("License is genuinely activated, but has expired")
	} else if status == lexactivator.LA_SUSPENDED {
		fmt.Println("License is genuinely activated, but has been suspended")
	} else {
		fmt.Println("License error status:", status)
	}
}

func softwareReleaseUpdateCallback(status int, release *lexactivator.Release, userData interface{}) {
	if status == lexactivator.LA_RELEASE_UPDATE_AVAILABLE {
		fmt.Println("A new update is available for the app!")
		fmt.Println("Release notes: ", release.Notes)
	} else if status == lexactivator.LA_RELEASE_UPDATE_AVAILABLE_NOT_ALLOWED {
		fmt.Println("A new update is available for the app but it's not allowed!")
		fmt.Println("Release notes: ", release.Notes)
	} else if status == lexactivator.LA_RELEASE_UPDATE_NOT_AVAILABLE {
		fmt.Println("Current version is already latest!")
	} else {
		fmt.Println("Error code: ", status)
	}
}

func initData() {
	var status int
	status = lexactivator.SetProductData("PASTE_CONTENT_OF_PRODUCT.DAT_FILE")
	if lexactivator.LA_OK != status {
		fmt.Println("Error Code:", status)
		os.Exit(1)
	}

	status = lexactivator.SetProductId("PASTE_PRODUCT_ID", lexactivator.LA_USER)
	if lexactivator.LA_OK != status {
		fmt.Println("Error Code:", status)
		os.Exit(1)
	}
	// Set this to the release version of your app
	status = lexactivator.SetReleaseVersion("1.0.0")
	if lexactivator.LA_OK != status {
		fmt.Println("Error Code:", status)
		os.Exit(1)
	}

}

func activate() {
	var status int
	status = lexactivator.SetLicenseKey("PASTE_LICENSE_KEY")
	if lexactivator.LA_OK != status {
		fmt.Println("Error Code:", status)
		os.Exit(1)
	}

	status = lexactivator.SetActivationMetadata("key1", "value1")
	if lexactivator.LA_OK != status {
		fmt.Println("Error Code:", status)
		os.Exit(1)
	}

	status = lexactivator.ActivateLicense()
	if lexactivator.LA_OK == status || lexactivator.LA_EXPIRED == status || lexactivator.LA_SUSPENDED == status {
		fmt.Println("License activated successfully:", status)
	} else {
		fmt.Println("License activation failed:", status)
	}
}

func activateTrial() {
	var status int
	status = lexactivator.SetTrialActivationMetadata("key1", "value1")
	if lexactivator.LA_OK != status {
		fmt.Println("Error Code:", status)
		os.Exit(1)
	}

	status = lexactivator.ActivateTrial()
	if lexactivator.LA_OK == status {
		fmt.Println("Product trial activated successfully!")
	} else if lexactivator.LA_TRIAL_EXPIRED == status {
		fmt.Println("Product trial has expired!")
	} else {
		fmt.Println("Product trial activation failed:", status)
	}
}

func main() {
	initData()
	var status int
	lexactivator.SetLicenseCallback(licenseCallback)
	status = lexactivator.IsLicenseGenuine()
	if lexactivator.LA_OK == status {
		var expiryDate uint
		lexactivator.GetLicenseExpiryDate(&expiryDate)
		fmt.Println("License expiry timestamp:", expiryDate)
		fmt.Println("License is genuinely activated!")
	} else if lexactivator.LA_EXPIRED == status {
		fmt.Println("License is genuinely activated but has expired!")
	} else if lexactivator.LA_SUSPENDED == status {
		fmt.Println("License is genuinely activated but has been suspended!")
	} else if lexactivator.LA_GRACE_PERIOD_OVER == status {
		fmt.Println("License is genuinely activated but grace period is over!")
	} else {
		var trialStatus int
		trialStatus = lexactivator.IsTrialGenuine()
		if lexactivator.LA_OK == trialStatus {
			var trialExpiryDate uint
			lexactivator.GetTrialExpiryDate(&trialExpiryDate)
			fmt.Println("Trial expiry timestamp:", trialExpiryDate)
		} else if lexactivator.LA_TRIAL_EXPIRED == trialStatus {
			fmt.Println("Trial has expired!")

			// Time to buy the license and activate the app
			activate()
		} else {
			fmt.Println("Either trial has not started or has been tampered!")
			// Activating the trial
			activateTrial()
		}
	}
	// Checking for software release update
	// Call SetReleaseVersion(), SetReleasePlatform() and SetReleaseChannel() before calling CheckReleaseUpdate()
	// Release version, platform and channel must be set before checking for an update
	// if lexactivator.LA_OK != status {
	// 	fmt.Println("Error Code:", status)
	// 	os.Exit(1)
	// }
	// status = lexactivator.SetReleaseChannel("RELEASE_CHANNEL")
	// if lexactivator.LA_OK != status {
	// 	fmt.Println("Error Code:", status)
	// 	os.Exit(1)
	// }
	// status = lexactivator.CheckReleaseUpdate(softwareReleaseUpdateCallback, lexactivator.LA_RELEASES_ALL, nil);
	// if lexactivator.LA_OK != status {
	// 	fmt.Println("Error Code:", status)
	// 	os.Exit(1)
	// }

	fmt.Println("Press Enter to exit...")
	bufio.NewReader(os.Stdin).ReadString('\n')
}
