#!/usr/bin/env bash

# Rather set these in .bashrc or whatever
KPI_DIR=~/kobo2/kpi
KOBOCAT_DIR=~/kobo2/kobocat
FORMPACK_DIR=~/kobo2/formpack
KOBO_DOCKER_DIR=~/kobo2/kobo-docker
KOBO_ENV_DIR=~/kobo2/kobo-env
KOBO_INSTALL_DIR=~/kobo2/kobo-install
EDITOR=vim

function kobo_run() {
    python3 $KOBO_INSTALL_DIR/run.py $@
}

function enter_container() {
    docker exec -it `docker ps | grep "$1" | awk '{print \$1}'` bash
}

function main() {
    case $1 in
        run)
            kobo_run "${@:2}"
        ;;

        start|-s)
            kobo_run
        ;;

        stop|-S)
            kobo_run --stop
        ;;

        logs|-l)
            kobo_run --logs
        ;;

        info|-i)
            kobo_run --info
        ;;

        watch|-w)
            kobo_run -cf run --publish 3000:3000 kpi npm run watch
        ;;

        restart|-r)
            kobo_run -cf restart "${@:2}"
        ;;

        rebuild|-R)
            kobo_run -cf build --no-cache --force-rm $2
        ;;

        attach|-a)
            if [ -z $2 ]; then
                enter_container kpi
            else
                enter_container $2
            fi
        ;;

        dockerfile|-df)
            $EDITOR $KOBO_DOCKER_DIR/docker-compose.frontend.yml
        ;;

        cleandb|-C)
            sudo rm -rf $KOBO_DOCKER_DIR/.vols/{db,mongo}
        ;;

        wtf)
            if [ -z $(which figlet) ]; then
                echo "Install \`figlet\`"
            elif [ -z $FIGLET_FONTDIR ]; then
                figlet "WTF KOBO!"
            else
                figlet -f `find $FIGLET_FONTDIR -type f -name "*.flf" | shuf \
                    | head -n 1` "WTF KOBO!"
            fi
        ;;

        gtfo)
            echo "Getting the f*** outtahere"
            kobo_run --stop && sudo shutdown now
        ;;

        *)
            echo "did you mean \`kobo wtf\`?"
        ;;

    esac
}

main $@

