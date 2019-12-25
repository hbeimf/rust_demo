package main

import (
	"log"
	"net/http"
	"os"

	"./router"
)

func main() {

	port := os.Getenv("PORT")
	router := router.Init()

	if port == "" {
		port = "8000"
	}

	if err := http.ListenAndServe(":"+port, router); err != nil {
		log.Fatal(err)
	}
}
