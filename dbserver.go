package main

import (
	"net/http"
	"strconv"

	bolt "go.etcd.io/bbolt"
)

func dbHandler(w http.ResponseWriter, req *http.Request) {
	switch req.URL.Path {
	case "/db/backup":
		backupHandler(w, req)
	default:
		w.WriteHeader(http.StatusNotFound)
	}
}

func backupHandler(w http.ResponseWriter, req *http.Request) {
	err := db.View(func(tx *bolt.Tx) error {
		w.Header().Set("Content-Type", "application/octet-stream")
		w.Header().Set("Content-Disposition", `attachment; filename="my.db"`)
		w.Header().Set("Content-Length", strconv.Itoa(int(tx.Size())))
		_, err := tx.WriteTo(w)
		return err
	})
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
	}
}
