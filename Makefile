IMAGE    ?= steigr/atlassian-bitbucket
VERSION  ?= $(shell git branch | grep \* | cut -d ' ' -f2)
PORT     ?= 7990
PORT_SSH ?= 7999
BASE     ?= steigr/tomcat:latest

all: image
	@true

image:
	sed 's#^FROM .*#FROM $(BASE)#' Dockerfile > Dockerfile.build
	docker pull $$(grep ^FROM Dockerfile.build | awk '{print $$2}')
	docker build --tag=$(IMAGE):$(VERSION) --file=Dockerfile.build .
	rm Dockerfile.build

run: image
	docker run --rm --env=TRACE --publish=$(PORT):$(PORT) --publish=$(PORT_SSH):$(PORT_SSH) --name=$(shell basename $(IMAGE)) --env=CATALINA_CONNECTOR_$(PORT)_upgrade=http2 $(IMAGE):$(VERSION) $(cmd)

debug: image
	docker run --rm --env=TRACE --publish=$(PORT):$(PORT) --publish=$(PORT_SSH):$(PORT_SSH) --name=$(shell basename $(IMAGE)) --tty --interactive --env=CATALINA_CONNECTOR_$(PORT)_upgrade=http2 $(IMAGE):$(VERSION) bash
