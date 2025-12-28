package main

import (
	"encoding/json"
	"log"
	"net/http"
	"os"
	"os/signal"
	"syscall"
)

type Status string
type Addr string

const (
	Status_OK       Status = "OK"
	Status_NotFound Status = "NotFound"
)

const LISTENER Addr = ":6000"

func (s Status) String() string {
	return string(s)
}

func (a Addr) String() string {
	return string(a)
}

type BaseResponse struct {
	Code    Status
	Message string
}

func HealthCheck(w http.ResponseWriter, r *http.Request) {
	json.NewEncoder(w).Encode(&BaseResponse{
		Message: "API is running!",
		Code:    Status_OK,
	})
}

func main() {

	mux := http.NewServeMux()
	mux.HandleFunc("/", HealthCheck)

	lis := &http.Server{
		Addr:    LISTENER.String(),
		Handler: mux,
	}

	log.Printf("Services is running on %s \n", LISTENER)

	go lis.ListenAndServe()

	sigs := make(chan os.Signal, 1)
	signal.Notify(sigs, syscall.SIGINT, syscall.SIGTERM)

	<-sigs
	log.Printf("Closing services...")
	lis.Close()

}
