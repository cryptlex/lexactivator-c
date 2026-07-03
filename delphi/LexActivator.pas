{$WARN UNSAFE_TYPE OFF} // PAnsiChar, PWideChar, untyped

unit LexActivator;

interface

{$IF CompilerVersion >= 16.0}
  {$DEFINE DELPHI_HAS_UINT64}
{$IFEND}

{$IF CompilerVersion >= 17.0}
  {$DEFINE DELPHI_HAS_INLINE}
{$IFEND}

{$IF CompilerVersion >= 18.0}
  {$DEFINE DELPHI_CLASS_CAN_BE_ABSTRACT}
  {$DEFINE DELPHI_HAS_RECORDS}
{$IFEND}

{$IF CompilerVersion >= 20.0}
  {$DEFINE DELPHI_IS_UNICODE}
  {$DEFINE DELPHI_HAS_CLOSURES}
{$IFEND}

{$IF CompilerVersion >= 21.0}
  {$DEFINE DELPHI_HAS_RTTI}
{$IFEND}

{$IF CompilerVersion >= 23.0}
  {$DEFINE DELPHI_HAS_INTPTR}
  {$DEFINE DELPHI_UNITS_SCOPED}
{$IFEND}

uses
  LexActivator.DelphiFeatures,
{$IFDEF DELPHI_UNITS_SCOPED}
  System.SysUtils,
  System.JSON,
  System.Generics.Collections
{$ELSE}
  SysUtils,
  JSON,
  Generics.Collections
{$ENDIF}
  ;

type
  TLAFlags = (lfUser, lfSystem, lfAllUsers, lfInMemory);
  TLAKeyStatus = (lkOK, lkExpired, lkSuspended, lkGracePeriodOver,
    lkTrialExpired, lkLocalTrialExpired, lkFail,
    lkException // for callback
    );

type
  TOrganizationAddress = record
    AddressLine1: UnicodeString;
    AddressLine2: UnicodeString;
    City: UnicodeString;
    State: UnicodeString;
    Country: UnicodeString;
    PostCode: UnicodeString;
end;

type
  TMetadata = record
    Key: string;
    Value: string;
end;

type
  TUserLicense = record
    Key: string;
    &Type: string;
    AllowedActivations: Int64;
    AllowedDeactivations: Int64;
    TotalActivations: UInt32;
    TotalDeactivations: UInt32;
    Metadata: TArray<TMetadata>;
end;

type
  TActivationMode = record
    InitialMode: UnicodeString;
    CurrentMode: UnicodeString;
end;

type
  TFeatureEntitlement = record
    FeatureName: UnicodeString;
    FeatureDisplayName: UnicodeString;
    Value: UnicodeString;
    ExpiresAt: Int64;
  end;

function LAFlagsToString(Item: TLAFlags): string;
function LAKeyStatusToString(Item: TLAKeyStatus): string;

(*
    PROCEDURE: SetProductFile()

    PURPOSE: Sets the absolute path of the Product.dat file.

    This function must be called on every start of your program
    before any other functions are called.

    NOTE: This function is deprecated. Use SetProductData() instead.

    PARAMETERS:
    * FilePath - absolute path of the product file (Product.dat)

    EXCEPTIONS: ELAFilePathException, ELAProductFileException

    NOTE: If this function fails to set the path of product file, none of the
    other functions will work.
*)

procedure SetProductFile(const FilePath: UnicodeString); deprecated 'Use SetProductData instead';

(*
    PROCEDURE: SetProductData()

    PURPOSE: Embeds the Product.dat file in the application.

    It can be used instead of SetProductFile() in case you want
    to embed the Product.dat file in your application.

    This function must be called on every start of your program
    before any other functions are called.

    PARAMETERS:
    * ProductData - content of the Product.dat file

    EXCEPTIONS: ELAProductDataException

    NOTE: If this function fails to set the product data, none of the
    other functions will work.
*)

procedure SetProductData(const ProductData: UnicodeString);

(*
    PROCEDURE: SetProductId()

    PURPOSE: Sets the product id of your application.

    This function must be called on every start of your program before
    any other functions are called, with the exception of SetProductFile()
    or SetProductData() function.

    PARAMETERS:
    * ProductId - the unique product id of your application as mentioned
      on the product page in the dashboard.

    * Flags - depending on your application's requirements, choose one of 
      the following values: 
      
       - lfUser: This flag indicates that the application does not require
        admin or root permissions to run.
      
       - lfSystem: This flag indicates that the application must be run with admin or 
        root permissions.
       
       - lfAllUsers: This flag is specifically designed for Windows and should be used 
        for system-wide activations. 
       
       - lfInMemory: This flag will store activation data in memory. Thus, requires 
        re-activation on every start of the application and should only be used in floating
        licenses.

    EXCEPTIONS: ELAWMICException, ELAProductFileException,
    ELAProductDataException, ELAProductIdException,
    ELASystemPermissionException

    NOTE: If this function fails to set the product id, none of the other
    functions will work.
*)

procedure SetProductId(const ProductId: UnicodeString; Flags: TLAFlags);

(*
    PROCEDURE: SetDataDirectory()

    PURPOSE: In case you want to change the default directory used by LexActivator to
    store the activation data on Linux and macOS, this function can be used to
    set a different directory.

    If you decide to use this function, then it must be called on every start of
    your program before calling SetProductFile() or SetProductData() function.

    Please ensure that the directory exists and your app has read and write
    permissions in the directory.

    PARAMETERS:
    * DirectoryPath - absolute path of the directory.

    EXCEPTIONS: ELAFilePermissionException
*)

procedure SetDataDirectory(const DirectoryPath: UnicodeString);

// Android-only SetJniEnv() is currently omitted

(*
    PROCEDURE: SetCustomDeviceFingerprint()

    PURPOSE: In case you don't want to use the LexActivator's advanced
    device fingerprinting algorithm, this function can be used to set a custom
    device fingerprint.

    If you decide to use your own custom device fingerprint then this function must be
    called on every start of your program immediately after calling SetProductFile()
    or SetProductData() function.

    The license fingerprint matching strategy is ignored if this function is used.

    PARAMETERS:
    * Fingerprint - string of minimum length 64 characters and maximum length 256 characters.

    EXCEPTIONS: ELAProductIdException, ELACustomFingerprintLengthException
*)

procedure SetCustomDeviceFingerprint(const Fingerprint: UnicodeString);

(*
    PROCEDURE: SetLicenseKey()

    PURPOSE: Sets the license key required to activate the license.

    PARAMETERS:
    * LicenseKey - a valid license key.

    EXCEPTIONS: ELAProductIdException, ELALicenseKeyException
*)

procedure SetLicenseKey(const LicenseKey: UnicodeString);

(*
    PROCEDURE: SetReleaseVersion()

    PURPOSE: Sets the current release version of your application.
    The release version appears along with the activation details in dashboard.

    PARAMETERS:
    * ReleaseVersion - string in following allowed formats: x.x, x.x.x, x.x.x.x.

    EXCEPTIONS: ELAProductIdException, ELAReleaseVersionFormatException
*)

procedure SetReleaseVersion(const ReleaseVersion: UnicodeString);

(*
    PROCEDURE: SetReleasePublishedDate()

    PURPOSE: Sets the release published date of your application.

    PARAMETERS:
    * ReleasePublishedDate - unix timestamp of release published date.

    EXCEPTIONS: ELAProductIdException
*)

procedure SetReleasePublishedDate(ReleasePublishedDate: LongWord);

(*
    PROCEDURE: SetDebugMode()

    PURPOSE: Enables network logs.

    This function should be used for network testing only in case of network errors.
    By default logging is disabled.

    This function generates the lexactivator-logs.log file in the same directory
    where the application is running.

    PARAMETERS:
    * Enable - 0 or 1 to disable or enable logging.

    RETURN CODES : LA_OK
*)

procedure SetDebugMode(Enable: LongWord);

(*
    PROCEDURE: SetCacheMode()

    PURPOSE: Enables or disables in-memory caching for LexActivator. This function is designed to control caching
    behavior to suit specific application requirements. Caching is enabled by default to enhance performance.

    Disabling caching is recommended in environments where multiple processes access the same license on a
    single machine and require real-time updates to the license state.

    PARAMETERS:
    * Enable - False or True to disable or enable in-memory caching.

    EXCEPTIONS: ELAProductIdException
*)

procedure SetCacheMode(Enable: Boolean);

(*
    PROCEDURE: SetTwoFactorAuthenticationCode()

    PURPOSE: Sets the two-factor authentication code for the user authentication.

    PARAMETERS:
    * TwoFactorAuthenticationCode - the 2FA code.

    EXCEPTIONS: ELAProductIdException, ELATwoFactorAuthenticationCodeInvalidException
*)

procedure SetTwoFactorAuthenticationCode(const TwoFactorAuthenticationCode: UnicodeString);

(*
    PROCEDURE: SetLicenseUserCredential()

    PURPOSE: Sets the license user email and password for authentication.

    This function must be called before ActivateLicense() or IsLicenseGenuine()
    function if 'requireAuthentication' property of the license is set to true.

    NOTE: This function is deprecated. Use AuthenticateUser() instead.

    PARAMETERS:
    * Email - user email address.
    * Password - user password.

    EXCEPTIONS: ELAProductIdException, ELALicenseKeyException
*)

procedure SetLicenseUserCredential(const Email, Password: UnicodeString); deprecated 'Use AuthenticateUser instead';

(*
    PROCEDURE: SetLicenseCallback()

    PURPOSE: Sets server sync callback function.

    Whenever the server sync occurs in a separate thread, and server returns the response,
    license callback function gets invoked with the following status codes:
    LA_OK, LA_EXPIRED, LA_SUSPENDED,
    LA_E_REVOKED, LA_E_ACTIVATION_NOT_FOUND, LA_E_MACHINE_FINGERPRINT,
    LA_E_AUTHENTICATION_FAILED, LA_E_COUNTRY, LA_E_INET, LA_E_SERVER,
    LA_E_RATE_LIMIT, LA_E_IP

    PARAMETERS:
    * Callback - name of the callback procedure, method or closure
    * Synchronized - whether callback must be invoked in main (GUI) thread
    using TThread.Synchronize
    Usually True for GUI applications and handlers like TForm1.OnLexActivator
    Must be False if there is no GUI message loop, like in console applications,
    but then another thread synchronization measures must be used.

    EXCEPTIONS: ELAProductIdException, ELALicenseKeyException
*)

type
  TLAProcedureCallback = procedure(const Error: Exception; Status: TLAKeyStatus);
  TLAMethodCallback = procedure(const Error: Exception; Status: TLAKeyStatus) of object;
  {$IFDEF DELPHI_HAS_CLOSURES}
  TLAClosureCallback = reference to procedure(const Error: Exception; Status: TLAKeyStatus);
  {$ENDIF}

procedure SetLicenseCallback(Callback: TLAProcedureCallback; Synchronized: Boolean); overload;
procedure SetLicenseCallback(Callback: TLAMethodCallback; Synchronized: Boolean); overload;
{$IFDEF DELPHI_HAS_CLOSURES}
procedure SetLicenseCallback(Callback: TLAClosureCallback; Synchronized: Boolean); overload;
{$ENDIF}

(*
    PROCEDURE: SetLicenseCallback()

    PURPOSE: Resets server sync callback function.

    EXCEPTIONS: ELAProductIdException, ELALicenseKeyException
*)

procedure ResetLicenseCallback;

(*
    PROCEDURE: SetActivationLeaseDuration()

    PURPOSE: Sets the lease duration for the activation.

    The activation lease duration is honoured when the allow client
    lease duration property is enabled.

    PARAMETERS:
    * LeaseDuration - value of the lease duration. A value of -1 indicates unlimited lease duration.

    EXCEPTIONS: ELAProductIdException, ELALicenseKeyException
*)

procedure SetActivationLeaseDuration(LeaseDuration: Int64);

(*
    PROCEDURE: SetActivationMetadata()

    PURPOSE: Sets the activation metadata.

    The  metadata appears along with the activation details of the license
    in dashboard.

    PARAMETERS:
    * Key - string of maximum length 256 characters with utf-8 encoding.
    * Value - string of maximum length 256 characters with utf-8 encoding.

    EXCEPTIONS: ELAProductIdException, ELALicenseKeyException,
    ELAMetadataKeyLengthException, ELAMetadataValueLengthException,
    ELAActivationMetadataLimitException
*)

procedure SetActivationMetadata(const Key, Value: UnicodeString);

(*
    PROCEDURE: SetTrialActivationMetadata()

    PURPOSE: Sets the trial activation metadata.

    The  metadata appears along with the trial activation details of the product
    in dashboard.

    PARAMETERS:
    * Key - string of maximum length 256 characters with utf-8 encoding.
    * Value - string of maximum length 256 characters with utf-8 encoding.

    EXCEPTIONS: ELAProductIdException, ELAMetadataKeyLengthException,
    ELAMetadataValueLengthException, ELATrialActivationMetadataLimitException
*)

procedure SetTrialActivationMetadata(const Key, Value: UnicodeString);

(*
    PROCEDURE: SetAppVersion()

    PURPOSE: Sets the current app version of your application.

    The app version appears along with the activation details in dashboard. It
    is also used to generate app analytics.

    This function is deprecated. Use SetReleaseVersion() instead.

    PARAMETERS:
    * AppVersion - string of maximum length 256 characters with utf-8 encoding.

    EXCEPTIONS: ELAProductIdException, ELAAppVersionLengthException
*)

procedure SetAppVersion(const AppVersion: UnicodeString); deprecated 'Use SetReleaseVersion instead';

(*
    PROCEDURE: SetOfflineActivationRequestMeterAttributeUses()

    PURPOSE: Sets the meter attribute uses for the offline activation request.

    This function should only be called before GenerateOfflineActivationRequest()
    function to set the meter attributes in case of offline activation.

    PARAMETERS:
    * Name - name of the meter attribute
    * AUses - the uses value

    RETURN CODES: LA_OK, LA_E_PRODUCT_ID, LA_E_LICENSE_KEY
*)

procedure SetOfflineActivationRequestMeterAttributeUses
  (const Name: UnicodeString; AUses: LongWord);

