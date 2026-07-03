#ifndef LEX_TYPES_H
#define LEX_TYPES_H

#include <stdint.h>
#define BUFFER_SIZE_256 256
#define BUFFER_SIZE_2048 2048
#define BUFFER_SIZE_4096 4096
#define MAX_METADATA_SIZE 100
#define MAX_RELEASE_PLATFORMS 10
#define MAX_LICENSE_KEYS 100
#define MAX_RELEASE_FILES 10
#define MAX_FEATURE_ENTITLEMENTS 200

#ifdef _WIN32
    typedef wchar_t CHARTYPE;
#else
    typedef char CHARTYPE;
#endif

/*
    STRUCT: ReleaseFile

    MEMBERS:
    * size        - Size of the file in bytes.
    * downloads   - Number of times this file has been downloaded.
    * secured     - Whether the file is secured (1) or not (0).
    * id          - Unique identifier for the release file.
    * name        - Name of the file.
    * url         - Download URL of the file.
    * extension   - File extension.
    * checksum    - Checksum of the file for integrity verification.
    * releaseId   - Unique identifier of the release this file belongs to.
    * createdAt   - Timestamp when the file was created.
    * updatedAt   - Timestamp when the file was last updated.
*/
typedef struct
{
    int size;
    int downloads;
    int secured;
    CHARTYPE id[BUFFER_SIZE_256];
    CHARTYPE name[BUFFER_SIZE_256];
    CHARTYPE url[BUFFER_SIZE_2048];
    CHARTYPE extension[BUFFER_SIZE_256];
    CHARTYPE checksum[BUFFER_SIZE_256];
    CHARTYPE releaseId[BUFFER_SIZE_256];
    CHARTYPE createdAt[BUFFER_SIZE_256];
    CHARTYPE updatedAt[BUFFER_SIZE_256];
} ReleaseFile;

/*
    STRUCT: Release

    MEMBERS:
    * totalFiles     - Number of files in this release.
    * isPrivate      - Whether the release is private (1) or public (0).
    * published      - Whether the release is published (1) or not (0).
    * id             - Unique identifier of the release.
    * createdAt      - Timestamp when the release was created.
    * updatedAt      - Timestamp when the release was last updated.
    * name           - Name of the release.
    * channel        - Release channel (e.g., stable, beta).
    * version        - Version of the release (e.g., 1.0.0).
    * notes          - Release notes.
    * publishedAt    - Timestamp when the release was published.
    * productId      - Unique identifier of the associated product.
    * platforms      - Supported platforms (e.g., windows, linux).
    * files          - Array of release files included in the release.
*/
typedef struct
{
    int totalFiles;
    int isPrivate;
    int published;
    CHARTYPE id[BUFFER_SIZE_256];
    CHARTYPE createdAt[BUFFER_SIZE_256];
    CHARTYPE updatedAt[BUFFER_SIZE_256];
    CHARTYPE name[BUFFER_SIZE_256];
    CHARTYPE channel[BUFFER_SIZE_256];
    CHARTYPE version[BUFFER_SIZE_256];
    CHARTYPE notes[BUFFER_SIZE_4096];
    CHARTYPE publishedAt[BUFFER_SIZE_256];
    CHARTYPE productId[BUFFER_SIZE_256];
    CHARTYPE platforms[MAX_RELEASE_PLATFORMS][BUFFER_SIZE_256];
    ReleaseFile files[MAX_RELEASE_FILES];
} Release;

/*
    STRUCT: OrganizationAddress

    MEMBERS:
    * addressLine1   - First line of the address.
    * addressLine2   - Second line of the address.
    * city           - City name.
    * state          - State.
    * country        - Country name.
    * postalCode     - Postal or ZIP code.
*/
typedef struct 
{
    CHARTYPE addressLine1[BUFFER_SIZE_256];
    CHARTYPE addressLine2[BUFFER_SIZE_256];
    CHARTYPE city[BUFFER_SIZE_256];
    CHARTYPE state[BUFFER_SIZE_256];
    CHARTYPE country[BUFFER_SIZE_256];
    CHARTYPE postalCode[BUFFER_SIZE_256];
} OrganizationAddress;

/*
    STRUCT: FeatureEntitlement

    MEMBERS:
    * featureName         - Name of the feature.
    * featureDisplayName  - Display name of the feature.
    * value               - Value associated with the feature.
*/
typedef struct 
{
    CHARTYPE featureName[BUFFER_SIZE_256];
    CHARTYPE featureDisplayName[BUFFER_SIZE_256];
    CHARTYPE value[BUFFER_SIZE_256];
} FeatureEntitlement;

/*
    STRUCT: Metadata

    MEMBERS:
    * key   - Key of the metadata.
    * value - Value of the metadata.
*/
typedef struct
{
    CHARTYPE key[BUFFER_SIZE_256];
    CHARTYPE value[BUFFER_SIZE_4096];
} Metadata;

/*
    STRUCT: UserLicense

    MEMBERS:
    * allowedActivations   - Maximum number of activations allowed.
    * allowedDeactivations - Maximum number of deactivations allowed.
    * key                  - License key.
    * type                 - Type of the license (e.g., "node-locked", "floating").
    * metadata             - Array of metadata associated with the user's license.
*/
typedef struct
{
    int64_t allowedActivations;
    int64_t allowedDeactivations;
    CHARTYPE key[BUFFER_SIZE_256];
    CHARTYPE type[BUFFER_SIZE_256];
    Metadata metadata[MAX_METADATA_SIZE];
} UserLicense;

#endif // LEX_TYPES_H