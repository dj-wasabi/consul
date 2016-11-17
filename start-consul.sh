#!/usr/bin/env bash

cat <<EOF > /consul/config/config.json
{
	"data_dir": "/consul/data",
	"domain": "dj-wasabi.local",
	"ui_dir": "/consul/ui",
	"log_level": "INFO",
	"client_addr": "0.0.0.0",
	"ports": {
		"dns": 53
	},
	"recursor": "8.8.8.8",
	"disable_update_check": true,
    "dns_config": {
      "allow_stale": true,
      "max_stale": "${DNS_MAX_STALE:-2}s",
      "node_ttl": "${DNS_NODE_TTL:-30}s",
      "service_ttl": {
        "*": "${DNS_SERVICE_TTL:-10}s"
      }
    }
}
EOF

main() {
	set -eo pipefail
	case "$1" in
	*)           exec /bin/consul agent -config-dir=/consul/config $@;;
	esac
}

main "$@"
