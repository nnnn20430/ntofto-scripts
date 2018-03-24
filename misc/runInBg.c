#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <errno.h>

extern char **environ;
char *progname;
char *pidfile = "/dev/stdout";

int daemonize(void) {
	int pid, fd, i, n = sysconf(_SC_OPEN_MAX);
	char buf[16];
	if ((pid = fork()) < 0) {
		return -1;
	} else if (pid != 0) {
		fd = open(pidfile, (O_WRONLY | O_CREAT | O_TRUNC),
		     (S_IRUSR |
		      S_IWUSR |
		      S_IRGRP |
		      S_IWGRP |
		      S_IROTH |
		      S_IWOTH)
		);
		if (fd == -1) {
			perror(progname);
			return -1;
		}
		i = sprintf(buf, "%i\n", pid);
		write(fd, buf, i);
		close(fd);
		return 0;
	}
	for (i = 0; i < n; i++)
		close(i);
	setsid();
	chdir("/");
	umask(0);
	return 1;
}

int main(int argc, char *argv[]) {
	int ret;
	progname = argv[0];
	if (argc < 2) {
		printf("%s: path [args...]\n", progname);
		return 1;
	} else {
		if (access(argv[1], X_OK)) {
			perror(progname);
			return errno;
		}
		if ((ret = daemonize()) == 0) {
			return 0;
		} else if (ret == -1) {
			return 1;
		}
		execve(argv[1], &argv[1], environ);
		perror(progname);
		return errno;
	}
}
