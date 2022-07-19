package main

import (
	"context"
	"fmt"
	"io/ioutil"
	"os"
	"path"
	"strings"
	"time"

	"github.com/go-cmd/cmd"
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

	pool.Acquire(context.Background(), 1)
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
		cmdToExec := cmd.NewCmd(c[0], c[1:]...)
		if cmdlines.Bash {
			cmdToExec = cmd.NewCmd("bash", "-c", strings.Join(c, " "))
		}
		task.cmdList = append(task.cmdList, cmdToExec)
		streamer.Write("+ Running command: "+strings.Join(c, " "), onFinal)

		cmdToExec.Env = os.Environ()
		for k, v := range task.Req.Envs {
			if !hasKey(tpl.Envs, k) {
				continue
			}
			cmdToExec.Env = append(cmdToExec.Env, k+"="+v)
		}
		cmdToExec.Dir = wksDir
		// manually set binary dir

		err := runCmdAsync(streamer, cmdToExec, task.ID)
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

func runCmdAsync(streamer *Streamer, c *cmd.Cmd, id int) error {
	log.Debugf("executing command: %v %+v", c.Name, c.Args)
	statusChan := c.Start() // non-blocking

	ticker := time.NewTicker(2 * time.Second)
	defer ticker.Stop()
	go func() {
		for range ticker.C {
			status := c.Status()
			CombinedOutput := ""
			if len(status.Stdout) > 0 {
				CombinedOutput += strings.Join(status.Stdout, "\n")
			}
			if len(status.Stderr) > 0 {
				CombinedOutput += strings.Join(status.Stderr, "\n")
			}
			streamer.Write(CombinedOutput, onLoad)
		}
	}()

	status := <-statusChan
	CombinedOutput := ""
	if len(status.Stdout) > 0 {
		CombinedOutput += strings.Join(status.Stdout, "\n")
	}
	if len(status.Stderr) > 0 {
		CombinedOutput += strings.Join(status.Stderr, "\n")
	}
	streamer.Write(CombinedOutput, onFinal)
	log.Printf("[%d] command finished with status: %+v", id, status.Exit)

	return nil
}
