package main

import (
	"encoding/json"
	"fmt"
	"net/http"
	"path"
	"strconv"
	"strings"
)

type APIRequest struct {
	Method string `json:"method"`
	Num    int    `json:"num"`
	Data   string `json:"data"`
}

func apiResponse(w http.ResponseWriter, r *http.Request) {

	w.Header().Set("Access-Control-Allow-Origin", "*")
	w.Header().Set("Access-Control-Allow-Headers", "Accept, Content-Type, Content-Length, Accept-Encoding, X-CSRF-Token, Authorization")
	if r.Method != "POST" && r.Method != "GET" {
		return
	}

	// read request body
	var request APIRequest
	if err := json.NewDecoder(r.Body).Decode(&request); err != nil {
		w.WriteHeader(http.StatusBadRequest)
		return
	}
	// log.Printf("API request: /api/%s", request.Method)
	// do something with request
	switch request.Method {
	case "SystemInfo":
		getSystemInfo(w)

	case "SystemConfig":
		getSystemConfig(w)

	case "SaveConf":
		SaveConf(w, request.Data)

	case "ReadTemplates":
		readTemplates(w)

	case "AddTemplates":
		addTemplates(w, request.Data)

	case "TaskList":
		getTasksList(w, request.Num)

	case "Task":
		getTaskDetails(w, request.Num)

	case "NewTask":
		newTask(w, request.Data)

	case "EditTask":
		editTask(w, request.Data)

	case "StartTask":
		startTask(w, request.Num)

	case "DeleteTask":
		deleteTask(w, request.Num)

	case "StopTask":
		stopTask(w, request.Num)

	default:
		// return error
		return
	}
}

func getFile(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Access-Control-Allow-Origin", "*")
	w.Header().Set("Access-Control-Allow-Headers", "Accept, Content-Type, Content-Length, Accept-Encoding, X-CSRF-Token, Authorization")

	taskid := strings.TrimPrefix(r.URL.Path, "/file/")
	if taskid != "" {
		//convert to int
		idx, err := strconv.Atoi(taskid)
		if err != nil {
			w.WriteHeader(http.StatusBadRequest)
			return
		}
		// fetch log
		task, ok := activeTasks[idx]
		if !ok {
			var err error
			task, err = getTask(idx)
			if err != nil {
				w.WriteHeader(http.StatusNotFound)
				return
			}
		}

		rootpath := path.Join(config.WksPath, fmt.Sprintf("task-%d", task.ID))

		log.Printf("File request: %s -> %s", r.URL.Path, rootpath)
		fs := fileHandler{rootpath}
		fs.ServeHTTP(w, r)
	}
}

func getLog(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Access-Control-Allow-Origin", "*")
	w.Header().Set("Access-Control-Allow-Headers", "Accept, Content-Type, Content-Length, Accept-Encoding, X-CSRF-Token, Authorization")

	taskid := strings.TrimPrefix(r.URL.Path, "/log/")
	if taskid != "" {
		//convert to int
		idx, err := strconv.Atoi(taskid)
		if err != nil {
			w.WriteHeader(http.StatusBadRequest)
			return
		}
		// fetch log
		task, ok := activeTasks[idx]
		if !ok {
			var err error
			task, err = getTask(idx)
			if err != nil {
				w.WriteHeader(http.StatusNotFound)
				return
			}
		}
		http.ServeFile(w, r, task.LogFile)
	}
}

func SaveConf(w http.ResponseWriter, data string) {
	w.Header().Set("Access-Control-Allow-Origin", "*")
	w.Header().Set("Access-Control-Allow-Headers", "Accept, Content-Type, Content-Length, Accept-Encoding, X-CSRF-Token, Authorization")
	log.Printf("Config set: %s", data)
	var conf baseConf
	if err := json.Unmarshal([]byte(data), &conf); err != nil {
		w.WriteHeader(http.StatusBadRequest)
		return
	}
	config = &conf
	SaveConfig()
	w.WriteHeader(http.StatusOK)
}
