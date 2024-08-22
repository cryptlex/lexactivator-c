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

#ifdef _WIN32
    typedef wchar_t CHARTYPE;
#else
    typedef char CHARTYPE;
#endif

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

typedef struct 
{
    CHARTYPE addressLine1[BUFFER_SIZE_256];
    CHARTYPE addressLine2[BUFFER_SIZE_256];
    CHARTYPE city[BUFFER_SIZE_256];
    CHARTYPE state[BUFFER_SIZE_256];
    CHARTYPE country[BUFFER_SIZE_256];
    CHARTYPE postalCode[BUFFER_SIZE_256];
} OrganizationAddress;

typedef struct
{
    CHARTYPE key[BUFFER_SIZE_256];
    CHARTYPE value[BUFFER_SIZE_4096];
} Metadata;

typedef struct
{
    int64_t allowedActivations;
    int64_t allowedDeactivations;
    CHARTYPE key[BUFFER_SIZE_256];
    CHARTYPE type[BUFFER_SIZE_256];
    Metadata metadata[MAX_METADATA_SIZE];
} UserLicense;

#endif // LEX_TYPES_H