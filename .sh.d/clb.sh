export WRK_DIR=/data/wrk

alias on-sl='sudo openvpn --config $WRK_DIR/ovpn/clb.ovpn'
alias on-hq='sudo openconnect -u ihar.hancharenka vpn.clarabridge.com'

export CLB_BASE_DIR=$WRK_DIR/clb
export CLB_MST_DIR=$WRK_DIR/microstructure
export CLB_LIB_DIR=$CLB_BASE_DIR/lib
export CLB_MSZ_DIR=$CLB_BASE_DIR/morfeusz/
export CLB_DIM_DIR=$CLB_BASE_DIR/docker-images

export CLB_AUTH_SRV_DIR=$CLB_BASE_DIR/cb-authentication-server
export CLB_OLD_AUTH_SRV_DIR=$CLB_MST_DIR/cb-auth-server
export CLB_SRC_DIR=$CLB_BASE_DIR/platform
export CLB_FX_DIR=$CLB_BASE_DIR/fx
export CLB_FX_MODULES_DIR=$CLB_FX_DIR/modules
export CLB_LP_DIR=$CLB_FX_DIR/lang-packs
export CLB_SVC_DIR=$CLB_FX_DIR/service
export CLB_NEW_FX_DIR=$CLB_FX_DIR/spikes/gra/native
export CLB_SVC_FX_DIR=$CLB_SVC_DIR/build/lib.fx
export CLB_ING_DIR=$CLB_BASE_DIR/ingestion-gateway
export CLB_INR_DIR=$CLB_BASE_DIR/ingestion-msg-router
export CLB_MINIO_DIR=$CLB_BASE_DIR/minio
export CB_NLP_GRADLE_CONTAINER_DIR=$CLB_BASE_DIR/.gradle-container
export CLB_INST_HELPER_DIR=$WRK_DIR/wnotes/clb/inst
export CLB_PRJ_HELPER_DIR=$WRK_DIR/prj/gra/kts/clb

export SQLCL_DIR=$WRK_DIR/sqlcl

export CB_NLP_TENSORFLOW_SYN_HOST=localhost
export CB_NLP_TENSORFLOW_SYN_PORT=0

alias granlp='gradle --warning-mode=all -Pbuild.type=nlp -Pnlp.workspace=$CLB_FX_DIR'

gra() {
    # local GRADLE_OPTS="-Xmx16g -XX:MaxHeapSize=16g"
    gradle --no-daemon --warning-mode=all $@
}

