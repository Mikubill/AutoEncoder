package main

import (
	"bytes"
	"fmt"
	"io/ioutil"
	"time"
)

type Streamer struct {
	buf        *bytes.Buffer
	lastUpdate time.Time
	task       *Task
}

func newStreamer(task *Task) *Streamer {
	return &Streamer{
		buf:        new(bytes.Buffer),
		lastUpdate: time.Time{},
		task:       task,
	}
}

func (s *Streamer) Write(p string) {
	txt := fmt.Sprintf("[%d] %s\n", s.task.ID, p)

	s.buf.Write([]byte(txt))
	log.Print(txt)

	// check buf size
	if time.Now().After(s.lastUpdate.Add(time.Second * 5)) {
		s.lastUpdate = time.Now()
		ioutil.WriteFile(s.task.LogFile, s.buf.Bytes(), 0644)
	}
}

func (s *Streamer) Close() {
	err := ioutil.WriteFile(s.task.LogFile, s.buf.Bytes(), 0644)
	if err != nil {
		log.Printf("[%d] error: %s", s.task.ID, err)
	}
	s.buf.Reset()
}
