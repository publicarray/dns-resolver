## ansible

Get facts: `ansible all -m setup -i hosts -u root`
Get facts-localhost: `ansible all -m setup -i "localhost," -c local`

## dnsdist

http://www.networksorcery.com/enp/protocol/dns.htm
http://dnsdist.org/README/

### stats/debugging

```lua
showVersion()
showServers()
dumpStats()
getPool(""):getCache():printStats()
showResponseLatency()
topQueries(10)
topSlow(10)
topClients(5)
topBandwidth(10)
-- https://www.iana.org/assignments/dns-parameters/dns-parameters.xhtml
topResponses(20) -- SERVFAIL = 2
topResponses(20, 3) -- NXDOMAIN = 3
grepq("0.0.0.0", 25)
grepq("2000ms", 25)
grepq("", 10) -- last 10 queries
showBinds()
showTCPStats()
showRules()
showDynBlocks()
```

### actions/rules

```lua
showRules()

addAction(makeRule("0.0.0.0"), TCAction())
addAction(makeRule("0.0.0.0"), DropAction())
addAction(makeRule("0.0.0.0"), TeeAction("8.8.8.8")) -- send queries to 8.8.8.8 and cache response
addDomainSpoof("example.com", "127.0.0.1")
addDomainBlock("exmple.com")

addDelay({"0.0.0.0", "example.com"}, 200)
addAction(makeRule("0.0.0.0"), DelayAction(200))

addAction(makeRule("0.0.0.0"), NoRecurseAction())
addNoRecurseRule("example.com")

addQPSLimit(makeRule("0.0.0.0"), 5)
addAction(MaxQPSIPRule(5), NoRecurseAction())

addAction(NotRule(QClassRule(1)), DropAction()) --Drop Queries that are not the internet class
addAction(OrRule{OpcodeRule(5), NotRule(QClassRule(1))}, DropAction()) --Drop Queries that are not the internet class or use the update command
addAction("example.com", RCodeAction(3)) --nxdomain for example.com
addAction(RegexRule("[0-9]{4,}\\.cn$"), DropAction())

rmRule(2)
mvRule(from, to)
```

### dynamic rules

```lua
-- This blocks IP addresses doing more than 10 queries/s over 10 seconds
function maintenance()
    addDynBlocks(exceedQRate(10, 10), "Exceeded query rate", 60)
end

exceedServFails(rate, seconds) -- exceed rate servails/s over seconds seconds
exceedNXDOMAINs(rate, seconds) -- exceed rate NXDOMAIN/s over seconds seconds
exceedRespByterate(rate, seconds) -- exeeded rate bytes/s answers over seconds seconds
exceedQTypeRate(type, rate, seconds) -- exceed rate queries/s for queries of type type over seconds seconds
```

## iptables

https://www.cyberciti.biz/tips/linux-iptables-examples.html

```sh
iptables -A INPUT -s 0.0.0.0 -j DROP -p udp
iptables -L -n -v
iptables -L --line-numbers
iptables -D INPUT 2
```

# Test DNS

https://pkgs.org/download/dnsperf


# DNS-over-(D)TLS

https://tools.ietf.org/html/rfc7858

https://datatracker.ietf.org/doc/draft-ietf-dprive-dtls-and-tls-profiles/

https://dnsprivacy.org/wiki/display/DP/DNS+Privacy+Implementation+Status

## Client:

https://dnsprivacy.org/wiki/display/DP/DNS+Privacy+Daemon+-+Stubby

https://getdnsapi.net/blog/dns-privacy-daemon-stubby/

https://getdnsapi.net/documentation/readme/

```sh
brew install getdns --with-libuv --with-libev
sudo nano /etc/stubby.conf 
```

/etc/stubby.conf 


```json
{ resolution_type: GETDNS_RESOLUTION_STUB
, dns_transport_list: [ GETDNS_TRANSPORT_TLS ]
, tls_authentication: GETDNS_AUTHENTICATION_REQUIRED
, tls_connection_retries: 9999999999
, tls_query_padding_blocksize: 256
, edns_client_subnet_private : 1
, idle_timeout: 10000
, listen_addresses: 
  [ { address_data: 127.0.0.1
    , address_type: "IPv4"
    , port: 60
    , tls_port: 60
  },
  { address_data: 0::1
    , address_type: "IPv6"
    , port: 60
    , tls_port: 60
  }, ]
, round_robin_upstreams: 1
, upstream_recursive_servers:
  [ { address_data: 45.76.113.31
    , tls_auth_name: "dns.seby.io"
    , tls_pubkey_pinset:
      [ { digest: "sha256"
        , value: u8HJKdVlrkl0cz7C9wETsvWGtwoB4WhZ8QXW+ky3E/s=
      } ]
    }
  ]
}

```