clb-misspel() {
    local LP_NAME="${1// }"
    local TARGET_DIR=$CLB_LP_DIR/$LP_NAME/resources/target
    local log4j_ver=2.11.2
    if [[ -z $LP_NAME ]]; then
        echo "LP_NAME is EMPTY - skip configuring"
    else
        (cd $TARGET_DIR;\
            export LD_LIBRARY_PATH=$TARGET_DIR/lib;\
            java \
                -Dfile.encoding=utf-8 \
                -Djava.library.path=$LD_LIBRARY_PATH \
                -Dlog4j.debug=true \
                -Dlog4j.configuration=file://$CLB_LIB_DIR/log4j.properties \
                -Dlog4j.configurationFile=lib/jfx.properties \
                -cp $CLB_LIB_DIR/log4j-slf4j-impl-$log4j_ver.jar:$CLB_LIB_DIR/log4j-core-$log4j_ver.jar:$CLB_LIB_DIR/log4j-api-$log4j_ver.jar:lib/jfxapp.jar\
                com.clarabridge.fx.Main \
                -config config-misspellings.xml \
                -properties lib/jfx.properties \
                -resbasedir . \
                -result result-misspellings.xml \
                misspellings.txt\
        )
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
    docker run --rm -d --name clb-eureka\
        -p 8761:8761\
        gcr.io/cb-images/cb-eureka:1.1.2
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

off-eureka() {
    docker stop clb-eureka
}

# cb-auth-server

psql-auth () {
    # create database oauth;
    psql -h localhost -d oauth -U postgres $@ # "$@"
}

run-auth() {
    (cd $CLB_AUTH_SRV_DIR;\
        java \
            -Dmanagement.server.port=8086\
            -jar build/libs/authentication-server-0.3.1.jar)
}

run-auth-eureka() {
    (cd $CLB_AUTH_SRV_DIR;\
        java \
            -Dspring.profiles.active=eureka\
            -Dmanagement.server.port=8086\
            -jar build/libs/authentication-server-0.3.1.jar)
}

run-auth-old() {
            #-Deureka.client.registerWithEureka=false\
            #-Deureka.client.fetchRegistry=false\
            #-Dspring.datasource.url=jdbc:postgresql://postgres.clarabridge.net:5432/oauth\
    (cd $CLB_OLD_AUTH_SRV_DIR;\
        java \
            -Dspring.profiles.active=dev\
            -jar build/libs/cb-auth-server-1.1.1.jar)
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
        ./gradlew -Pbuild.type=$CLB_BUILD_TYPE -Pnlp.workspace=$CLB_FX_DIR $TASK_NAME "$@"
    fi
}

clb-b () {
    local CLB_BUILD_TYPE="${1// }"
    shift
    if [[ -z $CLB_BUILD_TYPE ]]; then
        echo "CLB_BUILD_TYPE is EMPTY - skip gradle build"
    else
        local CLB_LOGB_DIR=$CLB_BASE_DIR/logb
        local val_dt=`date +"%Y-%m-%d-%H-%M-%S"`
        local CLB_LOG_DIR=$CLB_LOGB_DIR/$val_dt-cmp
        mkdir $CLB_LOG_DIR

        (cd $CLB_SRC_DIR;\
            clb-gra clean "$@" 2>&1 | tee $CLB_LOG_DIR/clean.txt;\
            clb-gra build "$@" 2>&1 | tee $CLB_LOG_DIR/build.txt;\
            clb-gra build "$@" 2>&1 | tee $CLB_LOG_DIR/copy.txt
        )
        # clb-b-copy-artifacts
    fi
}

clb-b-nlp () {
    clb-b nlp
}

clb-b-cont () {
    clb-b continuous
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

print-adv-host() {
    # enp2s0 - home, enp0s8 - wrk, vb
    ip -o -4 a | cut -d ' ' -f 2,7 | grep enp | head -1 | cut -d ' ' -f 2 | cut -d '/' -f 1
}

run-cmp() {
    local ADV_HOST=$(print-adv-host)

    local CLB_INST_DIR=$CLB_BASE_DIR/inst
    local CLB_SERVER_DIR=$CLB_INST_DIR/server

    # $CLB_INST_DIR/server/bin/catalina.sh run # run configtest start/stop -force
    # (cd $CLB_SERVER_DIR/bin; ./catalina.sh run)

    rm -rf $CLB_SERVER_DIR/logs
    mkdir $CLB_SERVER_DIR/logs

    #local JPDA_OPTS="-Xdebug -Xrunjdwp:transport=dt_socket,server=y,suspend=n,address=4142"
    local JPDA_OPTS="-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=4142"

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

clb-get-metrics() {
    curl -u "admin:admin" "http://localhost:18080/mobile/rest/metrics"
}

# FX stuff

fx-b() {
    (cd $CLB_FX_DIR;\
        ./container.sh -Pcore.ant.skip=true -Pmodules.ant.skip=true -Plp.ant.skip=true -Pservice.local=true $@)
}

cp-cape() {
    cp $CLB_FX_MODULES_DIR/cape/target/linux-x64/lib*.* $CLB_SVC_FX_DIR/
}

cp-bd() {
    cp $CLB_FX_MODULES_DIR/break-detector/target/linux-x64/lib*.* $CLB_SVC_FX_DIR/
}

cp-cte() {
    cp $CLB_FX_MODULES_DIR/ctevaluation/target/ctevaluation.jar $CLB_SVC_FX_DIR/
}

cp-morph-pl() {
    cp $CLB_FX_MODULES_DIR/morph_pl/build/libs/morph_pl*.jar $CLB_SVC_FX_DIR/morph_pl.jar
}

cp-msz() {
    cp $CLB_MSZ_DIR/clb/javaprovider/build/libs/morfeuszprovider-linux-*.jar $CLB_SVC_FX_DIR/
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
    local MDM_DIR=$CLB_BASE_DIR/madamira
    local MDM_RELEASE_DIR=$MDM_DIR/release-20140725-1.0

    (cd $MDM_RELEASE_DIR;\
        java\
        -Xmx2500m -Xms2500m -XX:NewRatio=3\
        -jar "$MDM_RELEASE_DIR/MADAMIRA-release-20140725-1.0.jar"\
        -s -msaonly)
}

# lttoolbox-bn

on-ltt() {
    docker run --rm\
        -d --name my-lttoolbox-service-bn \
        -p 8091:8080 -p 9099:9090 \
        gcr.io/cb-images/cb-nlp-bn-lttoolbox:0.8.0

        #cb-nlp-bn-lttoolbox:latest
}


# rabbit
on-rabbit () {
    local RABBITMQ_SRC_DIR=$CLB_BASE_DIR/rabbitmq
    # one-time: mkdir $RABBITMQ_SRC_DIR/mnesia
    docker run --rm \
        -d --name rabbitmq \
        -p 4369:4369 \
        -p 5671:5671 \
        -p 5672:5672 \
        -p 25672:25672 \
        -p 15672:15672 \
        -e RABBITMQ_DEFAULT_USER=user \
        -e RABBITMQ_DEFAULT_PASS=password \
        -v $RABBITMQ_SRC_DIR/mnesia:/var/lib/rabbitmq/mnesia:rw \
        rabbitmq:3.8.0-management
}

off-rabbit () {
    docker stop rabbitmq
}

# mongo

on-mongo () {
    local MONGODB_SRC_DIR=$CLB_BASE_DIR/mongodb
    # one-time: mkdir $MONGODB_SRC_DIR/mongodb
    #   sudo chown :root $MONGODB_SRC_DIR && chmod g+rwX $MONGODB_SRC_DIR

    # docker run --rm -ti \
    #    -e ALLOW_EMPTY_PASSWORD=yes \
    docker run --rm -d --name mongodb \
        -p 27017:27017 \
        -e MONGODB_USERNAME=admin \
        -e MONGODB_PASSWORD=admin \
        -e MONGODB_DATABASE=CB_Studio \
        -e MONGODB_SYSTEM_LOG_VERBOSITY=2 \
        -v $MONGODB_SRC_DIR:/bitnami:rw \
        bitnami/mongodb:4.2.1-r28
}

off-mongo () {
    docker stop mongodb
}

mongo-studio() {
    mongo 'mongodb://admin:admin@127.0.0.1:27017/CB_Studio' $@
}

# ing

on-ing() {
    docker run -d \
      --name ingestion-gateway \
      --network=host \
      -p 8123:8123 \
      -e spring.profiles.active=mock,development \
      -e spring.rabbitmq.host=localhost \
      -e JAVA_OPTS='-Xms4g -Xmx4g -XX:NewSize=3g -XX:+AlwaysPreTouch' \
      -e spring.kafka.bootstrap-servers=kafka-01:9092,kafka-02:9092 \
      -e eureka.client.enabled=false \
      -e eureka.client.serviceUrl.defaultZone=http://eureka-01:8443/eureka/,http://eureka-02:8443/eureka/ \
      -e router.language.en=EN-P0-IN,EN-P1-IN \
      -e router.fallback=ALL-P0-IN \
      gcr.io/cb-images/cb-ingestion-gateway:0.2.1

#      -e security.oauth2.client.client-id=my-ingestion-gateway \
#      -e security.oauth2.client.client-secret=secret \
#      -e security.oauth2.resource.token-info-uri=http://auth-server/oauth/check_token \
}

run-ing() {
    #export SPRING_RABBITMQ_HOST=$HOST
    #export SPRING_RABBITMQ_USERNAME=user
    #export SPRING_RABBITMQ_PASSWORD=password

    (cd $CLB_ING_DIR;\
        java \
            -Xms4g -Xmx4g -XX:NewSize=3g -XX:+AlwaysPreTouch \
            -Dspring.profiles.active=mock,development \
            -Dspring.rabbitmq.host=$HOST \
            -Dspring.rabbitmq.username=user \
            -Dspring.rabbitmq.password=password \
            -Drouter.language.en=EN-P0-IN,EN-P1-IN \
            -Drouter.fallback=ALL-P0-IN \
            -jar build/libs/ingestion-gateway-0.2.1.jar
    )
}

run-inr() {
    (cd $CLB_INR_DIR;\
        java \
            -Dspring.profiles.active=mock,development \
            -Dspring.rabbitmq.host=$HOST \
            -Dspring.rabbitmq.username=user \
            -Dspring.rabbitmq.password=password \
            -jar build/libs/ingestion-msg-router-0.2.2.jar
    )
}

# minio

run-minio() {
    (export MINIO_ACCESS_KEY=nlpsvc;\
        export MINIO_SECRET_KEY=devsecret;\
        minio server --compat $CLB_MINIO_DIR
    )
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

# TF

# clients shoud define the following env vars:
# export CB_NLP_TENSORFLOW_SYN_HOST=<hostname>
# export CB_NLP_TENSORFLOW_SYN_PORT=8500
# export CB_NLP_TENSORFLOW_SYN_BATCHSIZE=500
    #   bash -c "cd /opt/ud-research; pwd; ls -la models"

on-tf-hi() {
    docker run --rm\
        --name clb-tf-hi\
        -p 8500:8500\
        -d gcr.io/cb-images/cb-nlp-tf-dragnn-server-cpu:0.10\
        tensorflow_model_server \
            --enable_batching \
            --model_config_file=models/model_config_hi.txt \
            --batching_parameters_file=models/batching_config.txt
}

off-tf-hi () {
    docker stop clb-tf-hi
}

on-tf-fr() {
    docker run --rm -it\
        --name clb-tf-fr\
        -p 8500:8500\
        -d gcr.io/cb-images/cb-nlp-tf-dragnn-server-cpu:0.14\
        tensorflow_model_server \
            --enable_batching \
            --model_config_file=models/model_config_fr.txt \
            --batching_parameters_file=models/batching_config.txt
}

off-tf-fr () {
    docker stop clb-tf-fr
}

on-tf-sv() {
    docker run --rm\
        --name clb-tf-sv\
        -p 8500:8500\
        -d gcr.io/cb-images/cb-nlp-tf-dragnn-server-cpu:0.10\
        tensorflow_model_server \
            --enable_batching \
            --model_config_file=models/model_config_sv.txt \
            --batching_parameters_file=models/batching_config.txt
}

off-tf-sv () {
    docker stop clb-tf-sv
}

# spacy

on-spacy-pl() {
    # -ti\
    docker run --rm\
        -d --name clb-spacy-pl\
        -p 8089:8089\
        gcr.io/cb-images/cb-nlp-spacy-service-pl:0.1.4

    # gunicorn --bind=0.0.0.0:8000 api:__hug_wsgi__ --error-logfile=-
    # --bind=0.0.0.0:8000 --error-logfile=-

    # clients shoud define the following env vars:
    # export CB_NLP_SPACY_HTTP_HOST=localhost
    # export CB_NLP_SPACY_HTTP_PORT=8089
    # export CB_NLP_SPACY_HTTP_SCHEME=http
    # export CB_NLP_SPACY_SERVICE_LANG=pl
}

off-spacy-pl () {
    docker stop clb-spacy-pl
}

on-tps() {
    docker run --rm -d --name clb-tps\
        -p 8080:8080\
        -p 9090:9090\
        -v $CLB_BASE_DIR/industry-templates:/opt/clarabridge/templates-storage:ro \
        -e eureka.client.enabled=false \
        -e storage.path=file:../templates-storage \
        -e clientDetailsFilePath=./clients/clientDetails.yml \
        -w /opt/clarabridge/templates-service \
        gcr.io/cb-images/cb-template-service:1.0.3 \
        java -jar cb-templates-1.0.3.jar
}

off-tps() {
    docker stop clb-tps
}

# misc stuff

cp-regexp-en() {
    cp $CLB_NEW_FX_DIR/shared-lib/regexp/build/lib/main/debug/*.so $CLB_NEW_FX_DIR/lang-packs/english/build/dist/
}

# es6

doc-build-es6() {
    local ES_VERSION=6.8.13
    local ES_PLUGIN_VERSION=102
    local IMAGE=cb-elasticsearch6:$ES_VERSION.$ES_PLUGIN_VERSION

    local NEXUS_IP="${1// }"
    if [[ -z $NEXUS_IP ]]; then
        echo "NEXUS_IP is EMPTY - skipping..."
    else
    #   docker build -t $(IMAGE) --pull
        local NEXUS_URL=http://$NEXUS_IP:8081/content/groups/public
        docker build -t $IMAGE --build-arg ES_VERSION=$ES_VERSION --build-arg PLUGIN_VERSION=$ES_PLUGIN_VERSION --build-arg NEXUS_URL=$NEXUS_URL $CLB_DIM_DIR/cb-elasticsearch/6
    fi
}

# sudo vim /etc/sysctl.d/99-sysctl.conf
# and set vm.max_map_count to 262144.
# sudo sysctl --system
# sysctl vm.max_map_count
# sudo sysctl -w vm.max_map_count=262144

on-es6() {
    local ES6_SRC_DIR=$CLB_BASE_DIR/es6
    local ADV_HOST=$(print-adv-host)
    #    -p 5005:5005 \
    #    -e ES_JAVA_OPTS="-agentlib:jdwp=transport=dt_socket,address=*:5005,server=y,suspend=n" \
    docker run --rm -it \
        -d --name es6 \
        --user "$(id -u):$(id -g)"\
        -p 9200:9200 \
        -p 9300:9300 \
        -e cluster.name=ih-cluster \
        -e node.name=ih-node \
        -e transport.publish_host=$ADV_HOST \
        -e transport.publish_port=9300 \
        -e http.publish_host=$ADV_HOST \
        -e http.publish_port=9200 \
        -e indices.query.bool.max_clause_count=10240 \
        -e discovery.type=single-node \
        -v $ES6_SRC_DIR/data:/usr/share/elasticsearch/data:rw \
        cb-elasticsearch6:6.8.13.102
}

off-es6() {
    docker stop es6
}

# devstack

devstack() {
    local CLB_DEVSTACK_DIR=$CLB_BASE_DIR/DevStack

    (cd $CLB_DEVSTACK_DIR;\
        export DEVSTACK_DIR=$CLB_DEVSTACK_DIR/clarabridge/nlp;\
        ./devstack-linux $@
    )
    # devstack config --enable
}

alias rdp-bart='rdp-clb-sl bart01.clarabridge.net'
alias rdp-nlp-dev-2k8r1='rdp-clb-hq-admin nlp-dev-2k8r1.cbmain.clarabridge.com'
alias on-black2='xfreerdp -nego -sec-nla -sec-tls -sec-rdp +sec-ext /v:black2.clarabridge.net /u:ihar.hancharenka /gd:clarabridge.net +clipboard /w:1600 /h:1150'
