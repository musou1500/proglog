package main

import (
	"context"
	"flag"
	"fmt"
	"log"

	api "github.com/musou1500/proglog/api/v1"
	"github.com/musou1500/proglog/internal/config"
	"go.uber.org/zap"
	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials"
)

type cfg struct {
	ca   *string
	cert *string
	key  *string
	addr *string
	m    *string
}

func setupLogger() error {
	logger, err := zap.NewDevelopment()
	if err != nil {
		return err
	}
	zap.ReplaceGlobals(logger)
	return nil
}

func main() {
	setupLogger()
	cfg := cfg{}
	cfg.addr = flag.String("addr", "localhost:8400", "server address")
	cfg.cert = flag.String("cert", config.RootClientCertFile, "certificate file")
	cfg.key = flag.String("key", config.RootClientKeyFile, "key file")
	cfg.ca = flag.String("ca", config.CAFile, "certificate authority file")
	cfg.m = flag.String("m", "hello world", "message to send")
	flag.Parse()

	peerTLSConfig, err := config.SetupTLSConfig(config.TLSConfig{
		CertFile: *cfg.cert,
		KeyFile:  *cfg.key,
		CAFile:   *cfg.ca,
	})

	if err != nil {
		log.Fatal(err)
	}

	tlsCreds := credentials.NewTLS(peerTLSConfig)
	opts := []grpc.DialOption{grpc.WithTransportCredentials(tlsCreds)}
	conn, err := grpc.Dial(*cfg.addr, opts...)
	if err != nil {
		log.Fatal("dial fail ", err)
	}

	client := api.NewLogClient(conn)
	res, err := client.GetServers(context.Background(), &api.GetServersRequest{})

	if err != nil {
		log.Fatal("getservers fail ", err)
	}

	fmt.Println("servers:", res.Servers)
}
