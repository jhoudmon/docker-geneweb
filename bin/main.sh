#!/usr/bin/env bash

set -e

function startPortal()
{
    # Start GeneWeb
    /home/geneweb/distribution/gwd -lang ${LANGUAGE} -bd /home/geneweb/distribution/bases -hd /home/geneweb/distribution/gw/lang -p 2317 -log ${HOME}/logs/geneweb.log
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
    pushd ${HOME} 1> /dev/null

        if [[ -n "${HOST_IP}" ]]; then
           echo "${HOST_IP}" > ${HOME}/gwsetup_only.txt
        fi

        ensureBackupPathExists
        ensureImportPathExists

        /home/geneweb/distribution/gwsetup -p 2316 -gd /home/geneweb/distribution/gw -bindir /home/geneweb/distribution/gw -lang ${LANGUAGE}  -only ${HOME}/gwsetup_only.txt 2>&1 | tee -a ${HOME}/logs/gwsetup.log

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
            startSetup &
            startPortal
            ;;

        backup)
            runBackup
            ;;

        *)
            echo $"Usage: $0 {start-portal|start-setup|start-all|backup}"
            exit 1

esac
