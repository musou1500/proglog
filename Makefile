CONFIG_PATH=$(shell pwd)/config
TAG ?= 0.0.1


$(CONFIG_PATH)/model.conf:
	cp test/model.conf $(CONFIG_PATH)/model.conf

$(CONFIG_PATH)/policy.csv:
	cp test/policy.csv $(CONFIG_PATH)/policy.csv

.PHONY: test compile gencert build-docker

build:
	CGO_ENABLED=0 go build -o ./deploy/proglog ./cmd/proglog

compile:
	protoc --go_out=. \
		--go_opt=paths=source_relative \
		--go-grpc_out=. \
		--go-grpc_opt=paths=source_relative \
		api/v1/*.proto

test: $(CONFIG_PATH)/model.conf $(CONFIG_PATH)/policy.csv
	CONFIG_DIR=${CONFIG_PATH} go test -race ./...

gencert:
	cfssl gencert \
		-initca tests/ca-csr.json | cfssljson -bare ca
	cfssl gencert \
		-ca=ca.pem \
		-ca-key=ca-key.pem \
		-config=tests/ca-config.json \
		-profile=server \
		tests/server-csr.json | cfssljson -bare server
	cfssl gencert \
		-ca=ca.pem \
		-ca-key=ca-key.pem \
		-config=tests/ca-config.json \
		-profile=client \
		-cn="root" \
		tests/client-csr.json | cfssljson -bare root-client
	cfssl gencert \
		-ca=ca.pem \
		-ca-key=ca-key.pem \
		-config=tests/ca-config.json \
		-profile=client \
		-cn="nobody" \
		tests/client-csr.json | cfssljson -bare nobody-client
	mv *.pem *.csr ${CONFIG_PATH}

