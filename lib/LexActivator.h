/* LexActivator.h */
#pragma once

#include <stdint.h>
#ifdef _WIN32
    /*
    Make sure you're using the MSVC or Intel compilers on Windows.
    */
    #include <windows.h>

    #ifdef LEXACTIVATOR_EXPORTS
    	#ifdef LEXACTIVATOR__STATIC
            #define LEXACTIVATOR_API extern "C"
        #else
            #define LEXACTIVATOR_API extern "C" __declspec(dllexport)
        #endif
    #else
    	#ifdef __cplusplus
            #ifdef LEXACTIVATOR_STATIC
                #define LEXACTIVATOR_API extern "C"
            #else
                #define LEXACTIVATOR_API extern "C" __declspec(dllimport)
            #endif
        #else
            #ifdef LEXACTIVATOR_STATIC
                #define LEXACTIVATOR_API
            #else
                #define LEXACTIVATOR_API __declspec(dllimport)
            #endif
        #endif
    #endif

    #if defined(USE_STDCALL_DLL) && !defined(LEXACTIVATOR_STATIC)
        #define LA_CC __stdcall
    #else
        #define LA_CC __cdecl
    #endif
    typedef const wchar_t* CSTRTYPE;
    typedef wchar_t* STRTYPE;
#else
    #define LA_CC
    typedef int32_t HRESULT;
    #if __GNUC__ >= 4
        #ifdef __cplusplus
            #define LEXACTIVATOR_API extern "C" __attribute__((visibility("default")))
        #else
            #define LEXACTIVATOR_API __attribute__((visibility("default")))
        #endif
    #else
        #ifdef __cplusplus
            #define LEXACTIVATOR_API extern "C"
        #else
            #define LEXACTIVATOR_API
        #endif
    #endif
    typedef const char* CSTRTYPE;
    typedef char* STRTYPE;
#endif

#define LA_USER ((uint32_t)1)
#define LA_SYSTEM ((uint32_t)2)

#define LA_V_TRIAL ((uint32_t)1)
#define LA_UV_TRIAL ((uint32_t)2)

/*
    FUNCTION: SetProductFile()

    PURPOSE: Sets the path of the Product.dat file. This should be
    used if your application and Product.dat file are in different
    folders or you have renamed the Product.dat file.

    If this function is used, it must be called on every start of
    your program before any other functions are called.

    PARAMETERS:
    * filePath - path of the product file (Product.dat)

    RETURN CODES: LA_OK, LA_E_FPATH, LA_E_PFILE

    NOTE: If this function fails to set the path of product file, none of the
    other functions will work.
*/

LEXACTIVATOR_API HRESULT LA_CC SetProductFile(CSTRTYPE filePath);

/*
    FUNCTION: SetVersionGUID()

    PURPOSE: Sets the version GUID of your application. 

    This function must be called on every start of your program before
    any other functions are called, with the exception of SetProductFile()
    function.

    PARAMETERS:
    * versionGUID - the unique version GUID of your application as mentioned
      on the product version page of your application in the dashboard.

    * flags - depending upon whether your application requires admin/root 
      permissions to run or not, this parameter can have one of the following
      values: LA_SYSTEM, LA_USER

    RETURN CODES: LA_OK, LA_E_WMIC, LA_E_PFILE, LA_E_GUID, LA_E_PERMISSION

    NOTE: If this function fails to set the version GUID, none of the other
    functions will work.
*/

LEXACTIVATOR_API HRESULT LA_CC SetProductVersionGuid(CSTRTYPE versionGuid, uint32_t flags);

/*
    FUNCTION: SetProductKey()

    PURPOSE: Sets the product key required to activate the application.

    PARAMETERS:
    * productKey - a valid product key generated for the application.

    RETURN CODES: LA_OK, LA_E_GUID, LA_E_PKEY
*/

