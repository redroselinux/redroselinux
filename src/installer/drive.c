#include <dirent.h>
#include <stdio.h>
#include <string.h>
#include "mem.h"
#include "log.h"
#include "ui.h"

/* Get all block devices such from /sys/class/block.
 * User must free the result by themselves (and everything inside it).
 * Notes: returns a pointer to an array of strings, ends with NULL. */
char **get_blkdevs(void) {
  int size = 10;
  int iter = 0;

  char **result = alloc_size_arr(char *, size);

  DIR *d = opendir("/sys/class/block");
  if (!d)
    return NULL;

  struct dirent *e;
  while ((e = readdir(d)) != NULL) {
    if (e->d_name[0] == '.')
      continue;

    if (iter >= size - 1) {
      size += 10;
      result = resize_size_arr(result, char *, size);
    }

    result[iter++] = strdup(e->d_name);
  }

  closedir(d);

  result[iter] = NULL;
  return result;
}

/* Ask the user to pick a block device.
 * User must free the result by themselves. */
char* ask_blkdev() {
  char** blkdevs = get_blkdevs();

  info("Available installation drives:");
  char **p = blkdevs;
  while (*p) {
    // skip loop devs
    if (
      strlen(*p) >= 4 &&
      (*p)[0] == 'l' && (*p)[1] == 'o' && (*p)[2] == 'o' && (*p)[3]
    ) {
      p++;
      continue;
    }

    printf("    %s\n", *p);
    p++;
  }

  char* result;
  int found = 0;
  do {
    result = ask("Select a drive (will ask you again if you type it wrong)");
    p = blkdevs;
    while (*p) {
      if (!strcmp(*p, result)) {
        found = 1;
      }
      p++;
    }
  } while (!found);

  free_arr(blkdevs);
  return result;
}

/* Get the partition device file from the drive.
 * Takes the drive and partition number, returns the partition device file. */
char* get_partition(const char* drive, int partnum) {
    static __thread char buf[64];
    if (strncmp(drive, "/dev/nvme", 9) == 0 || strncmp(drive, "/dev/mmcblk", 11) == 0) {
        snprintf(buf, sizeof(buf), "%sp%d", drive, partnum);
    } else {
        snprintf(buf, sizeof(buf), "%s%d", drive, partnum);
    }
    return buf;
}
