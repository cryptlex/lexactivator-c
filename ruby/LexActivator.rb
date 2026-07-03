require "ffi"

module LexActivator
  extend FFI::Library
  ffi_lib ["#{File.dirname(__FILE__)}/libLexActivator.dylib", "./libLexActivator.so", "#{File.dirname(__FILE__)}/LexActivator.dll"]
  callback :license_callback, [:uint], :void
  callback :release_update_callback, [:uint], :void

  def self.attach_function(name, *_)
    begin; super;     rescue FFI::NotFoundError => e
      (class << self; self; end).class_eval { define_method(name) { |*_| raise e } }
    end
  end

  def self.encode_utf16(input)
    if FFI::Platform::IS_WINDOWS
      input.encode("UTF-16LE")
    else
      input
    end
  end

  def self.decode_utf16(input)
    if FFI::Platform::IS_WINDOWS
      "#{input}\0".force_encoding("UTF-16LE").encode("UTF-8", :invalid => :replace, :undef => :replace)
    else
      input
    end
  end

  module PermissionFlags
    LA_USER = 1
    LA_SYSTEM = 2
    LA_ALL_USERS = 3
    LA_IN_MEMORY = 4
  end

  BUFFER_SIZE_256 = 256
  BUFFER_SIZE_4096 = 4096
  MAX_METADATA_SIZE = 100 

  class OrganizationAddress < FFI::Struct
    layout :addressLine1, [:char, BUFFER_SIZE_256],
           :addressLine2, [:char, BUFFER_SIZE_256],
           :city, [:char, BUFFER_SIZE_256],
           :state, [:char, BUFFER_SIZE_256],
           :country, [:char, BUFFER_SIZE_256],
           :postalCode, [:char, BUFFER_SIZE_256]
  end

  class Metadata < FFI::Struct
    layout :key, [:char, BUFFER_SIZE_256],
           :value, [:char, BUFFER_SIZE_4096]
  end

  class UserLicense < FFI::Struct
    layout :allowedActivations, :int64,
           :allowedDeactivations, :int64,
           :key, [:char, BUFFER_SIZE_256],
           :totalActivations, :uint32,
           :totalDeactivations, :uint32,
           :type, [:char, BUFFER_SIZE_256],
           :metadata, [Metadata, MAX_METADATA_SIZE] 
  end

  class FeatureEntitlement < FFI::Struct
    layout :featureName, [:char, BUFFER_SIZE_256],
           :featureDisplayName, [:char, BUFFER_SIZE_256],
           :value, [:char, BUFFER_SIZE_256],
           :expiresAt, :int64
  end

  # @method SetProductFile(file_path)
  # @param [String] file_path
  # @return [Integer]
  # @scope class
  attach_function :SetProductFile, :SetProductFile, [:string], :int

  # @method SetProductData(product_data)
  # @param [String] product_data
  # @return [Integer]
  # @scope class
  attach_function :SetProductData, :SetProductData, [:string], :int

  # @method SetProductId(product_id, flags)
  # @param [String] product_id
  # @param [Integer] flags
  # @return [Integer]
  # @scope class
  attach_function :SetProductId, :SetProductId, [:string, :uint], :int

  # @method SetDebugMode(enable)
  # @param [Integer] enable - 0 or 1 to disable or enable logging.
  # @return [Integer]
  # @scope class
  attach_function :SetDebugMode, :SetDebugMode, [:uint], :int

  # @method SetCustomDeviceFingerprint(fingerprint)
  # @param [String] fingerprint
  # @return [Integer]
  # @scope class
  attach_function :SetCustomDeviceFingerprint, :SetCustomDeviceFingerprint, [:string], :int

  # @method SetLicenseKey(license_key)
  # @param [String] license_key
  # @return [Integer]
  # @scope class
  attach_function :SetLicenseKey, :SetLicenseKey, [:string], :int

  # @method SetLicenseUserCredential(email, password)
  # @param [String] email
  # @param [String] password
  # @return [Integer]
  # @scope class
  attach_function :SetLicenseUserCredential, :SetLicenseUserCredential, [:string, :string], :int

  # @method SetLicenseCallback(callback)
  # @param [FFI::Pointer(CallbackType)] callback
  # @return [Integer]
  # @scope class
  attach_function :SetLicenseCallback, :SetLicenseCallback, [:license_callback], :int
  
  # @method SetActivationLeaseDuration(leaseDuration)
  # @param [Integer] leaseDuration - value of the lease duration. A value of -1 indicates unlimited lease duration.
  # @return [Integer]
  # @scope class
  attach_function :SetActivationLeaseDuration, :SetActivationLeaseDuration, [:int64], :int

  # @method SetActivationMetadata(key, value)
  # @param [String] key
  # @param [String] value
  # @return [Integer]
  # @scope class
  attach_function :SetActivationMetadata, :SetActivationMetadata, [:string, :string], :int

  # @method SetTrialActivationMetadata(key, value)
  # @param [String] key
  # @param [String] value
  # @return [Integer]
  # @scope class
  attach_function :SetTrialActivationMetadata, :SetTrialActivationMetadata, [:string, :string], :int

  # @method SetAppVersion(app_version)
  # @param [String] app_version
  # @return [Integer]
  # @scope class
  attach_function :SetAppVersion, :SetAppVersion, [:string], :int

  # @method SetReleaseVersion(releaseVersion)
  # @param [String] releaseVersion - string in following allowed formats: x.x, x.x.x, x.x.x.x
  # @return [Integer]
  # @scope class
  attach_function :SetReleaseVersion, :SetReleaseVersion, [:string], :int
  
  # @method SetReleasePublishedDate(releasePublishedDate)
  # @param [Integer] releasePublishedDate - unix timestamp of release published date.
  # @return [Integer]
  # @scope class
  attach_function :SetReleasePublishedDate, :SetReleasePublishedDate, [:uint], :int

  # @method SetReleasePlatform(releasePlatform)
  # @param [String] releasePlatform - release platform e.g. windows, macos, linux 
  # @return [Integer]
  # @scope class
  attach_function :SetReleasePlatform, :SetReleasePlatform, [:string], :int

  # @method SetReleaseChannel(releaseChannel)
  # @param [String] releaseChannel - release channel e.g. stable
  # @return [Integer]
  # @scope class
  attach_function :SetReleaseChannel, :SetReleaseChannel, [:string], :int

  # @method SetOfflineActivationRequestMeterAttributeUses(name, uses)
  # @param [String] name - name of the meter attribute
  # @param [Integer] uses - the uses value
  # @return [Integer]
  # @scope class
  attach_function :SetOfflineActivationRequestMeterAttributeUses, :SetOfflineActivationRequestMeterAttributeUses, [:string, :uint], :int

  # @method SetNetworkProxy(proxy)
  # @param [String] proxy
  # @return [Integer]
  # @scope class
  attach_function :SetNetworkProxy, :SetNetworkProxy, [:string], :int

  # @method SetCryptlexHost(host)
  # @param [String] host
  # @return [Integer]
  # @scope class  
  attach_function :SetCryptlexHost, :SetCryptlexHost, [:string], :int

  # @method SetTwoFactorAuthenticationCode(twoFactorAuthenticationCode)
  # @param [String] twoFactorAuthenticationCode
  # @return [Integer]
  # @scope class
  attach_function :SetTwoFactorAuthenticationCode, :SetTwoFactorAuthenticationCode, [:string], :int

  # @method SetCacheMode(enable)
  # @param [Integer] enable - 0 or 1 to disable or enable in-memory caching.
  # @return [Integer]
  # @scope class
  attach_function :SetCacheMode, :SetCacheMode, [:uint], :int

  # @method GetProductMetadata(key, value, length)
  # @param [String] key
  # @param [String] value
  # @param [Integer] length
  # @return [Integer]
  # @scope class
  attach_function :GetProductMetadata, :GetProductMetadata, [:string, :pointer, :uint], :int

  # @method GetProductVersionName(name, length)
  # @param [String] name 
  # @param [Integer] length
  # @return [Integer]
  # @scope class
  attach_function :GetProductVersionName, :GetProductVersionName, [:pointer, :uint], :int

  # @method GetProductVersionDisplayName(displayName, length)
  # @param [String] displayName
  # @param [Integer] length
  # @return [Integer]
  # @scope class
  attach_function :GetProductVersionDisplayName, :GetProductVersionDisplayName, [:pointer, :uint], :int

  # @method GetLicenseAllowedActivations(allowedActivations)
  # @param [FFI::Pointer(*Int64T)] allowedActivations - A value of -1 indicates unlimited number of activations.
  # @return [Integer]
  # @scope class
  attach_function :GetLicenseAllowedActivations, :GetLicenseAllowedActivations, [:pointer], :int

  # @method GetLicenseTotalActivations(totalActivations)
  # @param [FFI::Pointer(*Uint32T)] totalActivations
  # @return [Integer]
  # @scope class
  attach_function :GetLicenseTotalActivations, :GetLicenseTotalActivations, [:pointer], :int

  # @method GetLicenseAllowedDeactivations()
  # @param [FFI::Pointer(*Int64T)] allowedDeactivations - A value of -1 indicates unlimited number of deactivations.
  # @return [Integer]
  # @scope class
  attach_function :GetLicenseAllowedDeactivations, :GetLicenseAllowedDeactivations, [:pointer], :int

  # @method GetLicenseTotalDeactivations()
  # @param [FFI::Pointer(*Uint32T)] totalDeactivations
  # @return [Integer]
  # @scope class
  attach_function :GetLicenseTotalDeactivations, :GetLicenseTotalDeactivations, [:pointer], :int

  # @method GetLicenseCreationDate(creationDate)
  # @param [FFI::Pointer(*Uint32T)] creationDate
  # @return [Integer]
  # @scope class
  attach_function :GetLicenseCreationDate, :GetLicenseCreationDate, [:pointer], :int

  # @method GetProductVersionFeatureFlag(name, enabled, data, length)
  # @param [String] name
  # @param [Integer] enabled - 0 or 1 indicating disabled or enabled for feature flag.
  # @param [String] data
  # @param [Integer] length
  # @return [Integer]
  # @scope class
  attach_function :GetProductVersionFeatureFlag, :GetProductVersionFeatureFlag, [:string, :pointer, :pointer, :uint], :int

  # @method GetLicenseEntitlementSetName(name, length)
  # @param [String] name
  # @param [Integer] length
  # @return [Integer]
  # @scope class
  attach_function :GetLicenseEntitlementSetName, :GetLicenseEntitlementSetName, [:pointer, :uint], :int

  # @method GetLicenseEntitlementSetDisplayName(displayName, length)
  # @param [String] displayName
  # @param [Integer] length
  # @return [Integer]
  # @scope class
  attach_function :GetLicenseEntitlementSetDisplayName, :GetLicenseEntitlementSetDisplayName, [:pointer, :uint], :int

  # @method GetFeatureEntitlements(featureEntitlements, length)
  # @param [FFI::Pointer(*FeatureEntitlement)] featureEntitlements - Pointer to an array of FeatureEntitlement structs
  # @param [Integer] length - The number of FeatureEntitlement structs in the array
  # @return [Integer]
  # @scope class
  attach_function :GetFeatureEntitlements, :GetFeatureEntitlements, [:pointer, :uint], :int

  # @method GetFeatureEntitlement(featureName, featureEntitlement)
  # @param [String] featureName - The name of the feature
  # @param [FFI::Pointer(*FeatureEntitlement)] featureEntitlement - Pointer to a FeatureEntitlement struct
  # @return [Integer]
  # @scope class
  attach_function :GetFeatureEntitlement, :GetFeatureEntitlement, [:string, :pointer], :int

  # @method GetLicenseMetadata(key, value, length)
  # @param [String] key
  # @param [String] value
  # @param [Integer] length
  # @return [Integer]
  # @scope class
  attach_function :GetLicenseMetadata, :GetLicenseMetadata, [:string, :pointer, :uint], :int

  # @method GetLicenseMeterAttribute(name, allowed_uses, total_uses, gross_uses)
  # @param [String] name
  # @param [FFI::Pointer(*Int64T)] allowed_uses
  # @param [FFI::Pointer(*Uint64T)] total_uses
  # @param [FFI::Pointer(*Uint64T)] gross_uses
  # @return [Integer]
  # @scope class
  attach_function :GetLicenseMeterAttribute, :GetLicenseMeterAttribute, [:string, :pointer, :pointer, :pointer], :int

  # @method GetLicenseKey(license_key, length)
  # @param [String] license_key
  # @param [Integer] length
  # @return [Integer]
  # @scope class
  attach_function :GetLicenseKey, :GetLicenseKey, [:pointer, :uint], :int

  # @method GetActivationCreationDate(creation_date)
  # @param [FFI::Pointer(*Uint32T)] creation_date
  # @return [Integer]
  # @scope class
  attach_function :GetActivationCreationDate, :GetActivationCreationDate, [:pointer], :int

  # @method GetActivationLastSyncedDate(last_synced_date)
  # @param [FFI::Pointer(*Uint32T)] last_synced_date
  # @return [Integer]
  # @scope class
  attach_function :GetActivationLastSyncedDate, :GetActivationLastSyncedDate, [:pointer], :int

  # @method GetLicenseExpiryDate(expiry_date)
  # @param [FFI::Pointer(*Uint32T)] expiry_date - A value of 0 indicates it has no expiry i.e a lifetime license.
  # @return [Integer]
  # @scope class
  attach_function :GetLicenseExpiryDate, :GetLicenseExpiryDate, [:pointer], :int

  # @method GetLicenseMaintenanceExpiryDate(maintenanceExpiryDate)
  # @param [FFI::Pointer(*Uint32T)] maintenanceExpiryDate - pointer to the integer that receives the value. A value of 0 indicates an unlimited maintenance period.  
  # @return [Integer]
  # @scope class
  attach_function :GetLicenseMaintenanceExpiryDate, :GetLicenseMaintenanceExpiryDate, [:pointer], :int

  # @method GetLicenseMaxAllowedReleaseVersion(maxAllowedReleaseVersion, length)
  # @param [String] maxAllowedReleaseVersion
  # @param [Integer] length 
  # @return [Integer]
  # @scope class
  attach_function :GetLicenseMaxAllowedReleaseVersion, :GetLicenseMaxAllowedReleaseVersion, [:pointer, :uint], :int

  # @method GetLicenseUserEmail(email, length)
  # @param [String] email
  # @param [Integer] length
  # @return [Integer]
  # @scope class
  attach_function :GetLicenseUserEmail, :GetLicenseUserEmail, [:pointer, :uint], :int

  # @method GetLicenseUserName(name, length)
  # @param [String] name
  # @param [Integer] length
  # @return [Integer]
  # @scope class
  attach_function :GetLicenseUserName, :GetLicenseUserName, [:pointer, :uint], :int

  # @method GetLicenseUserCompany(name, length)
  # @param [String] name
  # @param [Integer] length
  # @return [Integer]
  # @scope class
  attach_function :GetLicenseUserCompany, :GetLicenseUserCompany, [:pointer, :uint], :int

  # @method GetLicenseUserMetadata(key, value, length)
  # @param [String] key
  # @param [String] value
  # @param [Integer] length
  # @return [Integer]
  # @scope class
  attach_function :GetLicenseUserMetadata, :GetLicenseUserMetadata, [:string, :pointer, :uint], :int

  # @method GetLicenseOrganizationAddress(organizationAddress)
  # @param [FFI::Pointer(OrganizationAddress)] organizationAddress
  # @return [Integer]
  # @scope class
  attach_function :GetLicenseOrganizationAddress, :GetLicenseOrganizationAddress, [:pointer], :int

  # @method GetUserLicenses(userLicenses, length)
  # @param [FFI::Pointer(UserLicense)] userLicenses - Pointer to an array of UserLicense structs
  # @param [Integer] length - The number of UserLicense structs in the array
  # @return [Integer]
  # @scope class
  attach_function :GetUserLicenses, :GetUserLicenses, [:pointer, :uint], :int

  # @method GetLicenseOrganizationName(organizationName, length)
  # @param [String] organizationName
  # @param [Integer] length
  # @return [Integer]
  # @scope class
  attach_function :GetLicenseOrganizationName, :GetLicenseOrganizationName, [:pointer, :uint], :int

  # @method GetLicenseType(license_type, length)
  # @param [String] license_type
  # @param [Integer] length
  # @return [Integer]
  # @scope class
  attach_function :GetLicenseType, :GetLicenseType, [:pointer, :uint], :int

  # @method GetActivationId(id, length)
  # @param [String] id
  # @param [Integer] length
  # @return [Integer]
  # @scope class
  attach_function :GetActivationId, :GetActivationId, [:pointer, :uint], :int

  # @method GetActivationMetadata(key, value, length)
  # @param [String] key
  # @param [String] value
  # @param [Integer] length
  # @return [Integer]
  # @scope class
  attach_function :GetActivationMetadata, :GetActivationMetadata, [:string, :pointer, :uint], :int

  # @method GetActivationMode(initialMode, initialModeLength, currentMode, currentModeLength)
  # @param [String] initialMode
  # @param [Integer] initialModeLength
  # @param [String] currentMode
  # @param [Integer] currentModeLength
  # @return [Integer]
  # @scope class
  attach_function :GetActivationMode, :GetActivationMode, [:pointer, :uint, :pointer, :uint], :int

  # @method GetActivationMeterAttributeUses(name, uses)
  # @param [String] name
  # @param [FFI::Pointer(*Uint32T)] uses
  # @return [Integer]
  # @scope class
  attach_function :GetActivationMeterAttributeUses, :GetActivationMeterAttributeUses, [:string, :pointer], :int

  # @method GetServerSyncGracePeriodExpiryDate(expiry_date)
  # @param [FFI::Pointer(*Uint32T)] expiry_date
  # @return [Integer]
  # @scope class
  attach_function :GetServerSyncGracePeriodExpiryDate, :GetServerSyncGracePeriodExpiryDate, [:pointer], :int

  # @method GetLastActivationError(error_code)
  # @param [FFI::Pointer(*Uint32T)] error_code
  # @return [Integer]
  # @scope class
  attach_function :GetLastActivationError, :GetLastActivationError, [:pointer], :int

  # @method GetTrialActivationMetadata(key, value, length)
  # @param [String] key
  # @param [String] value
  # @param [Integer] length
  # @return [Integer]
  # @scope class
  attach_function :GetTrialActivationMetadata, :GetTrialActivationMetadata, [:string, :pointer, :uint], :int

  # @method GetTrialExpiryDate(trial_expiry_date)
  # @param [FFI::Pointer(*Uint32T)] trial_expiry_date
  # @return [Integer]
  # @scope class
  attach_function :GetTrialExpiryDate, :GetTrialExpiryDate, [:pointer], :int

  # @method GetTrialId(trial_id, length)
  # @param [String] trial_id
  # @param [Integer] length
  # @return [Integer]
  # @scope class
  attach_function :GetTrialId, :GetTrialId, [:pointer, :uint], :int

  # @method GetLibraryVersion(libraryVersion, length)
  # @param [String] libraryVersion
  # @param [Integer] length 
  # @return [Integer]
  # @scope class
  attach_function :GetLibraryVersion, :GetLibraryVersion, [:pointer, :uint], :int

  # @method GetLocalTrialExpiryDate(trial_expiry_date)
  # @param [FFI::Pointer(*Uint32T)] trial_expiry_date
  # @return [Integer]
  # @scope class
  attach_function :GetLocalTrialExpiryDate, :GetLocalTrialExpiryDate, [:pointer], :int

  # @method CheckForReleaseUpdate(platform, version, channel, callback)
  # @param [String] platform
  # @param [String] version
  # @param [String] channel
  # @param [FFI::Pointer(CallbackType)] callback
  # @return [Integer]
  # @scope class
  attach_function :CheckForReleaseUpdate, :CheckForReleaseUpdate, [:string, :string, :string, :release_update_callback], :int

  # @method AuthenticateUser(email, password)
  # @param [String] email
  # @param [String] password
  # @return [Integer]
  # @scope class
  attach_function :AuthenticateUser, :AuthenticateUser, [:string, :string], :int

  # @method AuthenticateUserWithIdToken(idToken)
  # @param [String] idToken - The id token obtained from the OIDC provider.
  # @return [Integer]
  # @scope class
  attach_function :AuthenticateUserWithIdToken, :AuthenticateUserWithIdToken, [:string], :int

  # @method ActivateLicense()
  # @return [Integer]
  # @scope class
  attach_function :ActivateLicense, :ActivateLicense, [], :int

  # @method ActivateLicenseOffline(file_path)
  # @param [String] file_path
  # @return [Integer]
  # @scope class
  attach_function :ActivateLicenseOffline, :ActivateLicenseOffline, [:string], :int

  # @method GenerateOfflineActivationRequest(file_path)
  # @param [String] file_path
  # @return [Integer]
  # @scope class
  attach_function :GenerateOfflineActivationRequest, :GenerateOfflineActivationRequest, [:string], :int

  # @method DeactivateLicense()
  # @return [Integer]
  # @scope class
  attach_function :DeactivateLicense, :DeactivateLicense, [], :int

  # @method GenerateOfflineDeactivationRequest(file_path)
  # @param [String] file_path
  # @return [Integer]
  # @scope class
  attach_function :GenerateOfflineDeactivationRequest, :GenerateOfflineDeactivationRequest, [:string], :int

  # @method IsLicenseGenuine()
  # @return [Integer]
  # @scope class
  attach_function :IsLicenseGenuine, :IsLicenseGenuine, [], :int

  # @method IsLicenseValid()
  # @return [Integer]
  # @scope class
  attach_function :IsLicenseValid, :IsLicenseValid, [], :int

  # @method ActivateTrial()
  # @return [Integer]
  # @scope class
  attach_function :ActivateTrial, :ActivateTrial, [], :int

  # @method ActivateTrialOffline(file_path)
  # @param [String] file_path
  # @return [Integer]
  # @scope class
  attach_function :ActivateTrialOffline, :ActivateTrialOffline, [:string], :int

  # @method GenerateOfflineTrialActivationRequest(file_path)
  # @param [String] file_path
  # @return [Integer]
  # @scope class
  attach_function :GenerateOfflineTrialActivationRequest, :GenerateOfflineTrialActivationRequest, [:string], :int

  # @method IsTrialGenuine()
  # @return [Integer]
  # @scope class
  attach_function :IsTrialGenuine, :IsTrialGenuine, [], :int

  # @method ActivateLocalTrial(trial_length)
  # @param [Integer] trial_length
  # @return [Integer]
  # @scope class
  attach_function :ActivateLocalTrial, :ActivateLocalTrial, [:uint], :int

  # @method IsLocalTrialGenuine()
  # @return [Integer]
  # @scope class
  attach_function :IsLocalTrialGenuine, :IsLocalTrialGenuine, [], :int

  # @method ExtendLocalTrial(trial_extension_length)
  # @param [Integer] trial_extension_length
  # @return [Integer]
  # @scope class
  attach_function :ExtendLocalTrial, :ExtendLocalTrial, [:uint], :int

  # @method IncrementActivationMeterAttributeUses(name, increment)
  # @param [String] name
  # @param [Integer] increment
  # @return [Integer]
  # @scope class
  attach_function :IncrementActivationMeterAttributeUses, :IncrementActivationMeterAttributeUses, [:string, :uint], :int

  # @method DecrementActivationMeterAttributeUses(name, decrement)
  # @param [String] name
  # @param [Integer] decrement
  # @return [Integer]
  # @scope class
  attach_function :DecrementActivationMeterAttributeUses, :DecrementActivationMeterAttributeUses, [:string, :uint], :int

  # @method ResetActivationMeterAttributeUses(name)
  # @param [String] name
  # @return [Integer]
  # @scope class
  attach_function :ResetActivationMeterAttributeUses, :ResetActivationMeterAttributeUses, [:string], :int

  # @method Reset()
  # @return [Integer]
  # @scope class
  attach_function :Reset, :Reset, [], :int
end
