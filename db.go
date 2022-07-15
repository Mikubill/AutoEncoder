package main

import (
	"encoding/binary"
	"encoding/json"
	"fmt"
	"os"

	bolt "go.etcd.io/bbolt"
)

var (
	db     *bolt.DB
	dbPath = os.Getenv("db_file")
)

func init() {
	var err error
	db, err = bolt.Open(dbPath, 0666, nil)
	if err != nil {
		panic(err)
	}

	db.Update(func(tx *bolt.Tx) error {
		for _, names := range []string{"tasks", "templates", "sys"} {
			_, err := tx.CreateBucketIfNotExists([]byte(names))
			if err != nil {
				return fmt.Errorf("create bucket: %s", err)
			}
		}
		return nil
	})
}

func SaveConfig() {
	data, err := json.Marshal(config)
	if err != nil {
		log.Warnf("Error marshalling config: %s", err)
		return
	}

	db.Update(func(tx *bolt.Tx) error {
		b := tx.Bucket([]byte("sys"))
		err := b.Put([]byte("config"), data)
		if err != nil {
			return fmt.Errorf("save config: %s", err)
		}
		return nil
	})
}

func LoadConfig() {
	baseConfig := &baseConf{
		PoolSize: 5,
		WksPath:  "/tmp",
		UpPath:   "/tmp",
	}

	db.View(func(tx *bolt.Tx) error {
		b := tx.Bucket([]byte("sys"))
		data := b.Get([]byte("config"))
		if data == nil {
			config = baseConfig
			return nil
		}
		err := json.Unmarshal(data, &config)
		if err != nil {
			log.Errorf("load config: %s", err)
		}
		return nil
	})
}

func saveTask(task *Task) error {
	err := db.Update(func(tx *bolt.Tx) error {
		b := tx.Bucket([]byte("tasks"))
		if task.ID == 0 {
			id, _ := b.NextSequence()
			log.Printf("New task ID: %d", id)
			task.ID = int(id)
		}
		data, err := json.Marshal(task)
		if err != nil {
			log.Warnf("Error marshalling task: %s", err)
			return err
		}

		err = b.Put(itob(task.ID), data)
		if err != nil {
			return fmt.Errorf("save task: %s", err)
		}
		return nil
	})
	if err != nil {
		return err
	}
	return nil
}

func getAllTasks() ([]*Task, error) {
	var tasks []*Task
	err := db.View(func(tx *bolt.Tx) error {
		b := tx.Bucket([]byte("tasks"))
		c := b.Cursor()
		for k, v := c.First(); k != nil; k, v = c.Next() {
			var task Task
			err := json.Unmarshal(v, &task)
			if err != nil {
				return fmt.Errorf("get all tasks: %s", err)
			}
			tasks = append(tasks, &task)
		}
		return nil
	})
	if err != nil {
		return nil, err
	}
	return reverseList(tasks), nil
}

func reverseList(list []*Task) []*Task {
	for i, j := 0, len(list)-1; i < j; i, j = i+1, j-1 {
		list[i], list[j] = list[j], list[i]
	}
	return list
}

func getTask(id int) (*Task, error) {
	var task Task
	err := db.View(func(tx *bolt.Tx) error {
		b := tx.Bucket([]byte("tasks"))
		data := b.Get(itob(id))
		if data == nil {
			return fmt.Errorf("task not found")
		}
		err := json.Unmarshal(data, &task)
		if err != nil {
			return fmt.Errorf("load task: %s", err)
		}
		return nil
	})
	if err != nil {
		return nil, err
	}
	return &task, nil
}

// itob returns an 8-byte big endian representation of v.
func itob(v int) []byte {
	b := make([]byte, 8)
	binary.BigEndian.PutUint64(b, uint64(v))
	return b
}
