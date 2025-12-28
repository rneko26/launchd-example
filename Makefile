CGO_ENABLED=0
export CGO_ENABLED

build:
	go build -v -o bin/service main.go && chmod +x bin/service

clean:
	rm bin/service