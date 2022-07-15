package main

import (
	"io"
	"mime/multipart"
	"net/http"
	"os"
	"path"
)

func extractFile(reader *multipart.Reader) (*multipart.Part, string) {
	for {
		part, err := reader.NextPart()
		if err == io.EOF {
			break
		}

		//if part.FileName() is empty, skip this iteration.
		if part.FileName() == "" {
			continue
		}
		filename := part.FileName()
		return part, filename
	}
	return nil, ""
}

// upload file
func uploadHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Access-Control-Allow-Origin", "*")
	if r.Method != "POST" {
		return
	}

	// Maximum upload of 10 MB files
	reader, err := r.MultipartReader()
	if err != nil {
		log.Printf("Error reading multipart: %v", err)
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	file, name := extractFile(reader)
	log.Println(file, name)

	// create destination file
	fid := randomString(12)
	pvl := path.Join(config.UpPath, fid)
	err = os.MkdirAll(pvl, 0755)
	if err != nil {
		log.Errorf("Error creating directory: %v", err)
		return
	}
	filename := path.Join(pvl, name)

	log.Printf("Uploading %s to %s", name, filename)
	f, err := os.OpenFile(filename, os.O_WRONLY|os.O_CREATE, 0666)
	if err != nil {
		log.Errorf("Error creating file: %v", err)
		return
	}
	defer f.Close()

	//copy each part to destination.

	io.Copy(f, file)
	w.Write([]byte(fid))
}
