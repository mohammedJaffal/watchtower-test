#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>

typedef struct {
    int id;
} worker_arg;

static void *worker(void *data) {
    worker_arg *arg = (worker_arg *)data;
    printf("pthread worker %d created and joined\n", arg->id);
    return NULL;
}

int main(int argc, char **argv) {
    int count = 1;
    pthread_t *threads;
    worker_arg *args;

    if (argc >= 2) {
        count = atoi(argv[1]);
    }
    if (count < 1) {
        count = 1;
    }
    if (count > 64) {
        count = 64;
    }

    threads = calloc((size_t)count, sizeof(pthread_t));
    args = calloc((size_t)count, sizeof(worker_arg));
    if (threads == NULL || args == NULL) {
        fprintf(stderr, "memory allocation failed\n");
        free(threads);
        free(args);
        return 1;
    }

    for (int i = 0; i < count; i++) {
        args[i].id = i + 1;
        if (pthread_create(&threads[i], NULL, worker, &args[i]) != 0) {
            fprintf(stderr, "pthread_create failed for worker %d\n", i + 1);
            free(threads);
            free(args);
            return 2;
        }
    }

    for (int i = 0; i < count; i++) {
        pthread_join(threads[i], NULL);
    }

    free(threads);
    free(args);
    return 0;
}
