package main

import (
	"embed"
	"io/fs"
	"net/http"

	"github.com/gorilla/mux"
)

//go:embed dist/*
var views embed.FS

func handleRequests(listenPort, tlsPort string) {

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
