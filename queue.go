package main

import (
	"bufio"
	"fmt"
	"io/ioutil"
	"os"
	"os/exec"
	"path"
	"strings"
	"time"

	"golang.org/x/sync/semaphore"
)

var (
	pool   *semaphore.Weighted
	config *baseConf
)

type baseConf struct {
	PoolSize int    `json:"pool_size"`
	WksPath  string `json:"wks_path"`
	UpPath   string `json:"up_path"`
}

func hasKey(m map[string]string, k string) bool {
	_, ok := m[k]
	return ok
}

func runTask(task *Task) {
	// create workspace
	wksDir := path.Join(config.WksPath, fmt.Sprintf("task-%d", task.ID))
	err := os.MkdirAll(wksDir, 0755)
	if err != nil {
		log.Errorf("Error creating directory: %v", err)
		return
	}
	task.LogFile = path.Join(wksDir, fmt.Sprintf("runlog-%s.log", randomString(6)))

	log.Printf("[%d] started", task.ID)
	task.Status = "queued"
	saveTask(task)

	pool.Acquire(task.context, 1)
	defer pool.Release(1)

	task.Status = "running"
	task.StartTime = time.Now()
	saveTask(task)

	streamer := newStreamer(task)
	defer streamer.Close()

	log.Printf("[%d] acquired semaphore", task.ID)

	tpl := templates[task.Req.Temple]
	// run cmd in list
	for _, cmdlines := range tpl.Steps {
		c := strings.Split(cmdlines.Cmd, " ")

		if task.Status == "stopped" {
			break
		}
		for k, v := range task.Req.Inputs {
			if !hasKey(tpl.Inputs, k) {
				continue
			}
			if strings.HasPrefix(tpl.Inputs[k], "file") {
				if strings.HasPrefix(v, "uploaded-file @") {
					v = strings.Replace(v, "uploaded-file @", "", 1)
					v = strings.TrimSpace(v)
					v = path.Join(config.UpPath, v)

					// scan folder and select the only one file
					files, err := ioutil.ReadDir(v)
					if err != nil {
						log.Printf("[%d] Error reading uploaded file: %s", task.ID, err)
						task.Status = "error"
						saveTask(task)
						return
					}
					v = path.Join(v, files[0].Name())
				}
				// check if file exists
				if _, err := os.Stat(v); err != nil {
					log.Printf("[%d] Error reading file: %s", task.ID, err)
					task.Status = "error"
					saveTask(task)
					return
				}
			}
			// c = strings.Replace(c, "%"+k+"%", v, -1)
			for i, vv := range c {
				if strings.Contains(vv, "%"+k+"%") {
					c[i] = strings.Replace(vv, "%"+k+"%", v, -1)
				}
			}
		}
		cmd := exec.CommandContext(task.context, c[0], c[1:]...)
		if cmdlines.Bash {
			cmd = exec.CommandContext(task.context, "bash", "-c", strings.Join(c, " "))
		}
		streamer.Write("Running command: " + cmd.String() + "\n")

		cmd.Env = os.Environ()
		for k, v := range task.Req.Envs {
			if !hasKey(tpl.Envs, k) {
				continue
			}
			cmd.Env = append(cmd.Env, k+"="+v)
		}
		cmd.Dir = wksDir
		// manually set binary dir

		err := runCmdAsync(streamer, cmd)
		if err != nil {
			log.Printf("[%d] error: %s", task.ID, err)
			task.Status = "error"
			saveTask(task)
			break
		}
	}

	if task.Status != "error" {
		task.Status = "finished"
		saveTask(task)
	}
}

func runCmdAsync(streamer *Streamer, cmd *exec.Cmd) error {
	log.Debugf("executing command: %s", cmd.String())

	// cmd.SysProcAttr = &syscall.SysProcAttr{Credential: &syscall.Credential{Uid: uint32(os.Getuid()), Gid: uint32(os.Getgid())}}
	// log.Debugf("syscall option: %+v", cmd.SysProcAttr.Credential)

	cmdReader, err := cmd.StdoutPipe()
	if err != nil {
		log.Warnf("error creating stdout pipe for cmd: %s", err)
		// return err
	} else {
		scanner := bufio.NewScanner(cmdReader)
		go func() {
			for scanner.Scan() {
				streamer.Write(scanner.Text())
			}
		}()
	}

	cmdReader2, err := cmd.StderrPipe()
	if err != nil {
		log.Warnf("error creating stdout pipe for cmd: %s", err)
		// return err
	} else {
		scanner2 := bufio.NewScanner(cmdReader2)
		go func() {
			for scanner2.Scan() {
				streamer.Write(scanner2.Text())
			}
		}()
	}

	err = cmd.Start()
	if err != nil {
		log.Warnf("error starting cmd: %s", err)
		return err
	}

	err = cmd.Wait()
	if err != nil {
		log.Warnf("error waiting for cmd: %s", err)
		return err
	}
	return nil
}