LEXACTIVATOR_API HRESULT LA_CC SetProductKey(CSTRTYPE productKey);

/*
    FUNCTION: SetExtraActivationData()

    PURPOSE: Sets the extra data which you may want to fetch from the user
    at the time of activation. 

    The extra data appears along with activation details of the product key
    in dashboard.

    PARAMETERS:
    * extraData - string of maximum length 256 characters with utf-8 encoding.

    RETURN CODES: LA_OK, LA_E_GUID, LA_E_EDATA_LEN

    NOTE: If the length of the string is more than 256, it is truncated to the
    allowed size.
*/

LEXACTIVATOR_API HRESULT LA_CC SetTrialActivationExtraData(CSTRTYPE extraData);
LEXACTIVATOR_API HRESULT LA_CC SetActivationExtraData(CSTRTYPE extraData);

/*
    FUNCTION: ActivateProduct()

    PURPOSE: Activates your application by contacting the Cryptlex servers. It 
    validates the key and returns with encrypted and digitally signed response
    which it stores and uses to activate your application.

    This function should be executed at the time of registration, ideally on
    a button click. 

    RETURN CODES: LA_OK, LA_EXPIRED, LA_REVOKED, LA_FAIL, LA_E_GUID, LA_E_PKEY,
    LA_E_INET, LA_E_VM, LA_E_TIME, LA_E_ACT_LIMIT
*/

LEXACTIVATOR_API HRESULT LA_CC ActivateProduct();

/*
    FUNCTION: DeactivateProduct()

    PURPOSE: Deactivates the application and frees up the correponding activation
    slot by contacting the Cryptlex servers.

    This function should be executed at the time of deregistration, ideally on
    a button click. 

    RETURN CODES: LA_OK, LA_EXPIRED, LA_REVOKED, LA_E_DEACT_LIMIT, LA_FAIL, LA_E_GUID,
    LA_E_PKEY, LA_E_INET
*/

LEXACTIVATOR_API HRESULT LA_CC DeactivateProduct();

/*
    FUNCTION: ActivateProductOffline()

    PURPOSE: Activates your application using the offline activation response
    file.
	
	PARAMETERS:
    * filePath - path of the offline activation response file.

    RETURN CODES: LA_OK, LA_EXPIRED, LA_FAIL, LA_E_GUID, LA_E_PKEY, LA_E_OFILE
    LA_E_VM, LA_E_TIME
*/

LEXACTIVATOR_API HRESULT LA_CC ActivateProductOffline(CSTRTYPE filePath);

/*
    FUNCTION: GenerateOfflineActivationRequest()

    PURPOSE: Generates the offline activation request needed for generating
    offline activation response in the dashboard.

    PARAMETERS:
    * filePath - path of the file, needed to be created, for the offline request.

    RETURN CODES: LA_OK, LA_FAIL, LA_E_GUID, LA_E_PKEY
*/

LEXACTIVATOR_API HRESULT LA_CC GenerateOfflineActivationRequest(CSTRTYPE filePath);

/*
    FUNCTION: GenerateOfflineDeactivationRequest()

    PURPOSE: Generates the offline deactivation request needed for deactivation of 
    the product key in the dashboard and deactivates the application.

    A valid offline deactivation file confirms that the application has been successfully
    deactivated on the user's machine.

    PARAMETERS:
    * filePath - path of the file, needed to be created, for the offline request.

    RETURN CODES: LA_OK, LA_EXPIRED, LA_REVOKED, LA_FAIL, LA_E_GUID, LA_E_PKEY
*/

LEXACTIVATOR_API HRESULT LA_CC GenerateOfflineDeactivationRequest(CSTRTYPE filePath);

