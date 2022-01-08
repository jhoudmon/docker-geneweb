#!/usr/bin/env bash

set -e

function startPortal()
{
    # Start GeneWeb
    /opt/geneweb/distribution/gwd -bd /opt/geneweb/distribution/bases -lang fr -hd /opt/geneweb/distribution/gw -p 2317 -log /opt/geneweb/logs/geneweb.log -add_lexicon /opt/geneweb/distribution/gw/lang/lexicon.txt
}

function ensureBackupPathExists()
{
    if [[ ! -d backup ]]; then
        mkdir -p backup
    fi
}

function ensureImportPathExists()
{
    if [[ ! -d import ]]; then
        mkdir -p import
    fi
}

function startSetup()
{
    pushd /opt/geneweb 1> /dev/null

        if [[ -n "${HOST_IP}" ]]; then
           echo "${HOST_IP}" > /opt/geneweb/gwsetup_only.txt
        fi

        ensureBackupPathExists
        ensureImportPathExists

        /opt/geneweb/distribution/gwsetup -p 2316 -gd /opt/geneweb/distribution/gw -bindir /opt/geneweb/distribution/gw -lang ${LANGUAGE}  -only /opt/geneweb/gwsetup_only.txt 2>&1 | tee -a /opt/geneweb/logs/gwsetup.log

    popd 1> /dev/null
}

function runBackup()
{
    # Run the backup of all GWB databases
    backup.sh
}

case "$1" in
        start-portal)
            startPortal
            ;;

        start-setup)
            startSetup
            ;;

        start-all)
            startPortal &
            startSetup
            ;;

        backup)
            runBackup
            ;;

        *)
            echo $"Usage: $0 {start-portal|start-setup|start-all|backup}"
            exit 1

esac
