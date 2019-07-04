COUNT="${1:-1}"
REPLICATION="${2:-1}"

trap 'kill -9 $(jobs -p); exit 0' EXIT

generate_hashrings_file() {
    local addresses=""
    local i=0
    while [ "$i" -lt "$COUNT" ]; do
        [ "$addresses" != "" ] && addresses="$addresses"", "
        addresses="$addresses""\"http://127.0.0.1:$((19291 +i))/api/v1/receive\""
        i=$((i + 1))
    done

    printf '[{\"endpoints\": [%s]}]' "$addresses"
}

store_addresses=""
i=0
while [ "$i" -lt "$COUNT" ]; do
    (
    mkdir -p ./receive_"$i"
    generate_hashrings_file > ./receive_"$i"/hashrings.json
    thanos receive \
        --debug.name remote-write-receive-"$i" \
        --grpc-address 127.0.0.1:$((18790 + i)) \
        --http-address 127.0.0.1:$((18890 + i)) \
        --remote-write.address 127.0.0.1:$((19291 +i)) \
        --labels receive='"true"' \
        --labels replica="\"$i\"" \
        --tsdb.path ./receive_"$i" \
        --log.level debug \
        --receive.local-endpoint http://127.0.0.1:$((19291 +i))/api/v1/receive \
        --receive.hashrings-file=./receive_"$i"/hashrings.json \
        --receive.replication-factor "$REPLICATION"
    ) &
    store_addresses="$store_addresses --store=127.0.0.1:$((18790 + i))"
    i=$((i + 1))
done

# (
# thanos query \
#     --debug.name query \
#     --grpc-address 127.0.0.1:19490 \
#     --http-address 127.0.0.1:19590 \
#     --log.level debug \
#     --query.replica-label replica \
#     --store.sd-dns-interval 5s \
#     $store_addresses
# ) &

for i in $(jobs -p); do wait "$i"; done
