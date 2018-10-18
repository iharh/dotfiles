export WRK_DIR=/data/wrk

alias on-sl='sudo openvpn --config $WRK_DIR/ovpn/clb.ovpn'
alias on-hq='sudo openconnect -u ihar.hancharenka vpn.clarabridge.com'

export CLB_BASE_DIR=$WRK_DIR/clb
export CLB_MST_DIR=$WRK_DIR/microstructure
export CLB_AUTH_SRV_DIR=$CLB_MST_DIR/cb-auth-server
export CLB_SRC_DIR=$CLB_BASE_DIR/platform
export CLB_FX_DIR=$CLB_BASE_DIR/fx
export CLB_LP_DIR=$CLB_FX_DIR/lang-packs
export CB_NLP_GRADLE_CONTAINER_DIR=$CLB_BASE_DIR/.gradle-container
export CLB_INST_HELPER_DIR=$WRK_DIR/wnotes/clb/inst
export CLB_PRJ_HELPER_DIR=$WRK_DIR/prj/gra/kts/clb

export SQLCL_DIR=$WRK_DIR/sqlcl

export CB_NLP_TENSORFLOW_SYN_HOST=localhost
export CB_NLP_TENSORFLOW_SYN_PORT=0

alias gra='gradle --warning-mode=all'
alias granlp='gradle --warning-mode=all -Pbuild.type=nlp -Pnlp.workspace=$CLB_FX_DIR'

clb-misspel() {
    local LP_NAME="${1// }"
    local TARGET_DIR=$CLB_LP_DIR/$LP_NAME/resources/target
    local log4j_ver=2.9.1
    if [[ -z $LP_NAME ]]; then
        echo "LP_NAME is EMPTY - skip configuring"
    else
                # -jar $TARGET_DIR/lib/jfxapp.jar \
                # -cp $TARGET_DIR/lib/log4j-slf4j-impl-$log4j_ver.jar:$TARGET_DIR/lib/log4j-core-$log4j_ver.jar:$TARGET_DIR/lib/log4j-api-$log4j_ver.jar:$TARGET_DIR/lib/jfxapp.jar\
                # com.clarabridge.fx.Main\
                # -properties $TARGET_DIR/lib/jfx.properties \
        (cd $TARGET_DIR;\
            export LD_LIBRARY_PATH=$TARGET_DIR/lib;\
            java \
                -Dfile.encoding=utf-8 \
                -Djava.library.path=$LD_LIBRARY_PATH \
                -Dlog4j.debug=true \
                -Dlog4j.configuration=file://$CLB_BASE_DIR/log4j.properties \
                -Dlog4j.configurationFile=lib/jfx.properties \
                -cp lib/log4j-slf4j-impl-$log4j_ver.jar:lib/log4j-core-$log4j_ver.jar:lib/log4j-api-$log4j_ver.jar:lib/jfxapp.jar\
                com.clarabridge.fx.Main\
                -config config-misspellings.xml \
                -properties lib/jfx.properties \
                -resbasedir . \
                -result result-misspellings.xml \
                misspellings.txt)
    fi
}

clb-en-misspel() {
    clb-misspel english
}
clb-de-misspel() {
    clb-misspel german
}

# PG

on-pg () {
    local PG_SRC_DIR=$CLB_BASE_DIR/postgresql
    # one-time: mkdir $PG_SRC_DIR/data

    docker run --rm\
    --name clb-pg\
    -p 5432:5432\
    --user "$(id -u):$(id -g)"\
    -v /etc/passwd:/etc/passwd:ro\
    -v $PG_SRC_DIR/data:/var/lib/postgresql/data:rw\
    -v $PG_SRC_DIR/postgres-passwd:/run/secrets/postgres-passwd:ro\
    -e POSTGRES_PASSWORD_FILE=/run/secrets/postgres-passwd\
    -d postgres:9.3
}

off-pg () {
    docker stop clb-pg
}

psql-cmp () {
    psql -h localhost -d postgres -U postgres $@ # "$@"
}

alias usql-cmp='usql pg://postgres@localhost/postgres?sslmode=disable'

# ORA

export ORA_DOC_NAME=ee11g

on-ora () {
    local ORA_DATA_DIR=$CLB_BASE_DIR/oradata
    docker run --rm\
    --shm-size=1G\
    --name $ORA_DOC_NAME\
    -p 1521:1521\
    -v $ORA_DATA_DIR/$ORA_DOC_NAME:/u01/app/oracle:rw\
    -e WEB_CONSOLE=false\
    -d sath89/oracle-ee-11g
#-e JAVA_JIT_ENABLED=false\
#-e DBCA_TOTAL_MEMORY=1024\
}

