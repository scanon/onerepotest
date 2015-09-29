SERVICE = onerepotest
SERVICE_CAPS = onerepotest
SERVICE_PORT = 5000
SPEC_FILE = onerepotest.spec

GITCOMMIT := $(shell git rev-parse --short HEAD)
TAGS := $(shell git tag --contains $(GITCOMMIT))

DIR = $(shell pwd)

LIB_DIR = lib

DEPLOY_RUNTIME ?= /kb/runtime
TARGET ?= /kb/deployment
SERVICE_DIR ?= $(TARGET)/services/$(SERVICE)
BIN = $(TARGET)/bin

PID_FILE = $(SERVICE_DIR)/service.pid
ACCESS_LOG_FILE = $(SERVICE_DIR)/access.log
ERR_LOG_FILE = $(SERVICE_DIR)/error.log
WORKERS = 5

# we have to name this LBIN_DIR (Local Bin Directory) so it doesn't conflict with a KBase common Makefile Variable
# with the same name!
LBIN_DIR = bin
ASYNC_JOB_SCRIPT_NAME = run_$(SERVICE_CAPS)_async_job.sh


default: compile-kb-module

compile-kb-module:
	kb-mobu compile $(SPEC_FILE) \
		--out $(LIB_DIR) \
		--plclname Bio::KBase::$(SERVICE_CAPS)::Client \
		--jsclname javascript/Client \
		--pyclname Client \
		--javasrc java \
		--java \
		--pysrvname OnerepotestServer \
		--pyimplname OnerepotestImpl

clean:
	rm -rfv $(LBIN_DIR)

deploy: deploy-service

deploy-service: deploy-service-libs deploy-executable-script deploy-service-scripts deploy-cfg

deploy-service-libs:
	@echo "Deploying libs to target: $(TARGET)"
	rsync -vrh $(LIB_DIR)/* $(TARGET)/lib/. \
		--exclude TestMathClient.pl --exclude TestPerlServer.sh \
		--exclude *.bak* --exclude AuthConstants.pm
	mkdir -p $(SERVICE_DIR)
	echo $(GITCOMMIT) > $(SERVICE_DIR)/$(SERVICE).serverdist
	echo $(TAGS) >> $(SERVICE_DIR)/$(SERVICE).serverdist

deploy-executable-script:
	@echo "Installing executable scripts to target: $(BIN)"
	echo '#!/bin/bash' > $(BIN)/$(ASYNC_JOB_SCRIPT_NAME)
	echo 'export KB_TOP=$(TARGET)' >> $(BIN)/$(ASYNC_JOB_SCRIPT_NAME)
	echo 'export KB_RUNTIME=/kb/runtime' >> $(BIN)/$(ASYNC_JOB_SCRIPT_NAME)
	echo 'export PATH=$$KB_RUNTIME/bin:$$KB_TOP/bin:$$PATH' >> $(BIN)/$(ASYNC_JOB_SCRIPT_NAME)
	echo 'export PYTHONPATH=$$KB_TOP/lib:$$PYTHONPATH' >> $(BIN)/$(ASYNC_JOB_SCRIPT_NAME)
	echo 'cd $$KB_TOP/lib' >> $(BIN)/$(ASYNC_JOB_SCRIPT_NAME)
	echo 'python OnerepotestServer.py $$1 $$2 $$3' >> $(BIN)/$(ASYNC_JOB_SCRIPT_NAME)

deploy-service-scripts:
	@echo "Preparing start/stop scripts for service"

deploy-cfg:
	@echo "Generating real deployment.cfg based on template"
