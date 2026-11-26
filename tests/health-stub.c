/* Minimal healthcheck stub used only by CI.
 *
 * The published images expose real HEALTHCHECK instructions: a TCP probe for
 * authserver (3724) and worldserver (8085), and a process probe for the
 * one-shot db-import target. In CI there is no game database, so the real
 * services cannot reach their listen state. This stub satisfies exactly the
 * condition each Dockerfile HEALTHCHECK tests, letting CI verify that Docker
 * actually reports status=healthy for every target, on every architecture.
 *
 * Real service binaries, non-root UID/GID, tini PID 1 and library resolution
 * are covered separately by tests/smoke.sh.
 */
#include <arpa/inet.h>
#include <netinet/in.h>
#include <string.h>
#include <stdlib.h>
#include <sys/socket.h>
#include <unistd.h>

int main(int argc, char **argv) {
    if (argc < 2) {
        /* Idle mode: stay alive so pgrep -x <binary> succeeds (db-import). */
        for (;;) {
            sleep(3600);
        }
    }

    int port = atoi(argv[1]);
    int fd = socket(AF_INET, SOCK_STREAM, 0);
    if (fd < 0) {
        return 1;
    }
    int reuse = 1;
    setsockopt(fd, SOL_SOCKET, SO_REUSEADDR, &reuse, sizeof(reuse));

    struct sockaddr_in addr;
    memset(&addr, 0, sizeof(addr));
    addr.sin_family = AF_INET;
    addr.sin_addr.s_addr = htonl(INADDR_LOOPBACK);
    addr.sin_port = htons((unsigned short)port);
    if (bind(fd, (struct sockaddr *)&addr, sizeof(addr)) != 0) {
        return 1;
    }
    if (listen(fd, 8) != 0) {
        return 1;
    }
    for (;;) {
        int conn = accept(fd, NULL, NULL);
        if (conn >= 0) {
            close(conn);
        }
    }
}
