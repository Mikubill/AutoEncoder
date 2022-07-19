package main

import (
	"bytes"
	"fmt"
	"io/ioutil"
	"strings"
	"sync"
	"time"
)

const (
	onLoad = iota
	onFinal
)

type Streamer struct {
	buf        *bytes.Buffer
	lastUpdate time.Time
	task       *Task
	lock       sync.Mutex
}

func newStreamer(task *Task) *Streamer {
	return &Streamer{
		buf:        new(bytes.Buffer),
		lastUpdate: time.Time{},
		task:       task,
	}
}

func (s *Streamer) Write(p string, attr int) {
	// convert cr to lf
	p = strings.Replace(p, "\r", "\n", -1)
	// convert lf to crlf
	p = strings.Replace(p, "\n", "\r\n", -1)
	txt := fmt.Sprintf("%s\n", p)

	outputs := append(s.buf.Bytes(), []byte(txt)...)

	if attr == onFinal {
		s.buf.Reset()
		s.buf.Write(outputs)
		log.Print(fmt.Sprintf("[%d] %s", s.task.ID, txt))
	}

	ioutil.WriteFile(s.task.LogFile, outputs, 0644)
}

func (s *Streamer) Close() {
	err := ioutil.WriteFile(s.task.LogFile, s.buf.Bytes(), 0644)
	if err != nil {
		log.Printf("[%d] error: %s", s.task.ID, err)
	}
	s.buf.Reset()
}