off-ora () {
    docker stop $ORA_DOC_NAME
}

bash-ora () {
    docker exec -ti $ORA_DOC_NAME bash
}

#docker exec -ti $ORA_DOC_NAME sqlplus system/oracle@//localhost:1521/EE.oracle.docker
# select database_status from v$instance;

sql-cmp() {
    export SQLPATH=$CLB_INST_HELPER_DIR/db/ora/script; $SQLCL_DIR/bin/sql lin_ss/clb@//localhost:1521/EE.oracle.docker $@
}

sql-cmp-system() {
    $SQLCL_DIR/bin/sql system/oracle@//localhost:1521/EE.oracle.docker $@
}

sql-cmp-sys() {
    $SQLCL_DIR/bin/sql sys/oracle@//localhost:1521/EE.oracle.docker as sysdba $@
}

sql-cmp-sys-silent() {
    $SQLCL_DIR/bin/sql -S sys/oracle@//localhost:1521/EE.oracle.docker as sysdba $@
}

sql-cmp-setup() {
    $SQLCL_DIR/bin/sql cb_setup/oracle@//localhost:1521/EE.oracle.docker $@
}

# cb-eureka

on-eureka() {
    docker run --rm\
        --name clb-eureka\
        -p 8761:8761\
        docker-registry.clarabridge.net:5000/cb_plat/cb-eureka
#      - server.port=8761
#      - spring.cloud.client.hostname=eureka
#      - eureka.instance.metadataMap.zone=usZone
#      - eureka.client.region=cbRegion
#      - eureka.client.availability-zones.cbRegion=usZone
#      - eureka.client.serviceUrl.usZone=http://eureka:8761/eureka/
#      - eureka.client.registerWithEureka=true
#      - eureka.client.fetchRegistry=true
#      - eureka.server.enableSelfPreservation=true
}

# cb-auth-server

psql-auth () {
    # create database oauth;
    psql -h localhost -d oauth -U postgres $@ # "$@"
}

on-auth() {
            #-Deureka.client.registerWithEureka=false\
            #-Deureka.client.fetchRegistry=false\
            #-Dspring.datasource.url=jdbc:postgresql://postgres.clarabridge.net:5432/oauth\
    (cd $CLB_AUTH_SRV_DIR;\
        java \
            -Dspring.profiles.active=dev\
            -jar build/libs/cb-auth-server-1.1.0.jar)
}

# default
# -Pbuild.type=continuous
# custom
# -Pnlp.workspace=.../clb/src/main

clb-repo-up () {
    local CLB_LOGB_DIR=$CLB_BASE_DIR/logb
    local val_dt=`date +"%Y-%m-%d-%H-%M-%S"`
    local CLB_LOG_DIR=$CLB_LOGB_DIR/$val_dt-repo
    mkdir $CLB_LOG_DIR
    local GIT_LOG=$CLB_LOG_DIR/git-changes.txt

    (cd $CLB_SRC_DIR;\
        local git_cur_br=`git rev-parse --abbrev-ref HEAD`;\
        echo GIT BRANCH: $git_cur_br;\
        git remote -v update --prune;\
        git log $git_cur_br..origin/$git_cur_br --name-status 2>&1 | tee $GIT_LOG;\
        git rebase origin/$git_cur_br | tee -a $GIT_LOG;\
        git status 2>&1 | tee $CLB_LOG_DIR/git-local.txt)
}


clb-b-copy-artifacts () {
    (cd $CLB_SRC_DIR;\
        gradle api-common:copyArtifacts;\
        gradle cld2:copyArtifacts;\
        gradle common.cache:copyArtifacts;\
        gradle discovery:copyArtifacts
    )
}

clb-gra () {
    local TASK_NAME="${1// }"
    if [[ -z $TASK_NAME ]]; then
        echo "TASK_NAME is EMPTY - skip gradle build"
    else
        # continuous nlp
        # local CLB_BUILD_TYPE=nlp
        local CLB_BUILD_TYPE=continuous
        # ./gradlew gradle
        ./gradlew -Pbuild.type=$CLB_BUILD_TYPE -Pnlp.workspace=$CLB_FX_DIR $TASK_NAME "$@"
    fi
}

