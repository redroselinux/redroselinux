#pragma once

char*** get_blkdevs();
char* ask_blkdev();
char* get_partition(const char* drive, int partnum);
