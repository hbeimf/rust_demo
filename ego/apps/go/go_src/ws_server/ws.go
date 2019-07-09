package ws_server

import (
	"log"
	"net/http"
	// "os"

	"./router"
)

// http://127.0.0.1:8880/api/admin/hello?cookie=xx&token=xxx

func Start() {

	// port := os.Getenv("PORT")
	router := router.Init()

	// if port == "" {
	// 	port = "8000"
	// }

	port := "8880"

	if err := http.ListenAndServe(":"+port, router); err != nil {
		// log.Fatal(err)
		log.Printf("start ws_server err: %#v", err)
	}

	log.Printf("start ws_server : %#v", port)
}
