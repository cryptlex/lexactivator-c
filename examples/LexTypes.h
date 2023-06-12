#ifndef LEX_TYPES_H
#define LEX_TYPES_H

#define BUFFER_SIZE 256
#define MAX_RELEASE_PLATFORMS 10
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
    CHARTYPE id[BUFFER_SIZE];
    CHARTYPE name[BUFFER_SIZE];
    CHARTYPE url[BUFFER_SIZE];
    CHARTYPE extension[BUFFER_SIZE];
    CHARTYPE checksum[BUFFER_SIZE];
    CHARTYPE releaseId[BUFFER_SIZE];
    CHARTYPE createdAt[BUFFER_SIZE];
    CHARTYPE updatedAt[BUFFER_SIZE];
} ReleaseFile;

typedef struct
{
    int totalFiles;
    int isPrivate;
    int published;
    CHARTYPE id[BUFFER_SIZE];
    CHARTYPE createdAt[BUFFER_SIZE];
    CHARTYPE updatedAt[BUFFER_SIZE];
    CHARTYPE name[BUFFER_SIZE];
    CHARTYPE channel[BUFFER_SIZE];
    CHARTYPE version[BUFFER_SIZE];
    CHARTYPE notes[BUFFER_SIZE];
    CHARTYPE publishedAt[BUFFER_SIZE];
    CHARTYPE productId[BUFFER_SIZE];
    CHARTYPE platforms[MAX_RELEASE_PLATFORMS][BUFFER_SIZE];
    ReleaseFile files[MAX_RELEASE_FILES];
} Release;

typedef struct 
{
    CHARTYPE addressLine1[BUFFER_SIZE];
    CHARTYPE addressLine2[BUFFER_SIZE];
    CHARTYPE city[BUFFER_SIZE];
    CHARTYPE state[BUFFER_SIZE];
    CHARTYPE country[BUFFER_SIZE];
    CHARTYPE postalCode[BUFFER_SIZE];
} OrganizationAddress;
#endif // LEX_TYPES_H