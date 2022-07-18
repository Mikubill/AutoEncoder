package main

import (
	"encoding/json"
	"io/ioutil"
	"net/http"
	"os"
	"sync"

	"gopkg.in/yaml.v3"
)

type Template struct {
	Name        string            `yaml:"name" json:"name"`
	Description string            `yaml:"description" json:"description"`
	Outputs     string            `yaml:"outputs" json:"outputs"`
	Steps       []Steps           `yaml:"steps" json:"steps"`
	Inputs      map[string]string `yaml:"inputs" json:"inputs"`
	Envs        map[string]string `yaml:"envs" json:"envs"`
}

type Steps struct {
	Name string `yaml:"name" json:"name"`
	Cmd  string `yaml:"cmd" json:"cmd"`
	Bash bool   `yaml:"bash" json:"bash"`
}

var (
	templates map[string]Template
	tLock     sync.RWMutex
)

func init() {
	// read templates from file
	yfile, err := ioutil.ReadFile(os.Getenv("TPL_FILE"))
	if err != nil {
		log.Fatal(err)
	}
	err2 := yaml.Unmarshal(yfile, &templates)
	if err2 != nil {
		log.Fatal(err2)
	}
}

func addTemplates(w http.ResponseWriter, b string) {
	tLock.Lock()
	defer tLock.Unlock()

	var t Template
	err := json.Unmarshal([]byte(b), &t)
	if err != nil {
		log.Fatal(err)
	}

	templates[t.Name] = t
	// save yaml
	yfile, err := yaml.Marshal(templates)
	if err != nil {
		log.Fatal(err)
	}
	err2 := ioutil.WriteFile("templates.yaml", yfile, 0644)
	if err2 != nil {
		log.Fatal(err2)
	}
}

func readTemplates(w http.ResponseWriter) {
	tLock.RLock()
	defer tLock.RUnlock()

	json.NewEncoder(w).Encode(templates)
}
