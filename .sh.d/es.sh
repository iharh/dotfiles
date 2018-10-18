on-es () {
    # latest
    # new ver of es do not require es.-prefix
    docker run -d -p 9200:9200 -p 9300:9300  docker-registry.clarabridge.net:5000/cb_plat/cb-elasticsearch:cb-7.1.18.6 elasticsearch -Des.cluster.name=es_cluster -Des.node.name=es_node -Dcb.classification.kafka.bootstrap.servers=192.168.235.101:9092
}
