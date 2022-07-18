package main

import (
	"os"

	"github.com/sirupsen/logrus"
	"golang.org/x/sync/semaphore"
)

var log = logrus.New()

// Configured via -ldflags during build
var GitCommit string

func init() {
	log.SetFormatter(&logrus.TextFormatter{
		ForceColors:   true,
		PadLevelText:  true,
		FullTimestamp: false,
	})
}

var rcaddr = os.Getenv("RC_ADDR")

func main() {

	log.Infoln("Simple CI/CD server by CircleDevs @ JYFansub")
	if len(os.Args) > 1 {
		if os.Args[1] == "-v" || os.Args[1] == "--version" {
			log.Infoln("Commit: " + GitCommit)
			os.Exit(0)
		}
	}

	listenPort := "127.0.0.1:33000"
	if os.Getenv("LISTEN_ADDR") != "" {
		listenPort = os.Getenv("LISTEN_ADDR")
	}
	tlsPort := "127.0.0.1:33001"
	if os.Getenv("TLS_ADDR") != "" {
		tlsPort = os.Getenv("TLS_ADDR")
	}

	log.Infoln("\n")
	log.Infoln("Configured with:")
	log.Infoln("Server: " + listenPort + " (HTTP)")
	log.Infoln("Server: " + tlsPort + " (HTTPS)")
	log.Infoln("Database: " + os.Getenv("DB_FILE"))
	log.Infoln("Templates: " + os.Getenv("TPL_FILE"))
	if rcaddr != "" {
		log.Infoln("Rc server: " + rcaddr)
		// resigerRcServer(rcaddr)
	}

	log.Infoln("\n\n")

	LoadConfig()
	go AutoCleanTemp()
	pool = semaphore.NewWeighted(int64(config.PoolSize))

	// restart unfinished tasks
	go restartTasks()
	handleRequests(listenPort, tlsPort)
}
