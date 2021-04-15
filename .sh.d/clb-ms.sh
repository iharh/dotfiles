export CLB_DIM_DIR=$CLB_BASE_DIR/docker-images

# common

gcr-img() {
    local IMG_ID="${1// }"
    if [[ -z $IMG_ID ]]; then
        echo "IMG_ID is EMPTY - skip listing"
    else
        gcloud container images list-tags gcr.io/cb-images/$IMG_ID  --format="table[box](TAGS,TIMESTAMP)"
    fi
}

# lttoolbox-bn

gcr-img-ltt-bn() {
    gcr-img cb-nlp-bn-lttoolbox
}

on-ltt-bn() {
    docker run --rm\
        -d --name clb-lttoolbox-service-bn \
        -p 8091:8080 -p 9099:9090 \
        gcr.io/cb-images/cb-nlp-bn-lttoolbox:0.8.0

        #cb-nlp-bn-lttoolbox:latest
}

off-ltt-bn() {
    docker stop clb-lttoolbox-service-bn
}

# spacy

gcr-img-spacy-pl() {
    gcr-img cb-nlp-spacy-service-pl
}

on-spacy-pl() {
    # -ti\
    docker run --rm\
        -d --name clb-spacy-pl\
        -p 8089:8089\
        gcr.io/cb-images/cb-nlp-spacy-service-pl:0.2.0-2ceb112

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

#curl -H "Content-Type:application/octet-stream" --data "CiBubHAtc3BhY3ktdGVzdGluZy1wb2xpc2gtcmVxdWVzdBI+CgYKBFBpZXMKBAoCamUKCgoId8WCb3NrxIUKCAoGcGl6esSZCgMKAXoKDgoMTm93ZWdvIEpvcmt1CgMKAS4SWwoDCgFXCggKBlBvbHNjZQoGCgR6aW1hCgYKBGplc3QKCAoGZMWCdWdhCgMKASwKBQoDYWxlCggKBmx1ZHppZQoMCgpyb3pncnplasSFCgcKBXNlcmNlCgMKASE=" http://localhost:8089/api/process

# "CiBubHAtc3BhY3ktdGVzdGluZy1wb2xpc2gtcmVxdWVzdBKUAQoSCgRQaWVzEgRQSUVTGAYoBDAbCg4KAmplEgJPThgQKAQwHQoZCgh3xYJvc2vEhRIHV8WBT1NLSRgBKAIwBAoTCgZwaXp6xJkSBVBJWlpBGAYwIwoMCgF6EgFaGAIoBjAHCiIKDE5vd2VnbyBKb3JrdRIMTk9XRUdPIEpPUktVGAYoBDAeCgwKAS4SAS4YEigEMCES5wEKDAoBVxIBVxgCKAIwBwoWCgZQb2xzY2USBlBPTFNLQRgGKAUwHgoSCgR6aW1hEgRaSU1BGAYoBTAbChcKBGplc3QSBEpFU1QYCyIDHCIWKAUwDQoUCgZkxYJ1Z2ESBkTFgVVHSRgBMCMKDAoBLBIBLBgSKAkwIQoQCgNhbGUSA0FMRRgMKAkwCAoTCgZsdWR6aWUSA0xVRBgGKAkwGwojCgpyb3pncnplasSFEgpST1pHUlpFSsSEGAoiAxwiFigFMAwKFAoFc2VyY2USBVNFUkNFGAYoCTAdCgwKASESASEYEigFMCE="

# TF

# clients shoud define the following env vars:
# export CB_NLP_TENSORFLOW_SYN_HOST=<hostname>
# export CB_NLP_TENSORFLOW_SYN_PORT=8500
# export CB_NLP_TENSORFLOW_SYN_BATCHSIZE=500
    #   bash -c "cd /opt/ud-research; pwd; ls -la models"

gcr-img-tf() {
    gcr-img cb-nlp-tf-dragnn-server-cpu
}

on-tf() {
    local LP_ID="${1// }"
    if [[ -z $LP_ID ]]; then
        echo "LP_ID is EMPTY - skip starting"
    else
        docker run --rm\
            --name clb-tf-$LP_ID\
            -p 8500:8500\
            -d gcr.io/cb-images/cb-nlp-tf-dragnn-server-cpu:0.15\
            tensorflow_model_server \
                --enable_batching \
                --model_config_file=models/model_config_$LP_ID.txt \
                --batching_parameters_file=models/batching_config.txt
    fi
}

on-tf-hi() {
    on-tf hi
}

off-tf-hi () {
    docker stop clb-tf-hi
}

on-tf-fr() {
    on-tf fr
}

off-tf-fr () {
    docker stop clb-tf-fr
}

on-tf-sv() {
    on-tf sv
}

off-tf-sv () {
    docker stop clb-tf-sv
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

put-cluster-settings-es() {
    curl -XPUT -H "Content-Type: application/json" http://localhost:9200/_cluster/settings \
        -d '{"persistent": {"cb.classification.kafka.bootstrap.servers": "ihdesk:9092"}}'
}

# ernie

doc-build-ernie() {
    (cd $CLB_DIM_DIR/cb-nlp-ernie;\
        docker build -t cb-nlp/cb-nlp-ernie:latest --pull .
    )
}

doc-build-ernie-serving() {
    (cd $CLB_DIM_DIR/cb-nlp-ernie-serving;\
        docker build -t cb-nlp/cb-nlp-ernie-serving:latest --pull .
    )
}

on-ernie() {
    (cd $CLB_MST_DIR/compose/ernie;\
        ./dco-up.sh
    )
}

off-ernie() {
    (cd $CLB_MST_DIR/compose/ernie;\
        ./dco-down.sh
    )
}

make-ernie-tmp() {
    docker exec -it ernie mkdir server/tmp
}

# chapters

on-chapters() {
    (cd $CLB_BASE_DIR/nlp-chapters-service;\
        docker-compose -f docker-compose.dev.yml up -d
    )
}

off-chapters() {
    (cd $CLB_BASE_DIR/nlp-chapters-service;\
        docker-compose -f docker-compose.dev.yml down
    )
}
