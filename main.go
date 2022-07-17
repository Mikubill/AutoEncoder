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
	log.Println("HTTP Server Started. Listening on port", listenPort)
	log.Fatal(http.ListenAndServe(listenPort, myRouter))
}

// Configured via -ldflags during build
var GitCommit string

func init() {
	log.SetFormatter(&logrus.TextFormatter{
		ForceColors:   true,
		PadLevelText:  true,
		FullTimestamp: false,
	})
}

func main() {

	log.Infoln("Simple CI/CD server by CircleDevs @ JYFansub")
	if len(os.Args) > 1 {
		if os.Args[1] == "-v" || os.Args[1] == "--version" {
			log.Infoln("Commit: " + GitCommit)
			os.Exit(0)
		}
	}
	log.Infoln("\n")

	log.Infoln("Configured with:")
	listenPort := "127.0.0.1:33000"
	if os.Getenv("ADDR") != "" {
		listenPort = os.Getenv("ADDR")
	}
	log.Infoln("Server: " + listenPort)
	log.Infoln("Database: " + os.Getenv("db_file"))
	log.Infoln("Templates: " + os.Getenv("template_file"))

	log.Infoln("\n\n")

	LoadConfig()
	go AutoCleanTemp()
	pool = semaphore.NewWeighted(int64(config.PoolSize))

	// restart unfinished tasks
	go restartTasks()
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