/*
    FUNCTION: IsProductGenuine()

    PURPOSE: It verifies whether your app is genuinely activated or not. The verification is
    done locally by verifying the cryptographic digital signature fetched at the time of
    activation.

    After verifying locally, it schedules a server check in a separate thread on due dates.
    The default interval for server check is 100 days and this can be changed if required.

    In case server validation fails due to network error, it retries every 15 minutes. If it
    continues to fail for fixed number of days (grace period), the function returns LA_GP_OVER
    instead of LA_OK. The default length of grace period is 30 days and this can be changed if 
    required.

    This function must be called on every start of your program to verify the activation
    of your app.

    RETURN CODES: LA_OK, LA_EXPIRED, LA_REVOKED, LA_GP_OVER, LA_FAIL, LA_E_GUID, LA_E_PKEY

    NOTE: If application was activated offline using ActivateProductOffline() function, you
    may want to set grace period to 0 to ignore grace period.
*/

LEXACTIVATOR_API HRESULT LA_CC IsProductGenuine(); 

/*
    FUNCTION: IsProductActivated()

    PURPOSE: It verifies whether your app is genuinely activated or not. The verification is
    done locally by verifying the cryptographic digital signature fetched at the time of
    activation.

    This is just an auxiliary function which you may use in some specific cases.

    RETURN CODES: LA_OK, LA_EXPIRED, LA_REVOKED, LA_GP_OVER, LA_FAIL, LA_E_GUID, LA_E_PKEY
*/

LEXACTIVATOR_API HRESULT LA_CC IsProductActivated(); 

/*
	FUNCTION: GetExtraActivationData()

	PURPOSE: Gets the value of the extra activation data.

	PARAMETERS:
	* extraData - pointer to a buffer that receives the value of the string
	* length - size of the buffer pointed to by the fieldValue parameter

	RETURN CODES: LA_OK, LA_E_GUID, LA_E_BUFFER_SIZE
*/


LEXACTIVATOR_API HRESULT LA_CC GetExtraActivationData(STRTYPE extraData, uint32_t length);


/*
    FUNCTION: GetCustomLicenseField()

    PURPOSE: Get the value of the custom field associated with the product key.

    PARAMETERS:
    * fieldId - id of the custom field whose value you want to get
    * fieldValue - pointer to a buffer that receives the value of the string
    * length - size of the buffer pointed to by the fieldValue parameter

    RETURN CODES: LA_OK, LA_E_CUSTOM_FIELD_ID, LA_E_GUID, LA_E_BUFFER_SIZE
*/

LEXACTIVATOR_API HRESULT LA_CC GetProductKeyCustomField(uint32_t fieldId, STRTYPE fieldValue, uint32_t length);

/*
    FUNCTION: GetProductKey()

    PURPOSE: Gets the stored product key which was used for activation.

    PARAMETERS:
    * productKey - pointer to a buffer that receives the value of the string
    * length - size of the buffer pointed to by the productKey parameter

    RETURN CODES: LA_OK, LA_E_PKEY, LA_E_GUID, LA_E_BUFFER_SIZE
*/

LEXACTIVATOR_API HRESULT LA_CC GetAppVersion(STRTYPE appVersion, uint32_t length);
LEXACTIVATOR_API HRESULT LA_CC GetProductKey(STRTYPE productKey, uint32_t length);
LEXACTIVATOR_API HRESULT LA_CC GetProductKeyEmail(STRTYPE productKeyEmail, uint32_t length);

/*
	FUNCTION: GetDaysLeftToExpiration()

    PURPOSE: Gets the number of remaining days after which the license expires.

    PARAMETERS:
    * daysLeft - pointer to the integer that receives the value

    RETURN CODES: LA_OK, LA_FAIL, LA_E_GUID
*/

LEXACTIVATOR_API HRESULT LA_CC GetProductKeyExpiryDate(uint32_t *daysLeft);
LEXACTIVATOR_API HRESULT LA_CC GetTrialExpiryDate(uint32_t *trialExpiryDate);
LEXACTIVATOR_API HRESULT LA_CC GetActivationExtraData(STRTYPE extraData, uint32_t length);
LEXACTIVATOR_API HRESULT LA_CC GetTrialActivationExtraData(STRTYPE trialExtraData, uint32_t length);

