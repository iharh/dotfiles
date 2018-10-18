on-zk () {
    docker run --rm\
      --name clb-zk\
      -p 2181:2181\
      -d gcr.io/cb-images/cb-zookeeper:3.4.13
}

off-zk() {
    docker stop clb-zk
}

on-kafka () {
    # enp2s0 - home, enp0s8 - wrk, vb
    local ADV_HOST=$(ip -o -4 a | cut -d ' ' -f 2,7 | grep enp | head -1 | cut -d ' ' -f 2 | cut -d '/' -f 1)
    docker run --rm\
      --name clb-kafka\
      -p 9092:9092\
      --env KAFKA_ZOOKEEPER_CONNECT=$ADV_HOST:2181\
      --env KAFKA_ADVERTISED_LISTENERS=PLAINTEXT://$ADV_HOST:9092\
      -d gcr.io/cb-images/cb-kafka:1.1.1
}

off-kafka() {
    docker stop clb-kafka
}
