require "./LexActivator"
require "./LexStatusCodes"


# Refer to following link for LexActivator API docs:
# https://github.com/cryptlex/lexactivator-c/blob/master/examples/LexActivator.h

def init()
  
  status = LexActivator.SetProductData(LexActivator::encode_utf16("QjUyQUI2MEZBNjkxMTkxNEUzODU3NDlDNjhERUIwMEQ=.hsxt2GEhlK2eJTHu0EDfPSOyVajGrg3a8drLojLLT8IftRPoL1GC1lVduol5X5OcDcNw5xgjnhRctesGdkldkKnamhMg6VKuUgJ3771T07ghyWRxnhPGGuHGyAB47x6SwSZfxtR3RMVH4I2kwN33T+LAVnPgaOIRMnl3Vt+yL1kcANUtJSzfvuxOwToLbF1aLYAfvLeI8wNbMGL6usVibjn4nDrme/dTXwqMl4g9kQfkYT/zm1bLgUv6xg6SUhZPaKHLjoNOqJ3xojHxrJ/n4kJ+2j6WWedfepqL1wnR+vu1VRNxNkkVxgHCM0HkeJ5qYf8L+RNAp8qISgILp4dsTX18HXSADXXK4YrTjAJItM+x6SxeL2kmhllB5/VLtjIOfJHz9y0QDrHJrq5O370zHC2CDiB+1Qj8wIbA/S+ej+nOgb29CFhezk+nACIjAnbF3w9Rdj7xBIsROVWXljVVwitRZE6Fdp44a3uPlJ3c8IVHOFDy/IJ+aQgeVKsOwlHwVMiS2p8uVlrJyNLTpZU3QDBBh14avbbusZ+EUvEp9SHo8tLTwOvrzppudcCpe+TT9OcwlXl72+IUabzaBUXD/Q81XVF1LgA/7GVECI8b+W+/IRAKo+qXWgw2TbBr66wigYeX9E4EEx2/NHWx+a7Q2Cu617UB9Da9lzJiQF8GzK15NXtl/vu/bxqGMskyytsfZJ8Xx2Z9AfVAwgZHINj19W1xf1Z+nYxrb8LExVTRe5lNNGCcHelXNfJE+TDx8OupI3pnLWCUX+x2m1AQbq2RJiXM5ORc7M41mZc6aS8oH/iXhPHJEXNAe5gaLdR4WXEO"))
  if LexStatusCodes::LA_OK != status
    puts "Error Code: #{status}"
    exit(status)
  end

  status = LexActivator.SetProductId(LexActivator::encode_utf16("01997b28-eeb0-7fcb-aab2-a6bf4a2f6fc3"), LexActivator::PermissionFlags::LA_USER)
  if LexStatusCodes::LA_OK != status
    puts "Error Code: #{status}"
    exit(status)
  end

  status = LexActivator.SetReleaseVersion(LexActivator::encode_utf16("1.0.0"))
  if LexStatusCodes::LA_OK != status
    puts "Error Code: #{status}"
    exit(status)
  end
end

def activate()
  status = LexActivator.SetLicenseKey(LexActivator::encode_utf16("2430B5-3FFBAA-49D881-311BC2-D1A748-E2DDEB"))
  if LexStatusCodes::LA_OK != status
    puts "Error Code: #{status}"
    exit(status)
  end

  status = LexActivator.SetActivationMetadata(LexActivator::encode_utf16("key1"), LexActivator::encode_utf16("value1"))
  if LexStatusCodes::LA_OK != status
    puts "Error Code: #{status}"
    exit(status)
  end

  status = LexActivator.ActivateLicense()
  if [LexStatusCodes::LA_OK, LexStatusCodes::LA_EXPIRED, LexStatusCodes::LA_SUSPENDED].include?(status)
    puts "License activated successfully: #{status}"
  else
    puts "License activation failed: #{status}"
    exit(status)
  end
end

def activate_trial()
  status = LexActivator.SetTrialActivationMetadata(LexActivator::encode_utf16("key1"), LexActivator::encode_utf16("value1"))
  if LexStatusCodes::LA_OK != status
    puts "Error Code: #{status}"
    exit(status)
  end

  status = LexActivator.ActivateTrial()
  if LexStatusCodes::LA_OK == status
    puts "Product trial activated successfully!"
  elsif LexStatusCodes::LA_TRIAL_EXPIRED == status
    puts "Product trial has expired!"
  else
    puts "Product trial activation failed: #{status}"
  end
end

# License callback (optional)
LicenseCallback = FFI::Function.new(:void, [:uint]) do |status|
  puts "License status: #{status}"
end

SoftwareReleaseUpdateCallback = FFI::Function.new(:void, [:uint]) do |status|
  puts "Release status: #{status}"
end

# Run it
init()
activate() # uncomment this to activate the license
LexActivator.SetLicenseCallback(LicenseCallback)
status = LexActivator.IsLicenseGenuine()
if LexStatusCodes::LA_OK == status
  # get days left for expiry
  expiryDate = FFI::MemoryPointer.new(:uint)
  LexActivator.GetLicenseExpiryDate(expiryDate)
  daysLeft = (expiryDate.read_int - Time.now.to_i) / 86400
  puts "Days left: #{daysLeft}"
  tier = FFI::MemoryPointer.new(:int64)
  LexActivator.GetLicenseEntitlementSetTier(tier)
  puts "tier: #{tier.read_int}" 
  # get license user email
  buffer = FFI::MemoryPointer.new(:char, 256)
  LexActivator.GetLicenseUserEmail(buffer, buffer.size)
  email = LexActivator::decode_utf16(buffer.read_string(buffer.size).rstrip)
  puts "License user email: #{email}"
  puts "License is genuinely activated!"
elsif LexStatusCodes::LA_EXPIRED == status
  puts "License is genuinely activated but has expired!"
elsif LexStatusCodes::LA_SUSPENDED == status
  puts "License is genuinely activated but has been suspended!"
elsif LexStatusCodes::LA_GRACE_PERIOD_OVER == status
  puts "License is genuinely activated but grace period is over!"
else
  trialStatus = LexActivator.IsTrialGenuine()
  if LexStatusCodes::LA_OK == trialStatus
    # get days left for expiry
    trialExpiryDate = FFI::MemoryPointer.new(:uint)
    LexActivator.GetTrialExpiryDate(trialExpiryDate)
    daysLeft = (trialExpiryDate.read_int - Time.now.to_i) / 86500
    puts "Trial days left: #{daysLeft}"
  elsif LexStatusCodes::LA_TRIAL_EXPIRED == trialStatus
    puts "Trial has expired!"
    # Time to buy the license and activate the app
    activate()
  else
    puts "Either trial has not started or has been tampered!"
    # Activating the trial
    activate_trial()
  end
end

# Checking for software release update
# Call SetReleasePlatform() and SetReleaseChannel() before calling CheckReleaseUpdate()
# Release platform and channel must be set before checking for an update
# status = LexActivator.SetReleasePlatform(LexActivator::encode_utf16("windows"))
# status = LexActivator.SetReleaseChannel(LexActivator::encode_utf16("1.0.0"))
# status = LexActivator.CheckForReleaseUpdate("windows", "1.0.0", "stable", SoftwareReleaseUpdateCallback)

puts "Press Enter to exit..."
gets