/*
    FUNCTION: SetTrialKey()

    PURPOSE: Sets the trial key required to activate the verified trial.

    PARAMETERS:
    * trialKey - trial key corresponding to the product version

    RETURN CODES: LA_OK, LA_E_GUID, LA_E_TKEY
*/

LEXACTIVATOR_API HRESULT LA_CC SetTrialKey(CSTRTYPE trialKey);

/*
    FUNCTION: ActivateTrial()

    PURPOSE: Starts the verified trial in your application by contacting the 
    Cryptlex servers. 

    This function should be executed when your application starts first time on
    the user's computer, ideally on a button click. 

    RETURN CODES: LA_OK, LA_T_EXPIRED, LA_FAIL, LA_E_GUID, LA_E_TKEY, LA_E_INET,
    LA_E_VM, LA_E_TIME
*/

LEXACTIVATOR_API HRESULT LA_CC ActivateTrial();

/*
    FUNCTION: IsTrialGenuine()

    PURPOSE: It verifies whether trial has started and is genuine or not. The
    verification is done locally by verifying the cryptographic digital signature
    fetched at the time of trial activation.

    This function must be called on every start of your program during the trial period.

    RETURN CODES: LA_OK, LA_T_EXPIRED, LA_FAIL, LA_E_GUID, LA_E_TKEY

    NOTE: The function is only meant for verified trials.
*/

LEXACTIVATOR_API HRESULT LA_CC IsTrialGenuine();

/*
    FUNCTION: ExtendTrial()

    PURPOSE: Extends the trial using the trial extension key generated in the dashboard
    for the product version.

    PARAMETERS:
    * trialExtensionKey - trial extension key generated for the product version

    RETURN CODES: LA_OK, LA_TEXT_EXPIRED, LA_FAIL, LA_E_GUID, LA_E_TEXT_KEY, LA_E_TKEY,
    LA_E_INET, LA_E_VM, LA_E_TIME

    NOTE: The function is only meant for verified trials.
*/

LEXACTIVATOR_API HRESULT LA_CC ExtendTrial(CSTRTYPE trialExtensionKey);

/*
    FUNCTION: InitializeTrial()

    PURPOSE: Starts the unverified trial if trial has not started yet and if
    trial has already started, it verifies the validity of trial.

    This function must be called on every start of your program during the trial period.

    PARAMETERS:
    * trialLength - trial length as set in the dashboard for the product version

    RETURN CODES: LA_OK, LA_T_EXPIRED, LA_FAIL, LA_E_GUID, LA_E_TRIAL_LEN

    NOTE: The function is only meant for unverified trials.
*/
LEXACTIVATOR_API HRESULT LA_CC InitializeTrial(uint32_t trialLength);

/*
    FUNCTION: GetTrialDaysLeft()

    PURPOSE: Gets the number of remaining trial days.

    If the trial has expired or has been tampered, daysLeft is set to 0 days.

    PARAMETERS:
    * daysLeft - pointer to the integer that receives the value
    * trialType - depending upon whether your application uses verified trial or not,
      this parameter can have one of the following values: LA_V_TRIAL, LA_UV_TRIAL

    RETURN CODES: LA_OK, LA_FAIL, LA_E_GUID

    NOTE: The trial must be started by calling ActivateTrial() or  InitializeTrial() at least
    once in the past before calling this function.
*/

LEXACTIVATOR_API HRESULT LA_CC GetTrialDaysLeft(uint32_t *daysLeft  , uint32_t trialType);

/*
    FUNCTION: SetDayIntervalForServerCheck()

    PURPOSE: Sets the interval for server checks done by IsProductGenuine() function.

    To disable sever check pass 0 as the day interval.

    PARAMETERS:
    * dayInterval - length of the interval in days

    RETURN CODES: LA_OK, LA_E_GUID
*/

