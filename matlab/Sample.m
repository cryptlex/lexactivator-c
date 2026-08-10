sProductData = 'PASTE_CONTENT_OF_PRODUCT.DAT_FILE';
sProductId = 'PASTE_PRODUCT_ID';
sReleaseVersion = '1.0.0';

%Loads the C library of LexActivator
sHeaderFile = './LexActivator.h';
sStatusHeaderFile = './LexStatusCodes.h';
sTypesHeaderFile = './LexTypes.h';
sSharedLibrary = 'LexActivator';
%unloadlibrary(sSharedLibrary)
if not(libisloaded(sSharedLibrary))
   loadlibrary(sSharedLibrary,sHeaderFile, 'addheader',sStatusHeaderFile, 'addheader',sTypesHeaderFile);
end
%Creates and prints the list of the functions of the library with their arguments
%list = libfunctions(sSharedLibrary,'-full');

% Calls function to set the product data
status = calllib(sSharedLibrary,'SetProductData',toString(sProductData));

if status ~= 0
    fprintf('Error Code: %.0f\n',status)
    return
end
% Calls function to set the product id
status = calllib(sSharedLibrary,'SetProductId',toString(sProductId), uint32(1));
if status ~= 0
    fprintf('Error Code: %.0f\n',status)
    return
end
% Calls function to set the release version
status = calllib(sSharedLibrary,'SetReleaseVersion',toString(sReleaseVersion));
if status ~= 0
    fprintf('Error Code: %.0f\n',status)
    return
end

% Calls function to check if license is activated
status = calllib(sSharedLibrary,'IsLicenseGenuine');
if status == 0
    fprintf('License is genuinely activated!\n')
    % [status, metadataKey, metadataValue] = calllib(sSharedLibrary,'GetLicenseMetadata', toString('feature1'), blanks(256),256 );
    % disp(metadataValue);
elseif status == 20
    fprintf('License is genuinely activated but has expired!\n')
elseif status == 21
    fprintf('License is genuinely activated but has been suspended!\n')
elseif status == 22
    fprintf('License is genuinely activated but grace period is over!\n')
else
    % Calls function to check if license is activated
    trialStatus = calllib(sSharedLibrary,'IsTrialGenuine');
    if trialStatus == 0
        fprintf('Trial is valid')
    elseif trialStatus == 25
        fprintf('Trial has expired!')
        % Time to buy the license and activate the app
        activate()
    else
        fprintf('Either trial has not started or has been tampered!\n')
        % Activating the trial
        activateTrial()
    end
end

% Checking for software release update
% Call SetReleaseVersion(), SetReleasePlatform() and SetReleaseChannel() before calling CheckReleaseUpdate()
% Release version, platform and channel must be set before checking for an update
% status = calllib(sSharedLibrary,'CheckReleaseUpdate',releaseUpdateCallback,uint32(2),[]);

function output = toString(input)
    if ispc
        output = [uint16(input) 0];
    else
        output = input;
    end
end

function activate()
    sSharedLibrary = 'LexActivator';
    sLicenseKey = 'PASTE_LICENCE_KEY';
    % Calls function to set the license key
    status = calllib(sSharedLibrary,'SetLicenseKey', toString(sLicenseKey));
	if status ~= 0
		fprintf('Error Code: %.0f\n',status)
		return
	end
    % Calls function to activate the license key
    status = calllib(sSharedLibrary,'ActivateLicense');
	if status == 0 || status == 20 || status == 21
		fprintf('License activated successfully: %.0f\n',status)
	else
		fprintf('License activation failed: %.0f\n',status)
	end
end

function activateTrial()
    sSharedLibrary = 'LexActivator';
    % Calls function to activate the trial
    status = calllib(sSharedLibrary,'ActivateTrial');
	if status == 0
		fprintf('Product trial activated successfully!\n')
	elseif status == 25
		fprintf('Product trial has expired!\n')
	else
		fprintf('Product trial activation failed:%.0f\n',status)
	end
end
