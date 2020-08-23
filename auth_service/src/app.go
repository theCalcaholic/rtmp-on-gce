package main

import (
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
	"path/filepath"
	"strings"
)

var configPath string
var config = map[string]string{}

func authHandler(w http.ResponseWriter, r *http.Request) {

	pw, err := getConfig(r.URL.Path)
	if err != nil || pw == "" {
		//http.Error(w, "no authentication config found for "+r.URL.Path+"!", http.StatusForbidden)
		fmt.Println("No authentication config found for " + r.URL.Path)
		fmt.Println("Authorization successful for " + r.URL.Path)
		fmt.Fprintf(w, "Authorization successful for "+r.URL.Path)
		return
	}
	pw = strings.Replace(pw, "\n", "", -1)

	r.ParseForm()
	providedPw := r.FormValue("pw")

	if pw == providedPw {
		fmt.Println("Authorization successful for " + r.URL.Path)
		fmt.Fprintf(w, "Authorization successful for "+r.URL.Path)
		return
	}
	fmt.Println("Authorization failed for "+r.URL.Path, http.StatusForbidden)
	http.Error(w, "Authorization failed for "+r.URL.Path, http.StatusForbidden)
}

func getConfig(key string) (string, error) {
	if entry, ok := config[key]; ok {
		return entry, nil
	}
	val, err := loadConfig(key)
	if err == nil {
		config[key] = val
	}
	return val, nil
}

func loadConfig(key string) (string, error) {
	filename := filepath.Join("/etc/auth_config/", filepath.Clean(key), "password")
	fmt.Println("Loading config from " + filename)
	body, err := ioutil.ReadFile(filename)
	if err != nil {
		return "", err
	}
	return string(body), nil
}

func main() {
	fmt.Println("Starting authentication server.")
	http.HandleFunc("/publish", authHandler)
	http.HandleFunc("/play", authHandler)
	log.Fatal(http.ListenAndServe(":80", nil))

	fmt.Println("Shutdown...")
}
