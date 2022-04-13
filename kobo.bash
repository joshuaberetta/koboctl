#!/usr/bin/env bash

# Rather set these in .bashrc or whatever
KPI_DIR=~/kobo/kpi
KOBOCAT_DIR=~/kobo/kobocat
FORMPACK_DIR=~/kobo/formpack
KOBO_DOCKER_DIR=~/kobo/kobo-docker
KOBO_ENV_DIR=~/kobo/kobo-env
KOBO_INSTALL_DIR=~/kobo/kobo-install
EDITOR=vim
NAME=kobo

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
            if [ -z $2 ]; then
                kobo_run
            else
                kobo_run -cf up -d $2
            fi
        ;;

        stop|-S)
            if [ -z $2 ]; then
                kobo_run --stop
            else
                kobo_run -cf stop $2
            fi
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
            $EDITOR $KOBO_DOCKER_DIR/docker-compose.frontend.override.yml
        ;;

        edit|-e)
            $EDITOR `which "$NAME"`
        ;;

        cleandb|-C)
            sudo rm -rf $KOBO_DOCKER_DIR/.vols/{db,mongo}
        ;;

        rms|-rs)
            sudo rm -rf $KOBO_DOCKER_DIR/.vols/static/kpi && sudo rm -rf $KPI_DIR/staticfiles
        ;;

        rm|-D)
            docker image ls | grep dev.kobofe | awk '{print $3}' | xargs docker image rm >/dev/null
            sudo rm -rf {$KOBO_DOCKER_DIR,$KOBO_ENV_DIR,$KOBO_INSTALL_DIR,$KPI_DIR,$KOBOCAT_DIR,$FORMPACK_DIR}
            git clone https://github.com/kobotoolbox/formpack.git $FORMPACK_DIR >/dev/null
            git clone https://github.com/kobotoolbox/kobocat.git $KOBOCAT_DIR >/dev/null
            git clone https://github.com/kobotoolbox/kpi.git $KPI_DIR >/dev/null
            git clone https://github.com/kobotoolbox/kobo-install.git $KOBO_INSTALL_DIR >/dev/null
            echo Done
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

