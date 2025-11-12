#ifndef RESULTS_WRITER_H
#define RESULTS_WRITER_H

#include <stdio.h>
#include <stdlib.h> 
#include <string.h>

#include <unistd.h>

#define RESULTS_DIR "results/"
#define DEFAULT_RESULTS_FILE "default_results_c.txt"

/**
 * Opens a file. Creates it if not existing.
 * Returns a FILE* on success.
 */ 
static inline FILE* open_results_file(void) {

    const char *env_filename = getenv("RESULTS_FILE");
    char filename_buf[256];

    // iff env variable exists:
    if (env_filename && *env_filename) {
        snprintf(filename_buf, sizeof(filename_buf), "%s_c", env_filename);
    } else {
        snprintf(filename_buf, sizeof(filename_buf), "%s", DEFAULT_RESULTS_FILE);
    }

    const char *filename = filename_buf;

    char path[512];
    snprintf(path, sizeof(path), RESULTS_DIR "%s", filename);

    FILE *f = fopen(path, "a");
    if (!f) {
        perror("Error opening results file");
        printf("Path: %s\n",path);
    }
    return f;
}

static inline const char* get_file_name(const char *path) {
    const char *slash = strrchr(path, '/');
    const char *file_name = slash ? slash + 1 : path;

    static char name[256];
    snprintf(name, sizeof(name), "%s", file_name);

    // find pointer to last dot
    char *dot = strrchr(name, '.');
    // strip last dot and extension if it has one
    if (dot) *dot = '\0';

    return name;
}
/**
 * Appends a line to file with name: value
 */ 
static inline void write_result(const char *file_path, double value) {

    FILE *f = open_results_file();
    if (!f) return;

    fprintf(f, "%s;%f\n", get_file_name(file_path), value);
    fclose(f);
}

#endif // RESULTS_WRITER_H