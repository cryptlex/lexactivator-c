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

#if _WIN32
	status = SetAppVersion(L"PASTE_YOUR_APP_VERION");
#else
	status = SetAppVersion("PASTE_YOUR_APP_VERION");
#endif
	if (LA_OK != status)
	{
		printf("Error code: %d", status);
		getchar();
		exit(status);
	}
}

// License callback is invoked when IsProductGenuine() completes a server sync
void LA_CC LicenseCallback(uint32_t status)
{
	// NOTE: Don't invoke IsProductGenuine(), ActivateLicense() or ActivateTrial() API functions in this callback
	printf("License status: %d", status);
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
		printf("License activated successfully: %d", status);
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
	// Setting license callback is recommended for floating licenses
	// SetLicenseCallback(LicenseCallback);
	int status = IsLicenseGenuine();
	if (LA_OK == status)
	{
		unsigned int expiryDate = 0;
		GetLicenseExpiryDate(&expiryDate);
		int daysLeft = (expiryDate - time(NULL)) / 86500;
		printf("Days left: %d\n", daysLeft);
		printf("License is genuinely activated!"); 
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
			int daysLeft = (trialExpiryDate - time(NULL)) / 86500;
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
