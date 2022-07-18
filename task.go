package main

import (
	"encoding/json"
	"fmt"
	"math/rand"
	"net/http"
	"os"
	"os/exec"
	"path"
	"strings"
	"sync"
	"syscall"
	"time"
)

type TaskReq struct {
	ID     int               `json:"id"`
	Name   string            `json:"name"`
	Temple string            `json:"template"`
	Inputs map[string]string `json:"inputs"`
	Envs   map[string]string `json:"envs"`
	Notes  string            `json:"notes"`
}

type TaskSummary struct {
	Name        string `json:"name"`
	ID          int    `json:"id"`
	Status      string `json:"status"`
	StatusWord  string `json:"status_word"`
	Description string `json:"description"`
}

type Task struct {
	Name      string    `json:"name"`
	ID        int       `json:"id"`
	Status    string    `json:"status"`
	LogFile   string    `json:"logfile"`
	Req       TaskReq   `json:"config"`
	StartTime time.Time `json:"starttime"`

	cancelFunc []CancelFunc
	runLock    sync.Mutex
}

var activeTasks = make(map[int]*Task)

type CancelFunc func()

func newCancelFunction(cmd *exec.Cmd) CancelFunc {
	cmd.SysProcAttr = &syscall.SysProcAttr{
		Setpgid:   true,
		Pdeathsig: syscall.SIGKILL,
	}
	return func() {
		pgid, err := syscall.Getpgid(cmd.Process.Pid)
		if err == nil {
			syscall.Kill(-pgid, 15) // note the minus sign
		}
		cmd.Process.Signal(os.Interrupt)
		time.Sleep(1 * time.Second)
		cmd.Process.Kill()
	}
}

func getTasksList(w http.ResponseWriter, page int) {
	// fetch data from db
	tasks, err := getAllTasks()
	if err != nil {
		log.Printf("Error getting tasks list: %s", err)
		w.WriteHeader(http.StatusInternalServerError)
		return
	}
	pageStart := (page - 1) * 10
	if len(tasks) > pageStart && pageStart > 0 {
		tasks = tasks[pageStart:]
	}
	if len(tasks) > 10 {
		tasks = tasks[:10]
	}

	tsm := []TaskSummary{}
	// create new json
	for _, task := range tasks {
		if task.Status == "deleted" {
			continue
		}
		tsm = append(tsm, TaskSummary{
			Name:        task.Name,
			ID:          task.ID,
			Status:      task.Status,
			Description: task.Req.Notes,
			StatusWord:  getDuration(task.StartTime),
		})
	}
	json.NewEncoder(w).Encode(tsm)
}

func getDuration(startTime time.Time) string {
	if startTime.IsZero() {
		return "-"
	}
	dur := time.Since(startTime)
	if dur.Hours() > 1 {
		return fmt.Sprintf("%dh%dm", int(dur.Hours()), int(dur.Minutes())%60)
	}
	if dur.Minutes() > 1 {
		return fmt.Sprintf("%dm%ds", int(dur.Minutes())%60, int(dur.Seconds())%60)
	}
	return fmt.Sprintf("%1.fs", dur.Seconds())
}

func getTaskDetails(w http.ResponseWriter, id int) {
	// fetch data from db
	task, ok := activeTasks[id]
	if !ok {
		var err error
		task, err = getTask(id)
		if err != nil {
			w.WriteHeader(http.StatusInternalServerError)
			return
		}
	}

	// create new json
	json.NewEncoder(w).Encode(task)
}

func randomString(n int) string {
	var letter = []rune("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ")
	// set seed
	rand.Seed(time.Now().UnixNano())
	b := make([]rune, n)
	for i := range b {
		b[i] = letter[rand.Intn(len(letter))]
	}
	return string(b)
}

func newTask(w http.ResponseWriter, req string) {
	// read request body
	var taskreq TaskReq
	err := json.Unmarshal([]byte(req), &taskreq)
	if err != nil {
		w.WriteHeader(http.StatusInternalServerError)
		return
	}
	if strings.TrimSpace(taskreq.Name) == "" {
		taskreq.Name = taskreq.Temple + "-" + randomString(6)
	}

	task := Task{
		Name:   taskreq.Name,
		Status: "created",
		Req:    taskreq,
	}

	err = saveTask(&task)
	if err != nil {
		w.WriteHeader(http.StatusInternalServerError)
		return
	}

	log.Printf("Creating task %s with req %+v", task.Name, taskreq)
	activeTasks[task.ID] = &task
}

func deleteTask(w http.ResponseWriter, id int) {
	// fetch data from db
	task, ok := activeTasks[id]
	if !ok {
		var err error
		task, err = getTask(id)
		if err != nil {
			w.WriteHeader(http.StatusInternalServerError)
			return
		}
	}
	task.runLock.Lock()
	defer task.runLock.Unlock()

	if task.Status == "deleted" {
		return
	}
	if task.cancelFunc != nil {
		for _, cancelFunc := range task.cancelFunc {
			cancelFunc()
		}
	}
	wksDir := path.Join(config.WksPath, fmt.Sprintf("task-%d", task.ID))
	os.RemoveAll(wksDir)
	task.Status = "deleted"
	saveTask(task)
}

func stopTask(w http.ResponseWriter, id int) {
	// fetch data from db
	task, ok := activeTasks[id]
	if !ok {
		var err error
		task, err = getTask(id)
		if err != nil {
			w.WriteHeader(http.StatusInternalServerError)
			return
		}
	}
	task.runLock.Lock()
	defer task.runLock.Unlock()
	if task.cancelFunc != nil {
		for _, cancelFunc := range task.cancelFunc {
			cancelFunc()
		}
	}
	time.Sleep(500 * time.Millisecond)
	task.Status = "stopped"
	saveTask(task)
}

func editTask(w http.ResponseWriter, req string) {
	// fetch data from db
	var taskreq TaskReq
	err := json.Unmarshal([]byte(req), &taskreq)
	if err != nil {
		log.Printf("Error parsing task req: %s", err)
		w.WriteHeader(http.StatusInternalServerError)
		return
	}

	task, ok := activeTasks[taskreq.ID]
	if !ok {
		var err error
		task, err = getTask(taskreq.ID)
		if err != nil {
			log.Printf("Error getting task %d: %s", taskreq.ID, err)
			w.WriteHeader(http.StatusInternalServerError)
			return
		}
	}
	task.runLock.Lock()
	defer task.runLock.Unlock()

	// only support not-started tasks
	if task.Status != "created" {
		// only mod notes
		task.Name = taskreq.Name
		task.Req.Name = taskreq.Name
		task.Req.Notes = taskreq.Notes
	} else {
		task.Req = taskreq
		task.Name = taskreq.Name
	}

	saveTask(task)
}

func startTask(w http.ResponseWriter, id int) {
	// fetch data from db
	task, ok := activeTasks[id]
	if !ok {
		var err error
		task, err = getTask(id)
		if err != nil {
			w.WriteHeader(http.StatusInternalServerError)
			return
		}
	}
	task.runLock.Lock()
	defer task.runLock.Unlock()

	if task.Status == "created" {
		task.Status = "running"
		saveTask(task)
		go runTask(task)
	}
}

func restartTasks() {
	tasks, err := getAllTasks()
	if err != nil {
		log.Printf("Error getting tasks list: %s", err)
		return
	}

	for _, task := range tasks {
		if task.Status == "running" || task.Status == "queued" {
			task.runLock.Lock()
			defer task.runLock.Unlock()
			go runTask(task)
		}
	}
}
