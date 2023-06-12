#include <stdio.h>
#include <stdlib.h>
#include <time.h>

// Uncomment following for Windows static build
/*
#if _WIN32
#define LEXACTIVATOR_STATIC
#pragma comment(lib, "winhttp")
#if _WIN64
#pragma comment(lib, "x64/libcurl_MD")
#pragma comment(lib, "x64/LexActivator")
#else
#pragma comment(lib, "x86/libcurl_MD")
#pragma comment(lib, "x86/LexActivator")
#endif
#endif
*/

#if _WIN32
#if _WIN64
#pragma comment(lib, "x64/LexActivator")
#else
#pragma comment(lib, "x86/LexActivator")
#endif
#endif

#include "LexActivator.h"

void init()
{
	int status;

#if _WIN32
	// status = SetProductFile(L"ABSOLUTE_PATH_OF_PRODUCT.DAT_FILE");
	status = SetProductData(L"PASTE_CONTENT_OF_PRODUCT.DAT_FILE");
#else
	//  status = SetProductFile("ABSOLUTE_PATH_OF_PRODUCT.DAT_FILE");
	status = SetProductData("PASTE_CONTENT_OF_PRODUCT.DAT_FILE");
#endif
	if (LA_OK != status)
	{
		printf("Error code: %d", status);
		getchar();
		exit(status);
	}

#if _WIN32
	status = SetProductId(L"PASTE_PRODUCT_ID", LA_USER);
#else
	status = SetProductId("PASTE_PRODUCT_ID", LA_USER);
#endif
	if (LA_OK != status)
	{
		printf("Error code: %d", status);
		getchar();
		exit(status);
	}
}

void setReleaseParams()
{
	int status;
	// Ensure that platform, channel and release actually exist for the release.
#if _WIN32
	status = SetReleasePlatform(L"RELEASE_PLATFORM");
#else
	status = SetReleasePlatform("RELEASE_PLATFORM"); // set the actual platform of the release e.g windows, macos, linux
#endif
	if (LA_OK != status)
	{
		printf("Error code: %d", status);
		getchar();
		exit(status);
	}

#if _WIN32
	status = SetReleaseChannel(L"RELEASE_CHANNEL");
#else
	status = SetReleaseChannel("RELEASE_CHANNEL"); // set the actual channel of the release e.g stable
#endif
	if (LA_OK != status)
	{
		printf("Error code: %d", status);
		getchar();
		exit(status);
	}

#if _WIN32
	status = SetReleaseVersion(L"1.2.3");
#else
	status = SetReleaseVersion("1.2.3");
#endif
	if (LA_OK != status)
	{
		printf("Error code: %d", status);
		getchar();
		exit(status);
	}
}

// License callback is invoked when IsLicenseGenuine() completes a server sync
void LA_CC LicenseCallback(uint32_t status)
{
	// NOTE: Don't invoke IsLicenseGenuine(), ActivateLicense() or ActivateTrial() API functions in this callback
	printf("\nLicense status: %d\n", status);
}

// Software release update callback is invoked when CheckReleaseUpdate() gets a response from the server
void LA_CC SoftwareReleaseUpdateCallback(int status, Release* release, void* custom_data)
{
	switch (status)
	{
	case LA_RELEASE_UPDATE_AVAILABLE:
		printf("A new update is available for the app.\n");
		printf("Release notes: %s\n", release->notes);
		break;

	case LA_RELEASE_UPDATE_AVAILABLE_NOT_ALLOWED:
		printf("A new update is available for the app but it's not allowed.\n");
		printf("Release notes: %s\n", release->notes);
		break;

	case LA_RELEASE_UPDATE_NOT_AVAILABLE:
		printf("Current version is already latest.\n");
		break;

	default:
		printf("Error code: %d\n", status);
	}
}

// Ideally on a button click inside a dialog
void activate()
{
	int status;
#if _WIN32
	status = SetLicenseKey(L"PASTE_LICENCE_KEY");
#else
	status = SetLicenseKey("PASTE_LICENCE_KEY");
#endif
	if (LA_OK != status)
	{
		printf("Error code: %d", status);
		getchar();
		exit(status);
	}

#if _WIN32
	status = SetActivationMetadata(L"key1", L"value1");
#else
	status = SetActivationMetadata("key1", "value1");
#endif
	if (LA_OK != status)
	{
		printf("Error code: %d", status);
		getchar();
		exit(status);
	}

	status = ActivateLicense();
	if (LA_OK == status || LA_EXPIRED == status || LA_SUSPENDED == status)
	{
		printf("License activated successfully: %d\n", status);
	}
	else
	{
		printf("License activation failed: %d", status);
	}
}

// Ideally on a button click inside a dialog
void activateTrial()
{
	int status;

#if _WIN32
	status = SetTrialActivationMetadata(L"key1", L"value1");
#else
	status = SetTrialActivationMetadata("key1", "value1");
#endif
	if (LA_OK != status)
	{
		printf("Error code: %d", status);
		getchar();
		exit(status);
	}

	status = ActivateTrial();
	if (LA_OK == status)
	{
		printf("Product trial activated successfully!");
	}
	else if (LA_TRIAL_EXPIRED == status)
	{
		printf("Product trial has expired!");
	}
	else
	{
		printf("Product trial activation failed: %d", status);
	}
}

int main()
{
	init();
	// Setting release params is required if CheckReleaseUpdate() is used, otherwise optional
	setReleaseParams();
	// Setting license callback is recommended for floating licenses
	// SetLicenseCallback(LicenseCallback);
	int status = IsLicenseGenuine();
	if (LA_OK == status)
	{
		unsigned int expiryDate = 0;
		GetLicenseExpiryDate(&expiryDate);
		int daysLeft = (expiryDate - time(NULL)) / 86400;
		printf("Days left: %d\n", daysLeft);
		printf("License is genuinely activated!\n");

		// Checking for software release update
		status = CheckReleaseUpdate(SoftwareReleaseUpdateCallback, LA_RELEASES_ALL, NULL);
		if (LA_OK != status)
		{
			printf("Error checking for software release update: %d", status);
		}
	}
	else if (LA_EXPIRED == status)
	{
		printf("License is genuinely activated but has expired!");
	}
	else if (LA_SUSPENDED == status)
	{
		printf("License is genuinely activated but has been suspended!");
	}
	else if (LA_GRACE_PERIOD_OVER == status)
	{
		printf("License is genuinely activated but grace period is over!");
	}
	else
	{
		int trialStatus;
		trialStatus = IsTrialGenuine();
		if (LA_OK == trialStatus)
		{
			unsigned int trialExpiryDate = 0;
			GetTrialExpiryDate(&trialExpiryDate);
			int daysLeft = (trialExpiryDate - time(NULL)) / 86400;
			printf("Trial days left: %d", daysLeft);
		}
		else if (LA_TRIAL_EXPIRED == trialStatus)
		{
			printf("Trial has expired!");

			// Time to buy the license and activate the app
			activate();
		}
		else
		{
			printf("Either trial has not started or has been tampered!");
			// Activating the trial
			activateTrial();
		}
	}
	getchar();
	return 0;
}
