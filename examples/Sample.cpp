#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include "LexActivator.h"

#if _WIN32
#if _WIN64
#pragma comment(lib, "x64/LexActivator")
#else
#pragma comment(lib, "x86/LexActivator")
#endif
#endif

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
	status = SetProductVersionGuid(L"PASTE_PRODUCT_VERSION_GUID", LA_USER);
#else
	status = SetProductVersionGuid("PASTE_PRODUCT_VERSION_GUID", LA_SYSTEM);
#endif
	if (LA_OK != status)
	{
		printf("Error code: %d", status);
		getchar();
		exit(status);
	}

#if _WIN32
	status = SetAppVersion(L"2.4.0");
#else
	status = SetAppVersion("2.4.0");
#endif
	if (LA_OK != status)
	{
		printf("Error code: %d", status);
		getchar();
		exit(status);
	}
}

// Ideally on a button click inside a dialog
void activate()
{
	int status;
#if _WIN32
	status = SetProductKey(L"PASTE_PRODUCT_KEY");
#else
	status = SetProductKey("PASTE_PRODUCT_KEY");
#endif
	if (LA_OK != status)
	{
		printf("Error code: %d", status);
		getchar();
		exit(status);
	}

#if _WIN32
	status = SetActivationExtraData(L"SAMPLE DATA");
#else
	status = SetActivationExtraData("SAMPLE DATA");
#endif
	if (LA_OK != status)
	{
		printf("Error code: %d", status);
		getchar();
		exit(status);
	}

	status = ActivateProduct();
	if (LA_OK == status || LA_EXPIRED == status || LA_REVOKED == status)
	{
		printf("Product activated successfully: %d", status);
	}
	else
	{
		printf("Product activation failed: %d", status);
	}
}

// Ideally on a button click inside a dialog
void activateTrial()
{
	int status;

#if _WIN32
	status = SetTrialActivationExtraData(L"SAMPLE DATA");
#else
	status = SetTrialActivationExtraData("SAMPLE DATA");
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
	else if (LA_EXPIRED == status)
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
	int status = IsProductGenuine();
	if (LA_OK == status)
	{
		unsigned int expiryDate = 0;
		GetProductKeyExpiryDate(&expiryDate);
		int daysLeft = (expiryDate - time(NULL)) / 86500;
		printf("Days left: %d\n", daysLeft);
		printf("Product is genuinely activated!"); 
	}
	else if (LA_EXPIRED == status)
	{
		printf("Product is genuinely activated, but license validity has expired!");
	}
	else if (LA_REVOKED == status)
	{
		printf("Product is genuinely activated, but product key has been revoked!");
	}
	else if (LA_GP_OVER == status)
	{
		printf("Product is genuinely activated, but grace period is over!");
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
		else if (LA_T_EXPIRED == trialStatus)
		{
			printf("Trial has expired!");

			// Time to buy the product key and activate the app
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
