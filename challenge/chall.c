#include <stdio.h>
#include <unistd.h>
#include <resolv.h> // Provides b64_pton

#define BUF_SIZE 0x1C0
#define B64_SIZE 601

void setup() {
    setvbuf(stdin, NULL, _IONBF, 0);
    setvbuf(stdout, NULL, _IONBF, 0);
    setvbuf(stderr, NULL, _IONBF, 0);
}

int main(int argc, char const *argv[]) {
    setup();
    FILE* _stderr = stderr;

    puts("This message leads straight to the end, can you blossom anew from it?");
    printf("Your response: ");

    char b64_buf[B64_SIZE] = {0};
    read(STDIN_FILENO, b64_buf, sizeof(b64_buf) - 1);

    // Native GLIBC / POSIX Base64 decode directly into stderr.
    // 0x1C0 decoded bytes are now controllable.
    b64_pton(b64_buf, (unsigned char *)_stderr, BUF_SIZE);

    return 0;
}