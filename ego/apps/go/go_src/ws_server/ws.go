package ws_server

import (
	"log"
	"net/http"
	// "os"

	"./router"
)

func Start() {

	// port := os.Getenv("PORT")
	router := router.Init()

	// if port == "" {
	// 	port = "8000"
	// }

	port := "8880"

	if err := http.ListenAndServe(":"+port, router); err != nil {
		log.Fatal(err)
	}
}