```sh
stubby -i

stubby -h
getdns_query -h
```

~/Library/LaunchAgents/stubby.plist            

```
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple$
<plist version="1.0">
  <dict>
    <key>Label</key>
    <string>stubby</string>
    <key>ProgramArguments</key>
    <array>
      <string>/usr/local/bin/stubby</string>
      <string>-C</string>
      <string>/etc/stubby.conf</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
  </dict>
</plist>
```

```
launchctl load -w ~/Library/LaunchAgents/stubby.plist
```

## Recurser:

https://dnsprivacy.org/wiki/display/DP/Running+a+DNS+Privacy+server

### haproxy

```sh
yum -y install haproxy
```

semanage port -a -t commplex_main_port_t -p tcp 853
/etc/haproxy/haproxy.cfg 

```
global
log 127.0.0.1 user warning
chroot /var/lib/haproxy
user haproxy
group haproxy
daemon
maxconn 4000 
#maxconn 1024
pidfile /var/run/haproxy.pid
tune.ssl.default-dh-param 2048
ssl-default-bind-ciphers ECDHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384
ssl-default-bind-options force-tlsv12
 
   # Default SSL material locations
   ca-base /etc/ssl/certs
   crt-base /etc/ssl/private
defaults
    log global
    mode tcp
    balance roundrobin
    timeout http-request 10s
    timeout queue 1m
    timeout connect 10s
    timeout client 1m
    timeout server 1m
    timeout http-keep-alive 1m
    timeout check 10s

listen dns
    log global
    option tcplog
    bind 0.0.0.0:853 ssl crt /etc/haproxy/dns.seby.io/certkey.pem
    server server1 127.0.0.1:56
```

#### certs

```sh
wget https://raw.githubusercontent.com/lukas2511/dehydrated/master/dehydrated
chmod +x ./dehydrated
mkdir /etc/dehydrated

yum -y install python-pip gcc python-dev curl libffi-dev openssl-devel
# pip install requests[security]
pip install dns-lexicon

```

/etc/dehydrated/config or /usr/local/etc/dehydrated/config

```
CA="https://acme-v01.api.letsencrypt.org/directory"
#CA="https://acme-staging.api.letsencrypt.org/directory"
LICENSE="https://letsencrypt.org/documents/LE-SA-v1.1.1-August-1-2016.pdf"
CERTDIR=/etc/haproxy
CHALLENGETYPE="dns-01"
HOOK=/etc/dehydrated/hook.sh
PRIVATE_KEY_RENEW="no"
PRIVATE_KEY_ROLLOVER="no"
#CONTACT_EMAIL=alice@example.com
export PROVIDER=cloudflare
export LEXICON_CLOUDFLARE_USERNAME=example@domain.com
export LEXICON_CLOUDFLARE_TOKEN=
```

/etc/dehydrated/hook.sh

source: https://blog.thesparktree.com/generating-intranet-and-private-network-ssl