LEXACTIVATOR_API HRESULT LA_CC SetDayIntervalForServerCheck(uint32_t dayInterval);

/*
    FUNCTION: SetGracePeriodForNetworkError()

    PURPOSE: Sets the grace period for failed re-validation requests sent
    by IsProductGenuine() function, caused due to network errors.
    
    It determines how long in days, should IsProductGenuine() function retry
    contacting CryptLex Servers, before returning LA_GP_OVER instead of LA_OK.

    To ignore grace period pass 0 as the grace period. This may be useful in
    case of offline activations.

    PARAMETERS:
    * gracePeriod - length of the grace period in days

    RETURN CODES: LA_OK, LA_E_GUID
*/

LEXACTIVATOR_API HRESULT LA_CC SetGracePeriodForNetworkError(uint32_t gracePeriod);

/*
    FUNCTION: SetNetworkProxy()

    PURPOSE: Sets the network proxy to be used when contacting CryptLex servers.

    The proxy format should be: [protocol://][username:password@]machine[:port]

    Following are some examples of the valid proxy strings:
        - http://127.0.0.1:8000/
        - http://user:pass@127.0.0.1:8000/
        - socks5://127.0.0.1:8000/

    PARAMETERS:
    * proxy - proxy string having correct proxy format

    RETURN CODES: LA_OK, LA_E_GUID, LA_E_NET_PROXY

    NOTE: Proxy settings of the computer are automatically detected. So, in most of the 
    cases you don't need to care whether your user is behind a proxy server or not.
*/

LEXACTIVATOR_API HRESULT LA_CC SetNetworkProxy(CSTRTYPE proxy);


/*
    FUNCTION: SetCryptlexHost()

    PURPOSE: In case you are running Cryptlex on a private web server, you can set the
    host for your private server.

    PARAMETERS:
    * host - the address of the private web server running Cryptlex

    RETURN CODES: LA_OK, LA_E_GUID, LA_E_HOST_URL

    NOTE: This function should never be used unless you have opted for a private Cryptlex
    Server.
*/

LEXACTIVATOR_API HRESULT LA_CC SetCryptlexHost(CSTRTYPE host);


/*** Return Codes ***/

#define LA_OK           ((HRESULT)0x00000000L)

#define LA_FAIL         ((HRESULT)0x00000001L)

/*
    CODE: LA_EXPIRED

    MESSAGE: The product key has expired or system time has been tampered
    with. Ensure your date and time settings are correct.
*/

#define LA_EXPIRED	    ((HRESULT)0x00000002L)

/*
    CODE: LA_REVOKED

    MESSAGE: The product key has been revoked.
*/

#define LA_REVOKED      ((HRESULT)0x00000003L)

/*
    CODE: LA_GP_OVER

    MESSAGE: The grace period is over.
*/

#define LA_GP_OVER      ((HRESULT)0x00000004L)

/*
    CODE: LA_E_INET

    MESSAGE: Failed to connect to the server due to network error.
*/

#define LA_E_INET		((HRESULT)0x00000005L)

/*
    CODE: LA_E_PKEY

    MESSAGE: Invalid product key.
*/

#define LA_E_PKEY		((HRESULT)0x00000006L)

/*
    CODE: LA_E_PFILE

    MESSAGE: Invalid or corrupted product file.
*/

#define LA_E_PFILE		((HRESULT)0x00000007L)

/*
    CODE: LA_E_FPATH

    MESSAGE: Invalid product file path.
*/

#define LA_E_FPATH		((HRESULT)0x00000008L)

/*
    CODE: LA_E_GUID

    MESSAGE: The version GUID doesn't match that of the product file.
*/

#define LA_E_GUID		((HRESULT)0x00000009L)

/*
    CODE: LA_E_OFILE

    MESSAGE: Invalid offline activation response file.
*/

