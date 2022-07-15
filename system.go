package main

import (
	"encoding/json"
	"net/http"
)

func getSystemConfig(w http.ResponseWriter) {
	json.NewEncoder(w).Encode(config)
}
