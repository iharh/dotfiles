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
