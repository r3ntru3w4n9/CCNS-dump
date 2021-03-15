package main

import (
	"bufio"
	"io"
	"log"
	"net"
	"strings"
	"sync"
	"time"
)

func main() {
	panicIfNotNull := func(err error) {
		if err != nil {
			panic(err)
		}
	}
	listener, err := net.Listen("tcp", "localhost:9999")
	log.Println("listening", listener)
	panicIfNotNull(err)

	servers := make([]bufio.ReadWriter, 0)
	clients := make([]bufio.ReadWriter, 0)

	for {
		conn, err := listener.Accept()
		log.Println("accepted", conn)
		panicIfNotNull(err)
		defer conn.Close()

		var mutex sync.Mutex

		go func(c net.Conn) {
			time.Sleep(1 * time.Second)

			r := bufio.NewReader(c)
			w := bufio.NewWriter(c)
			rw := *bufio.NewReadWriter(r, w)

			mutex.Lock()
			clients = append(clients, rw)
			log.Println("appended", rw, "to", clients)
			mutex.Unlock()

			isServer := false

			for {
				var s string
				switch byt, _, err := rw.ReadLine(); err {
				case io.EOF:
				case nil:
					s = strings.Trim(string(byt), " \n")
				default:
					panicIfNotNull(err)
				}

				log.Println("received", s)
				log.Println("is server", isServer)
				if s == "" {
					break
				}

				if s == "SERV" {
					isServer = true
					mutex.Lock()
					for i := 0; i < len(clients); i++ {
						if clients[i] == rw {
							clients[i], clients[len(clients)-1] = clients[len(clients)-1], clients[i]
							clients = clients[:len(clients)-1]
							servers = append(servers, rw)
							log.Println("clients", clients)
							log.Println("servers", servers)
							break
						}
					}
					mutex.Unlock()
					continue
				}

				if isServer {
					for i := 0; i < len(clients); i++ {
						log.Println("write to client", i, clients[i])
						clients[i].WriteString(s + "\n")
						clients[i].Flush()
					}
				} else {
					for i := 0; i < len(servers); i++ {
						log.Println("write to server", i, servers[i])
						servers[i].WriteString(s + "\n")
						servers[i].Flush()
					}

				}

			}
		}(conn)
	}
}
