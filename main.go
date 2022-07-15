package main

import (
	"embed"
	"io/fs"
	"net/http"
	"os"
	"path/filepath"
	"time"

	"github.com/gorilla/mux"
	"github.com/sirupsen/logrus"
	"golang.org/x/sync/semaphore"
)

//go:embed dist/*
var views embed.FS

var log = logrus.New()

func handleRequests(listenPort string) {

	// creates a new instance of a mux router
	myRouter := mux.NewRouter().StrictSlash(true)
	// replace http.HandleFunc with myRouter.HandleFunc
	myRouter.HandleFunc("/api", apiResponse)
	myRouter.HandleFunc("/upload", uploadHandler)
	myRouter.HandleFunc("/db", dbHandler)
	myRouter.HandleFunc("/log/{id}", getLog)
	myRouter.HandleFunc("/file/{id}", getFile)

	fSys, err := fs.Sub(views, "dist")
	if err != nil {
		panic(err)
	}

	myRouter.NotFoundHandler = http.FileServer(http.FS(fSys))
	// finally, instead of passing in nil, we want
	// to pass in our newly created router as the second
	// argument
	log.Fatal(http.ListenAndServe(listenPort, myRouter))
}

func main() {
	log.Infoln("Simple CI/CD server by CircleDevs @ JYFansub")
	listenPort := "127.0.0.1:33000"
	if len(os.Args) > 1 {
		listenPort = os.Args[1]
	}

	LoadConfig()
	go AutoCleanTemp()
	pool = semaphore.NewWeighted(int64(config.PoolSize))

	// restart unfinished tasks
	go restartTasks()
	log.Println("HTTP Server Started. Listening on port", listenPort)
	handleRequests(listenPort)
}

func AutoCleanTemp() {
	for {
		cleanTemp()
		time.Sleep(time.Hour)
	}
}

func cleanTemp() {
	log.Println("Cleaning temp directory")
	filepath.Walk(config.UpPath, func(path string, info os.FileInfo, err error) error {
		if err != nil {
			log.Errorln(err)
			return err
		}
		if info.IsDir() {
			return nil
		}
		if time.Since(info.ModTime()) > 12*time.Hour {
			log.Println("Deleting file:", path)
			err = os.Remove(path)
			if err != nil {
				log.Errorln(err)
			}
		}
		return nil
	})
	log.Println("Temp directory cleaned")
}
