package main

import (
	"fmt"
	"os"
	"os/exec"
	"syscall"
)

func main() {
	var (
		err error;
		pArgs []string;
		pCmd string;
		p *os.Process;
	)
	if len(os.Args) < 2 {
		fmt.Printf("%v: command [args...]\n", os.Args[0])
		os.Exit(1)
	}
	pArgs = make([]string, len(os.Args[1:]))
	copy(pArgs, os.Args[1:])
	pCmd, err = exec.LookPath(pArgs[0])
	if err != nil {
		fmt.Printf("%v\n", err)
		os.Exit(1)
	}
	p, err = os.StartProcess(pCmd, pArgs, &os.ProcAttr{
		Env: os.Environ(),
		Files: []*os.File{},
		Sys: &syscall.SysProcAttr{
			Setsid: true,
		},
	})
	if err != nil {
		fmt.Printf("%v\n", err)
		os.Exit(1)
	}
	fmt.Printf("%v\n", p.Pid)
	p.Release()
}