(*
    PROCEDURE: SetNetworkProxy()

    PURPOSE: Sets the network proxy to be used when contacting Cryptlex servers.

    The proxy format should be: [protocol://][username:password@]machine[:port]

    Following are some examples of the valid proxy strings:
        - http://127.0.0.1:8000/
        - http://user:pass@127.0.0.1:8000/
        - socks5://127.0.0.1:8000/

    PARAMETERS:
    * Proxy - proxy string having correct proxy format

    EXCEPTIONS: ELAProductIdException, ELANetProxyException

    NOTE: Proxy settings of the computer are automatically detected. So, in most of the
    cases you don't need to care whether your user is behind a proxy server or not.
*)

procedure SetNetworkProxy(const Proxy: UnicodeString);

(*
    PROCEDURE: SetCryptlexHost()

    PURPOSE: In case you are running Cryptlex on-premise, you can set the
    host for your on-premise server.

    PARAMETERS:
    * Host - the address of the Cryptlex on-premise server

    EXCEPTIONS: ELAProductIdException, ELAHostURLException
*)

procedure SetCryptlexHost(const Host: UnicodeString);

(*
    FUNCTION: GetProductMetadata()

    PURPOSE: Gets the product metadata as set in the dashboard.

    This is available for trial as well as license activations.

    PARAMETERS:
    * Key - key to retrieve the value

    RESULT: Product metadata as set in the dashboard

    EXCEPTIONS: ELAProductIdException, ELAMetadataKeyNotFoundException,
    ELABufferSizeException
*)

function GetProductMetadata(const Key: UnicodeString): UnicodeString;

(*
    FUNCTION: GetLicenseEntitlementSetName()

    PURPOSE: Gets the license entitlement set name.

    RESULT: License entitlement set name.

    EXCEPTIONS: ELAFailException, ELAProductIdException, ELATimeException,
    ELATimeModifiedException, ELAEntitlementSetNotLinkedException,
    ELABufferSizeException
*)

function GetLicenseEntitlementSetName: UnicodeString;

(*
    FUNCTION: GetLicenseEntitlementSetDisplayName()

    PURPOSE: Gets the license entitlement set display name.

    RESULT: License entitlement set display name.

    EXCEPTIONS: ELAFailException, ELAProductIdException, ELATimeException,
    ELATimeModifiedException, ELAEntitlementSetNotLinkedException,
    ELABufferSizeException
*)

function GetLicenseEntitlementSetDisplayName: UnicodeString;

(*
    FUNCTION: GetFeatureEntitlements()

    PURPOSE: Gets the feature entitlements associated with the license.

    Feature entitlements can be linked directly to a license (license feature entitlements) 
    or via entitlement sets. If a feature entitlement is defined in both, the value from 
    the license feature entitlement takes precedence, overriding the entitlement set value.

    RESULT: Array of feature entitlements.

    EXCEPTIONS: ELAFailException, ELAProductIdException, ELATimeException, 
    ELATimeModifiedException, ELABufferSizeException,
    ELAFeatureEntitlementsInvalidException
*)

function GetFeatureEntitlements: TArray<TFeatureEntitlement>;

(*
    FUNCTION: GetFeatureEntitlement()

    PURPOSE: Gets the feature entitlement associated with the license.

    Feature entitlements can be linked directly to a license (license feature entitlements) 
    or via entitlement sets. If a feature entitlement is defined in both, the value from 
    the license feature entitlement takes precedence, overriding the entitlement set value.

    PARAMETERS:
    * FeatureName - name of the feature entitlement

    RESULT: Feature entitlement.

    EXCEPTIONS: ELAFailException, ELAProductIdException, ELATimeException, 
    ELATimeModifiedException, ELABufferSizeException, 
    ELAFeatureEntitlementNotFoundException, ELAFeatureEntitlementsInvalidException
*)

function GetFeatureEntitlement(const FeatureName: UnicodeString): TFeatureEntitlement;

(*
    FUNCTION: GetProductVersionName()

    PURPOSE: Gets the product version name.

    This function is deprecated. Use GetLicenseEntitlementSetName() instead.

    RESULT: Product version name.

    EXCEPTIONS: ELAFailException, ELAProductIdException, ELATimeException,
    ELATimeModifiedException, ELAProductVersionNotLinkedException,
    ELABufferSizeException
*)

function GetProductVersionName: UnicodeString; deprecated 'Use GetLicenseEntitlementSetName instead';

(*
    FUNCTION: GetProductVersionDisplayName()

    PURPOSE: Gets the product version display name.

    This function is deprecated. Use GetLicenseEntitlementSetDisplayName() instead.

    RESULT: Product version display name.

    EXCEPTIONS: ELAFailException, ELAProductIdException, ELATimeException,
    ELATimeModifiedException, ELAProductVersionNotLinkedException,
    ELABufferSizeException
*)

function GetProductVersionDisplayName: UnicodeString; deprecated 'Use GetLicenseEntitlementSetDisplayName instead';

(*
    FUNCTION: GetProductVersionFeatureFlag()

    PURPOSE: Gets the product version feature flag.

    This function is deprecated. Use GetFeatureEntitlement() instead.

    PARAMETERS:
    * Name - name of the feature flag
    * Data - variable that receives the value of the string

    RESULT: Product version feature flag.

    EXCEPTIONS: ELAFailException, ELAProductIdException, ELATimeException,
    ELATimeModifiedException, ELAProductVersionNotLinkedException,
    ELAFeatureFlagNotFoundException, ELABufferSizeException
*)

function GetProductVersionFeatureFlag(const Name: UnicodeString; out Data: UnicodeString): Boolean; deprecated 'Use GetFeatureEntitlement instead';

(*
    FUNCTION: GetLicenseMetadata()

    PURPOSE: Gets the license metadata as set in the dashboard.

    PARAMETERS:
    * Key - key to retrieve the value

    RESULT: License metadata as set in the dashboard

    EXCEPTIONS: ELAFailException, ELAProductIdException,
    ELAMetadataKeyNotFoundException, ELABufferSizeException
*)

function GetLicenseMetadata(const Key: UnicodeString): UnicodeString;

(*
    PROCEDURE: GetLicenseMeterAttribute()

    PURPOSE: Gets the license meter attribute allowed, total and gross uses.

    PARAMETERS:
    * Name - name of the meter attribute
    * AllowedUses - the integer that receives the value. A value of -1 indicates unlimited allowed uses.
    * TotalUses - the integer that receives the value
    * GrossUses - the integer that receives the value

    EXCEPTIONS: ELAFailException, ELAProductIdException,
    ELAMeterAttributeNotFound
*)

procedure GetLicenseMeterAttribute
  (const Name: UnicodeString; out AllowedUses: Int64; TotalUses, GrossUses: UInt64);

(*
    FUNCTION: GetLicenseKey()

    PURPOSE: Gets the license key used for activation.

    RESULT: License key used for activation

    EXCEPTIONS: ELAFailException, ELAProductIdException,
    ELABufferSizeException
*)

function GetLicenseKey: UnicodeString;

(*
    FUNCTION: GetLicenseAllowedActivations()

    PURPOSE: Gets the allowed activations of the license.

    RESULT: Allowed activations of the license. A value of -1 indicates unlimited number of activations.

    EXCEPTIONS: ELAFailException, ELAProductIdException, ELATimeException,
    ELATimeModifiedException
*)

function GetLicenseAllowedActivations: Int64;

(*
    FUNCTION: GetLicenseTotalActivations()

    PURPOSE: Gets the total activations of the license.

    RESULT: Total activations of the license.

    RETURN CODES: ELAFailException, ELAProductIdException, ELATimeException,
    ELATimeModifiedException
*)

function GetLicenseTotalActivations: LongWord;

(*
    FUNCTION: GetLicenseTotalDeactivations()

    PURPOSE: Gets the total deactivations of the license.

    RESULT: Total deactivations of the license.

    RETURN CODES: ELAFailException, ELAProductIdException, ELATimeException,
    ELATimeModifiedException
*)

function GetLicenseTotalDeactivations: LongWord;

(*
    FUNCTION: GetLicenseAllowedDeactivations()

    PURPOSE: Gets the allowed deactivations of the license.

    RESULT: Allowed deactivations of the license. A value of -1 indicates unlimited number of deactivations.

    EXCEPTIONS: ELAFailException, ELAProductIdException, ELATimeException,
    ELATimeModifiedException
*)

function GetLicenseAllowedDeactivations: Int64;

(*
    FUNCTION: GetLicenseCreationDate()

    PURPOSE: Gets the license creation date timestamp.

    RESULT: License creation date timestamp.

    RETURN CODES: ELAFailException, ELAProductIdException, ELATimeException, ELALicenseKeyException
    ELATimeModifiedException
*)

function GetLicenseCreationDate: TDateTime;

(*
    FUNCTION: GetLicenseActivationDate()

    PURPOSE: Gets the activation creation date timestamp.

    RESULT: Activation creation date timestamp.

    RETURN CODES: ELAFailException, ELAProductIdException, ELATimeException, ELALicenseKeyException
    ELATimeModifiedException
*)

function GetLicenseActivationDate: TDateTime;

(*
    FUNCTION: GetLicenseMaintenanceExpiryDate()

    PURPOSE: Gets the license maintenance expiry date timestamp.

    RESULT: Maintenance expiry date timestamp.

    RETURN CODES: ELAFailException, ELAProductIdException, ELATimeException, ELALicenseKeyException
    ELATimeModifiedException
*)

function GetLicenseMaintenanceExpiryDate: TDateTime;

(*
    FUNCTION: GetLicenseMaxAllowedReleaseVersion()

    PURPOSE: Gets the maximum allowed release version of the license.

    RESULT: Max allowed release version.

    EXCEPTIONS: ELAFailException, ELAProductIdException, ELALicenseKeyException, ELATimeException,
    ELATimeModifiedException, ELABufferSizeException
*)

function GetLicenseMaxAllowedReleaseVersion: UnicodeString;

(*
    FUNCTION: GetLicenseOrganizationName()

    PURPOSE: Gets the organization name associated with the license.

    RESULT: Organization name.

    EXCEPTIONS: ELAFailException, ELAProductIdException, ELATimeException,
    ELATimeModifiedException, ELABufferSizeException
*)

function GetLicenseOrganizationName: UnicodeString;

(*
    FUNCTION: GetActivationId()

    PURPOSE: Gets the activation id.

    RESULT: Activation id.

    EXCEPTIONS: ELAFailException, ELAProductIdException, ELATimeException,
    ELATimeModifiedException, ELABufferSizeException
*)

function GetActivationId: UnicodeString;

(*
    FUNCTION: GetActivationMode()

    PURPOSE: Gets the mode of activation (online or offline).

    RESULT: Activation mode.

    EXCEPTIONS: ELAFailException, ELAProductIdException, ELALicenseKeyException,
    ELATimeModifiedException, ELABufferSizeException
*)

function GetActivationMode: TActivationMode;

(*
    FUNCTION: GetLicenseOrganizationAddress()

    PURPOSE: Gets the address associated with the license organization.

    RESULT: Organization address.

    EXCEPTIONS: ELAFailException, ELAProductIdException, ELATimeException,
    ELATimeModifiedException, ELABufferSizeException
*)

function GetLicenseOrganizationAddress: TOrganizationAddress;

(*
    FUNCTION: GetUserLicenses()

    PURPOSE: Gets the user licenses for the product.

    This function sends a network request to Cryptlex servers to get the licenses.
    Make sure AuthenticateUser() function is called before calling this function.

    RESULT: User licenses for the product.

    EXCEPTIONS: ELAFailException, ELAProductIdException, ELAInetException, ELAServerException,
    ELARateLimitException, ELAUserNotAuthenticatedException, ELABufferSizeException
*)

function GetUserLicenses: TArray<TUserLicense>;

(*
    FUNCTION: GetActivationLastSyncedDate()

    PURPOSE: Gets the activation last synced date timestamp.

    Initially, this timestamp matches the activation creation date, and then updates with each successful server sync.

    RESULT: Activation last synced date timestamp.

    EXCEPTIONS: ELAFailException, ELAProductIdException, ELATimeException,
    ELATimeModifiedException
*)

function GetActivationLastSyncedDate: TDateTime;

(*
    FUNCTION: GetLicenseExpiryDate()

    PURPOSE: Gets the license expiry date timestamp.
    A value of 0 indicates it has no expiry i.e a lifetime license.

    RESULT: License expiry date timestamp

    EXCEPTIONS: ELAFailException, ELAProductIdException, ELALicenseKeyException
    ELATimeException, ELATimeModifiedException
*)

function GetLicenseExpiryDate: TDateTime;

(*
    FUNCTION: GetLicenseUserEmail()

    PURPOSE: Gets the email associated with license user.

    RESULT: Email associated with license user

    EXCEPTIONS: ELAFailException, ELAProductIdException, ELATimeException,
    ELATimeModifiedException, ELABufferSizeException
*)

function GetLicenseUserEmail: UnicodeString;

(*
    FUNCTION: GetLicenseUserName()

    PURPOSE: Gets the name associated with the license user.

    RESULT: Name associated with the license user

    EXCEPTIONS: ELAFailException, ELAProductIdException, ELATimeException,
    ELATimeModifiedException, ELABufferSizeException
*)

function GetLicenseUserName: UnicodeString;

(*
    FUNCTION: GetLicenseUserCompany()

    PURPOSE: Gets the company associated with the license user.

    RESULT: Company associated with the license user.

    EXCEPTIONS: ELAFailException, ELAProductIdException, ELATimeException,
    ELATimeModifiedException, ELABufferSizeException
*)

function GetLicenseUserCompany: UnicodeString;

(*
    FUNCTION: GetLicenseUserMetadata()

    PURPOSE: Gets the metadata associated with the license user.

    PARAMETERS:
    * Key - key to retrieve the value

    RESULT: metadata associated with the license user.

    RETURN CODES: ELAFailException, ELAProductIdException,
    ELAMetadataKeyNotFoundException, ELABufferSizeException
*)

function GetLicenseUserMetadata(const Key: UnicodeString): UnicodeString;

(*
    FUNCTION: GetLicenseType()

    PURPOSE: Gets the license type (node-locked or hosted-floating).

    RESULT: License type

    EXCEPTIONS: ELAFailException, ELAProductIdException, ELATimeException,
    ELATimeModifiedException, ELABufferSizeException
*)

function GetLicenseType: UnicodeString;

(*
    FUNCTION: GetActivationMetadata()

    PURPOSE: Gets the activation metadata.

    PARAMETERS:
    * Key - key to retrieve the value

    RESULT: activation metadata

    EXCEPTIONS: ELAProductIdException, ELAMetadataKeyNotFoundException,
    ELABufferSizeException
*)

function GetActivationMetadata(const Key: UnicodeString): UnicodeString;

(*
    FUNCTION: GetActivationMeterAttributeUses()

    PURPOSE: Gets the meter attribute uses consumed by the activation.

    PARAMETERS:
    * Name - name of the meter attribute

    RESULT: Meter attribute uses consumed by the activation.

    EXCEPTIONS: ELAFailException, ELAProductIdException,
    ELAMeterAttributeNotFoundException
*)

function GetActivationMeterAttributeUses(const Name: UnicodeString): LongWord;

(*
    FUNCTION: GetServerSyncGracePeriodExpiryDate()

    PURPOSE: Gets the server sync grace period expiry date timestamp.

    RESULT: Grace period expiry date timestamp.

    EXCEPTIONS: ELAFailException, ELAProductIdException, ELATimeException,
    ELATimeModifiedException
*)

function GetServerSyncGracePeriodExpiryDate: TDateTime;

(*
    FUNCTION: GetLastActivationError()

    PURPOSE: Gets the error code that caused the activation data to be cleared.

    RESULT: Error code that caused activation data deletion.

    EXCEPTIONS: ELAProductIdException
*)

function GetLastActivationError: UInt32;

(*
    FUNCTION: GetTrialActivationMetadata()

    PURPOSE: Gets the trial activation metadata.

    PARAMETERS:
    * Key - key to retrieve the value

    RESULT: Trial activation metadata

    EXCEPTIONS: ELAProductIdException, ELAMetadataKeyNotFoundException,
    ELABufferSizeException
*)

function GetTrialActivationMetadata(const Key: UnicodeString): UnicodeString;

(*
    FUNCTION: GetTrialExpiryDate()

    PURPOSE: Gets the trial expiry date timestamp.

    RESULT: Trial expiry date timestamp

    EXCEPTIONS: ELAFailException, ELAProductIdException, ELATimeException,
    ELATimeModifiedException
*)

function GetTrialExpiryDate: TDateTime;

(*
    FUNCTION: GetTrialId()

    PURPOSE: Gets the trial activation id. Used in case of trial extension.

    RESULT: Trial activation id

    EXCEPTIONS: ELAFailException, ELAProductIdException, ELATimeException,
    ELATimeModifiedException, ELABufferSizeException
*)

function GetTrialId: UnicodeString;

(*
    FUNCTION: GetLocalTrialExpiryDate()

    PURPOSE: Gets the trial expiry date timestamp.

    RESULT: Trial expiry date timestamp

    EXCEPTIONS: ELAFailException, ELAProductIdException,
    ELATimeModifiedException
*)

function GetLocalTrialExpiryDate: TDateTime;

(*
    FUNCTION: GetLibraryVersion()

    PURPOSE: Gets the version of this library.

    PARAMETERS:
    * libraryVersion - pointer to a buffer that receives the value of the string
    * length - size of the buffer pointed to by the libraryVersion parameter

    RETURN CODES: LA_OK, LA_E_BUFFER_SIZE
*)

function GetLibraryVersion: UnicodeString;

(*
    FUNCTION: CheckForReleaseUpdate()

    PURPOSE: Checks whether a new release is available for the product.

    This function should only be used if you manage your releases through
    Cryptlex release management API.

    PARAMETERS:
    * Platform - release platform e.g. windows, macos, linux
    * Version - current release version
    * Channel - release channel e.g. stable
    * ReleaseUpdateCallback - name of the callback function.

    RETURN CODES: LA_OK, LA_E_PRODUCT_ID, LA_E_LICENSE_KEY, LA_E_RELEASE_VERSION_FORMAT
*)

procedure CheckForReleaseUpdate(const APlatform, Version, Channel: UnicodeString; Callback: TLAProcedureCallback; Synchronized: Boolean); overload;
procedure CheckForReleaseUpdate(const APlatform, Version, Channel: UnicodeString; Callback: TLAMethodCallback; Synchronized: Boolean); overload;
{$IFDEF DELPHI_HAS_CLOSURES}
procedure CheckForReleaseUpdate(const APlatform, Version, Channel: UnicodeString; Callback: TLAClosureCallback; Synchronized: Boolean); overload;
{$ENDIF}

(*
    PROCEDURE: ResetCheckForReleaseUpdateCallback()

    PURPOSE: Resets release update check callback function.
*)

procedure ResetCheckForReleaseUpdateCallback;

(*
    FUNCTION: ActivateLicense()

    PURPOSE: Activates the license by contacting the Cryptlex servers. It
    validates the key and returns with encrypted and digitally signed token
    which it stores and uses to activate your application.

    This function should be executed at the time of registration, ideally on
    a button click.

    RETURN CODES: lkOK, LkExpired, lkSuspended, lkRevoked, lkFail

    EXCEPTIONS: ELAProductIdException, ELAInetException,
    ELAVMException, ELATimeException, ELAActivationLimitException,
    ELAServerException, ELAClientException, ELAAuthenticationFailedException,
    ELALicenseTypeException, ELACountryException, ELAIPException,
    ELARateLimitException, ELALicenseKeyException
*)

function ActivateLicense: TLAKeyStatus;

(*
    FUNCTION: ActivateLicenseOffline()

    PURPOSE: Activates your licenses using the offline activation response file.

    PARAMETERS:
    * FilePath - path of the offline activation response file.

    RETURN CODES: lkOK, lkExpired, lkFail

    EXCEPTIONS: ELAProductIdException, ELALicenseKeyException,
    ELAOfflineResponseFileException, ELAVMException, ELATimeException,
    ELAFilePathException, ELAOfflineResponseFileExpiredException
*)

function ActivateLicenseOffline(const FilePath: UnicodeString): TLAKeyStatus;

(*
    FUNCTION: AuthenticateUser()

    PURPOSE: It sends the request to the Cryptlex servers to authenticate the user.

    PARAMETERS:
    * Email - user email address.
    * Password - user password.

    RETURN CODES: lkOK, lkExpired, lkFail

    EXCEPTIONS: ELAProductIdException, ELATwoFactorAuthenticationCodeMissingException, ELAInetException, ELARateLimitException,
    ELATwoFactorAuthenticationCodeInvalidException, ELAAuthenticationFailedException, ELALoginTemporarilyLockedException, ELAServerException
*)

function AuthenticateUser(const Email , Password: UnicodeString): TLAKeyStatus;

(*
    FUNCTION: AuthenticateUserWithIdToken()

    PURPOSE: Authenticates the user via OIDC Id token.

    PARAMETERS:
    * IdToken - The id token obtained from the OIDC provider.

    RETURN CODES: lkOK, lkExpired, lkFail

    EXCEPTIONS: ELAProductIdException, ELAInetException, ELAServerException, ELARateLimitException, ELAAuthenticationIdTokenInvalidException
    ELAOIDCSSONotEnabledException, ELAUsersLimitReachedException
*)

function AuthenticateUserWithIdToken(const Token: UnicodeString): TLAKeyStatus;

(*
    PROCEDURE: GenerateOfflineActivationRequest()

    PURPOSE: Generates the offline activation request needed for generating
    offline activation response in the dashboard.

    PARAMETERS:
    * FilePath - path of the file for the offline request.

    EXCEPTION: ELAFailException, ELAProductIdException, ELALicenseKeyException,
    ELAFilePermissionException
*)

procedure GenerateOfflineActivationRequest(const FilePath: UnicodeString);

(*
    FUNCTION: DeactivateLicense()

    PURPOSE: Deactivates the license activation and frees up the corresponding activation
    slot by contacting the Cryptlex servers.

    This function should be executed at the time of de-registration, ideally on
    a button click.

    RETURN CODES: lkOk, lkFail

    EXCEPTIONS: ELADeactivationLimitException, ELAProductIdException,
    ELATimeException, ELALicenseKeyException, ELAInetException,
    ELAServerException, ELARateLimitException, ELATimeModifiedException
*)

function DeactivateLicense: TLAKeyStatus;

(*
    PROCEDURE: GenerateOfflineDeactivationRequest()

    PURPOSE: Generates the offline deactivation request needed for deactivation of
    the license in the dashboard and deactivates the license locally.

    A valid offline deactivation file confirms that the license has been successfully
    deactivated on the user's machine.

    PARAMETERS:
    * FilePath - path of the file for the offline request.

    EXCEPTION: ELAFailException, ELAProductIdException, ELALicenseKeyException,
    ELAFilePermissionException, ELATimeException, ELATimeModifiedException
*)

procedure GenerateOfflineDeactivationRequest(const FilePath: UnicodeString);

(*
    FUNCTION: IsLicenseGenuine()

    PURPOSE: It verifies whether your app is genuinely activated or not. The verification is
    done locally by verifying the cryptographic digital signature fetched at the time of
    activation.

    After verifying locally, it schedules a server check in a separate thread. After the
    first server sync it periodically does further syncs at a frequency set for the license.

    In case server sync fails due to network error, and it continues to fail for fixed
    number of days (grace period), the function returns lkGracePeriodOver instead of lkOK.

    This function must be called on every start of your program to verify the activation
    of your app.

    RETURN CODES: lkOK, lkExpired, lkSuspended, lkGracePeriodOver, lkFail

    EXCEPTIONS: ELAProductIdException, ELALicenseKeyException,
    ELATimeException, ELATimeModifiedException, ELAMachineFingerprintException

    NOTE: If application was activated offline using ActivateLicenseOffline() function, you
    may want to set grace period to 0 to ignore grace period.
*)

function IsLicenseGenuine: TLAKeyStatus;

(*
    FUNCTION: IsLicenseValid()

    PURPOSE: It verifies whether your app is genuinely activated or not. The verification is
    done locally by verifying the cryptographic digital signature fetched at the time of
    activation.

    This is just an auxiliary function which you may use in some specific cases, when you
    want to skip the server sync.

    RETURN CODES: lkOK, lkExpired, lkSuspended, lkGracePeriodOver, lkFail

    EXCEPTIONS: ELAProductIdException, ELALicenseKeyException,
    ELATimeException, ELATimeModifiedException, ELAMachineFingerprintException

    NOTE: You may want to set grace period to 0 to ignore grace period.
*)

function IsLicenseValid: TLAKeyStatus;

(*
    FUNCTION: ActivateTrial()

    PURPOSE: Starts the verified trial in your application by contacting the
    Cryptlex servers.

    This function should be executed when your application starts first time on
    the user's computer, ideally on a button click.

    RETURN CODES: lkOK, lkTrialExpired, lkFail

    EXCEPTIONS: ELAProductIdException, ELAInetException,
    ELAVMException, ELATimeException, ELAServerException, ELAClientException,
    ELACountryException, ELAIPException, ELARateLimitException
*)

function ActivateTrial: TLAKeyStatus;

(*
    FUNCTION: ActivateTrialOffline()

    PURPOSE: Activates your trial using the offline activation response file.

    PARAMETERS:
    * FilePath - path of the offline activation response file.

    RETURN CODES: lkOK, lkTrialExpired, lkFail

    EXCEPTIONS: ELAProductIdException,
    ELAOfflineResponseFileException, ELAVMException, ELATimeException,
    ELAFilePathException, ELAOfflineResponseFileExpiredException
*)

function ActivateTrialOffline(const FilePath: UnicodeString): TLAKeyStatus;

(*
    PROCEDURE: GenerateOfflineTrialActivationRequest()

    PURPOSE: Generates the offline trial activation request needed for generating
    offline trial activation response in the dashboard.

    PARAMETERS:
    * FilePath - path of the file for the offline request.

    RETURN CODES: ELAFailException, ELAProductIdException,
    ELAFilePermissionException
*)

procedure GenerateOfflineTrialActivationRequest(const FilePath: UnicodeString);

(*
    FUNCTION: IsTrialGenuine()

    PURPOSE: It verifies whether trial has started and is genuine or not. The
    verification is done locally by verifying the cryptographic digital signature
    fetched at the time of trial activation.

    This function must be called on every start of your program during the trial period.

    RETURN CODES: lkOK, lkTrialExpired, lkFail

    EXCEPTIONS: ELATimeException, ELAProductIdException,
    ELATimeModifiedException

*)

function IsTrialGenuine: TLAKeyStatus;

(*
    FUNCTION: ActivateLocalTrial()

    PURPOSE: Starts the local(unverified) trial.

    This function should be executed when your application starts first time on
    the user's computer.

    PARAMETERS:
    * TrialLength - trial length in days

    RETURN CODES: lkOK, lkLocalTrialExpired, lkFail

    EXCEPTIONS: ELAProductIdException,
    ELATimeModifiedException

    NOTE: The function is only meant for local(unverified) trials.
*)

function ActivateLocalTrial(TrialLength: LongWord): TLAKeyStatus;

(*
    FUNCTION: IsLocalTrialGenuine()

    PURPOSE: It verifies whether trial has started and is genuine or not. The
    verification is done locally.

    This function must be called on every start of your program during the trial period.

    RETURN CODES: lkOK, lkLocalTrialExpired, lkFail

    EXCEPTIONS: ELAProductIdException,
    ELATimeModifiedException

    NOTE: The function is only meant for local(unverified) trials.
*)

function IsLocalTrialGenuine: TLAKeyStatus;

(*
    FUNCTION: ExtendLocalTrial()

    PURPOSE: Extends the local trial.

    PARAMETERS:
    * TrialExtensionLength - number of days to extend the trial

    RETURN CODES: lkOK, lkFail

    EXCEPTIONS: ELAProductIdException,
    ELATimeModifiedException

    NOTE: The function is only meant for local(unverified) trials.
*)

function ExtendLocalTrial(TrialExtensionLength: LongWord): TLAKeyStatus;

(*
    PROCEDURE: IncrementActivationMeterAttributeUses()

    PURPOSE: Increments the meter attribute uses of the activation.

    PARAMETERS:
    * Name - name of the meter attribute
    * Increment - the increment value

    EXCEPTIONS: ELAFailException, ELAProductIdException,
    ELAMeterAttributeNotFoundException, ELAInetException, ELATimeException,
    ELAServerException, ELAClientException,
    ELAMeterAttributeUsesLimitReachedException,
    ELAAuthenticationFailedException, ELACountryException, ELAIPException,
    ELARateLimitException, ELALicenseKeyException
*)

procedure IncrementActivationMeterAttributeUses(const Name: UnicodeString; Increment: LongWord);

(*
    PROCEDURE: DecrementActivationMeterAttributeUses()

    PURPOSE: Decrements the meter attribute uses of the activation.

    PARAMETERS:
    * Name - name of the meter attribute
    * Decrement - the decrement value

    EXCEPTIONS: ELAFailException, ELAProductIdException,
    ELAMeterAttributeNotFoundException, ELAInetException, ELATimeException,
    ELAServerException, ELAClientException, ELARateLimitException,
    ELALicenseKeyException, ELAAuthenticationFailedException,
    ELACountryException, ELAIPException, ELAActivationNotFoundException

    NOTE: If the decrement is more than the current uses, it resets the uses to 0.
*)

procedure DecrementActivationMeterAttributeUses(const Name: UnicodeString; Decrement: LongWord);

(*
    PROCEDURE: ResetActivationMeterAttributeUses()

    PURPOSE: Resets the meter attribute uses consumed by the activation.

    PARAMETERS:
    * name - name of the meter attribute
    * decrement - the decrement value

    EXCEPTIONS: ELAFailException, ELAProductIdException,
    ELAMeterAttributeNotFoundException, ELAInetException, ELATimeException,
    ELAServerException, ELAClientException, ELARateLimitException,
    ELALicenseKeyException, ELAAuthenticationFailedException,
    ELACountryException, ELAIPException, ELAActivationNotFoundException
*)

procedure ResetActivationMeterAttributeUses(const Name: UnicodeString);

(*
    PROCEDURE: LAReset()

    PURPOSE: Resets the activation and trial data stored in the machine.

    This function is meant for developer testing only.

    EXCEPTIONS: ELAProductIdException

    NOTE: The function does not reset local(unverified) trial data.
*)

procedure LAReset;

(*** Exceptions ***)

type
  TLAStatusCode = type Integer;

  {$M+}
  ELAError = class(Exception) // parent of all LexActivator exceptions
  protected
    FErrorCode: TLAStatusCode;
  public
    // create exception of an appropriate class
    class function CreateByCode(ErrorCode: TLAStatusCode): ELAError;

    // check for LA_OK, otherwise raise exception
    class procedure Check(ErrorCode: TLAStatusCode); {$IFDEF DELPHI_HAS_INLINE} inline; {$ENDIF}

    // convert LA_OK into True, LA_FAIL into False, otherwise raise exception
    class function CheckOKFail(ErrorCode: TLAStatusCode): Boolean; {$IFDEF DELPHI_HAS_INLINE} inline; {$ENDIF}

    // convert ErrorCode to TLAKeyStatus, otherwise raise exception
    // LA_FAIL will be converted to lkFail
    class function CheckKeyStatus(ErrorCode: TLAStatusCode): TLAKeyStatus;

    property ErrorCode: TLAStatusCode read FErrorCode;
  end;
  {$M-}

  // Exceptional situation for LA_E_* codes
  ELAException = class(ELAError);

  // Function returned a code not understandable by Delphi binding yet
  ELAUnknownErrorCodeException = class(ELAException)
  protected
    constructor Create(AErrorCode: TLAStatusCode);
  end;

  ELAKeyStatusError = class(ELAError)
  protected
    FKeyStatus: TLAKeyStatus;
  public
    // create exception of an appropriate class
    class function CreateByKeyStatus(KeyStatus: TLAKeyStatus): ELAError;
    property KeyStatus: TLAKeyStatus read FKeyStatus;
  end;

    (*
        CODE: LA_FAIL

        MESSAGE: Failure code.
    *)

  ELAFailException = class(ELAKeyStatusError)
  public
    constructor Create; overload;
    constructor Create(const Msg: string); overload;
    procedure AfterConstruction; override;
  end;

    (*
        CODE: LA_EXPIRED

        MESSAGE: The license has expired or system time has been tampered
        with. Ensure your date and time settings are correct.
    *)

  ELAExpiredError = class(ELAKeyStatusError)
  public
    constructor Create;
  end;

    (*
        CODE: LA_SUSPENDED

        MESSAGE: The license has been suspended.
    *)

  ELASuspendedError = class(ELAKeyStatusError)
  public
    constructor Create;
  end;

    (*
        CODE: LA_GRACE_PERIOD_OVER

        MESSAGE: The grace period for server sync is over.
    *)

  ELAGracePeriodOverError = class(ELAKeyStatusError)
  public
    constructor Create;
  end;

    (*
        CODE: LA_TRIAL_EXPIRED

        MESSAGE: The trial has expired or system time has been tampered
        with. Ensure your date and time settings are correct.
    *)

  ELATrialExpiredError = class(ELAKeyStatusError)
  public
    constructor Create;
  end;

    (*
        CODE: LA_LOCAL_TRIAL_EXPIRED

        MESSAGE: The local trial has expired or system time has been tampered
        with. Ensure your date and time settings are correct.
    *)

  ELALocalTrialExpiredError = class(ELAKeyStatusError)
  public
    constructor Create;
  end;

//    (*
//        CODE: LA_RELEASE_UPDATE_AVAILABLE
//
//        MESSAGE: A new update is available for the product. This means a new release has
//        been published for the product.
//    *)
//    LA_RELEASE_UPDATE_AVAILABLE = 30,
//
//    (*
//        CODE: LA_RELEASE_NO_UPDATE_AVAILABLE
//
//        MESSAGE: No new update is available for the product. The current version is latest.
//    *)
//    LA_RELEASE_NO_UPDATE_AVAILABLE = 31,

    (*
        CODE: LA_E_FILE_PATH

        MESSAGE: Invalid file path.
    *)

  ELAFilePathException = class(ELAException)
  public
    constructor Create;
  end;

    (*
        CODE: LA_E_PRODUCT_FILE

        MESSAGE: Invalid or corrupted product file.
    *)

  ELAProductFileException = class(ELAException)
  public
    constructor Create;
  end;

    (*
        CODE: LA_E_PRODUCT_DATA

        MESSAGE: Invalid product data.
    *)

  ELAProductDataException = class(ELAException)
  public
    constructor Create;
  end;

    (*
        CODE: LA_E_PRODUCT_ID

        MESSAGE: The product id is incorrect.
    *)

  ELAProductIdException = class(ELAException)
  public
    constructor Create;
  end;

    (*
        CODE: LA_E_SYSTEM_PERMISSION

        MESSAGE: Insufficient system permissions. Occurs when LA_SYSTEM flag is used
        but application is not run with admin privileges.
    *)

  ELASystemPermissionException = class(ELAException)
  public
    constructor Create;
  end;

    (*
        CODE: LA_E_FILE_PERMISSION

        MESSAGE: No permission to write to file.
    *)

  ELAFilePermissionException = class(ELAException)
  public
    constructor Create;
  end;

    (*
        CODE: LA_E_WMIC

        MESSAGE: Fingerprint couldn't be generated because Windows Management
        Instrumentation (WMI) service has been disabled. This error is specific
        to Windows only.
    *)

  ELAWMICException = class(ELAException)
  public
    constructor Create;
  end;

    (*
        CODE: LA_E_TIME

        MESSAGE: The difference between the network time and the system time is
        more than allowed clock offset.
    *)

  ELATimeException = class(ELAException)
  public
    constructor Create;
  end;

    (*
        CODE: LA_E_INET

        MESSAGE: Failed to connect to the server due to network error.
    *)

  ELAInetException = class(ELAException)
  public
    constructor Create;
  end;

    (*
        CODE: LA_E_NET_PROXY

        MESSAGE: Invalid network proxy.
    *)

  ELANetProxyException = class(ELAException)
  public
    constructor Create;
  end;

    (*
        CODE: LA_E_HOST_URL

        MESSAGE: Invalid Cryptlex host url.
    *)

  ELAHostURLException = class(ELAException)
  public
    constructor Create;
  end;

    (*
        CODE: LA_E_BUFFER_SIZE

        MESSAGE: The buffer size was smaller than required.
    *)

  ELABufferSizeException = class(ELAException)
  public
    constructor Create;
  end;

    (*
        CODE: LA_E_APP_VERSION_LENGTH

        MESSAGE: App version length is more than 256 characters.
    *)

  ELAAppVersionLengthException = class(ELAException)
  public
    constructor Create;
  end;

    (*
        CODE: LA_E_REVOKED

        MESSAGE: The license has been revoked.
    *)

  ELARevokedException = class(ELAException)
  public
    constructor Create;
  end;

    (*
        CODE: LA_E_LICENSE_KEY

        MESSAGE: Invalid license key.
    *)

  ELALicenseKeyException = class(ELAException)
  public
    constructor Create;
  end;

    (*
        CODE: LA_E_LICENSE_TYPE

        MESSAGE: Invalid license type. Make sure floating license
        is not being used.
    *)

  ELALicenseTypeException = class(ELAException)
  public
    constructor Create;
  end;

    (*
        CODE: LA_E_OFFLINE_RESPONSE_FILE

        MESSAGE: Invalid offline activation response file.
    *)

  ELAOfflineResponseFileException = class(ELAException)
  public
    constructor Create;
  end;

    (*
        CODE: LA_E_OFFLINE_RESPONSE_FILE_EXPIRED

        MESSAGE: The offline activation response has expired.
    *)

  ELAOfflineResponseFileExpiredException = class(ELAException)
  public
    constructor Create;
  end;

    (*
        CODE: LA_E_ACTIVATION_LIMIT

        MESSAGE: The license has reached it's allowed activations limit.
    *)

  ELAActivationLimitException = class(ELAException)
  public
    constructor Create;
  end;

    (*
        CODE: LA_E_ACTIVATION_NOT_FOUND

        MESSAGE: The license activation was deleted on the server.
    *)

  ELAActivationNotFoundException = class(ELAException)
  public
    constructor Create;
  end;

    (*
        CODE: LA_E_DEACTIVATION_LIMIT

        MESSAGE: The license has reached it's allowed deactivations limit.
    *)

  ELADeactivationLimitException = class(ELAException)
  public
    constructor Create;
  end;

    (*
        CODE: LA_E_TRIAL_NOT_ALLOWED

        MESSAGE: Trial not allowed for the product.
    *)

  ELATrialNotAllowedException = class(ELAException)
  public
    constructor Create;
  end;

    (*
        CODE: LA_E_TRIAL_ACTIVATION_LIMIT

        MESSAGE: Your account has reached it's trial activations limit.
    *)

  ELATrialActivationLimitException = class(ELAException)
  public
    constructor Create;
  end;

    (*
        CODE: LA_E_MACHINE_FINGERPRINT

        MESSAGE: Machine fingerprint has changed since activation.
    *)

  ELAMachineFingerprintException = class(ELAException)
  public
    constructor Create;
  end;

    (*
        CODE: LA_E_METADATA_KEY_LENGTH

        MESSAGE: Metadata key length is more than 256 characters.
    *)

  ELAMetadataKeyLengthException = class(ELAException)
  public
    constructor Create;
  end;

    (*
        CODE: LA_E_METADATA_VALUE_LENGTH

        MESSAGE: Metadata value length is more than 256 characters.
    *)

  ELAMetadataValueLengthException = class(ELAException)
  public
    constructor Create;
  end;

    (*
        CODE: LA_E_ACTIVATION_METADATA_LIMIT

        MESSAGE: The license has reached it's metadata fields limit.
    *)

  ELAActivationMetadataLimitException = class(ELAException)
  public
    constructor Create;
  end;

    (*
        CODE: LA_E_TRIAL_ACTIVATION_METADATA_LIMIT

        MESSAGE: The trial has reached it's metadata fields limit.
    *)

  ELATrialActivationMetadataLimitException = class(ELAException)
  public
    constructor Create;
  end;

    (*
        CODE: LA_E_METADATA_KEY_NOT_FOUND

        MESSAGE: The metadata key does not exist.
    *)

  ELAMetadataKeyNotFoundException = class(ELAException)
  public
    constructor Create;
  end;

    (*
        CODE: LA_E_TIME_MODIFIED

        MESSAGE: The system time has been tampered (backdated).
    *)

  ELATimeModifiedException = class(ELAException)
  public
    constructor Create;
  end;

    (*
        CODE: LA_E_RELEASE_VERSION_FORMAT

        MESSAGE: Invalid version format.
    *)

  ELAReleaseVersionFormatException = class(ELAException)
  public
    constructor Create;
  end;

    (*
        CODE: LA_E_AUTHENTICATION_FAILED

        MESSAGE: Incorrect email or password.
    *)

  ELAAuthenticationFailedException = class(ELAException)
  public
    constructor Create;
  end;

    (*
        CODE: LA_E_METER_ATTRIBUTE_NOT_FOUND

        MESSAGE: The meter attribute does not exist.
    *)

  ELAMeterAttributeNotFoundException = class(ELAException)
  public
    constructor Create;
  end;

    (*
        CODE: LA_E_METER_ATTRIBUTE_USES_LIMIT_REACHED

        MESSAGE: The meter attribute has reached it's usage limit.
    *)

  ELAMeterAttributeUsesLimitReachedException = class(ELAException)
  public
    constructor Create;
  end;

    (*
        CODE: LA_E_CUSTOM_FINGERPRINT_LENGTH

        MESSAGE: Custom device fingerprint length is less than 64 characters
        or more than 256 characters.
    *)

  ELACustomFingerprintLengthException = class(ELAException)
  public
    constructor Create;
  end;

    (*
        CODE: LA_E_PRODUCT_VERSION_NOT_LINKED
        MESSAGE: No product version is linked with the license.
    *)
  ELAProductVersionNotLinkedException = class(ELAException)
  public
    constructor Create;
  end;
    (*
        CODE: LA_E_FEATURE_FLAG_NOT_FOUND
        MESSAGE: The product version feature flag does not exist.
    *)
  ELAFeatureFlagNotFoundException = class(ELAException)
  public
    constructor Create;
  end;
    (*
        CODE: LA_E_RELEASE_PLATFORM_LENGTH
        MESSAGE: Release platform length is more than 256 characters.
    *)
  ELAReleasePlatformLengthException = class(ELAException)
  public
    constructor Create;
  end;
    (*
        CODE: LA_E_RELEASE_Channel_LENGTH
        MESSAGE: Release channel length is more than 256 characters.
    *)
  ELAReleaseChannelLengthException = class(ELAException)
  public
    constructor Create;
  end;

    (*
        CODE: LA_E_VM

        MESSAGE: Application is being run inside a virtual machine / hypervisor,
        and activation has been disallowed in the VM.
    *)

  ELAVMException = class(ELAException)
  public
    constructor Create;
  end;

    (*
        CODE: LA_E_COUNTRY

        MESSAGE: Country is not allowed.
    *)

  ELACountryException = class(ELAException)
  public
    constructor Create;
  end;

    (*
        CODE: LA_E_IP

        MESSAGE: IP address is not allowed.
    *)

  ELAIPException = class(ELAException)
  public
    constructor Create;
  end;

    (*
        CODE: LA_E_CONTAINER

        MESSAGE: Application is being run inside a container and
        activation has been disallowed in the container.
    *)

  ELAContainerException = class(ELAException)
  public
    constructor Create;
  end;

    (*
        CODE: LA_E_USER_NOT_AUTHENTICATED

        MESSAGE: Application is being run inside a container and
        activation has been disallowed in the container.
    *)

  ELAUserNotAuthenticatedException = class(ELAException)
  public
    constructor Create;
  end;

    (*
        CODE: LA_E_TWO_FACTOR_AUTHENTICATION_CODE_MISSING

        MESSAGE: The two-factor authentication code for the user authentication is missing.
    *)

  ELATwoFactorAuthenticationCodeMissingException = class(ELAException)
  public
    constructor Create;
  end;

    (*
        CODE: LA_E_TWO_FACTOR_AUTHENTICATION_CODE_INVALID

        MESSAGE: The two-factor authentication code provided by the user is invalid.
    *)

  ELATwoFactorAuthenticationCodeInvalidException = class(ELAException)
  public
    constructor Create;
  end;

    (*
        CODE: LA_E_RATE_LIMIT

        MESSAGE: Rate limit for API has reached, try again later.
    *)

  ELARateLimitException = class(ELAException)
  public
    constructor Create;
  end;

    (*
        CODE: LA_E_SERVER

        MESSAGE: Server error.
    *)

  ELAServerException = class(ELAException)
  public
    constructor Create;
  end;

    (*
        CODE: LA_E_CLIENT

        MESSAGE: Client error.
    *)

  ELAClientException = class(ELAException)
  public
    constructor Create;
  end;

    (*
        CODE: LA_E_ACCOUNT_ID

        MESSAGE: Invalid account ID.
    *)

  ELAAccountIdException = class(ELAException)
  public
    constructor Create;
  end;

    (*
        CODE: LA_E_LOGIN_TEMPORARILY_LOCKED

        MESSAGE: The user account has been temporarily locked for 5 mins due to 5 failed attempts.
    *)

  ELALoginTemporarilyLockedException = class(ELAException)
  public
    constructor Create;
  end;

    (*
        CODE: LA_E_AUTHENTICATION_ID_TOKEN_INVALID

        MESSAGE: Invalid authentication ID token.
    *)

  ELAAuthenticationIdTokenInvalidException = class(ELAException)
  public
    constructor Create;
  end;

    (*
        CODE: LA_E_OIDC_SSO_NOT_ENABLED

        MESSAGE: OIDC SSO is not enabled.
    *)

  ELAOIDCSSONotEnabledException = class(ELAException)
  public
    constructor Create;
  end;

    (*
        CODE: LA_E_USERS_LIMIT_REACHED

        MESSAGE: The allowed users for this account has reached its limit.
    *)

  ELAUsersLimitReachedException = class(ELAException)
  public
    constructor Create;
  end;

    (*
        CODE: LA_E_OS_USER

        MESSAGE: OS user has changed since activation and the license is user-locked.
    *)

  ELAOSUserException = class(ELAException)
  public
    constructor Create;
  end;

    (*
        CODE: LA_E_INVALID_PERMISSION_FLAG

      MESSAGE: Invalid permission flag.
    *)

  ELAInvalidPermissionFlagException = class(ELAException)
  public
    constructor Create;
  end;

    (*
        CODE: LA_E_FREE_PLAN_ACTIVATION_LIMIT_REACHED

        MESSAGE: The free plan has reached it's activation limit.
    *)

  ELAFreePlanActivationLimitReachedException = class(ELAException)
  public
    constructor Create;
  end;

    (*
        CODE: LA_E_FEATURE_ENTITLEMENTS_INVALID

        MESSAGE: Invalid feature entitlements.
    *)

  ELAFeatureEntitlementsInvalidException = class(ELAException)
  public
    constructor Create;
  end;

    (*
        CODE: LA_E_FEATURE_ENTITLEMENT_NOT_FOUND

        MESSAGE: The feature entitlement does not exist.
    *)

  ELAFeatureEntitlementNotFoundException = class(ELAException)
  public
    constructor Create;
  end;

    (*
        CODE: LA_E_ENTITLEMENT_SET_NOT_LINKED

        MESSAGE: No entitlement set is linked to the license.
    *)

  ELAEntitlementSetNotLinkedException = class(ELAException)
  public
    constructor Create;
  end;

    (*
        CODE: LA_E_LICENSE_NOT_EFFECTIVE

        MESSAGE: The license cannot be activated before its effective date.
    *)

  ELALicenseNotEffectiveException = class(ELAException)
  public
    constructor Create;
  end;

implementation

uses
{$IFDEF DELPHI_UNITS_SCOPED}
  System.TypInfo, System.DateUtils, System.Classes, Winapi.Windows
{$ELSE}
  TypInfo, DateUtils, Classes, Windows
{$ENDIF}
  ;

const
  LexActivator_DLL = 'LexActivator.dll';

const
  LAFlagsToLongWord: array[TLAFlags] of LongWord = (1, 2, 3, 4);

function LAFlagsToString(Item: TLAFlags): string;
begin
  if (Item >= Low(TLAFlags)) and (Item <= High(TLAFlags)) then
  begin
    // sane value
    Result := GetEnumName(TypeInfo(TLAFlags), Integer(Item));
  end else begin
    // invalid value, should not appear
    Result := '$' + IntToHex(Integer(Item), 2 * SizeOf(Item));
  end;
end;

function LAKeyStatusToString(Item: TLAKeyStatus): string;
begin
  if (Item >= Low(TLAKeyStatus)) and (Item <= High(TLAKeyStatus)) then
  begin
    // sane value
    Result := GetEnumName(TypeInfo(TLAKeyStatus), Integer(Item));
  end else begin
    // invalid value, should not appear
    Result := '$' + IntToHex(Integer(Item), 2 * SizeOf(Item));
  end;
end;

(*** Return Codes ***)

const

    (*
        CODE: LA_OK

        MESSAGE: Success code.
    *)

  LA_OK = TLAStatusCode(0);

    (*
        CODE: LA_FAIL

        MESSAGE: Failure code.
    *)

  LA_FAIL = TLAStatusCode(1);

    (*
        CODE: LA_EXPIRED

        MESSAGE: The license has expired or system time has been tampered
        with. Ensure your date and time settings are correct.
    *)

  LA_EXPIRED = TLAStatusCode(20);

    (*
        CODE: LA_SUSPENDED

        MESSAGE: The license has been suspended.
    *)

  LA_SUSPENDED = TLAStatusCode(21);

    (*
        CODE: LA_GRACE_PERIOD_OVER

        MESSAGE: The grace period for server sync is over.
    *)

  LA_GRACE_PERIOD_OVER = TLAStatusCode(22);

    (*
        CODE: LA_TRIAL_EXPIRED

        MESSAGE: The trial has expired or system time has been tampered
        with. Ensure your date and time settings are correct.
    *)

  LA_TRIAL_EXPIRED = TLAStatusCode(25);

    (*
        CODE: LA_LOCAL_TRIAL_EXPIRED

        MESSAGE: The local trial has expired or system time has been tampered
        with. Ensure your date and time settings are correct.
    *)

  LA_LOCAL_TRIAL_EXPIRED = TLAStatusCode(26);

    (*
        CODE: LA_RELEASE_UPDATE_AVAILABLE

        MESSAGE: A new update is available for the product. This means a new release has
        been published for the product.
    *)

  LA_RELEASE_UPDATE_AVAILABLE = TLAStatusCode(30);

    (*
        CODE: LA_RELEASE_NO_UPDATE_AVAILABLE

        MESSAGE: No new update is available for the product. The current version is latest.
    *)

  LA_RELEASE_NO_UPDATE_AVAILABLE = TLAStatusCode(31);

    (*
        CODE: LA_E_FILE_PATH

        MESSAGE: Invalid file path.
    *)

  LA_E_FILE_PATH = TLAStatusCode(40);

    (*
        CODE: LA_E_PRODUCT_FILE

        MESSAGE: Invalid or corrupted product file.
    *)

  LA_E_PRODUCT_FILE = TLAStatusCode(41);

    (*
        CODE: LA_E_PRODUCT_DATA

        MESSAGE: Invalid product data.
    *)

  LA_E_PRODUCT_DATA = TLAStatusCode(42);

    (*
        CODE: LA_E_PRODUCT_ID

        MESSAGE: The product id is incorrect.
    *)

  LA_E_PRODUCT_ID = TLAStatusCode(43);

    (*
        CODE: LA_E_SYSTEM_PERMISSION

        MESSAGE: Insufficient system permissions. Occurs when LA_SYSTEM flag is used
        but application is not run with admin privileges.
    *)

  LA_E_SYSTEM_PERMISSION = TLAStatusCode(44);

    (*
        CODE: LA_E_FILE_PERMISSION

        MESSAGE: No permission to write to file.
    *)

  LA_E_FILE_PERMISSION = TLAStatusCode(45);

    (*
        CODE: LA_E_WMIC

        MESSAGE: Fingerprint couldn't be generated because Windows Management
        Instrumentation (WMI) service has been disabled. This error is specific
        to Windows only.
    *)

  LA_E_WMIC = TLAStatusCode(46);

    (*
        CODE: LA_E_TIME

        MESSAGE: The difference between the network time and the system time is
        more than allowed clock offset.
    *)

  LA_E_TIME = TLAStatusCode(47);

    (*
        CODE: LA_E_INET

        MESSAGE: Failed to connect to the server due to network error.
    *)

  LA_E_INET = TLAStatusCode(48);

    (*
        CODE: LA_E_NET_PROXY

        MESSAGE: Invalid network proxy.
    *)

  LA_E_NET_PROXY = TLAStatusCode(49);

    (*
        CODE: LA_E_HOST_URL

        MESSAGE: Invalid Cryptlex host url.
    *)

  LA_E_HOST_URL = TLAStatusCode(50);

    (*
        CODE: LA_E_BUFFER_SIZE

        MESSAGE: The buffer size was smaller than required.
    *)

  LA_E_BUFFER_SIZE = TLAStatusCode(51);

    (*
        CODE: LA_E_APP_VERSION_LENGTH

        MESSAGE: App version length is more than 256 characters.
    *)

  LA_E_APP_VERSION_LENGTH = TLAStatusCode(52);

    (*
        CODE: LA_E_REVOKED

        MESSAGE: The license has been revoked.
    *)

  LA_E_REVOKED = TLAStatusCode(53);

    (*
        CODE: LA_E_LICENSE_KEY

        MESSAGE: Invalid license key.
    *)

  LA_E_LICENSE_KEY = TLAStatusCode(54);

    (*
        CODE: LA_E_LICENSE_TYPE

        MESSAGE: Invalid license type. Make sure floating license
        is not being used.
    *)

  LA_E_LICENSE_TYPE = TLAStatusCode(55);

    (*
        CODE: LA_E_OFFLINE_RESPONSE_FILE

        MESSAGE: Invalid offline activation response file.
    *)

  LA_E_OFFLINE_RESPONSE_FILE = TLAStatusCode(56);

    (*
        CODE: LA_E_OFFLINE_RESPONSE_FILE_EXPIRED

        MESSAGE: The offline activation response has expired.
    *)

  LA_E_OFFLINE_RESPONSE_FILE_EXPIRED = TLAStatusCode(57);

    (*
        CODE: LA_E_ACTIVATION_LIMIT

        MESSAGE: The license has reached it's allowed activations limit.
    *)

  LA_E_ACTIVATION_LIMIT = TLAStatusCode(58);

    (*
        CODE: LA_E_ACTIVATION_NOT_FOUND

        MESSAGE: The license activation was deleted on the server.
    *)

  LA_E_ACTIVATION_NOT_FOUND = TLAStatusCode(59);

    (*
        CODE: LA_E_DEACTIVATION_LIMIT

        MESSAGE: The license has reached it's allowed deactivations limit.
    *)

  LA_E_DEACTIVATION_LIMIT = TLAStatusCode(60);

    (*
        CODE: LA_E_TRIAL_NOT_ALLOWED

        MESSAGE: Trial not allowed for the product.
    *)

  LA_E_TRIAL_NOT_ALLOWED = TLAStatusCode(61);

    (*
        CODE: LA_E_TRIAL_ACTIVATION_LIMIT

        MESSAGE: Your account has reached it's trial activations limit.
    *)

  LA_E_TRIAL_ACTIVATION_LIMIT = TLAStatusCode(62);

    (*
        CODE: LA_E_MACHINE_FINGERPRINT

        MESSAGE: Machine fingerprint has changed since activation.
    *)

  LA_E_MACHINE_FINGERPRINT = TLAStatusCode(63);

    (*
        CODE: LA_E_METADATA_KEY_LENGTH

        MESSAGE: Metadata key length is more than 256 characters.
    *)

  LA_E_METADATA_KEY_LENGTH = TLAStatusCode(64);

    (*
        CODE: LA_E_METADATA_VALUE_LENGTH

        MESSAGE: Metadata value length is more than 256 characters.
    *)

  LA_E_METADATA_VALUE_LENGTH = TLAStatusCode(65);

    (*
        CODE: LA_E_ACTIVATION_METADATA_LIMIT

        MESSAGE: The license has reached it's metadata fields limit.
    *)

  LA_E_ACTIVATION_METADATA_LIMIT = TLAStatusCode(66);

    (*
        CODE: LA_E_TRIAL_ACTIVATION_METADATA_LIMIT

        MESSAGE: The trial has reached it's metadata fields limit.
    *)

  LA_E_TRIAL_ACTIVATION_METADATA_LIMIT = TLAStatusCode(67);

    (*
        CODE: LA_E_METADATA_KEY_NOT_FOUND

        MESSAGE: The metadata key does not exist.
    *)

  LA_E_METADATA_KEY_NOT_FOUND = TLAStatusCode(68);

    (*
        CODE: LA_E_TIME_MODIFIED

        MESSAGE: The system time has been tampered (backdated).
    *)

  LA_E_TIME_MODIFIED = TLAStatusCode(69);

    (*
        CODE: LA_E_RELEASE_VERSION_FORMAT

        MESSAGE: Invalid version format.
    *)

  LA_E_RELEASE_VERSION_FORMAT = TLAStatusCode(70);

    (*
        CODE: LA_E_AUTHENTICATION_FAILED

        MESSAGE: Incorrect email or password.
    *)

  LA_E_AUTHENTICATION_FAILED = TLAStatusCode(71);

    (*
        CODE: LA_E_METER_ATTRIBUTE_NOT_FOUND

        MESSAGE: The meter attribute does not exist.
    *)

  LA_E_METER_ATTRIBUTE_NOT_FOUND = TLAStatusCode(72);

    (*
        CODE: LA_E_METER_ATTRIBUTE_USES_LIMIT_REACHED

        MESSAGE: The meter attribute has reached it's usage limit.
    *)

  LA_E_METER_ATTRIBUTE_USES_LIMIT_REACHED = TLAStatusCode(73);

    (*
        CODE: LA_E_CUSTOM_FINGERPRINT_LENGTH

        MESSAGE: Custom device fingerprint length is less than 64 characters
        or more than 256 characters.
    *)

  LA_E_CUSTOM_FINGERPRINT_LENGTH = TLAStatusCode(74);

    (*
        CODE: LA_E_PRODUCT_VERSION_NOT_LINKED

        MESSAGE: No product version is linked with the license.
    *)

  LA_E_PRODUCT_VERSION_NOT_LINKED = TLAStatusCode(75);

    (*
        CODE: LA_E_FEATURE_FLAG_NOT_FOUND

        MESSAGE: The product version feature flag does not exist.
    *)

  LA_E_FEATURE_FLAG_NOT_FOUND = TLAStatusCode(76);

    (*
        CODE: LA_E_RELEASE_PLATFORM_LENGTH

        MESSAGE: Release platform length is more than 256 characters.
    *)

  LA_E_RELEASE_PLATFORM_LENGTH = TLAStatusCode(78);

    (*
        CODE: LA_E_RELEASE_CHANNEL_LENGTH

        MESSAGE: Release channel length is more than 256 characters.
    *)

  LA_E_RELEASE_CHANNEL_LENGTH = TLAStatusCode(79);

    (*
        CODE: LA_E_VM

        MESSAGE: Application is being run inside a virtual machine / hypervisor,
        and activation has been disallowed in the VM.
    *)

  LA_E_VM = TLAStatusCode(80);

    (*
        CODE: LA_E_COUNTRY

        MESSAGE: Country is not allowed.
    *)

  LA_E_COUNTRY = TLAStatusCode(81);

    (*
        CODE: LA_E_IP

        MESSAGE: IP address is not allowed.
    *)

  LA_E_IP = TLAStatusCode(82);

    (*
        CODE: LA_E_CONTAINER

        MESSAGE: Application is being run inside a container and
        activation has been disallowed in the container.
    *)

  LA_E_CONTAINER = TLAStatusCode(83);

    (*
        CODE: LA_E_USER_NOT_AUTHENTICATED

        MESSAGE: The user is not authenticated.
    *)

  LA_E_USER_NOT_AUTHENTICATED = TLAStatusCode(87);

    (*
        CODE: LA_E_TWO_FACTOR_AUTHENTICATION_CODE_MISSING

        MESSAGE: The two-factor authentication code for the user authentication is missing.
    *)

  LA_E_TWO_FACTOR_AUTHENTICATION_CODE_MISSING = TLAStatusCode(88);

    (*
        CODE: LA_E_TWO_FACTOR_AUTHENTICATION_CODE_INVALID

        MESSAGE: The two-factor authentication code provided by the user is invalid.
    *)

  LA_E_TWO_FACTOR_AUTHENTICATION_CODE_INVALID = TLAStatusCode(89);

    (*
        CODE: LA_E_RATE_LIMIT

        MESSAGE: Rate limit for API has reached, try again later.
    *)

  LA_E_RATE_LIMIT = TLAStatusCode(90);

    (*
        CODE: LA_E_SERVER

        MESSAGE: Server error.
    *)

  LA_E_SERVER = TLAStatusCode(91);

    (*
        CODE: LA_E_CLIENT

        MESSAGE: Client error.
    *)

  LA_E_CLIENT = TLAStatusCode(92);

    (*
        CODE: LA_E_ACCOUNT_ID

        MESSAGE: Invalid account ID.
    *)

  LA_E_ACCOUNT_ID = TLAStatusCode(93);
  
    (*
        CODE: LA_E_LOGIN_TEMPORARILY_LOCKED

        MESSAGE: The user account has been temporarily locked for 5 mins due to 5 failed attempts.
    *)

  LA_E_LOGIN_TEMPORARILY_LOCKED = TLAStatusCode(100);

    (*
        CODE: LA_E_AUTHENTICATION_ID_TOKEN_INVALID

        MESSAGE: Invalid authentication ID token.
    *)

  LA_E_AUTHENTICATION_ID_TOKEN_INVALID = TLAStatusCode(101);

    (*
        CODE: LA_E_OIDC_SSO_NOT_ENABLED

        MESSAGE: OIDC SSO is not enabled.
    *)

  LA_E_OIDC_SSO_NOT_ENABLED = TLAStatusCode(102);

    (*
        CODE: LA_E_USERS_LIMIT_REACHED

        MESSAGE: The allowed users for this account has reached its limit.
    *)

  LA_E_USERS_LIMIT_REACHED = TLAStatusCode(103);

    (*
        CODE: LA_E_OS_USER

        MESSAGE: OS user has changed since activation and the license is user-locked.
    *)

  LA_E_OS_USER = TLAStatusCode(104);

    (*
        CODE: LA_E_INVALID_PERMISSION_FLAG

        MESSAGE: Invalid permission flag.
    *)

  LA_E_INVALID_PERMISSION_FLAG = TLAStatusCode(105);

    (*
        CODE: LA_E_FREE_PLAN_ACTIVATION_LIMIT_REACHED

        MESSAGE: The free plan has reached it's activation limit.
    *)

  LA_E_FREE_PLAN_ACTIVATION_LIMIT_REACHED = TLAStatusCode(106);

    (*
        CODE: LA_E_FEATURE_ENTITLEMENTS_INVALID

        MESSAGE: Invalid feature entitlements.
    *)

  LA_E_FEATURE_ENTITLEMENTS_INVALID = TLAStatusCode(107);

    (*
        CODE: LA_E_FEATURE_ENTITLEMENT_NOT_FOUND

        MESSAGE: The feature entitlement does not exist.
    *)

  LA_E_FEATURE_ENTITLEMENT_NOT_FOUND = TLAStatusCode(108);

    (*
        CODE: LA_E_ENTITLEMENT_SET_NOT_LINKED

        MESSAGE: No entitlement set is linked to the license.
    *)

  LA_E_ENTITLEMENT_SET_NOT_LINKED = TLAStatusCode(109);

    (*
        CODE: LA_E_LICENSE_NOT_EFFECTIVE

        MESSAGE: The license cannot be activated before its effective date.
    *)

  LA_E_LICENSE_NOT_EFFECTIVE = TLAStatusCode(110);

(*********************************************************************************)

function Thin_SetProductFile(const filePath: PWideChar): TLAStatusCode; cdecl;
  external LexActivator_DLL name 'SetProductFile';

procedure SetProductFile(const FilePath: UnicodeString);
begin
  if not ELAError.CheckOKFail(Thin_SetProductFile(PWideChar(FilePath))) then
    raise
    ELAFailException.Create('Failed to set the path of the Product.dat file');
end;

function Thin_SetProductData(const productData: PWideChar): TLAStatusCode; cdecl;
  external LexActivator_DLL name 'SetProductData';

procedure SetProductData(const ProductData: UnicodeString);
begin
  if not ELAError.CheckOKFail(Thin_SetProductData(PWideChar(ProductData))) then
    raise
    ELAFailException.Create('Failed to embed the Product.dat file in the application');
end;

function Thin_SetProductId(const productId: PWideChar; flags: LongWord): TLAStatusCode; cdecl;
  external LexActivator_DLL name 'SetProductId';

procedure SetProductId(const ProductId: UnicodeString; Flags: TLAFlags);
begin
  if not ELAError.CheckOKFail(Thin_SetProductId(PWideChar(ProductId), LAFlagsToLongWord[Flags])) then
    raise
    ELAFailException.CreateFmt('Failed to set the product id of the application ' +
      'to %s', [ProductId]);
end;

function Thin_SetDataDirectory(const directoryPath: PWideChar): TLAStatusCode; cdecl;
  external LexActivator_DLL name 'SetDataDirectory';

procedure SetDataDirectory(const DirectoryPath: UnicodeString);
begin
  if not ELAError.CheckOKFail(Thin_SetDataDirectory(PWideChar(DirectoryPath))) then
    raise
    ELAFailException.CreateFmt('Failed to change the directory used by ' +
      'LexActivator to store the activation data to %s', [DirectoryPath]);
end;

function Thin_SetCustomDeviceFingerprint(const fingerprint: PWideChar): TLAStatusCode; cdecl;
  external LexActivator_DLL name 'SetCustomDeviceFingerprint';

procedure SetCustomDeviceFingerprint(const Fingerprint: UnicodeString);
begin
  if not ELAError.CheckOKFail(Thin_SetCustomDeviceFingerprint(PWideChar(Fingerprint))) then
    raise
    ELAFailException.Create('Failed to set the custom device fingerprint');
end;

function Thin_SetLicenseKey(const licenseKey: PWideChar): TLAStatusCode; cdecl;
  external LexActivator_DLL name 'SetLicenseKey';

procedure SetLicenseKey(const LicenseKey: UnicodeString);
begin
  if not ELAError.CheckOKFail(Thin_SetLicenseKey(PWideChar(LicenseKey))) then
    raise
    ELAFailException.Create('Failed to set the license key');
end;

function Thin_SetReleaseVersion(const releaseVersion: PWideChar): TLAStatusCode; cdecl;
  external LexActivator_DLL name 'SetReleaseVersion';

procedure SetReleaseVersion(const ReleaseVersion: UnicodeString);
begin
  if not ELAError.CheckOKFail(Thin_SetReleaseVersion(PWideChar(ReleaseVersion))) then
    raise
    ELAFailException.Create('Failed to set release version');
end;

function Thin_SetReleasePublishedDate(releasePublishedDate: LongWord): TLAStatusCode; cdecl;
  external LexActivator_DLL name 'SetReleasePublishedDate';

procedure SetReleasePublishedDate(ReleasePublishedDate: LongWord);
begin
  if not ELAError.CheckOKFail(Thin_SetReleasePublishedDate(ReleasePublishedDate)) then
    raise
    ELAFailException.Create('Failed to set the release publish date');
end;

function Thin_SetDebugMode(enable: LongWord): TLAStatusCode; cdecl;
  external LexActivator_DLL name 'SetDebugMode';

procedure SetDebugMode(Enable: LongWord);
begin
  if not ELAError.CheckOKFail(Thin_SetDebugMode(Enable)) then
    raise
    ELAFailException.Create('Failed to set the debug mode');
end;

function Thin_SetCacheMode(enable: Boolean): TLAStatusCode; cdecl;
  external LexActivator_DLL name 'SetCacheMode';

procedure SetCacheMode(Enable: Boolean);
begin
  if not ELAError.CheckOKFail(Thin_SetCacheMode(Enable)) then
    raise
    ELAFailException.Create('Failed to set the cache mode');
end;

function Thin_SetTwoFactorAuthenticationCode(const twoFactorAuthenticationCode: PWideChar): TLAStatusCode; cdecl;
  external LexActivator_DLL name 'SetTwoFactorAuthenticationCode';

procedure SetTwoFactorAuthenticationCode(const TwoFactorAuthenticationCode: UnicodeString);
begin
  if not ELAError.CheckOKFail(Thin_SetTwoFactorAuthenticationCode(PWideChar(TwoFactorAuthenticationCode))) then
    raise
    ELAFailException.Create('Failed to set the two factor authentication code');
end;

function Thin_SetLicenseUserCredential(const email, password: PWideChar): TLAStatusCode; cdecl;
  external LexActivator_DLL name 'SetLicenseUserCredential';

procedure SetLicenseUserCredential(const Email, Password: UnicodeString);
begin
  if not ELAError.CheckOKFail(Thin_SetLicenseUserCredential(PWideChar(Email), PWideChar(Password))) then
    raise
    ELAFailException.Create('Failed to set the license key');
end;

type
  TLAThin_CallbackType = procedure (StatusCode: LongWord); cdecl;

function Thin_SetLicenseCallback(callback: TLAThin_CallbackType): TLAStatusCode; cdecl;
  external LexActivator_DLL name 'SetLicenseCallback';

type
  TLALicenseCallbackKind =
    (lckNone,
     lckProcedure,
     lckMethod
     {$IFDEF DELPHI_HAS_CLOSURES}, lckClosure{$ENDIF});
  TLACallbackIndex = (lciSetLicenseCallback, lciCheckForReleaseUpdate);

var
  LALicenseCallbackKind: array[TLACallbackIndex] of TLALicenseCallbackKind = (lckNone, lckNone);
  LAProcedureCallback: array[TLACallbackIndex] of TLAProcedureCallback;
  LAMethodCallback: array[TLACallbackIndex] of TLAMethodCallback;
  {$IFDEF DELPHI_HAS_CLOSURES}
  LAClosureCallback: array[TLACallbackIndex] of TLAClosureCallback;
  {$ENDIF}
  LALicenseCallbackSynchronized: array[TLACallbackIndex] of Boolean;
  LAStatusCode: array[TLACallbackIndex] of TLAStatusCode;
  LALicenseCallbackMutex: array[TLACallbackIndex] of TRTLCriticalSection;

type
  TLAThin_BaseCallbackProxyClass = class
  public
    class procedure Invoke;
  protected
    class function ProxyIndex: TLACallbackIndex; virtual; abstract;
  end;

  TLAThin_LicenseCallbackProxyClass = class(TLAThin_BaseCallbackProxyClass)
  protected
    class function ProxyIndex: TLACallbackIndex; override;
  end;

  TLAThin_UpdateCallbackProxyClass = class(TLAThin_BaseCallbackProxyClass)
  protected
    class function ProxyIndex: TLACallbackIndex; override;
  end;

class procedure TLAThin_BaseCallbackProxyClass.Invoke;
var
  KeyStatus: TLAKeyStatus;
  LocalProxyIndex: TLACallbackIndex;

  procedure DoInvoke(const Error: Exception);
  begin
    case LALicenseCallbackKind[LocalProxyIndex] of
      lckNone: Exit;
      lckProcedure:
        if Assigned(LAProcedureCallback[LocalProxyIndex]) then
          LAProcedureCallback[LocalProxyIndex](Error, KeyStatus);
      lckMethod:
        if Assigned(LAMethodCallback[LocalProxyIndex]) then
          LAMethodCallback[LocalProxyIndex](Error, KeyStatus);
      {$IFDEF DELPHI_HAS_CLOSURES}
      lckClosure:
        if Assigned(LAClosureCallback[LocalProxyIndex]) then
          LAClosureCallback[LocalProxyIndex](Error, KeyStatus);
      {$ENDIF}
    else
      // there should be default logging here like NSLog, but there is none in Delphi
    end;
  end;

var
  FailError: Exception;

begin
  try
    LocalProxyIndex := ProxyIndex;

    EnterCriticalSection(LALicenseCallbackMutex[LocalProxyIndex]);
    try
      case LALicenseCallbackKind[LocalProxyIndex] of
        lckNone: Exit;
        lckProcedure: if not Assigned(LAProcedureCallback[LocalProxyIndex]) then Exit;
        lckMethod: if not Assigned(LAMethodCallback[LocalProxyIndex]) then Exit;
        {$IFDEF DELPHI_HAS_CLOSURES}
        lckClosure: if not Assigned(LAClosureCallback[LocalProxyIndex]) then Exit;
        {$ENDIF}
      else
        // there should be default logging here like NSLog, but there is none in Delphi
      end;

      try
        KeyStatus := ELAError.CheckKeyStatus(LAStatusCode[LocalProxyIndex]);
      except
        on Error: ELAError do
        begin
          KeyStatus := lkException;
          DoInvoke(Error);
          Exit;
        end;
      end;

      FailError := nil;
      try
        FailError := ELAError.CreateByCode(LAStatusCode[LocalProxyIndex]);
        DoInvoke(FailError);
      finally
        FreeAndNil(FailError);
      end;
    finally
      // This recursive mutex prevents the following scenario:
      //
      // (Main thread)    SetLicenseCallback
      // (Tangent thread) LAThin_CallbackProxy going to invoke X.OnLexActivator
      // (Main thread)    ResetLicenseCallback
      // (Main thread)    X.Free
      //
      // Main thread is not allowed to proceed to X.Free until callback is finished
      // On the other hand, if callback removes itself, recursive mutex will allow that
      LeaveCriticalSection(LALicenseCallbackMutex[LocalProxyIndex]);
    end;
  except
    // there should be default logging here like NSLog, but there is none in Delphi
  end;
end;

class function TLAThin_LicenseCallbackProxyClass.ProxyIndex: TLACallbackIndex;
begin
  Result := lciSetLicenseCallback;
end;

class function TLAThin_UpdateCallbackProxyClass.ProxyIndex: TLACallbackIndex;
begin
  Result := lciCheckForReleaseUpdate;
end;

procedure LAThin_CallbackProxy(StatusCode: LongWord); cdecl;
const
  LocalProxyIndex = lciSetLicenseCallback;
type
  TLAThin_CallbackProxyClass = TLAThin_LicenseCallbackProxyClass;
begin
  try
    EnterCriticalSection(LALicenseCallbackMutex[LocalProxyIndex]);
    try
      case LALicenseCallbackKind[LocalProxyIndex] of
        lckNone: Exit;
        lckProcedure: if not Assigned(LAProcedureCallback[LocalProxyIndex]) then Exit;
        lckMethod: if not Assigned(LAMethodCallback[LocalProxyIndex]) then Exit;
        {$IFDEF DELPHI_HAS_CLOSURES}
        lckClosure: if not Assigned(LAClosureCallback[LocalProxyIndex]) then Exit;
        {$ENDIF}
      else
        // there should be default logging here like NSLog, but there is none in Delphi
      end;

      LAStatusCode[LocalProxyIndex] := TLAStatusCode(StatusCode);
      if not LALicenseCallbackSynchronized[LocalProxyIndex] then
      begin
        TLAThin_CallbackProxyClass.Invoke;
        Exit;
      end;
    finally
      LeaveCriticalSection(LALicenseCallbackMutex[LocalProxyIndex]);
    end;

    // Race condition here
    //
    // Invoke should probably run exactly the same (captured) handler,
    // but instead it reenters mutex, and handler can be different at
    // that moment. For most sane use cases behavior should be sound
    // anyway.

    TThread.Synchronize(nil, TLAThin_CallbackProxyClass.Invoke);
  except
    // there should be default logging here like NSLog, but there is none in Delphi
  end;
end;

procedure LAThin_CallbackProxy2(StatusCode: LongWord); cdecl;
const
  LocalProxyIndex = lciCheckForReleaseUpdate;
type
  TLAThin_CallbackProxyClass = TLAThin_UpdateCallbackProxyClass;
begin
  try
    EnterCriticalSection(LALicenseCallbackMutex[LocalProxyIndex]);
    try
      case LALicenseCallbackKind[LocalProxyIndex] of
        lckNone: Exit;
        lckProcedure: if not Assigned(LAProcedureCallback[LocalProxyIndex]) then Exit;
        lckMethod: if not Assigned(LAMethodCallback[LocalProxyIndex]) then Exit;
        {$IFDEF DELPHI_HAS_CLOSURES}
        lckClosure: if not Assigned(LAClosureCallback[LocalProxyIndex]) then Exit;
        {$ENDIF}
      else
        // there should be default logging here like NSLog, but there is none in Delphi
      end;

      LAStatusCode[LocalProxyIndex] := TLAStatusCode(StatusCode);
      if not LALicenseCallbackSynchronized[LocalProxyIndex] then
      begin
        TLAThin_CallbackProxyClass.Invoke;
        Exit;
      end;
    finally
      LeaveCriticalSection(LALicenseCallbackMutex[LocalProxyIndex]);
    end;

    // Race condition here
    //
    // Invoke should probably run exactly the same (captured) handler,
    // but instead it reenters mutex, and handler can be different at
    // that moment. For most sane use cases behavior should be sound
    // anyway.

    TThread.Synchronize(nil, TLAThin_CallbackProxyClass.Invoke);
  except
    // there should be default logging here like NSLog, but there is none in Delphi
  end;
end;

procedure SetLicenseCallback(Callback: TLAProcedureCallback; Synchronized: Boolean);
const
  LocalProxyIndex = lciSetLicenseCallback;
begin
  EnterCriticalSection(LALicenseCallbackMutex[LocalProxyIndex]);
  try
    LAProcedureCallback[LocalProxyIndex] := Callback;
    LALicenseCallbackSynchronized[LocalProxyIndex] := Synchronized;
    LALicenseCallbackKind[LocalProxyIndex] := lckProcedure;

    if not ELAError.CheckOKFail(Thin_SetLicenseCallback(LAThin_CallbackProxy)) then
      raise
      ELAFailException.Create('Failed to set server sync callback');
  finally
    LeaveCriticalSection(LALicenseCallbackMutex[LocalProxyIndex]);
  end;
end;

procedure SetLicenseCallback(Callback: TLAMethodCallback; Synchronized: Boolean);
const
  LocalProxyIndex = lciSetLicenseCallback;
begin
  EnterCriticalSection(LALicenseCallbackMutex[LocalProxyIndex]);
  try
    LAMethodCallback[LocalProxyIndex] := Callback;
    LALicenseCallbackSynchronized[LocalProxyIndex] := Synchronized;
    LALicenseCallbackKind[LocalProxyIndex] := lckMethod;

    if not ELAError.CheckOKFail(Thin_SetLicenseCallback(LAThin_CallbackProxy)) then
      raise
      ELAFailException.Create('Failed to set server sync callback');
  finally
    LeaveCriticalSection(LALicenseCallbackMutex[LocalProxyIndex]);
  end;
end;

{$IFDEF DELPHI_HAS_CLOSURES}
procedure SetLicenseCallback(Callback: TLAClosureCallback; Synchronized: Boolean);
const
  LocalProxyIndex = lciSetLicenseCallback;
begin
  EnterCriticalSection(LALicenseCallbackMutex[LocalProxyIndex]);
  try
    LAClosureCallback[LocalProxyIndex] := Callback;
    LALicenseCallbackSynchronized[LocalProxyIndex] := Synchronized;
    LALicenseCallbackKind[LocalProxyIndex] := lckClosure;

    if not ELAError.CheckOKFail(Thin_SetLicenseCallback(LAThin_CallbackProxy)) then
      raise
      ELAFailException.Create('Failed to set server sync callback');
  finally
    LeaveCriticalSection(LALicenseCallbackMutex[LocalProxyIndex]);
  end;
end;
{$ENDIF}

procedure LAThin_CallbackDummy(StatusCode: LongWord); cdecl;
begin
  ;
end;

procedure ResetLicenseCallback;
const
  LocalProxyIndex = lciSetLicenseCallback;
begin
  EnterCriticalSection(LALicenseCallbackMutex[LocalProxyIndex]);
  try
    LALicenseCallbackKind[LocalProxyIndex] := lckNone;

    if not ELAError.CheckOKFail(Thin_SetLicenseCallback(LAThin_CallbackDummy)) then
      raise
      ELAFailException.Create('Failed to set server sync callback');
  finally
    LeaveCriticalSection(LALicenseCallbackMutex[LocalProxyIndex]);
  end;
end;

function Thin_SetActivationLeaseDuration(leaseDuration: Int64): TLAStatusCode; cdecl;
  external LexActivator_DLL name 'SetActivationLeaseDuration';

procedure SetActivationLeaseDuration(LeaseDuration: Int64);
begin
  if not ELAError.CheckOKFail(Thin_SetActivationLeaseDuration(LeaseDuration)) then
    raise
    ELAFailException.Create('Failed to set the lease duration for the activation');
end;

function Thin_SetActivationMetadata(const key, value: PWideChar): TLAStatusCode; cdecl;
  external LexActivator_DLL name 'SetActivationMetadata';

procedure SetActivationMetadata(const Key, Value: UnicodeString);
begin
  if not ELAError.CheckOKFail(Thin_SetActivationMetadata(PWideChar(Key), PWideChar(Value))) then
    raise
    ELAFailException.Create('Failed to set the activation metadata');
end;

function Thin_SetTrialActivationMetadata(const key, value: PWideChar): TLAStatusCode; cdecl;
  external LexActivator_DLL name 'SetTrialActivationMetadata';

procedure SetTrialActivationMetadata(const Key, Value: UnicodeString);
begin
  if not ELAError.CheckOKFail(Thin_SetTrialActivationMetadata(PWideChar(Key), PWideChar(Value))) then
    raise
    ELAFailException.Create('Failed to set the trial activation metadata');
end;

function Thin_SetAppVersion(const appVersion: PWideChar): TLAStatusCode; cdecl;
  external LexActivator_DLL name 'SetAppVersion';

procedure SetAppVersion(const AppVersion: UnicodeString);
begin
  if not ELAError.CheckOKFail(Thin_SetAppVersion(PWideChar(AppVersion))) then
    raise
    ELAFailException.CreateFmt('Failed to set the current app version of the ' +
    'application to %s', [AppVersion]);
end;

function Thin_SetOfflineActivationRequestMeterAttributeUses
  (const name: PWideChar; AUses: LongWord): TLAStatusCode; cdecl;
  external LexActivator_DLL name 'SetOfflineActivationRequestMeterAttributeUses';

procedure SetOfflineActivationRequestMeterAttributeUses
  (const Name: UnicodeString; AUses: LongWord);
begin
  if not ELAError.CheckOKFail(Thin_SetOfflineActivationRequestMeterAttributeUses(PWideChar(Name), AUses)) then
    raise
    ELAFailException.CreateFmt('Failed to set the meter attribute %s uses for the offline activation request', [Name]);
end;

function Thin_SetNetworkProxy(const proxy: PWideChar): TLAStatusCode; cdecl;
  external LexActivator_DLL name 'SetNetworkProxy';

procedure SetNetworkProxy(const Proxy: UnicodeString);
begin
  if not ELAError.CheckOKFail(Thin_SetNetworkProxy(PWideChar(Proxy))) then
    raise
    ELAFailException.CreateFmt('Failed to set the network proxy to ' +
    '%s', [Proxy]);
end;

function Thin_SetCryptlexHost(const host: PWideChar): TLAStatusCode; cdecl;
  external LexActivator_DLL name 'SetCryptlexHost';

procedure SetCryptlexHost(const Host: UnicodeString);
begin
  if not ELAError.CheckOKFail(Thin_SetCryptlexHost(PWideChar(Host))) then
    raise
    ELAFailException.CreateFmt('Failed to set the ' +
      'host for your on-premise server to %s', [Host]);
end;

function Thin_GetProductMetadata(const key: PWideChar; out value; length: LongWord): TLAStatusCode; cdecl;
  external LexActivator_DLL name 'GetProductMetadata';

function GetProductMetadata(const Key: UnicodeString): UnicodeString;
var
  ErrorCode: TLAStatusCode;
  function Try256(var OuterResult: UnicodeString): Boolean;
  var
    Buffer: array[0 .. 255] of WideChar;
  begin
    ErrorCode := Thin_GetProductMetadata(PWideChar(Key), Buffer, Length(Buffer));
    Result := ErrorCode <> LA_E_BUFFER_SIZE;
    if ErrorCode = LA_OK then OuterResult := Buffer;
  end;
  function TryHigh(var OuterResult: UnicodeString): Boolean;
  var
    Buffer: UnicodeString;
    Size: Integer;
  begin
    Size := 512;
    repeat
      Size := Size * 2;
      SetLength(Buffer, 0);
      SetLength(Buffer, Size);
      ErrorCode := Thin_GetProductMetadata(PWideChar(Key), PWideChar(Buffer)^, Size);
      Result := ErrorCode <> LA_E_BUFFER_SIZE;
    until Result or (Size >= 128 * 1024);
    if ErrorCode = LA_OK then OuterResult := PWideChar(Buffer);
  end;
begin
  if not Try256(Result) then TryHigh(Result);
  if not ELAError.CheckOKFail(ErrorCode) then
    raise ELAFailException.CreateFmt('Failed to get the product metadata with key %s', [Key]);
end;

function Thin_GetProductVersionName(out name; length: LongWord): TLAStatusCode; cdecl;
  external LexActivator_DLL name 'GetProductVersionName';

function GetProductVersionName: UnicodeString;
var
  ErrorCode: TLAStatusCode;
  function Try256(var OuterResult: UnicodeString): Boolean;
  var
    Buffer: array[0 .. 255] of WideChar;
  begin
    ErrorCode := Thin_GetProductVersionName(Buffer, Length(Buffer));
    Result := ErrorCode <> LA_E_BUFFER_SIZE;
    if ErrorCode = LA_OK then OuterResult := Buffer;
  end;
  function TryHigh(var OuterResult: UnicodeString): Boolean;
  var
    Buffer: UnicodeString;
    Size: Integer;
  begin
    Size := 512;
    repeat
      Size := Size * 2;
      SetLength(Buffer, 0);
      SetLength(Buffer, Size);
      ErrorCode := Thin_GetProductVersionName(PWideChar(Buffer)^, Size);
      Result := ErrorCode <> LA_E_BUFFER_SIZE;
    until Result or (Size >= 128 * 1024);
    if ErrorCode = LA_OK then OuterResult := PWideChar(Buffer);
  end;
begin
  if not Try256(Result) then TryHigh(Result);
  if not ELAError.CheckOKFail(ErrorCode) then
    raise ELAFailException.Create('Failed to get the product version name');
end;

function Thin_GetProductVersionDisplayName(out displayName; length: LongWord): TLAStatusCode; cdecl;
  external LexActivator_DLL name 'GetProductVersionDisplayName';

function GetProductVersionDisplayName: UnicodeString;
var
  ErrorCode: TLAStatusCode;
  function Try256(var OuterResult: UnicodeString): Boolean;
  var
    Buffer: array[0 .. 255] of WideChar;
  begin
    ErrorCode := Thin_GetProductVersionDisplayName(Buffer, Length(Buffer));
    Result := ErrorCode <> LA_E_BUFFER_SIZE;
    if ErrorCode = LA_OK then OuterResult := Buffer;
  end;
  function TryHigh(var OuterResult: UnicodeString): Boolean;
  var
    Buffer: UnicodeString;
    Size: Integer;
  begin
    Size := 512;
    repeat
      Size := Size * 2;
      SetLength(Buffer, 0);
      SetLength(Buffer, Size);
      ErrorCode := Thin_GetProductVersionDisplayName(PWideChar(Buffer)^, Size);
      Result := ErrorCode <> LA_E_BUFFER_SIZE;
    until Result or (Size >= 128 * 1024);
    if ErrorCode = LA_OK then OuterResult := PWideChar(Buffer);
  end;
begin
  if not Try256(Result) then TryHigh(Result);
  if not ELAError.CheckOKFail(ErrorCode) then
    raise ELAFailException.Create('Failed to get the product version display name');
end;

function Thin_GetProductVersionFeatureFlag(const name: PWideChar; out enabled: LongWord; out data; length: LongWord): TLAStatusCode; cdecl;
  external LexActivator_DLL name 'GetProductVersionFeatureFlag';

function GetProductVersionFeatureFlag(const Name: UnicodeString; out Data: UnicodeString): Boolean;
var
  Enabled: LongWord;
  ErrorCode: TLAStatusCode;
  function Try256(var OuterResult: UnicodeString): Boolean;
  var
    Buffer: array[0 .. 255] of WideChar;
  begin
    ErrorCode := Thin_GetProductVersionFeatureFlag(PWideChar(Name), Enabled, Buffer, Length(Buffer));
    Result := ErrorCode <> LA_E_BUFFER_SIZE;
    if ErrorCode = LA_OK then OuterResult := Buffer;
  end;
  function TryHigh(var OuterResult: UnicodeString): Boolean;
  var
    Buffer: UnicodeString;
    Size: Integer;
  begin
    Size := 512;
    repeat
      Size := Size * 2;
      SetLength(Buffer, 0);
      SetLength(Buffer, Size);
      ErrorCode := Thin_GetProductVersionFeatureFlag(PWideChar(Name), Enabled, PWideChar(Buffer)^, Size);
      Result := ErrorCode <> LA_E_BUFFER_SIZE;
    until Result or (Size >= 128 * 1024);
    if ErrorCode = LA_OK then OuterResult := PWideChar(Buffer);
  end;
begin
  Enabled := 0;
  if not Try256(Data) then TryHigh(Data);
  if not ELAError.CheckOKFail(ErrorCode) then
    raise ELAFailException.Create('Failed to get the product version feature flag');
  Result := Enabled <> 0;
end;

function Thin_GetLicenseEntitlementSetName(out name; length: LongWord): TLAStatusCode; cdecl;
  external LexActivator_DLL name 'GetLicenseEntitlementSetName';

function GetLicenseEntitlementSetName: UnicodeString;
var
  ErrorCode: TLAStatusCode;
  function Try256(var OuterResult: UnicodeString): Boolean;
  var
    Buffer: array[0 .. 255] of WideChar;
  begin
    ErrorCode := Thin_GetLicenseEntitlementSetName(Buffer, Length(Buffer));
    Result := ErrorCode <> LA_E_BUFFER_SIZE;
    if ErrorCode = LA_OK then OuterResult := Buffer;
  end;
  function TryHigh(var OuterResult: UnicodeString): Boolean;
  var
    Buffer: UnicodeString;
    Size: Integer;
  begin
    Size := 512;
    repeat
      Size := Size * 2;
      SetLength(Buffer, 0);
      SetLength(Buffer, Size);
      ErrorCode := Thin_GetLicenseEntitlementSetName(PWideChar(Buffer)^, Size);
      Result := ErrorCode <> LA_E_BUFFER_SIZE;
    until Result or (Size >= 128 * 1024);
    if ErrorCode = LA_OK then OuterResult := PWideChar(Buffer);
  end;
begin
  if not Try256(Result) then TryHigh(Result);
  if not ELAError.CheckOKFail(ErrorCode) then
    raise ELAFailException.Create('Failed to get the license entitlement set name');
end;

function Thin_GetLicenseEntitlementSetDisplayName(out displayName; length: LongWord): TLAStatusCode; cdecl;
  external LexActivator_DLL name 'GetLicenseEntitlementSetDisplayName';

function GetLicenseEntitlementSetDisplayName: UnicodeString;
var
  ErrorCode: TLAStatusCode;
  function Try256(var OuterResult: UnicodeString): Boolean;
  var
    Buffer: array[0 .. 255] of WideChar;
  begin
    ErrorCode := Thin_GetLicenseEntitlementSetDisplayName(Buffer, Length(Buffer));
    Result := ErrorCode <> LA_E_BUFFER_SIZE;
    if ErrorCode = LA_OK then OuterResult := Buffer;
  end;
  function TryHigh(var OuterResult: UnicodeString): Boolean;
  var
    Buffer: UnicodeString;
    Size: Integer;
  begin
    Size := 512;
    repeat
      Size := Size * 2;
      SetLength(Buffer, 0);
      SetLength(Buffer, Size);
      ErrorCode := Thin_GetLicenseEntitlementSetDisplayName(PWideChar(Buffer)^, Size);
      Result := ErrorCode <> LA_E_BUFFER_SIZE;
    until Result or (Size >= 128 * 1024);
    if ErrorCode = LA_OK then OuterResult := PWideChar(Buffer);
  end;
begin
  if not Try256(Result) then TryHigh(Result);
  if not ELAError.CheckOKFail(ErrorCode) then
    raise ELAFailException.Create('Failed to get the license entitlement set display name');
end;

function Thin_GetFeatureEntitlement(const featureName: PWideChar; out featureEntitlement; length: LongWord): TLAStatusCode; cdecl;
  external LexActivator_DLL name 'GetFeatureEntitlementInternal';

function GetFeatureEntitlement(const FeatureName: UnicodeString): TFeatureEntitlement;
var
  ErrorCode: TLAStatusCode;
  JSONString: UnicodeString;
  JSONObject: TJSONObject;
  FeatureEntitlement: TFeatureEntitlement;

  function GetJSONStrValue(const JSONObject: TJSONObject; const FieldName: string): string;
  var
    JSONValue: TJSONValue;
  begin
    Result := '';
    JSONValue := JSONObject.GetValue(FieldName);
    if JSONValue <> nil then
      Result := JSONValue.Value;
  end;

  function GetJSONInt64Value(const JSONObject: TJSONObject; const FieldName: string): Int64;
  var
    JSONValue: TJSONValue;
  begin
    Result := 0;
    JSONValue := JSONObject.GetValue(FieldName);
    if (JSONValue <> nil) and JSONValue.TryGetValue(Result) then
      Exit;
  end;

  function Try256(var OuterResult: UnicodeString): Boolean;
  var
    Buffer: array[0 .. 255] of WideChar;
  begin
    ErrorCode := Thin_GetFeatureEntitlement(PWideChar(FeatureName), Buffer, Length(Buffer));
    Result := ErrorCode <> LA_E_BUFFER_SIZE;
    if ErrorCode = LA_OK then
      OuterResult := Buffer;
  end;

  function TryHigh(var OuterResult: UnicodeString): Boolean;
  var
    Buffer: UnicodeString;
    Size: Integer;
  begin
    Size := 512;
    repeat
      Size := Size * 2;
      SetLength(Buffer, Size);
      ErrorCode := Thin_GetFeatureEntitlement(PWideChar(FeatureName), PWideChar(Buffer)^, Size);
      Result := ErrorCode <> LA_E_BUFFER_SIZE;
    until Result or (Size >= 128 * 1024);
    if ErrorCode = LA_OK then
      OuterResult := PWideChar(Buffer);
  end;

begin
  if not Try256(JSONString) then TryHigh(JSONString);

  if not ELAError.CheckOKFail(ErrorCode) then
    raise ELAFailException.Create('Failed to get feature entitlement');

  JSONObject := TJSONObject.ParseJSONValue(JSONString) as TJSONObject;

  try
    FeatureEntitlement.FeatureName := GetJSONStrValue(JSONObject, 'featureName');
    FeatureEntitlement.FeatureDisplayName := GetJSONStrValue(JSONObject, 'featureDisplayName');
    FeatureEntitlement.Value := GetJSONStrValue(JSONObject, 'value');
    FeatureEntitlement.ExpiresAt := GetJSONInt64Value(JSONObject, 'expiresAt');
  finally
    JSONObject.Free;
  end;

  Result := FeatureEntitlement;
end;


function Thin_GetFeatureEntitlements(out featureEntitlements; length: LongWord): TLAStatusCode; cdecl;
  external LexActivator_DLL name 'GetFeatureEntitlementsInternal';

function GetFeatureEntitlements: TArray<TFeatureEntitlement>;
var
  ErrorCode: TLAStatusCode;
  JSONString: UnicodeString;
  JSONArray: TJSONArray;
  FeatureEntitlement: TFeatureEntitlement;
  I: Integer;

  function GetJSONStrValue(const JSONObject: TJSONObject; const FieldName: string): string;
  var
    JSONValue: TJSONValue;
  begin
    Result := '';
    JSONValue := JSONObject.GetValue(FieldName);
    if JSONValue <> nil then
      Result := JSONValue.Value;
  end;

  function GetJSONInt64Value(const JSONObject: TJSONObject; const FieldName: string): Int64;
  var
    JSONValue: TJSONValue;
  begin
    Result := 0;
    JSONValue := JSONObject.GetValue(FieldName);
    if (JSONValue <> nil) and JSONValue.TryGetValue(Result) then
      Exit;
  end;

  function Try256(var OuterResult: UnicodeString): Boolean;
  var
    Buffer: array[0..255] of WideChar;
  begin
    ErrorCode := Thin_GetFeatureEntitlements(Buffer, Length(Buffer));
    Result := ErrorCode <> LA_E_BUFFER_SIZE;
    if ErrorCode = LA_OK then
      OuterResult := Buffer;
  end;

  function TryHigh(var OuterResult: UnicodeString): Boolean;
  var
    Buffer: UnicodeString;
    Size: Integer;
  begin
    Size := 512;
    repeat
      Size := Size * 2;
      SetLength(Buffer, Size);
      ErrorCode := Thin_GetFeatureEntitlements(PWideChar(Buffer)^, Size);
      Result := ErrorCode <> LA_E_BUFFER_SIZE;
    until Result or (Size >= 128 * 1024);
    if ErrorCode = LA_OK then
      OuterResult := PWideChar(Buffer);
  end;

begin
  Result := nil;
  if not Try256(JSONString) then TryHigh(JSONString);
  if not ELAError.CheckOKFail(ErrorCode) then
    raise ELAFailException.Create('Failed to get feature entitlements');

  // If JSON string is empty, return empty array
  if JSONString = '' then
    Exit;

  JSONArray := TJSONObject.ParseJSONValue(JSONString) as TJSONArray;
  try
    if JSONArray <> nil then
    begin
      SetLength(Result, JSONArray.Count);
      for I := 0 to JSONArray.Count - 1 do
      begin
        FeatureEntitlement := Default(TFeatureEntitlement);
        FeatureEntitlement.FeatureName := GetJSONStrValue(JSONArray.Items[I] as TJSONObject, 'featureName');
        FeatureEntitlement.FeatureDisplayName := GetJSONStrValue(JSONArray.Items[I] as TJSONObject, 'featureDisplayName');
        FeatureEntitlement.Value := GetJSONStrValue(JSONArray.Items[I] as TJSONObject, 'value');
        FeatureEntitlement.ExpiresAt := GetJSONInt64Value(JSONArray.Items[I] as TJSONObject, 'expiresAt');
        Result[I] := FeatureEntitlement;
      end;
    end;
  finally
    JSONArray.Free;
  end;
end;

function Thin_GetLicenseMetadata(const key: UnicodeString; out value; length: LongWord): TLAStatusCode; cdecl;
  external LexActivator_DLL name 'GetLicenseMetadata';

function GetLicenseMetadata(const Key: UnicodeString): UnicodeString;
var
  ErrorCode: TLAStatusCode;
  function Try256(var OuterResult: UnicodeString): Boolean;
  var
    Buffer: array[0 .. 255] of WideChar;
  begin
    ErrorCode := Thin_GetLicenseMetadata(PWideChar(Key), Buffer, Length(Buffer));
    Result := ErrorCode <> LA_E_BUFFER_SIZE;
    if ErrorCode = LA_OK then OuterResult := Buffer;
  end;
  function TryHigh(var OuterResult: UnicodeString): Boolean;
  var
    Buffer: UnicodeString;
    Size: Integer;
  begin
    Size := 512;
    repeat
      Size := Size * 2;
      SetLength(Buffer, 0);
      SetLength(Buffer, Size);
      ErrorCode := Thin_GetLicenseMetadata(PWideChar(Key), PWideChar(Buffer)^, Size);
      Result := ErrorCode <> LA_E_BUFFER_SIZE;
    until Result or (Size >= 128 * 1024);
    if ErrorCode = LA_OK then OuterResult := PWideChar(Buffer);
  end;
begin
  if not Try256(Result) then TryHigh(Result);
  if not ELAError.CheckOKFail(ErrorCode) then
    raise ELAFailException.CreateFmt('Failed to get the license metadata with key %s', [Key]);
end;

function Thin_GetLicenseMeterAttribute
  (const name: PWideChar; out allowedUses: Int64; out totalUses, grossUses: UInt64): TLAStatusCode; cdecl;
  external LexActivator_DLL name 'GetLicenseMeterAttribute';

procedure GetLicenseMeterAttribute
  (const Name: UnicodeString; out AllowedUses: Int64; TotalUses, GrossUses: UInt64);
begin
  if not ELAError.CheckOKFail(Thin_GetLicenseMeterAttribute
    (PWideChar(Name), AllowedUses, TotalUses, GrossUses)) then
    raise
    ELAFailException.CreateFmt('Failed to get the license meter attribute %s uses', [Name]);
end;

function Thin_GetLicenseKey(out licenseKey; length: LongWord): TLAStatusCode; cdecl;
  external LexActivator_DLL name 'GetLicenseKey';

function GetLicenseKey: UnicodeString;
var
  ErrorCode: TLAStatusCode;
  function Try256(var OuterResult: UnicodeString): Boolean;
  var
    Buffer: array[0 .. 255] of WideChar;
  begin
    ErrorCode := Thin_GetLicenseKey(Buffer, Length(Buffer));
    Result := ErrorCode <> LA_E_BUFFER_SIZE;
    if ErrorCode = LA_OK then OuterResult := Buffer;
  end;
  function TryHigh(var OuterResult: UnicodeString): Boolean;
  var
    Buffer: UnicodeString;
    Size: Integer;
  begin
    Size := 512;
    repeat
      Size := Size * 2;
      SetLength(Buffer, 0);
      SetLength(Buffer, Size);
      ErrorCode := Thin_GetLicenseKey(PWideChar(Buffer)^, Size);
      Result := ErrorCode <> LA_E_BUFFER_SIZE;
    until Result or (Size >= 128 * 1024);
    if ErrorCode = LA_OK then OuterResult := PWideChar(Buffer);
  end;
begin
  if not Try256(Result) then TryHigh(Result);
  if not ELAError.CheckOKFail(ErrorCode) then
    raise ELAFailException.Create('Failed to get the license key used for activation');
end;

function Thin_GetLicenseAllowedActivations(out allowedActivations: Int64): TLAStatusCode; cdecl;
  external LexActivator_DLL name 'GetLicenseAllowedActivations';

function GetLicenseAllowedActivations: Int64;
begin
  if not ELAError.CheckOKFail(Thin_GetLicenseAllowedActivations(Result)) then
    raise
    ELAFailException.Create('Failed to get the allowed activations of the license');
end;

function Thin_GetLicenseTotalActivations(out totalActivations: LongWord): TLAStatusCode; cdecl;
  external LexActivator_DLL name 'GetLicenseTotalActivations';

function GetLicenseTotalActivations: LongWord;
begin
  if not ELAError.CheckOKFail(Thin_GetLicenseTotalActivations(Result)) then
    raise
    ELAFailException.Create('Failed to get the total activations of the license');
end;

function Thin_GetLicenseAllowedDeactivations(out allowedDeactivations: Int64): TLAStatusCode; cdecl;
  external LexActivator_DLL name 'GetLicenseAllowedDeactivations';

function GetLicenseAllowedDeactivations: Int64;
begin
  if not ELAError.CheckOKFail(Thin_GetLicenseAllowedDeactivations(Result)) then
    raise
    ELAFailException.Create('Failed to get the allowed deactivations of the license');
end;

function Thin_GetLicenseTotalDeactivations(out totalDeactivations: LongWord): TLAStatusCode; cdecl;
  external LexActivator_DLL name 'GetLicenseTotalDeactivations';

function GetLicenseTotalDeactivations: LongWord;
begin
  if not ELAError.CheckOKFail(Thin_GetLicenseTotalDeactivations(Result)) then
    raise
    ELAFailException.Create('Failed to get the total deactivations of the license');
end;

function Thin_GetLicenseCreationDate(out creationDate: LongWord): TLAStatusCode; cdecl;
  external LexActivator_DLL name 'GetLicenseCreationDate';

function GetLicenseCreationDate: TDateTime;
var
  creationDate: LongWord;
begin
  if not ELAError.CheckOKFail(Thin_GetLicenseCreationDate(creationDate)) then
    raise
    ELAFailException.Create('Failed to get the license creation date');
   Result := UnixToDateTime(creationDate);
end;

function Thin_GetLicenseActivationDate(out activationDate: LongWord): TLAStatusCode; cdecl;
  external LexActivator_DLL name 'GetLicenseActivationDate';

function GetLicenseActivationDate: TDateTime;
var
  activationDate: LongWord;
begin
  if not ELAError.CheckOKFail(Thin_GetLicenseActivationDate(activationDate)) then
    raise
    ELAFailException.Create('Failed to get the activation creation date');
   Result := UnixToDateTime(activationDate);
end;

function Thin_GetLicenseMaintenanceExpiryDate(out maintenanceExpiryDate: LongWord): TLAStatusCode; cdecl;
  external LexActivator_DLL name 'GetLicenseMaintenanceExpiryDate';

function GetLicenseMaintenanceExpiryDate: TDateTime;
var
  maintenanceExpiryDate: LongWord;
begin
  if not ELAError.CheckOKFail(Thin_GetLicenseMaintenanceExpiryDate(maintenanceExpiryDate)) then
    raise
    ELAFailException.Create('Failed to get the maintenance expiry date');
   Result := UnixToDateTime(maintenanceExpiryDate);
end;

function Thin_GetLicenseMaxAllowedReleaseVersion(out releaseVersion; length: LongWord): TLAStatusCode; cdecl;
  external LexActivator_DLL name 'GetLicenseMaxAllowedReleaseVersion';

function GetLicenseMaxAllowedReleaseVersion: UnicodeString;
var
  ErrorCode: TLAStatusCode;
  function Try256(var OuterResult: UnicodeString): Boolean;
  var
    Buffer: array[0 .. 255] of WideChar;
  begin
    ErrorCode := Thin_GetLicenseMaxAllowedReleaseVersion(Buffer, Length(Buffer));
    Result := ErrorCode <> LA_E_BUFFER_SIZE;
    if ErrorCode = LA_OK then OuterResult := Buffer;
  end;
  function TryHigh(var OuterResult: UnicodeString): Boolean;
  var
    Buffer: UnicodeString;
    Size: Integer;
  begin
    Size := 512;
    repeat
      Size := Size * 2;
      SetLength(Buffer, 0);
      SetLength(Buffer, Size);
      ErrorCode := Thin_GetLicenseMaxAllowedReleaseVersion(PWideChar(Buffer)^, Size);
      Result := ErrorCode <> LA_E_BUFFER_SIZE;
    until Result or (Size >= 128 * 1024);
    if ErrorCode = LA_OK then OuterResult := PWideChar(Buffer);
  end;
begin
  if not Try256(Result) then TryHigh(Result);
  if not ELAError.CheckOKFail(ErrorCode) then
    raise ELAFailException.Create('Failed to get the max allowed release version');
end;

function Thin_GetLicenseOrganizationName(out organizationName; length: LongWord): TLAStatusCode; cdecl;
  external LexActivator_DLL name 'GetLicenseOrganizationName';

function GetLicenseOrganizationName: UnicodeString;
var
  ErrorCode: TLAStatusCode;
  function Try256(var OuterResult: UnicodeString): Boolean;
  var
    Buffer: array[0 .. 255] of WideChar;
  begin
    ErrorCode := Thin_GetLicenseOrganizationName(Buffer, Length(Buffer));
    Result := ErrorCode <> LA_E_BUFFER_SIZE;
    if ErrorCode = LA_OK then OuterResult := Buffer;
  end;
  function TryHigh(var OuterResult: UnicodeString): Boolean;
  var
    Buffer: UnicodeString;
    Size: Integer;
  begin
    Size := 512;
    repeat
      Size := Size * 2;
      SetLength(Buffer, 0);
      SetLength(Buffer, Size);
      ErrorCode := Thin_GetLicenseOrganizationName(PWideChar(Buffer)^, Size);
      Result := ErrorCode <> LA_E_BUFFER_SIZE;
    until Result or (Size >= 128 * 1024);
    if ErrorCode = LA_OK then OuterResult := PWideChar(Buffer);
  end;
begin
  if not Try256(Result) then TryHigh(Result);
  if not ELAError.CheckOKFail(ErrorCode) then
    raise ELAFailException.Create('Failed to get organization name');
end;

function Thin_GetActivationId(out activationId; length: LongWord): TLAStatusCode; cdecl;
  external LexActivator_DLL name 'GetActivationId';

function GetActivationId: UnicodeString;
var
  ErrorCode: TLAStatusCode;
  function Try256(var OuterResult: UnicodeString): Boolean;
  var
    Buffer: array[0 .. 255] of WideChar;
  begin
    ErrorCode := Thin_GetActivationId(Buffer, Length(Buffer));
    Result := ErrorCode <> LA_E_BUFFER_SIZE;
    if ErrorCode = LA_OK then OuterResult := Buffer;
  end;
  function TryHigh(var OuterResult: UnicodeString): Boolean;
  var
    Buffer: UnicodeString;
    Size: Integer;
  begin
    Size := 512;
    repeat
      Size := Size * 2;
      SetLength(Buffer, 0);
      SetLength(Buffer, Size);
      ErrorCode := Thin_GetActivationId(PWideChar(Buffer)^, Size);
      Result := ErrorCode <> LA_E_BUFFER_SIZE;
    until Result or (Size >= 128 * 1024);
    if ErrorCode = LA_OK then OuterResult := PWideChar(Buffer);
  end;
begin
  if not Try256(Result) then TryHigh(Result);
  if not ELAError.CheckOKFail(ErrorCode) then
    raise ELAFailException.Create('Failed to get activation id');
end;

function Thin_GetActivationMode(initialMode: PWideChar; initialModeLength: LongWord;
  currentMode: PWideChar; currentModeLength: LongWord): Integer; cdecl;
  external LexActivator_DLL name 'GetActivationMode';

function GetActivationMode: TActivationMode;
var
  ErrorCode: TLAStatusCode;
  ActivationMode: TActivationMode;

  function Try256: Boolean;
  var
    InitialBuffer, CurrentBuffer: array[0 .. 255] of WideChar;
  begin
    ErrorCode := Thin_GetActivationMode(InitialBuffer, Length(InitialBuffer), CurrentBuffer, Length(CurrentBuffer));
    Result := ErrorCode <> LA_E_BUFFER_SIZE;
    if ErrorCode = LA_OK then
    begin
      ActivationMode.InitialMode := InitialBuffer;
      ActivationMode.CurrentMode := CurrentBuffer;
    end;
  end;

  function TryHigh: Boolean;
  var
    InitialBuffer, CurrentBuffer: UnicodeString;
    Size: Integer;
  begin
    Size := 512;
    repeat
      Size := Size * 2;
      SetLength(InitialBuffer, Size);
      SetLength(CurrentBuffer, Size);
      ErrorCode := Thin_GetActivationMode(PWideChar(InitialBuffer), Size, PWideChar(CurrentBuffer), Size);
      Result := ErrorCode <> LA_E_BUFFER_SIZE;
    until Result or (Size >= 128 * 1024);
    if ErrorCode = LA_OK then
    begin
      ActivationMode.InitialMode := PWideChar(InitialBuffer);
      ActivationMode.CurrentMode := PWideChar(CurrentBuffer);
    end;
  end;

begin
  if not Try256 then
    TryHigh;

  if not ELAError.CheckOKFail(ErrorCode) then
    raise ELAFailException.Create('Failed to get the activation mode.');

  Result := ActivationMode;
end;

function Thin_GetLicenseOrganizationAddress(out organizationAddress; length: LongWord): TLAStatusCode; cdecl;
  external LexActivator_DLL name 'GetLicenseOrganizationAddressInternal';

function GetLicenseOrganizationAddress: TOrganizationAddress;
var
  ErrorCode: TLAStatusCode;
  JSONString: UnicodeString;
  JSONObject: TJSONObject;

  // Internal helper functions to handle buffer sizes
  function Try256(var OuterResult: UnicodeString): Boolean;
  var
    Buffer: array[0 .. 255] of WideChar;
  begin
    ErrorCode := Thin_GetLicenseOrganizationAddress(Buffer, Length(Buffer));
    Result := ErrorCode <> LA_E_BUFFER_SIZE;
    if ErrorCode = LA_OK then OuterResult := Buffer;
  end;

  function TryHigh(var OuterResult: UnicodeString): Boolean;
  var
    Buffer: UnicodeString;
    Size: Integer;
  begin
    Size := 512;
    repeat
      Size := Size * 2;
      SetLength(Buffer, 0);
      SetLength(Buffer, Size);
      ErrorCode := Thin_GetLicenseOrganizationAddress(PWideChar(Buffer)^, Size);
      Result := ErrorCode <> LA_E_BUFFER_SIZE;
    until Result or (Size >= 128 * 1024);
    if ErrorCode = LA_OK then OuterResult := PWideChar(Buffer);
  end;

begin
  if not Try256(JSONString) then TryHigh(JSONString);

  if not ELAError.CheckOKFail(ErrorCode) then
    raise ELAFailException.Create('Failed to get organization address linked to license');

  Result:= Default(TOrganizationAddress);

  if JSONString <> '' then
  begin
    try
      JSONObject := TJSONObject.ParseJSONValue(JSONString) as TJSONObject;
      if JSONObject <> nil then
      try
        JSONObject.TryGetValue('AddressLine1', Result.AddressLine1);
        JSONObject.TryGetValue('AddressLine2', Result.AddressLine2);
        JSONObject.TryGetValue('City', Result.City);
        JSONObject.TryGetValue('State', Result.State);
        JSONObject.TryGetValue('Country', Result.Country);
        JSONObject.TryGetValue('PostCode', Result.PostCode);
      finally
        JSONObject.Free;
      end
      else
        raise Exception.Create('Error while parsing JSON: Invalid JSON data');
    except
      on E: Exception do
      begin
        raise Exception.Create('Error while parsing JSON: ' + E.Message);
      end;
    end;
  end;
end;

function Thin_GetUserLicenses(out userLicenses; length: LongWord): TLAStatusCode; cdecl;
  external LexActivator_DLL name 'GetUserLicensesInternal';

function GetUserLicenses: TArray<TUserLicense>;
var
  ErrorCode: TLAStatusCode;
  JSONString: UnicodeString;
  JSONArray: TJSONArray;
  LicenseItem: TUserLicense;
  MetadataArray: TJSONArray;
  MetadataItem: TJSONObject;
  Metadata: TMetadata;
  I, J: Integer;

  function GetJSONStrValue(const JSONObject: TJSONObject; const FieldName: string): string;
  var
    JSONValue: TJSONValue;
  begin
    Result := '';
    JSONValue := JSONObject.GetValue(FieldName);
    if JSONValue <> nil then
      Result := JSONValue.Value;
  end;

  function GetJSONInt64Value(const JSONObject: TJSONObject; const FieldName: string): Int64;
  var
    JSONValue: TJSONValue;
  begin
    Result := 0;
    JSONValue := JSONObject.GetValue(FieldName);
    if (JSONValue <> nil) and JSONValue.TryGetValue(Result) then
      Exit;
  end;

  function GetJSONUInt32Value(const JSONObject: TJSONObject; const FieldName: string): UInt32;
  var
    JSONValue: TJSONValue;
  begin
    Result := 0;
    JSONValue := JSONObject.GetValue(FieldName);
    if (JSONValue <> nil) and JSONValue.TryGetValue(Result) then
      Exit;
  end;

  function Try256(var OuterResult: UnicodeString): Boolean;
  var
    Buffer: array[0..255] of WideChar;
  begin
    ErrorCode := Thin_GetUserLicenses(Buffer, Length(Buffer));
    Result := ErrorCode <> LA_E_BUFFER_SIZE;
    if ErrorCode = LA_OK then
      OuterResult := Buffer;
  end;

  function TryHigh(var OuterResult: UnicodeString): Boolean;
  var
    Buffer: UnicodeString;
    Size: Integer;
  begin
    Size := 512;
    repeat
      Size := Size * 2;
      SetLength(Buffer, Size);
      ErrorCode := Thin_GetUserLicenses(PWideChar(Buffer)^, Size);
      Result := ErrorCode <> LA_E_BUFFER_SIZE;
    until Result or (Size >= 128 * 1024);
    if ErrorCode = LA_OK then
      OuterResult := PWideChar(Buffer);
  end;

begin
  Result := nil;

  if not Try256(JSONString) then
    if not TryHigh(JSONString) then
      raise Exception.Create('Failed to fetch user licenses: Unable to retrieve data.');

  if ErrorCode <> LA_OK then
    raise Exception.Create('Failed to get user licenses. Error code: ' + IntToStr(ErrorCode));

  JSONArray := TJSONObject.ParseJSONValue(JSONString) as TJSONArray;
  if JSONArray = nil then
    raise Exception.Create('Error while parsing JSON: Invalid JSON data or empty JSON array');

  try
    SetLength(Result, JSONArray.Count);
    for I := 0 to JSONArray.Count - 1 do
    begin
      LicenseItem := Default(TUserLicense);
      
      LicenseItem.Key := GetJSONStrValue(JSONArray.Items[I] as TJSONObject, 'key');
      LicenseItem.&Type := GetJSONStrValue(JSONArray.Items[I] as TJSONObject, 'type');
      LicenseItem.AllowedActivations := GetJSONInt64Value(JSONArray.Items[I] as TJSONObject, 'allowedActivations');
      LicenseItem.AllowedDeactivations := GetJSONInt64Value(JSONArray.Items[I] as TJSONObject, 'allowedDeactivations');
      LicenseItem.TotalActivations := GetJSONUInt32Value(JSONArray.Items[I] as TJSONObject, 'totalActivations');
      LicenseItem.TotalDeactivations := GetJSONUInt32Value(JSONArray.Items[I] as TJSONObject, 'totalDeactivations');
      MetadataArray := (JSONArray.Items[I] as TJSONObject).GetValue('metadata') as TJSONArray;
      if MetadataArray <> nil then
      begin
        SetLength(LicenseItem.Metadata, MetadataArray.Count);
        for J := 0 to MetadataArray.Count - 1 do
        begin
          MetadataItem := MetadataArray.Items[J] as TJSONObject;
          Metadata.Key := GetJSONStrValue(MetadataItem, 'key');
          Metadata.Value := GetJSONStrValue(MetadataItem, 'value');
          LicenseItem.Metadata[J] := Metadata;
        end;
      end;

      Result[I] := LicenseItem;
    end;
  finally
    JSONArray.Free;
  end;
end;

function Thin_GetActivationLastSyncedDate(out lastSyncedDate: LongWord): TLAStatusCode; cdecl;
  external LexActivator_DLL name 'GetActivationLastSyncedDate';

function GetActivationLastSyncedDate: TDateTime;
var
  LastSyncedDate: LongWord;
begin
  if not ELAError.CheckOKFail(Thin_GetActivationLastSyncedDate(LastSyncedDate)) then
    raise
    ELAFailException.Create('Failed to get the activation last synced date timestamp');
  Result := UnixToDateTime(LastSyncedDate);
end;

function Thin_GetLicenseExpiryDate(out expiryDate: LongWord): TLAStatusCode; cdecl;
  external LexActivator_DLL name 'GetLicenseExpiryDate';

function GetLicenseExpiryDate: TDateTime;
var
  ExpiryDate: LongWord;
begin
  if not ELAError.CheckOKFail(Thin_GetLicenseExpiryDate(ExpiryDate)) then
    raise
    ELAFailException.Create('Failed to get the license expiry date timestamp');
  Result := UnixToDateTime(ExpiryDate);
end;

function Thin_GetLicenseUserEmail(out email; length: LongWord): TLAStatusCode; cdecl;
  external LexActivator_DLL name 'GetLicenseUserEmail';

function GetLicenseUserEmail: UnicodeString;
var
  ErrorCode: TLAStatusCode;
  function Try256(var OuterResult: UnicodeString): Boolean;
  var
    Buffer: array[0 .. 255] of WideChar;
  begin
    ErrorCode := Thin_GetLicenseUserEmail(Buffer, Length(Buffer));
    Result := ErrorCode <> LA_E_BUFFER_SIZE;
    if ErrorCode = LA_OK then OuterResult := Buffer;
  end;
  function TryHigh(var OuterResult: UnicodeString): Boolean;
  var
    Buffer: UnicodeString;
    Size: Integer;
  begin
    Size := 512;
    repeat
      Size := Size * 2;
      SetLength(Buffer, 0);
      SetLength(Buffer, Size);
      ErrorCode := Thin_GetLicenseUserEmail(PWideChar(Buffer)^, Size);
      Result := ErrorCode <> LA_E_BUFFER_SIZE;
    until Result or (Size >= 128 * 1024);
    if ErrorCode = LA_OK then OuterResult := PWideChar(Buffer);
  end;
begin
  if not Try256(Result) then TryHigh(Result);
  if not ELAError.CheckOKFail(ErrorCode) then
    raise ELAFailException.Create('Failed to get the email associated with license user');
end;

function Thin_GetLicenseUserName(out name; length: LongWord): TLAStatusCode; cdecl;
  external LexActivator_DLL name 'GetLicenseUserName';

function GetLicenseUserName: UnicodeString;
var
  ErrorCode: TLAStatusCode;
  function Try256(var OuterResult: UnicodeString): Boolean;
  var
    Buffer: array[0 .. 255] of WideChar;
  begin
    ErrorCode := Thin_GetLicenseUserName(Buffer, Length(Buffer));
    Result := ErrorCode <> LA_E_BUFFER_SIZE;
    if ErrorCode = LA_OK then OuterResult := Buffer;
  end;
  function TryHigh(var OuterResult: UnicodeString): Boolean;
  var
    Buffer: UnicodeString;
    Size: Integer;
  begin
    Size := 512;
    repeat
      Size := Size * 2;
      SetLength(Buffer, 0);
      SetLength(Buffer, Size);
      ErrorCode := Thin_GetLicenseUserName(PWideChar(Buffer)^, Size);
      Result := ErrorCode <> LA_E_BUFFER_SIZE;
    until Result or (Size >= 128 * 1024);
    if ErrorCode = LA_OK then OuterResult := PWideChar(Buffer);
  end;
begin
  if not Try256(Result) then TryHigh(Result);
  if not ELAError.CheckOKFail(ErrorCode) then
    raise ELAFailException.Create('Failed to get the name associated with the license user');
end;

function Thin_GetLicenseUserCompany(out company; length: LongWord): TLAStatusCode; cdecl;
  external LexActivator_DLL name 'GetLicenseUserCompany';

function GetLicenseUserCompany: UnicodeString;
var
  ErrorCode: TLAStatusCode;
  function Try256(var OuterResult: UnicodeString): Boolean;
  var
    Buffer: array[0 .. 255] of WideChar;
  begin
    ErrorCode := Thin_GetLicenseUserCompany(Buffer, Length(Buffer));
    Result := ErrorCode <> LA_E_BUFFER_SIZE;
    if ErrorCode = LA_OK then OuterResult := Buffer;
  end;
  function TryHigh(var OuterResult: UnicodeString): Boolean;
  var
    Buffer: UnicodeString;
    Size: Integer;
  begin
    Size := 512;
    repeat
      Size := Size * 2;
      SetLength(Buffer, 0);
      SetLength(Buffer, Size);
      ErrorCode := Thin_GetLicenseUserCompany(PWideChar(Buffer)^, Size);
      Result := ErrorCode <> LA_E_BUFFER_SIZE;
    until Result or (Size >= 128 * 1024);
    if ErrorCode = LA_OK then OuterResult := PWideChar(Buffer);
  end;
begin
  if not Try256(Result) then TryHigh(Result);
  if not ELAError.CheckOKFail(ErrorCode) then
    raise ELAFailException.Create('Failed to get the company associated with the license user');
end;

function Thin_GetLicenseUserMetadata(const key: PWideChar; out value; length: LongWord): TLAStatusCode; cdecl;
  external LexActivator_DLL name 'GetLicenseUserMetadata';

function GetLicenseUserMetadata(const Key: UnicodeString): UnicodeString;
var
  ErrorCode: TLAStatusCode;
  function Try256(var OuterResult: UnicodeString): Boolean;
  var
    Buffer: array[0 .. 255] of WideChar;
  begin
    ErrorCode := Thin_GetLicenseUserMetadata(PWideChar(Key), Buffer, Length(Buffer));
    Result := ErrorCode <> LA_E_BUFFER_SIZE;
    if ErrorCode = LA_OK then OuterResult := Buffer;
  end;
  function TryHigh(var OuterResult: UnicodeString): Boolean;
  var
    Buffer: UnicodeString;
    Size: Integer;
  begin
    Size := 512;
    repeat
      Size := Size * 2;
      SetLength(Buffer, 0);
      SetLength(Buffer, Size);
      ErrorCode := Thin_GetLicenseUserMetadata(PWideChar(Key), PWideChar(Buffer)^, Size);
      Result := ErrorCode <> LA_E_BUFFER_SIZE;
    until Result or (Size >= 128 * 1024);
    if ErrorCode = LA_OK then OuterResult := PWideChar(Buffer);
  end;
begin
  if not Try256(Result) then TryHigh(Result);
  if not ELAError.CheckOKFail(ErrorCode) then
    raise ELAFailException.CreateFmt('Failed to get the metadata %s associated with the license user', [Key]);
end;

function Thin_GetLicenseType(out name; length: LongWord): TLAStatusCode; cdecl;
  external LexActivator_DLL name 'GetLicenseType';

function GetLicenseType: UnicodeString;
var
  ErrorCode: TLAStatusCode;
  function Try256(var OuterResult: UnicodeString): Boolean;
  var
    Buffer: array[0 .. 255] of WideChar;
  begin
    ErrorCode := Thin_GetLicenseType(Buffer, Length(Buffer));
    Result := ErrorCode <> LA_E_BUFFER_SIZE;
    if ErrorCode = LA_OK then OuterResult := Buffer;
  end;
  function TryHigh(var OuterResult: UnicodeString): Boolean;
  var
    Buffer: UnicodeString;
    Size: Integer;
  begin
    Size := 512;
    repeat
      Size := Size * 2;
      SetLength(Buffer, 0);
      SetLength(Buffer, Size);
      ErrorCode := Thin_GetLicenseType(PWideChar(Buffer)^, Size);
      Result := ErrorCode <> LA_E_BUFFER_SIZE;
    until Result or (Size >= 128 * 1024);
    if ErrorCode = LA_OK then OuterResult := PWideChar(Buffer);
  end;
begin
  if not Try256(Result) then TryHigh(Result);
  if not ELAError.CheckOKFail(ErrorCode) then
    raise ELAFailException.Create('Failed to get the license type');
end;

function Thin_GetActivationMetadata(const key: PWideChar; out value; length: LongWord): TLAStatusCode; cdecl;
  external LexActivator_DLL name 'GetActivationMetadata';

function GetActivationMetadata(const Key: UnicodeString): UnicodeString;
var
  ErrorCode: TLAStatusCode;
  function Try256(var OuterResult: UnicodeString): Boolean;
  var
    Buffer: array[0 .. 255] of WideChar;
  begin
    ErrorCode := Thin_GetActivationMetadata(PWideChar(Key), Buffer, Length(Buffer));
    Result := ErrorCode <> LA_E_BUFFER_SIZE;
    if ErrorCode = LA_OK then OuterResult := Buffer;
  end;
  function TryHigh(var OuterResult: UnicodeString): Boolean;
  var
    Buffer: UnicodeString;
    Size: Integer;
  begin
    Size := 512;
    repeat
      Size := Size * 2;
      SetLength(Buffer, 0);
      SetLength(Buffer, Size);
      ErrorCode := Thin_GetActivationMetadata(PWideChar(Key), PWideChar(Buffer)^, Size);
      Result := ErrorCode <> LA_E_BUFFER_SIZE;
    until Result or (Size >= 128 * 1024);
    if ErrorCode = LA_OK then OuterResult := PWideChar(Buffer);
  end;
begin
  if not Try256(Result) then TryHigh(Result);
  if not ELAError.CheckOKFail(ErrorCode) then
    raise ELAFailException.CreateFmt('Failed to get the activation metadata with key %s', [Key]);
end;

function Thin_GetActivationMeterAttributeUses(const name: PWideChar; out AUses: LongWord): TLAStatusCode; cdecl;
  external LexActivator_DLL name 'GetActivationMeterAttributeUses';

function GetActivationMeterAttributeUses(const Name: UnicodeString): LongWord;
begin
  if not ELAError.CheckOKFail(Thin_GetActivationMeterAttributeUses(PWideChar(Name), Result)) then
    raise
    ELAFailException.CreateFmt
    ('Failed to get the meter attribute %s uses consumed by the activation', [Name]);
end;

function Thin_GetServerSyncGracePeriodExpiryDate(out expiryDate: LongWord): TLAStatusCode; cdecl;
  external LexActivator_DLL name 'GetServerSyncGracePeriodExpiryDate';

function GetServerSyncGracePeriodExpiryDate: TDateTime;
var
  ExpiryDate: LongWord;
begin
  if not ELAError.CheckOKFail(Thin_GetServerSyncGracePeriodExpiryDate(ExpiryDate)) then
    raise
    ELAFailException.Create('Failed to get the server sync grace period expiry date timestamp');
  Result := UnixToDateTime(ExpiryDate);
end;

function Thin_GetLastActivationError(out errorCode: UInt32): TLAStatusCode; cdecl;
  external LexActivator_DLL name 'GetLastActivationError';

function GetLastActivationError: UInt32;
var
  ErrorCode: UInt32;
begin
  if not ELAError.CheckOKFail(Thin_GetLastActivationError(Result)) then
    raise
    ELAFailException.Create('Failed to get the error code');
end;

function Thin_GetTrialActivationMetadata(const key: PWideChar; out value; length: LongWord): TLAStatusCode; cdecl;
  external LexActivator_DLL name 'GetTrialActivationMetadata';

function GetTrialActivationMetadata(const Key: UnicodeString): UnicodeString;
var
  ErrorCode: TLAStatusCode;
  function Try256(var OuterResult: UnicodeString): Boolean;
  var
    Buffer: array[0 .. 255] of WideChar;
  begin
    ErrorCode := Thin_GetTrialActivationMetadata(PWideChar(Key), Buffer, Length(Buffer));
    Result := ErrorCode <> LA_E_BUFFER_SIZE;
    if ErrorCode = LA_OK then OuterResult := Buffer;
  end;
  function TryHigh(var OuterResult: UnicodeString): Boolean;
  var
    Buffer: UnicodeString;
    Size: Integer;
  begin
    Size := 512;
    repeat
      Size := Size * 2;
      SetLength(Buffer, 0);
      SetLength(Buffer, Size);
      ErrorCode := Thin_GetTrialActivationMetadata(PWideChar(Key), PWideChar(Buffer)^, Size);
      Result := ErrorCode <> LA_E_BUFFER_SIZE;
    until Result or (Size >= 128 * 1024);
    if ErrorCode = LA_OK then OuterResult := PWideChar(Buffer);
  end;
begin
  if not Try256(Result) then TryHigh(Result);
  if not ELAError.CheckOKFail(ErrorCode) then
    raise ELAFailException.CreateFmt('Failed to get the trial activation metadata with key %s', [Key]);
end;

function Thin_GetTrialExpiryDate(out trialExpiryDate: LongWord): TLAStatusCode; cdecl;
  external LexActivator_DLL name 'GetTrialExpiryDate';

function GetTrialExpiryDate: TDateTime;
var
  TrialExpiryDate: LongWord;
begin
  if not ELAError.CheckOKFail(Thin_GetTrialExpiryDate(TrialExpiryDate)) then
    raise
    ELAFailException.Create('Failed to get the trial expiry date timestamp');
  Result := UnixToDateTime(TrialExpiryDate);
end;

function Thin_GetTrialId(out trialId; length: LongWord): TLAStatusCode; cdecl;
  external LexActivator_DLL name 'GetTrialId';

function GetTrialId: UnicodeString;
var
  ErrorCode: TLAStatusCode;
  function Try256(var OuterResult: UnicodeString): Boolean;
  var
    Buffer: array[0 .. 255] of WideChar;
  begin
    ErrorCode := Thin_GetTrialId(Buffer, Length(Buffer));
    Result := ErrorCode <> LA_E_BUFFER_SIZE;
    if ErrorCode = LA_OK then OuterResult := Buffer;
  end;
  function TryHigh(var OuterResult: UnicodeString): Boolean;
  var
    Buffer: UnicodeString;
    Size: Integer;
  begin
    Size := 512;
    repeat
      Size := Size * 2;
      SetLength(Buffer, 0);
      SetLength(Buffer, Size);
      ErrorCode := Thin_GetTrialId(PWideChar(Buffer)^, Size);
      Result := ErrorCode <> LA_E_BUFFER_SIZE;
    until Result or (Size >= 128 * 1024);
    if ErrorCode = LA_OK then OuterResult := PWideChar(Buffer);
  end;
begin
  if not Try256(Result) then TryHigh(Result);
  if not ELAError.CheckOKFail(ErrorCode) then
    raise ELAFailException.Create('Failed to get the trial activation id');
end;

function Thin_GetLocalTrialExpiryDate(out trialExpiryDate: LongWord): TLAStatusCode; cdecl;
  external LexActivator_DLL name 'GetLocalTrialExpiryDate';

function GetLocalTrialExpiryDate: TDateTime;
var
  TrialExpiryDate: LongWord;
begin
  if not ELAError.CheckOKFail(Thin_GetLocalTrialExpiryDate(TrialExpiryDate)) then
    raise
    ELAFailException.Create('Failed to get the trial expiry date timestamp');
  Result := UnixToDateTime(TrialExpiryDate);
end;

function Thin_GetLibraryVersion(out libraryVersion; length: LongWord): TLAStatusCode; cdecl;
  external LexActivator_DLL name 'GetLibraryVersion';

function GetLibraryVersion: UnicodeString;
var
  ErrorCode: TLAStatusCode;
  function Try256(var OuterResult: UnicodeString): Boolean;
  var
    Buffer: array[0 .. 255] of WideChar;
  begin
    ErrorCode := Thin_GetLibraryVersion(Buffer, Length(Buffer));
    Result := ErrorCode <> LA_E_BUFFER_SIZE;
    if ErrorCode = LA_OK then OuterResult := Buffer;
  end;
  function TryHigh(var OuterResult: UnicodeString): Boolean;
  var
    Buffer: UnicodeString;
    Size: Integer;
  begin
    Size := 512;
    repeat
      Size := Size * 2;
      SetLength(Buffer, 0);
      SetLength(Buffer, Size);
      ErrorCode := Thin_GetLibraryVersion(PWideChar(Buffer)^, Size);
      Result := ErrorCode <> LA_E_BUFFER_SIZE;
    until Result or (Size >= 128 * 1024);
    if ErrorCode = LA_OK then OuterResult := PWideChar(Buffer);
  end;
begin
  if not Try256(Result) then TryHigh(Result);
  if not ELAError.CheckOKFail(ErrorCode) then
    raise ELAFailException.Create('Failed to get the version of this library');
end;

function Thin_CheckForReleaseUpdate(const aplatform, version, channel: PWideChar;
  releaseUpdateCallback: TLAThin_CallbackType): TLAStatusCode; cdecl;
  external LexActivator_DLL name 'CheckForReleaseUpdate';

procedure CheckForReleaseUpdate(const APlatform, Version, Channel: UnicodeString;
  Callback: TLAProcedureCallback; Synchronized: Boolean); overload;
const
  LocalProxyIndex = lciCheckForReleaseUpdate;
begin
  EnterCriticalSection(LALicenseCallbackMutex[LocalProxyIndex]);
  try
    LAProcedureCallback[LocalProxyIndex] := Callback;
    LALicenseCallbackSynchronized[LocalProxyIndex] := Synchronized;
    LALicenseCallbackKind[LocalProxyIndex] := lckProcedure;

    if not ELAError.CheckOKFail(Thin_CheckForReleaseUpdate
        (PWideChar(APlatform), PWideChar(Version), PWideChar(Channel),
         LAThin_CallbackProxy2)) then
      raise
      ELAFailException.Create('Failed to set release update check callback');
  finally
    LeaveCriticalSection(LALicenseCallbackMutex[LocalProxyIndex]);
  end;
end;

procedure CheckForReleaseUpdate(const APlatform, Version, Channel: UnicodeString;
  Callback: TLAMethodCallback; Synchronized: Boolean); overload;
const
  LocalProxyIndex = lciCheckForReleaseUpdate;
begin
  EnterCriticalSection(LALicenseCallbackMutex[LocalProxyIndex]);
  try
    LAMethodCallback[LocalProxyIndex] := Callback;
    LALicenseCallbackSynchronized[LocalProxyIndex] := Synchronized;
    LALicenseCallbackKind[LocalProxyIndex] := lckMethod;

    if not ELAError.CheckOKFail(Thin_CheckForReleaseUpdate
        (PWideChar(APlatform), PWideChar(Version), PWideChar(Channel),
         LAThin_CallbackProxy2)) then
      raise
      ELAFailException.Create('Failed to set release update check callback');
  finally
    LeaveCriticalSection(LALicenseCallbackMutex[LocalProxyIndex]);
  end;
end;

{$IFDEF DELPHI_HAS_CLOSURES}
procedure CheckForReleaseUpdate(const APlatform, Version, Channel: UnicodeString;
  Callback: TLAClosureCallback; Synchronized: Boolean); overload;
const
  LocalProxyIndex = lciCheckForReleaseUpdate;
begin
  EnterCriticalSection(LALicenseCallbackMutex[LocalProxyIndex]);
  try
    LAClosureCallback[LocalProxyIndex] := Callback;
    LALicenseCallbackSynchronized[LocalProxyIndex] := Synchronized;
    LALicenseCallbackKind[LocalProxyIndex] := lckClosure;

    if not ELAError.CheckOKFail(Thin_CheckForReleaseUpdate
        (PWideChar(APlatform), PWideChar(Version), PWideChar(Channel),
         LAThin_CallbackProxy2)) then
      raise
      ELAFailException.Create('Failed to set release update check callback');
  finally
    LeaveCriticalSection(LALicenseCallbackMutex[LocalProxyIndex]);
  end;
end;
{$ENDIF}

procedure ResetCheckForReleaseUpdateCallback;
const
  LocalProxyIndex = lciCheckForReleaseUpdate;
begin
  EnterCriticalSection(LALicenseCallbackMutex[LocalProxyIndex]);
  try
    LALicenseCallbackKind[LocalProxyIndex] := lckNone;

    // no API to unset
  finally
    LeaveCriticalSection(LALicenseCallbackMutex[LocalProxyIndex]);
  end;
end;

function Thin_ActivateLicense: TLAStatusCode; cdecl;
  external LexActivator_DLL name 'ActivateLicense';

function ActivateLicense: TLAKeyStatus;
begin
  Result := ELAError.CheckKeyStatus(Thin_ActivateLicense);
end;

function Thin_ActivateLicenseOffline(const filePath: PWideChar): TLAStatusCode; cdecl;
  external LexActivator_DLL name 'ActivateLicenseOffline';

function ActivateLicenseOffline(const FilePath: UnicodeString): TLAKeyStatus;
begin
  Result := ELAError.CheckKeyStatus(Thin_ActivateLicenseOffline(PWideChar(FilePath)));
end;

function Thin_AuthenticateUser(const email , password : PWideChar): TLAStatusCode; cdecl;
  external LexActivator_DLL name 'AuthenticateUser';

function AuthenticateUser(const Email , Password : unicodestring): TLAKeyStatus;
begin
  Result := ELAError.CheckKeyStatus(Thin_AuthenticateUser(PWideChar(Email),PWideChar(Password)));
end;

function Thin_AuthenticateUserWithIdToken(const token : PWideChar): TLAStatusCode; cdecl;
  external LexActivator_DLL name 'AuthenticateUserWithIdToken';

function AuthenticateUserWithIdToken(const Token : unicodestring): TLAKeyStatus;
begin
  Result := ELAError.CheckKeyStatus(Thin_AuthenticateUserWithIdToken(PWideChar(Token)));
end;

function Thin_GenerateOfflineActivationRequest(const filePath: PWideChar): TLAStatusCode; cdecl;
  external LexActivator_DLL name 'GenerateOfflineActivationRequest';

procedure GenerateOfflineActivationRequest(const FilePath: UnicodeString);
begin
  if not ELAError.CheckOKFail(Thin_GenerateOfflineActivationRequest(PWideChar(FilePath))) then
    raise
    ELAFailException.Create('Failed to generate the offline activation request');
end;

function Thin_DeactivateLicense: TLAStatusCode; cdecl;
  external LexActivator_DLL name 'DeactivateLicense';

function DeactivateLicense: TLAKeyStatus;
begin
  Result := ELAError.CheckKeyStatus(Thin_DeactivateLicense);
end;

function Thin_GenerateOfflineDeactivationRequest(const filePath: PWideChar): TLAStatusCode; cdecl;
  external LexActivator_DLL name 'GenerateOfflineDeactivationRequest';

procedure GenerateOfflineDeactivationRequest(const FilePath: UnicodeString);
begin
  if not ELAError.CheckOKFail(Thin_GenerateOfflineDeactivationRequest(PWideChar(FilePath))) then
    raise
    ELAFailException.Create('Failed to generate the offline deactivation request');
end;

function Thin_IsLicenseGenuine: TLAStatusCode; cdecl;
  external LexActivator_DLL name 'IsLicenseGenuine';

function IsLicenseGenuine: TLAKeyStatus;
begin
  Result := ELAError.CheckKeyStatus(Thin_IsLicenseGenuine);
end;

function Thin_IsLicenseValid: TLAStatusCode; cdecl;
  external LexActivator_DLL name 'IsLicenseValid';

function IsLicenseValid: TLAKeyStatus;
begin
  Result := ELAError.CheckKeyStatus(Thin_IsLicenseValid);
end;

function Thin_ActivateTrial: TLAStatusCode; cdecl;
  external LexActivator_DLL name 'ActivateTrial';

function ActivateTrial: TLAKeyStatus;
begin
  Result := ELAError.CheckKeyStatus(Thin_ActivateTrial);
end;

function Thin_ActivateTrialOffline(const filePath: PWideChar): TLAStatusCode; cdecl;
  external LexActivator_DLL name 'ActivateTrialOffline';

function ActivateTrialOffline(const FilePath: UnicodeString): TLAKeyStatus;
begin
  Result := ELAError.CheckKeyStatus(Thin_ActivateTrialOffline(PWideChar(FilePath)));
end;

function Thin_GenerateOfflineTrialActivationRequest(const filePath: PWideChar): TLAStatusCode; cdecl;
  external LexActivator_DLL name 'GenerateOfflineTrialActivationRequest';

procedure GenerateOfflineTrialActivationRequest(const FilePath: UnicodeString);
begin
  if not ELAError.CheckOKFail(Thin_GenerateOfflineTrialActivationRequest(PWideChar(FilePath))) then
    raise
    ELAFailException.Create('Failed to generate the offline trial activation request');
end;

function Thin_IsTrialGenuine: TLAStatusCode; cdecl;
  external LexActivator_DLL name 'IsTrialGenuine';

function IsTrialGenuine: TLAKeyStatus;
begin
  Result := ELAError.CheckKeyStatus(Thin_IsTrialGenuine);
end;

function Thin_ActivateLocalTrial(trialLength: LongWord): TLAStatusCode; cdecl;
  external LexActivator_DLL name 'ActivateLocalTrial';

function ActivateLocalTrial(TrialLength: LongWord): TLAKeyStatus;
begin
  Result := ELAError.CheckKeyStatus(Thin_ActivateLocalTrial(TrialLength));
end;

function Thin_IsLocalTrialGenuine: TLAStatusCode; cdecl;
  external LexActivator_DLL name 'IsLocalTrialGenuine';

function IsLocalTrialGenuine: TLAKeyStatus;
begin
  Result := ELAError.CheckKeyStatus(Thin_IsLocalTrialGenuine);
end;

function Thin_ExtendLocalTrial(trialExtensionLength: LongWord): TLAStatusCode; cdecl;
  external LexActivator_DLL name 'ExtendLocalTrial';

function ExtendLocalTrial(TrialExtensionLength: LongWord): TLAKeyStatus;
begin
  Result := ELAError.CheckKeyStatus(Thin_ExtendLocalTrial(TrialExtensionLength));
end;

function Thin_IncrementActivationMeterAttributeUses(const name: PWideChar; increment: LongWord): TLAStatusCode; cdecl;
  external LexActivator_DLL name 'IncrementActivationMeterAttributeUses';

procedure IncrementActivationMeterAttributeUses(const Name: UnicodeString; Increment: LongWord);
begin
  if not ELAError.CheckOKFail(Thin_IncrementActivationMeterAttributeUses(PWideChar(Name), Increment)) then
    raise
    ELAFailException.CreateFmt('Failed to increment the meter attribute %s uses of the activation', [Name]);
end;

function Thin_DecrementActivationMeterAttributeUses(const name: PWideChar; decrement: LongWord): TLAStatusCode; cdecl;
  external LexActivator_DLL name 'DecrementActivationMeterAttributeUses';

procedure DecrementActivationMeterAttributeUses(const Name: UnicodeString; Decrement: LongWord);
begin
  if not ELAError.CheckOKFail(Thin_DecrementActivationMeterAttributeUses(PWideChar(Name), Decrement)) then
    raise
    ELAFailException.CreateFmt('Failed to decrement the meter attribute %s uses of the activation', [Name]);
end;

function Thin_ResetActivationMeterAttributeUses(const name: PWideChar): TLAStatusCode; cdecl;
  external LexActivator_DLL name 'ResetActivationMeterAttributeUses';

procedure ResetActivationMeterAttributeUses(const Name: UnicodeString);
begin
  if not ELAError.CheckOKFail(Thin_ResetActivationMeterAttributeUses(PWideChar(Name))) then
    raise
    ELAFailException.CreateFmt('Failed to reset the meter attribute %s uses consumed by the activation', [Name]);
end;

function Thin_Reset: TLAStatusCode; cdecl;
  external LexActivator_DLL name 'Reset';

procedure LAReset;
begin
  if not ELAError.CheckOKFail(Thin_Reset) then
    raise
    ELAFailException.Create('Failed to reset the activation and trial data');
end;

class function ELAError.CreateByCode(ErrorCode: TLAStatusCode): ELAError;
begin
  case ErrorCode of
    LA_OK: Result := nil;
    LA_FAIL: Result := ELAFailException.Create;
    LA_EXPIRED: Result := ELAExpiredError.Create;
    LA_SUSPENDED: Result := ELASuspendedError.Create;
    LA_GRACE_PERIOD_OVER: Result := ELAGracePeriodOverError.Create;
    LA_TRIAL_EXPIRED: Result := ELATrialExpiredError.Create;
    LA_LOCAL_TRIAL_EXPIRED: Result := ELALocalTrialExpiredError.Create;
    LA_RELEASE_UPDATE_AVAILABLE: Result := ELAUnknownErrorCodeException.Create(ErrorCode);
    LA_RELEASE_NO_UPDATE_AVAILABLE: Result := ELAUnknownErrorCodeException.Create(ErrorCode);
    LA_E_FILE_PATH: Result := ELAFilePathException.Create;
    LA_E_PRODUCT_FILE: Result := ELAProductFileException.Create;
    LA_E_PRODUCT_DATA: Result := ELAProductDataException.Create;
    LA_E_PRODUCT_ID: Result := ELAProductIdException.Create;
    LA_E_SYSTEM_PERMISSION: Result := ELASystemPermissionException.Create;
    LA_E_FILE_PERMISSION: Result := ELAFilePermissionException.Create;
    LA_E_WMIC: Result := ELAWMICException.Create;
    LA_E_TIME: Result := ELATimeException.Create;
    LA_E_INET: Result := ELAInetException.Create;
    LA_E_NET_PROXY: Result := ELANetProxyException.Create;
    LA_E_HOST_URL: Result := ELAHostURLException.Create;
    LA_E_BUFFER_SIZE: Result := ELABufferSizeException.Create;
    LA_E_APP_VERSION_LENGTH: Result := ELAAppVersionLengthException.Create;
    LA_E_REVOKED: Result := ELARevokedException.Create;
    LA_E_LICENSE_KEY: Result := ELALicenseKeyException.Create;
    LA_E_LICENSE_TYPE: Result := ELALicenseTypeException.Create;
    LA_E_OFFLINE_RESPONSE_FILE: Result := ELAOfflineResponseFileException.Create;
    LA_E_OFFLINE_RESPONSE_FILE_EXPIRED: Result := ELAOfflineResponseFileExpiredException.Create;
    LA_E_ACTIVATION_LIMIT: Result := ELAActivationLimitException.Create;
    LA_E_ACTIVATION_NOT_FOUND: Result := ELAActivationNotFoundException.Create;
    LA_E_DEACTIVATION_LIMIT: Result := ELADeactivationLimitException.Create;
    LA_E_TRIAL_NOT_ALLOWED: Result := ELATrialNotAllowedException.Create;
    LA_E_TRIAL_ACTIVATION_LIMIT: Result := ELATrialActivationLimitException.Create;
    LA_E_MACHINE_FINGERPRINT: Result := ELAMachineFingerprintException.Create;
    LA_E_METADATA_KEY_LENGTH: Result := ELAMetadataKeyLengthException.Create;
    LA_E_METADATA_VALUE_LENGTH: Result := ELAMetadataValueLengthException.Create;
    LA_E_ACTIVATION_METADATA_LIMIT: Result := ELAActivationMetadataLimitException.Create;
    LA_E_TRIAL_ACTIVATION_METADATA_LIMIT: Result := ELATrialActivationMetadataLimitException.Create;
    LA_E_METADATA_KEY_NOT_FOUND: Result := ELAMetadataKeyNotFoundException.Create;
    LA_E_TIME_MODIFIED: Result := ELATimeModifiedException.Create;
    LA_E_RELEASE_VERSION_FORMAT: Result := ELAReleaseVersionFormatException.Create;
    LA_E_AUTHENTICATION_FAILED: Result := ELAAuthenticationFailedException.Create;
    LA_E_METER_ATTRIBUTE_NOT_FOUND: Result := ELAMeterAttributeNotFoundException.Create;
    LA_E_METER_ATTRIBUTE_USES_LIMIT_REACHED: Result := ELAMeterAttributeUsesLimitReachedException.Create;
    LA_E_CUSTOM_FINGERPRINT_LENGTH: Result := ELACustomFingerprintLengthException.Create;
    LA_E_PRODUCT_VERSION_NOT_LINKED: Result := ELAProductVersionNotLinkedException.Create;
    LA_E_FEATURE_FLAG_NOT_FOUND: Result := ELAFeatureFlagNotFoundException.Create;
    LA_E_RELEASE_PLATFORM_LENGTH: Result := ELAReleasePlatformLengthException.Create;
    LA_E_RELEASE_CHANNEL_LENGTH: Result := ELAReleaseChannelLengthException.Create;
    LA_E_VM: Result := ELAVMException.Create;
    LA_E_COUNTRY: Result := ELACountryException.Create;
    LA_E_IP: Result := ELAIPException.Create;
    LA_E_CONTAINER: Result := ELAContainerException.Create;
    LA_E_USER_NOT_AUTHENTICATED: Result := ELAUserNotAuthenticatedException.Create;
    LA_E_TWO_FACTOR_AUTHENTICATION_CODE_MISSING: Result := ELATwoFactorAuthenticationCodeMissingException.Create;
    LA_E_TWO_FACTOR_AUTHENTICATION_CODE_INVALID: Result := ELATwoFactorAuthenticationCodeInvalidException.Create;
    LA_E_RATE_LIMIT: Result := ELARateLimitException.Create;
    LA_E_SERVER: Result := ELAServerException.Create;
    LA_E_CLIENT: Result := ELAClientException.Create;
    LA_E_ACCOUNT_ID: Result := ELAAccountIdException.Create;
    LA_E_LOGIN_TEMPORARILY_LOCKED: Result := ELALoginTemporarilyLockedException.Create;
    LA_E_AUTHENTICATION_ID_TOKEN_INVALID: Result := ELAAuthenticationIdTokenInvalidException.Create;
    LA_E_OIDC_SSO_NOT_ENABLED: Result := ELAOIDCSSONotEnabledException.Create;
    LA_E_USERS_LIMIT_REACHED: Result := ELAUsersLimitReachedException.Create;
    LA_E_OS_USER: Result := ELAOSUserException.Create;
    LA_E_INVALID_PERMISSION_FLAG: Result := ELAInvalidPermissionFlagException.Create;
    LA_E_FREE_PLAN_ACTIVATION_LIMIT_REACHED: Result := ELAFreePlanActivationLimitReachedException.Create;
    LA_E_FEATURE_ENTITLEMENTS_INVALID: Result := ELAFeatureEntitlementsInvalidException.Create;
    LA_E_FEATURE_ENTITLEMENT_NOT_FOUND: Result := ELAFeatureEntitlementNotFoundException.Create;
    LA_E_ENTITLEMENT_SET_NOT_LINKED: Result := ELAEntitlementSetNotLinkedException.Create;
    LA_E_LICENSE_NOT_EFFECTIVE: Result := ELALicenseNotEffectiveException.Create;
  else
    Result := ELAUnknownErrorCodeException.Create(ErrorCode);
  end;
end;

// check for LA_OK, otherwise raise exception
class procedure ELAError.Check(ErrorCode: TLAStatusCode);
begin
  // E2441 Inline function declared in interface section must not use local
  // symbol 'LA_OK'.
  if ErrorCode <> 0 {LA_OK} then
    raise CreateByCode(ErrorCode);
end;

class function ELAError.CheckOKFail(ErrorCode: TLAStatusCode): Boolean;
begin
  // E2441 Inline function declared in interface section must not use local
  // symbol 'LA_OK'
  case ErrorCode of
    0 {LA_OK}: Result := True;
    1 {LA_FAIL}: Result := False;
  else
    raise CreateByCode(ErrorCode);
  end;
end;

class function ELAError.CheckKeyStatus(ErrorCode: TLAStatusCode): TLAKeyStatus;
begin
  case ErrorCode of
    LA_OK: Result := lkOK;
    LA_EXPIRED: Result := lkExpired;
    LA_SUSPENDED: Result := lkSuspended;
    LA_GRACE_PERIOD_OVER: Result := lkGracePeriodOver;
    LA_TRIAL_EXPIRED: Result := lkTrialExpired;
    LA_LOCAL_TRIAL_EXPIRED: Result := lkLocalTrialExpired;
    LA_FAIL: Result := lkFail;
  else
    raise CreateByCode(ErrorCode);
  end;
end;

constructor ELAUnknownErrorCodeException.Create(AErrorCode: TLAStatusCode);
begin
  inherited CreateFmt('LexActivator error %d', [AErrorCode]);
  FErrorCode := AErrorCode;
end;

constructor ELAFailException.Create;
begin
  inherited Create('Failed');
end;

constructor ELAFailException.Create(const Msg: string);
begin
  inherited;
end;

procedure ELAFailException.AfterConstruction;
begin
  FErrorCode := LA_FAIL;
  FKeyStatus := lkFail;
end;

class function ELAKeyStatusError.CreateByKeyStatus(KeyStatus: TLAKeyStatus): ELAError;
begin
  case KeyStatus of
    lkOK: Result := nil;
    lkExpired: Result := ELAExpiredError.Create;
    lkSuspended: Result := ELASuspendedError.Create;
    lkGracePeriodOver: Result := ELAGracePeriodOverError.Create;
    lkTrialExpired: Result := ELATrialExpiredError.Create;
    lkLocalTrialExpired: Result := ELALocalTrialExpiredError.Create;
    lkFail: Result := ELAFailException.Create;
  else
    if (KeyStatus >= Low(TLAKeyStatus)) and (KeyStatus <= High(TLAKeyStatus)) then
    begin
      // forgot to update list?
      Result := ELAKeyStatusError.Create('Key state is ' +
        GetEnumName(TypeInfo(TLAKeyStatus), Integer(KeyStatus)));
      ELAKeyStatusError(Result).FKeyStatus := KeyStatus;
    end else begin
      // invalid value, should not appear
      Result := ELAKeyStatusError.CreateFmt('Key state is %d',
        [Integer(KeyStatus)]);
      ELAKeyStatusError(Result).FKeyStatus := KeyStatus;
    end;
  end;
end;

constructor ELAExpiredError.Create;
begin
  inherited Create('The license has expired or system time has been tampered ' +
    'with. Ensure your date and time settings are correct');
  FErrorCode := LA_EXPIRED;
  FKeyStatus := lkExpired;
end;

constructor ELASuspendedError.Create;
begin
  inherited Create('The license has been suspended');
  FErrorCode := LA_SUSPENDED;
  FKeyStatus := lkSuspended;
end;

constructor ELAGracePeriodOverError.Create;
begin
  inherited Create('The grace period for server sync is over');
  FErrorCode := LA_GRACE_PERIOD_OVER;
  FKeyStatus := lkGracePeriodOver;
end;

constructor ELATrialExpiredError.Create;
begin
  inherited Create('The trial has expired or system time has been tampered ' +
    'with. Ensure your date and time settings are correct');
  FErrorCode := LA_TRIAL_EXPIRED;
  FKeyStatus := lkTrialExpired;
end;

constructor ELALocalTrialExpiredError.Create;
begin
  inherited Create('The local trial has expired or system time has been tampered ' +
    'with. Ensure your date and time settings are correct');
  FErrorCode := LA_LOCAL_TRIAL_EXPIRED;
  FKeyStatus := lkLocalTrialExpired;
end;

constructor ELAFilePathException.Create;
begin
  inherited Create('Invalid file path');
  FErrorCode := LA_E_FILE_PATH;
end;

constructor ELAProductFileException.Create;
begin
  inherited Create('Invalid or corrupted product file');
  FErrorCode := LA_E_PRODUCT_FILE;
end;

constructor ELAProductDataException.Create;
begin
  inherited Create('Invalid product data');
  FErrorCode := LA_E_PRODUCT_DATA;
end;

constructor ELAProductIdException.Create;
begin
  inherited Create('The product id is incorrect');
  FErrorCode := LA_E_PRODUCT_ID;
end;

constructor ELASystemPermissionException.Create;
begin
  inherited Create('Insufficient system permissions');
  FErrorCode := LA_E_SYSTEM_PERMISSION;
end;

constructor ELAFilePermissionException.Create;
begin
  inherited Create('No permission to write to file');
  FErrorCode := LA_E_FILE_PERMISSION;
end;

constructor ELAWMICException.Create;
begin
  inherited Create('Fingerprint couldn''t be generated because Windows Management ' +
    'Instrumentation (WMI) service has been disabled');
  FErrorCode := LA_E_WMIC;
end;

constructor ELATimeException.Create;
begin
  inherited Create('The difference between the network time and the system time is ' +
    'more than allowed clock offset');
  FErrorCode := LA_E_TIME;
end;

constructor ELAInetException.Create;
begin
  inherited Create('Failed to connect to the server due to network error');
  FErrorCode := LA_E_INET;
end;

constructor ELANetProxyException.Create;
begin
  inherited Create('Invalid network proxy');
  FErrorCode := LA_E_NET_PROXY;
end;

constructor ELAHostURLException.Create;
begin
  inherited Create('Invalid Cryptlex host url');
  FErrorCode := LA_E_HOST_URL;
end;

constructor ELABufferSizeException.Create;
begin
  inherited Create('The buffer size was smaller than required');
  FErrorCode := LA_E_BUFFER_SIZE;
end;

constructor ELAAppVersionLengthException.Create;
begin
  inherited Create('App version length is more than 256 characters');
  FErrorCode := LA_E_APP_VERSION_LENGTH;
end;

constructor ELARevokedException.Create;
begin
  inherited Create('The license has been revoked');
  FErrorCode := LA_E_REVOKED;
end;

constructor ELALicenseKeyException.Create;
begin
  inherited Create('Invalid license key');
  FErrorCode := LA_E_LICENSE_KEY;
end;

constructor ELALicenseTypeException.Create;
begin
  inherited Create('Invalid license type. Make sure floating license ' +
    'is not being used');
  FErrorCode := LA_E_LICENSE_TYPE;
end;

constructor ELAOfflineResponseFileException.Create;
begin
  inherited Create('Invalid offline activation response file');
  FErrorCode := LA_E_OFFLINE_RESPONSE_FILE;
end;

constructor ELAOfflineResponseFileExpiredException.Create;
begin
  inherited Create('The offline activation response has expired');
  FErrorCode := LA_E_OFFLINE_RESPONSE_FILE_EXPIRED;
end;

constructor ELAActivationLimitException.Create;
begin
  inherited Create('The license has reached its allowed activations limit');
  FErrorCode := LA_E_ACTIVATION_LIMIT;
end;

constructor ELAActivationNotFoundException.Create;
begin
  inherited Create('The license activation was deleted on the server');
  FErrorCode := LA_E_ACTIVATION_NOT_FOUND;
end;

constructor ELADeactivationLimitException.Create;
begin
  inherited Create('The license has reached its allowed deactivations limit');
  FErrorCode := LA_E_DEACTIVATION_LIMIT;
end;

constructor ELATrialNotAllowedException.Create;
begin
  inherited Create('Trial not allowed for the product');
  FErrorCode := LA_E_TRIAL_NOT_ALLOWED;
end;

constructor ELATrialActivationLimitException.Create;
begin
  inherited Create('Your account has reached its trial activations limit');
  FErrorCode := LA_E_TRIAL_ACTIVATION_LIMIT;
end;

constructor ELAMachineFingerprintException.Create;
begin
  inherited Create('Machine fingerprint has changed since activation');
  FErrorCode := LA_E_MACHINE_FINGERPRINT;
end;

constructor ELAMetadataKeyLengthException.Create;
begin
  inherited Create('Metadata key length is more than 256 characters');
  FErrorCode := LA_E_METADATA_KEY_LENGTH;
end;

constructor ELAMetadataValueLengthException.Create;
begin
  inherited Create('Metadata value length is more than 256 characters');
  FErrorCode := LA_E_METADATA_VALUE_LENGTH;
end;

constructor ELAActivationMetadataLimitException.Create;
begin
  inherited Create('The license has reached its metadata fields limit');
  FErrorCode := LA_E_ACTIVATION_METADATA_LIMIT;
end;

constructor ELATrialActivationMetadataLimitException.Create;
begin
  inherited Create('The trial has reached its metadata fields limit');
  FErrorCode := LA_E_TRIAL_ACTIVATION_METADATA_LIMIT;
end;

constructor ELAMetadataKeyNotFoundException.Create;
begin
  inherited Create('The metadata key does not exist');
  FErrorCode := LA_E_METADATA_KEY_NOT_FOUND;
end;

constructor ELATimeModifiedException.Create;
begin
  inherited Create('The system time has been tampered (backdated)');
  FErrorCode := LA_E_TIME_MODIFIED;
end;

constructor ELAReleaseVersionFormatException.Create;
begin
  inherited Create('Invalid version format');
  FErrorCode := LA_E_RELEASE_VERSION_FORMAT;
end;

constructor ELAAuthenticationFailedException.Create;
begin
  inherited Create('Incorrect email or password');
  FErrorCode := LA_E_AUTHENTICATION_FAILED;
end;

constructor ELAMeterAttributeNotFoundException.Create;
begin
  inherited Create('The meter attribute does not exist');
  FErrorCode := LA_E_METER_ATTRIBUTE_NOT_FOUND;
end;

constructor ELAMeterAttributeUsesLimitReachedException.Create;
begin
  inherited Create('The meter attribute has reached it''s usage limit');
  FErrorCode := LA_E_METER_ATTRIBUTE_USES_LIMIT_REACHED;
end;

constructor ELACustomFingerprintLengthException.Create;
begin
  inherited Create('Custom device fingerprint length is less than 64 characters ' +
    'or more than 256 characters');
  FErrorCode := LA_E_CUSTOM_FINGERPRINT_LENGTH;
end;

constructor ELAProductVersionNotLinkedException.Create;
begin
  inherited Create('No product version is linked with the license');
  FErrorCode := LA_E_PRODUCT_VERSION_NOT_LINKED;
end;

constructor ELAFeatureFlagNotFoundException.Create;
begin
  inherited Create('The product version feature flag does not exist');
  FErrorCode := LA_E_FEATURE_FLAG_NOT_FOUND;
end;

constructor ELAReleasePlatformLengthException.Create;
begin
  inherited Create('Release platform length is more than 256 characters..');
  FErrorCode := LA_E_RELEASE_PLATFORM_LENGTH;
end;

constructor ELAReleaseChannelLengthException.Create;
begin
  inherited Create('Release channel length is more than 256 characters..');
  FErrorCode := LA_E_RELEASE_CHANNEL_LENGTH;
end;

constructor ELAVMException.Create;
begin
  inherited Create('Application is being run inside a virtual machine / hypervisor, ' +
    'and activation has been disallowed in the VM');
  FErrorCode := LA_E_VM;
end;

constructor ELACountryException.Create;
begin
  inherited Create('Country is not allowed');
  FErrorCode := LA_E_COUNTRY;
end;

constructor ELAIPException.Create;
begin
  inherited Create('IP address is not allowed');
  FErrorCode := LA_E_IP;
end;

constructor ELAContainerException.Create;
begin
  inherited Create('Application is being run inside a container and ' +
    'activation has been disallowed in the container');
  FErrorCode := LA_E_CONTAINER;
end;

constructor ELAUserNotAuthenticatedException.Create;
begin
  inherited Create('The user is not authenticated.');
  FErrorCode := LA_E_USER_NOT_AUTHENTICATED;
end;

constructor ELATwoFactorAuthenticationCodeMissingException.Create;
begin
  inherited Create('The two-factor authentication code for the user authentication is missing.');
  FErrorCode := LA_E_TWO_FACTOR_AUTHENTICATION_CODE_MISSING;
end;

constructor ELATwoFactorAuthenticationCodeInvalidException.Create;
begin
  inherited Create('The two-factor authentication code provided by the user is invalid.');
  FErrorCode := LA_E_TWO_FACTOR_AUTHENTICATION_CODE_INVALID;
end;

constructor ELARateLimitException.Create;
begin
  inherited Create('Rate limit for API has reached, try again later');
  FErrorCode := LA_E_RATE_LIMIT;
end;

constructor ELAServerException.Create;
begin
  inherited Create('Server error');
  FErrorCode := LA_E_SERVER;
end;

constructor ELAClientException.Create;
begin
  inherited Create('Client error');
  FErrorCode := LA_E_CLIENT;
end;

constructor ELAAccountIdException.Create;
begin
  inherited Create('Invalid account ID');
  FErrorCode := LA_E_ACCOUNT_ID;
end;

constructor ELALoginTemporarilyLockedException.Create;
begin
  inherited Create('The user account has been temporarily locked for 5 mins due to 5 failed attempts');
  FErrorCode := LA_E_LOGIN_TEMPORARILY_LOCKED;
end;

constructor ELAAuthenticationIdTokenInvalidException.Create;
begin
  inherited Create('Invalid authentication ID token');
  FErrorCode := LA_E_AUTHENTICATION_ID_TOKEN_INVALID;
end;

constructor ELAOIDCSSONotEnabledException.Create;
begin
  inherited Create('OIDC SSO is not enabled');
  FErrorCode := LA_E_OIDC_SSO_NOT_ENABLED;
end;

constructor ELAUsersLimitReachedException.Create;
begin
  inherited Create('The license has reached its allowed users limit');
  FErrorCode := LA_E_USERS_LIMIT_REACHED;
end;

constructor ELAOSUserException.Create;
begin
  inherited Create('OS user has changed since activation and the license is user-locked.');
  FErrorCode := LA_E_OS_USER;
end;

constructor ELAInvalidPermissionFlagException.Create;
begin
  inherited Create('Invalid permission flag');
  FErrorCode := LA_E_INVALID_PERMISSION_FLAG;
end;

constructor ELAFreePlanActivationLimitReachedException.Create;
begin
  inherited Create('The free plan has reached it''s activation limit.');
  FErrorCode := LA_E_FREE_PLAN_ACTIVATION_LIMIT_REACHED;
end;

constructor ELAFeatureEntitlementsInvalidException.Create;
begin
  inherited Create('Invalid feature entitlements');
  FErrorCode := LA_E_FEATURE_ENTITLEMENTS_INVALID;
end;

constructor ELAFeatureEntitlementNotFoundException.Create;
begin
  inherited Create('The feature entitlement does not exist');
  FErrorCode := LA_E_FEATURE_ENTITLEMENT_NOT_FOUND;
end;

constructor ELAEntitlementSetNotLinkedException.Create;
begin
  inherited Create('No entitlement set is linked to the license');
  FErrorCode := LA_E_ENTITLEMENT_SET_NOT_LINKED;
end;

constructor ELALicenseNotEffectiveException.Create;
begin
  inherited Create('The license cannot be activated before its effective date');
  FErrorCode := LA_E_LICENSE_NOT_EFFECTIVE;
end;

initialization
  InitializeCriticalSection(LALicenseCallbackMutex[lciSetLicenseCallback]);
  InitializeCriticalSection(LALicenseCallbackMutex[lciCheckForReleaseUpdate]);
finalization
  try ResetCheckForReleaseUpdateCallback; except end;
  try ResetLicenseCallback; except end;
  DeleteCriticalSection(LALicenseCallbackMutex[lciCheckForReleaseUpdate]);
  DeleteCriticalSection(LALicenseCallbackMutex[lciSetLicenseCallback]);
end.
