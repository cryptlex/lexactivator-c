#include <stdio.h>
#include <stdlib.h>
#include "../lib/LexActivator.h"

#if _WIN32
	#if _WIN64
	#pragma comment(lib,"../lib/x64/LexActivator")
	#else
	#pragma comment(lib,"../lib/x86/LexActivator")
	#endif
#endif

int main()
{
	int status;
	status = SetProductFile("Product.dat");
	if(LA_OK != status) {
		printf("Error code: %d",status); 
		getchar();
		return status;
	}
	status = SetProductVersionGuid("59A44CE9-5415-8CF3-BD54-EA73A64E9A1B", LA_USER);
	if(LA_OK != status) {
		printf("Error code: %d",status); 
		getchar();
		return status;
	}
	status = IsProductGenuine();
	if(LA_OK == status) {
		printf("Product is genuinely activated!");  
	}
	else if(LA_EXPIRED == status) {
		printf("Product is genuinely activated, but license validity has expired!");  
	}
	else if(LA_GP_OVER == status) {
		printf("Product is genuinely activated, but grace period is over!");  
	}
	else {
		int trialStatus;
		trialStatus = IsTrialGenuine();
		if (LA_OK == trialStatus)
		{
			unsigned int daysLeft = 0;
			//GetTrialDaysLeft(&daysLeft,LA_V_TRIAL);
			printf("Trial days left: %d", daysLeft);
		} 
		else if (LA_T_EXPIRED == trialStatus)
		{
			printf("Trial has expired!");
			// Time to buy the product key and activate the app
			status = SetProductKey("986D8-DE8AF-C2B37-50BF5-03EA1");
			if(LA_OK != status) {
				printf("Error code: %d",status);  
				getchar();
				return status;
			}
			SetActivationExtraData("sample data ");
			// Activating the product
			status = ActivateProduct();    // Ideally on a button click inside a dialog
			if (LA_OK == status){
				printf("Product activated successfully!");
			}
			else {
				printf("Product activation failed: %d" , status);
			}
		} 
		else
		{
			printf("Either trial has not started or has been tampered!");
			// Activating the trial
			trialStatus = ActivateTrial();   // Ideally on a button click inside a dialog
			if (LA_OK == trialStatus){
				unsigned int daysLeft = 0;
				// GetTrialDaysLeft(&daysLeft,LA_V_TRIAL);
				printf("Trial started, days left: %d",daysLeft);
			}
			else {
				//Trial was tampered or has expired
				printf("Trial activation failed: %d", trialStatus);
			}
		}
	}     
	getchar();
	return 0;
}