clb-b () {
    local CLB_LOGB_DIR=$CLB_BASE_DIR/logb
    local val_dt=`date +"%Y-%m-%d-%H-%M-%S"`
    local CLB_LOG_DIR=$CLB_LOGB_DIR/$val_dt-cmp
    mkdir $CLB_LOG_DIR

    # local CLB_GRA_PROPS="-Pbuild.type=$CLB_BUILD_TYPE -Pnlp.workspace=$CLB_FX_DIR"
    (cd $CLB_SRC_DIR;\
        clb-gra clean "$@" 2>&1 | tee $CLB_LOG_DIR/clean.txt;\
        clb-gra build "$@" 2>&1 | tee $CLB_LOG_DIR/build.txt;\
        clb-gra build "$@" 2>&1 | tee $CLB_LOG_DIR/copy.txt
    )
    # clb-b-copy-artifacts
}

clb-gra-cfg() {
    gradle -b $CLB_PRJ_HELPER_DIR/build.gradle.kts clbCfg
}

clb-i-lp() {
    local LP_ID="${1// }"
    if [[ -z $LP_ID ]]; then
        echo "$LP_ID is EMPTY - skip LP install"
    else
        local CLB_LP_INSTALLER=`find $CLB_LP_DIR/$LP_ID/installer/target -name "setup_*.zip"`
        # echo CLB_LP_INSTALLER: $CLB_LP_INSTALLER
        (cd $CLB_INST_DIR; 7z x $CLB_LP_INSTALLER)
    fi
}