#define LA_E_OFILE		((HRESULT)0x0000000AL)

/*
    CODE: LA_E_PERMISSION

    MESSAGE: Insufficent system permissions. Occurs when LA_SYSTEM flag is used
    but application is not run with admin privileges.
*/

#define LA_E_PERMISSION ((HRESULT)0x0000000BL)	

/*
    CODE: LA_E_EDATA_LEN

    MESSAGE: Extra activation data length is more than 256 characters.
*/

#define LA_E_EDATA_LEN  ((HRESULT)0x0000000CL)

/*
    CODE: LA_E_TKEY

    MESSAGE: The trial key doesn't match that of the product file.
*/

#define LA_E_TKEY		((HRESULT)0x0000000DL)  

/*
    CODE: LA_E_TIME

    MESSAGE: The system time has been tampered with. Ensure your date
    and time settings are correct.
*/

#define LA_E_TIME		((HRESULT)0x0000000EL)  

/*
    CODE: LA_E_VM

    MESSAGE: Application is being run inside a virtual machine / hypervisor,
    and activation has been disallowed in the VM.
    but
*/

#define LA_E_VM		    ((HRESULT)0x0000000FL)  

/*
    CODE: LA_E_WMIC

    MESSAGE: Fingerprint couldn't be generated because Windows Management 
    Instrumentation (WMI) service has been disabled. This error is specific
    to Windows only.
*/

#define LA_E_WMIC		((HRESULT)0x0000010L)

/*
    CODE: LA_E_TEXT_KEY

    MESSAGE: Invalid trial extension key.
*/

#define LA_E_TEXT_KEY	((HRESULT)0x0000011L)

/*
    CODE: LA_E_TRIAL_LEN

    MESSAGE: The trial length doesn't match that of the product file.
*/

#define LA_E_TRIAL_LEN  ((HRESULT)0x0000012L)

/*
    CODE: LA_T_EXPIRED

    MESSAGE: The trial has expired or system time has been tampered
    with. Ensure your date and time settings are correct.
*/

#define LA_T_EXPIRED    ((HRESULT)0x0000013L)

/*
    CODE: LA_TEXT_EXPIRED

    MESSAGE: The trial extension key being used has already expired or system
    time has been tampered with. Ensure your date and time settings are correct.
*/

#define LA_TEXT_EXPIRED ((HRESULT)0x0000014L)

/*
    CODE: LA_E_BUFFER_SIZE

    MESSAGE: The buffer size was smaller than required.
*/

#define LA_E_BUFFER_SIZE ((HRESULT)0x0000015L)

/*
    CODE: LA_E_CUSTOM_FIELD_ID

    MESSAGE: Invalid custom field id.
*/

#define LA_E_CUSTOM_FIELD_ID ((HRESULT)0x0000016L)

/*
    CODE: LA_E_NET_PROXY

    MESSAGE: Invalid network proxy.
*/

#define LA_E_NET_PROXY ((HRESULT)0x0000017L)

/*
    CODE: LA_E_HOST_URL

    MESSAGE: Invalid Cryptlex host url.
*/

#define LA_E_HOST_URL ((HRESULT)0x0000018L)

/*
    CODE: LA_E_DEACT_LIMIT

    MESSAGE: Deactivation limit for key has reached
*/

#define LA_E_DEACT_LIMIT ((HRESULT)0x0000019L)

/*
    CODE: LA_E_ACT_LIMIT

    MESSAGE: Activation limit for key has reached
*/

#define LA_E_ACT_LIMIT ((HRESULT)0x000001AL)

/*
CODE: LA_E_PDATA

MESSAGE: Invalid product data
*/

#define LA_E_PDATA ((HRESULT)0x000001BL)

/*
CODE: LA_E_SERVER

MESSAGE: Server error
*/

#define LA_E_SERVER ((HRESULT)0x000001CL)





