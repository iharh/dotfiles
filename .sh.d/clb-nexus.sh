# nexus 2

on-nexus () {
    local PG_SRC_DIR=$CLB_BASE_DIR/nexus2
    # one-time: https://github.com/sonatype/docker-nexus#persistent-data
    # mkdir $CLB_BASE_DIR/nexus2 && sudo chown -R 200 $CLB_BASE_DIR/nexus2

    docker run --rm\
    --name clb-nexus\
    -p 8081:8081\
    -v $CLB_BASE_DIR/nexus2:/sonatype-work:rw\
    -d sonatype/nexus:2.14.20-02

    #--user "$(id -u):$(id -g)"\
    #-v /etc/passwd:/etc/passwd:ro\
}

off-nexus () {
    docker stop clb-nexus
}
