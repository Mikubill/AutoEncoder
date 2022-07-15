package main

import (
	"fmt"
	"html/template"
	"math"
	"net/http"
	"net/url"
	"os"
	"path/filepath"
	"sort"
	"strings"
)

var (
	osPathSeparator              = string(filepath.Separator)
	directoryListingTemplateText = `
<html>
<head>
	<title>{{ .Title }}</title>
	<meta name="viewport" content="width=device-width, initial-scale=1">
	<style>body{font-family: sans-serif;}td{padding:.5em;}a{display:block;}tbody tr:nth-child(odd){background:#eee;}.number{text-align:right}.text{text-align:left;word-break:break-all;}canvas,table{width:100%;max-width:100%;}</style>
</head>
<body>
<h1>{{ .Title }}</h1>
{{ if .Files }}
<table>
	<thead>
		<tr>
			<th>Name</th>
			<th>Size</th>
			<th>Modified</th>
		</tr>
	</thead>
	<tbody>
	{{ range .Files }}
		<tr>
			<td><a href="{{ .URL }}">{{ .Name }}</a></td>
			<td class="number">{{ .Size }}</td>
			<td class="text">{{ .Modified }}</td>
		</tr>
	{{ end }}
	</tbody>
</table>
{{ else }}
<p>No files found.</p>
{{ end }}
</body>
</html>
`
	directoryListingTemplate = template.Must(template.New("directoryListing").Parse(directoryListingTemplateText))
)

type directoryListingData struct {
	Title string
	Files []directoryListingFileData
}

type directoryListingFileData struct {
	Name     string
	IsDir    bool
	Size     string
	URL      *url.URL
	Modified string
}

func (f *fileHandler) serveDirectoryListing(w http.ResponseWriter, r *http.Request, osPath string) error {
	d, err := os.Open(osPath)
	if err != nil {
		return err
	}
	files, err := d.Readdir(-1)
	if err != nil {
		return err
	}
	sort.Slice(files, func(i, j int) bool { return files[i].Name() < files[j].Name() })
	w.Header().Set("Content-Type", "text/html; charset=utf-8")
	return directoryListingTemplate.Execute(w, directoryListingData{

		Title: func() string {
			relPath, _ := filepath.Rel(f.Directory, osPath)
			return filepath.Join(filepath.Base(f.Directory), relPath)

		}(),
		Files: func() (out []directoryListingFileData) {
			for _, d := range files {
				if d.IsDir() {
					continue
				}
				currentPath := r.URL.Query().Get("path")
				out = append(out, directoryListingFileData{
					Name:     d.Name(),
					IsDir:    d.IsDir(),
					Size:     InttoString(d.Size()),
					URL:      &url.URL{Path: r.URL.Path, RawQuery: url.Values{"path": {currentPath + osPathSeparator + d.Name()}}.Encode()},
					Modified: d.ModTime().Format("2006-01-02 15:04:05"),
				})
			}
			return out
		}(),
	})
}

func InttoString(f int64) string {
	const (
		KB = 1024
		MB = 1024 * KB
		GB = 1024 * MB
	)
	divBy := func(x int64) int {
		return int(math.Round(float64(f) / float64(x)))
	}
	switch {
	case f < KB:
		return fmt.Sprintf("%d", f)
	case f < MB:
		return fmt.Sprintf("%dK", divBy(KB))
	case f < GB:
		return fmt.Sprintf("%dM", divBy(MB))
	case f >= GB:
		fallthrough
	default:
		return fmt.Sprintf("%dG", divBy(GB))
	}
}

type fileHandler struct {
	Directory string
}

func (f *fileHandler) serveStatus(w http.ResponseWriter, r *http.Request, status int) error {
	w.WriteHeader(status)
	_, err := w.Write([]byte(http.StatusText(status)))
	if err != nil {
		return err
	}
	return nil
}

// ServeHTTP is http.Handler.ServeHTTP
func (f *fileHandler) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	urlPath := r.URL.Query().Get("path")
	if !strings.HasPrefix(urlPath, "/") {
		urlPath = "/" + urlPath
	}

	osPath := strings.ReplaceAll(urlPath, "/", osPathSeparator)
	osPath = filepath.Clean(osPath)
	osPath = filepath.Join(f.Directory, osPath)

	log.Printf("%s %s %s", r.RemoteAddr, r.Method, osPath)
	info, err := os.Stat(osPath)
	switch {
	case os.IsNotExist(err):
		_ = f.serveStatus(w, r, http.StatusNotFound)
	case os.IsPermission(err):
		_ = f.serveStatus(w, r, http.StatusForbidden)
	case err != nil:
		_ = f.serveStatus(w, r, http.StatusInternalServerError)
	case info.IsDir():
		err := f.serveDirectoryListing(w, r, osPath)
		if err != nil {
			_ = f.serveStatus(w, r, http.StatusInternalServerError)
		}
	default:
		http.ServeFile(w, r, osPath)
	}
}