clb-i() {
    local CLB_INST_DIR=$CLB_BASE_DIR/inst
    #   /etc/security/limits.d/clarabridge.conf
    mkdir -p $CLB_INST_DIR
    cp -r $CLB_SRC_DIR/build/tmp/* $CLB_INST_DIR

    clb-gra-cfg

    # sudo chmod +x $CLB_INST_DIR/server/bin/catalina.sh
    ln -s $CLB_SRC_DIR/cbtests/tests/groovy $CLB_INST_DIR/scripts/groovy

    # clb-i-lp arabic
    # clb-i-lp hindi
}

clb-i-pg() {
    clb-i
    clb-conf pg
    clb-fill-pg
}

clb-i-ora() {
    clb-i
    clb-conf ora
}

clb-conf() {
    local DB_ID="${1// }"
    if [[ -z $DB_ID ]]; then
        echo "$DB_ID is EMPTY - skip configuring"
    else
        local CLB_INST_DIR=$CLB_BASE_DIR/inst
        local CLB_CONF_DIR=$CLB_INST_DIR/configurer
        cp $CLB_INST_HELPER_DIR/cfg-$DB_ID.properties $CLB_CONF_DIR/commandLineConfig.properties
        (cd $CLB_CONF_DIR; java -XX:+HeapDumpOnOutOfMemoryError -mx4096m -Dfile.encoding=UTF-8 -jar configurer-cmp.jar run.xml run 0 1)
    fi
}

clb-conf-lp() {
    local CLB_INST_DIR=$CLB_BASE_DIR/inst
    local CLB_CONF_DIR=$CLB_INST_DIR/configurer
    local JPDA_OPTS="-agentlib:jdwp=transport=dt_socket,server=y,suspend=y,address=4142"
    export LP_LANG_CODE=bn
    (cd $CLB_CONF_DIR; java -XX:+HeapDumpOnOutOfMemoryError -mx512m -Doracle.jdbc.timezoneAsRegion=false -Dfile.encoding=UTF-8 -jar configurer-cmp.jar run.xml run 3 1)
}

clb-fill-pg() {
    local CLB_INST_HELPER_PG_SCRIPT_DIR=$CLB_INST_HELPER_DIR/db/pg/script

    echo "pg_fill_lin..."
    psql-cmp -f $CLB_INST_HELPER_PG_SCRIPT_DIR/pg_fill_lin.sql -a -e
}

run-cmp() {
    local CLB_INST_DIR=$CLB_BASE_DIR/inst
    local CLB_SERVER_DIR=$CLB_INST_DIR/server

    # $CLB_INST_DIR/server/bin/catalina.sh run # run configtest start/stop -force
    # (cd $CLB_SERVER_DIR/bin; ./catalina.sh run)

    rm -rf $CLB_SERVER_DIR/logs
    mkdir $CLB_SERVER_DIR/logs

    #local JPDA_OPTS="-Xdebug -Xrunjdwp:transport=dt_socket,server=y,suspend=n,address=4142"
    local JPDA_OPTS="-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=4142"

    # enp2s0 - home, enp0s8 - wrk, vb
    local ADV_HOST=$(ip -o -4 a | cut -d ' ' -f 2,7 | grep enp | head -1 | cut -d ' ' -f 2 | cut -d '/' -f 1)


    (cd $CLB_SERVER_DIR/bin;\
        export LD_LIBRARY_PATH="$CLB_INST_DIR/fx:$LD_LIBRARY_PATH";\
        export CB_NLP_TENSORFLOW_SYN_HOST=localhost;\
        export CB_NLP_TENSORFLOW_SYN_PORT=8500;\
        export CB_NLP_TENSORFLOW_SYN_BATCHSIZE=256;\
        java\
        $JPDA_OPTS\
        -Dkafka.bootstrap.servers=$ADV_HOST:9092\
        -Dkafka.cb.zookeeper.servers=$ADV_HOST:2181\
        -Djava.util.logging.config.file=$CLB_SERVER_DIR/conf/logging.properties\
        -Djava.util.logging.manager=org.apache.juli.ClassLoaderLogManager\
        -Dcatalina.es.version=1x\
        -Djava.endorsed.dirs="$CLB_SERVER_DIR/endorsed"\
        -classpath "$CLB_SERVER_DIR/bin/bootstrap.jar:$CLB_SERVER_DIR/bin/tomcat-juli.jar"\
        -Dcatalina.base="$CLB_SERVER_DIR"\
        -Dcatalina.home="$CLB_SERVER_DIR"\
        -Djava.io.tmpdir="$CLB_SERVER_DIR/temp"\
        -Djava.library.path="$CLB_INST_DIR/fx"\
        -javaagent:"$CLB_SERVER_DIR/lib.cb/clarabridge-memory-agent.jar"\
        org.apache.catalina.startup.Bootstrap start)
}

clb-un() {
    local CLB_INST_DIR=$CLB_BASE_DIR/inst
    rm -rf $CLB_INST_DIR
    mkdir $CLB_INST_DIR
}

clb-un-pg() {
    clb-un

    local CLB_LOGB_DIR=$CLB_BASE_DIR/logb
    local val_dt=`date +"%Y-%m-%d-%H-%M-%S"`
    local CLB_LOG_DIR=$CLB_LOGB_DIR/$val_dt-drop-pg
    mkdir $CLB_LOG_DIR

    local CLB_INST_HELPER_PG_SCRIPT_DIR=$CLB_INST_HELPER_DIR/db/pg/script

    echo "pg_drop_detect_lin..."
    psql-cmp -A -t -f $CLB_INST_HELPER_PG_SCRIPT_DIR/pg_drop_detect_lin.sql -o$CLB_LOG_DIR/drop_pg.sql
    cat $CLB_LOG_DIR/drop_pg.sql
    echo "drop_pg..."
    psql-cmp -f $CLB_LOG_DIR/drop_pg.sql -a -e

    echo "pg_drop_detect_other..."
    psql-cmp -A -t -f $CLB_INST_HELPER_PG_SCRIPT_DIR/pg_drop_detect_other.sql -o$CLB_LOG_DIR/drop_pg_other.sql
    cat $CLB_LOG_DIR/drop_pg_other.sql
    echo "drop_pg_other..."
    psql-cmp -f $CLB_LOG_DIR/drop_pg_other.sql -a -e

    rm -rf $CLB_LOG_DIR
}

clb-un-ora() {
    clb-un

    local CLB_LOGB_DIR=$CLB_BASE_DIR/logb
    local val_dt=`date +"%Y-%m-%d-%H-%M-%S"`
    local CLB_LOG_DIR=$CLB_LOGB_DIR/$val_dt-drop-ora
    mkdir $CLB_LOG_DIR

    local CLB_INST_HELPER_ORA_SCRIPT_DIR=$CLB_INST_HELPER_DIR/db/ora/script

    echo "ora_drop_detect_lin..."
    local DROP_FILE_NAME=$CLB_LOG_DIR/drop_ora.sql
    sql-cmp-sys-silent "@$CLB_INST_HELPER_ORA_SCRIPT_DIR/ora_drop_detect_lin.sql" >$DROP_FILE_NAME
    echo 'exit;' >> $DROP_FILE_NAME
    cat $DROP_FILE_NAME
    echo "drop_ora..."
    sql-cmp-sys-silent "@$DROP_FILE_NAME"

    #echo "ora_drop_detect_other..."
    #local DROP_OTHER_FILE_NAME=$CLB_LOG_DIR/drop_ora_other.sql
    #sql-cmp-sys-silent "@$CLB_INST_HELPER_ORA_SCRIPT_DIR/ora_drop_detect_other.sql" >$DROP_OTHER_FILE_NAME
    #echo 'exit;' >> $DROP_OTHER_FILE_NAME
    #cat $DROP_OTHER_FILE_NAME
    #echo "drop_ora_other..."
    #sql-cmp-sys-silent "@$DROP_OTHER_FILE_NAME"

    rm -rf $CLB_LOG_DIR
}

# LP

lp-make-inst-res() {
    ant make-installer\
        -Dpublish.lp.res=true\
        -Dnexus.realm='Sonatype Nexus Repository Manager'\
        -Dnexus.host=$NEXUS_HOST\
        -Dnexus.repo.snapshots="http://$NEXUS_HOST:8081/content/repositories/releases"
}

# madamira-ar

run-mdm() {
    local MDM_DIR=$CLB_BASE_DIR/third-party/MADAMIRA
    local MDM_RELEASE_DIR=$MDM_DIR/release-20140725-1.0

    (cd $MDM_RELEASE_DIR;\
        java\
        -Xmx2500m -Xms2500m -XX:NewRatio=3\
        -jar "$MDM_RELEASE_DIR/MADAMIRA-release-20140725-1.0.jar"\
        -s -msaonly)
}

# lttoolbox-bn

on-ltt() {
    docker run \
        -d --name my-lttoolbox-service-bn \
        -p 8091:8080 -p 9099:9090 \
        cb-lttoolbox-bn:latest

        #cb-nlp-bn-lttoolbox:latest
}

# TF

run-tf-hi() {
    local CLB_UDR_DIR=$CLB_BASE_DIR/ud-research

    docker run -it -p 8500:8500 -v $CLB_UDR_DIR/models:/opt/ud-research/models docker-registry.clarabridge.net:5000/cb_nlp/dragnn-server-cpu:latest \
    tensorflow_model_server \
            --enable_batching \
            --model_config_file=models/model_config_hi.txt \
            --batching_parameters_file=models/batching_config.txt
}

# /cert-ignore -sec-tls
# +nego +sec-rdp +sec-tls +sec-nla +sec-rdp
# /log-level:TRACE

rdp-clb-sl() {
    local HOST_ID="${1// }"
    if [[ -z $HOST_ID ]]; then
        echo "HOST_ID is EMPTY - skipping..."
    else # -nego -sec-nla -sec-tls -sec-rdp +sec-ext
        echo "HOST_ID is $HOST_ID..."
        xfreerdp /v:$HOST_ID /u:ihar.hancharenka /gd:clarabridge.net +clipboard /w:1600 /h:1150
    fi
}

rdp-clb-hq() {
    local HOST_ID="${1// }"
    if [[ -z $HOST_ID ]]; then
        echo "HOST_ID is EMPTY - skipping..."
    else # -nego -sec-nla -sec-tls -sec-rdp +sec-ext
        echo "HOST_ID is $HOST_ID..."
        xfreerdp /v:$HOST_ID /u:ihar.hancharenka /gd:cbmain.clarabridge.com +clipboard /w:1600 /h:1150
    fi
}

rdp-clb-hq-admin() {
    local HOST_ID="${1// }"
    if [[ -z $HOST_ID ]]; then
        echo "HOST_ID is EMPTY - skipping..."
    else # -nego -sec-nla -sec-tls -sec-rdp +sec-ext
        echo "HOST_ID is $HOST_ID..."
        xfreerdp /v:$HOST_ID /u:Administrator /gd:cbmain.clarabridge.com +clipboard /w:1600 /h:1150
    fi
}

alias rdp-bart='rdp-clb-sl bart01.clarabridge.net'
alias rdp-nlp-dev-2k8r1='rdp-clb-hq-admin nlp-dev-2k8r1.cbmain.clarabridge.com'
alias on-black2='xfreerdp -nego -sec-nla -sec-tls -sec-rdp +sec-ext /v:black2.clarabridge.net /u:ihar.hancharenka /gd:clarabridge.net +clipboard /w:1600 /h:1150'