```
#!/usr/bin/env bash
#
# Example how to deploy a DNS challange using lexicon

set -e
set -u
set -o pipefail

export PROVIDER=${PROVIDER:-"cloudflare"}

function deploy_challenge {
    local DOMAIN="${1}" TOKEN_FILENAME="${2}" TOKEN_VALUE="${3}"

    echo "deploy_challenge called: ${DOMAIN}, ${TOKEN_FILENAME}, ${TOKEN_VALUE}"

    lexicon $PROVIDER create ${DOMAIN} TXT --name="_acme-challenge.${DOMAIN}." --content="${TOKEN_VALUE}"

    sleep 30

    # This hook is called once for every domain that needs to be
    # validated, including any alternative names you may have listed.
    #
    # Parameters:
    # - DOMAIN
    #   The domain name (CN or subject alternative name) being
    #   validated.
    # - TOKEN_FILENAME
    #   The name of the file containing the token to be served for HTTP
    #   validation. Should be served by your web server as
    #   /.well-known/acme-challenge/${TOKEN_FILENAME}.
    # - TOKEN_VALUE
    #   The token value that needs to be served for validation. For DNS
    #   validation, this is what you want to put in the _acme-challenge
    #   TXT record. For HTTP validation it is the value that is expected
    #   be found in the $TOKEN_FILENAME file.
}

function clean_challenge {
    local DOMAIN="${1}" TOKEN_FILENAME="${2}" TOKEN_VALUE="${3}"

    echo "clean_challenge called: ${DOMAIN}, ${TOKEN_FILENAME}, ${TOKEN_VALUE}"

    lexicon $PROVIDER delete ${DOMAIN} TXT --name="_acme-challenge.${DOMAIN}." --content="${TOKEN_VALUE}"

    # This hook is called after attempting to validate each domain,
    # whether or not validation was successful. Here you can delete
    # files or DNS records that are no longer needed.
    #
    # The parameters are the same as for deploy_challenge.
}

function deploy_cert {
    local DOMAIN="${1}" KEYFILE="${2}" CERTFILE="${3}" FULLCHAINFILE="${4}" CHAINFILE="${5}"

    echo "deploy_cert called: ${DOMAIN}, ${KEYFILE}, ${CERTFILE}, ${FULLCHAINFILE}, ${CHAINFILE}"

    # This hook is called once for each certificate that has been
    # produced. Here you might, for instance, copy your new certificates
    # to service-specific locations and reload the service.
    #
    # Parameters:
    # - DOMAIN
    #   The primary domain name, i.e. the certificate common
    #   name (CN).
    # - KEYFILE
    #   The path of the file containing the private key.
    # - CERTFILE
    #   The path of the file containing the signed certificate.
    # - FULLCHAINFILE
    #   The path of the file containing the full certificate chain.
    # - CHAINFILE
    #   The path of the file containing the intermediate certificate(s).
}

function unchanged_cert {
    local DOMAIN="${1}" KEYFILE="${2}" CERTFILE="${3}" FULLCHAINFILE="${4}" CHAINFILE="${5}"

    echo "unchanged_cert called: ${DOMAIN}, ${KEYFILE}, ${CERTFILE}, ${FULLCHAINFILE}, ${CHAINFILE}"

    # This hook is called once for each certificate that is still
    # valid and therefore wasn't reissued.
    #
    # Parameters:
    # - DOMAIN
    #   The primary domain name, i.e. the certificate common
    #   name (CN).
    # - KEYFILE
    #   The path of the file containing the private key.
    # - CERTFILE
    #   The path of the file containing the signed certificate.
    # - FULLCHAINFILE
    #   The path of the file containing the full certificate chain.
    # - CHAINFILE
    #   The path of the file containing the intermediate certificate(s).
}

exit_hook() {
  # This hook is called at the end of a dehydrated command and can be used
  # to do some final (cleanup or other) tasks.

  :
}

HANDLER=$1; shift; $HANDLER "$@"
```

/etc/dehydrated/domains.txt

```
dns.seby.io www.dns.seby.io
```

```sh
./dehydrated -c
cat /etc/haproxy/dns.seby.io/fullchain.pem /etc/haproxy/dns.seby.io/privkey.pem  > /etc/haproxy/dns.seby.io/certkey.pem
```
https://report-uri.io/home/pubkey_hash

#### haproxy logs 

/etc/rsyslog.conf 

```
# Provides UDP syslog reception
$ModLoad imudp
$UDPServerAddress 127.0.0.1
$UDPServerRun 514
```

```
service rsyslog restart
```


## Test

https://dnsprivacy.org/wiki/display/DP/DNS+Privacy+Test+Servers

https://github.com/Sinodun/dnsperf-tcp



### TCP fast open


/etc/sysctl.conf

```
net.ipv4.tcp_fastopen = 3
```

```sh
echo "3" > /proc/sys/net/ipv4/tcp_fastopen
sudo sysctl -w net.ipv4.tcp_fastopen=3
echo "net.ipv4.tcp_fastopen=3" > /etc/sysctl.d/30-tcp_fastopen.conf
sysctl --system
sysctl -p
reboot
cat /proc/sys/net/ipv4/tcp_fastopen
```
