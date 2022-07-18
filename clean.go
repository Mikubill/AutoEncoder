package main

import (
	"os"
	"path/filepath"
	"time"
)

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
