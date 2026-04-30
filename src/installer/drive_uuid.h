// was ai used in this file? yes
//
// this is a separate file because i used including source files
// in other files so it kinda broke because of a problem like
// this cannot use that -> backend.c <- include that

#ifndef DRIVE_UUID_H
#define DRIVE_UUID_H

#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <fcntl.h>
#include <unistd.h>

typedef struct {
    uint8_t bytes[16];
} uuid_t;

typedef struct {
    uuid_t id;
    char   drive[256];
    char   uuid_str[37];
} drive_uuid_t;


static inline int _uuid_random_bytes(uint8_t *buf, size_t n)
{
    int fd = open("/dev/urandom", O_RDONLY);
    if (fd < 0) return -1;
    ssize_t got = read(fd, buf, n);
    close(fd);
    return (got == (ssize_t)n) ? 0 : -1;
}


static inline int uuid_generate(uuid_t *out)
{
    if (_uuid_random_bytes(out->bytes, 16) != 0)
        return -1;

    out->bytes[6] = (uint8_t)((out->bytes[6] & 0x0F) | 0x40);
    out->bytes[8] = (uint8_t)((out->bytes[8] & 0x3F) | 0x80);

    return 0;
}


static inline void uuid_to_string(const uuid_t *id, char *dst)
{
    const uint8_t *b = id->bytes;
    snprintf(dst, 37,
        "%02x%02x%02x%02x-"
        "%02x%02x-"
        "%02x%02x-"
        "%02x%02x-"
        "%02x%02x%02x%02x%02x%02x",
        b[0],  b[1],  b[2],  b[3],
        b[4],  b[5],
        b[6],  b[7],
        b[8],  b[9],
        b[10], b[11], b[12], b[13], b[14], b[15]);
}


static inline int assign_uuid_to_drive(const char *drive, drive_uuid_t *out)
{
   memset(out, 0, sizeof(*out));
   strncpy(out->drive, drive, sizeof(out->drive) - 1);

   if (uuid_generate(&out->id) != 0)
       return -1;

   uuid_to_string(&out->id, out->uuid_str);

   char path[512];
   snprintf(path, sizeof(path), "%s/.drive_uuid", drive);

   FILE *f = fopen(path, "w");
   if (!f)
       return -1;

   fprintf(f, "%s\n", out->uuid_str);
   fclose(f);

   return 0;
}

static inline int uuid_drive(char *drive)
{
    drive_uuid_t tmp;

    if (assign_uuid_to_drive(drive, &tmp) != 0)
        return -1;

    printf("  Assigned UUID %s to %s\n", tmp.uuid_str, drive);
    sync();
    return 0;
}

static inline char *get_drive_uuid(const char *drive)
{
    char path[512];
    snprintf(path, sizeof(path), "%s/.drive_uuid", drive);

    FILE *f = fopen(path, "r");
    if (!f)
        return NULL;

    char *uuid = (char *)malloc(37);
    if (!uuid) {
        fclose(f);
        return NULL;
    }

    if (fscanf(f, "%36s", uuid) != 1) {
        free(uuid);
        fclose(f);
        return NULL;
    }

    fclose(f);
    return uuid;
}

#endif /* DRIVE_UUID_H */
