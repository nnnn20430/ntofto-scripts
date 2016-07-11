#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

extern char** environ;

int daemon_int(void)
{
	int pid;
	if ((pid = fork()) < 0) {
		return (-1);
	} else if (pid != 0) {
		printf("%i\n", pid);
		return(0);
	}
	setsid();   /* become session leader */
	chdir("/"); /* change the working dir */
	umask(0);   /* clear out the file mode creation mask */
	return(1);
}

int main(int argc, char *argv[]) {
	if (daemon_int() < 1) {
		return(0);	
	}
	if (argc == 2) {
		char *nullarray[0];
		execve(argv[1], nullarray, environ);
	}
}
