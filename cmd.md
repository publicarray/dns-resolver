# Common commands for administering a DNS server

http://www.networksorcery.com/enp/protocol/dns.htm

## Ansible

Get facts: `ansible all -m setup -i hosts -u root`

Get facts-localhost: `ansible all -m setup -i "localhost," -c local`

## Sign message with keybase pgp key

https://keybase.io/docs/command_line

```bash
keybase pgp sign -i message.txt --clearsign > message.txt.asc
keybase pgp sign -i message.txt --detached # Signature only
keybase pgp verify -i message.txt.asc
```

### keybase signature

```bash
keybase sign -i message.txt -o message.txt.sig
keybase verify -i message.txt.sig 
```

## Networking

```sh
netstat -s

```

## dnsdist

https://dnsdist.org/

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
showDNSCryptBinds()
showTCPStats()
showRules()
showDynBlocks()
```

### actions/rules

http://dnsdist.org/rules-actions.html?highlight=addaction#packet-policies

```lua
showRules()

addAction({"0.0.0.0"}, TCAction())
addAction({"0.0.0.0"}, DropAction())
addAction({"0.0.0.0"}, TeeAction("8.8.8.8")) -- send queries to 8.8.8.8 and cache response
--addDomainSpoof("example.com", "127.0.0.1")
--addDomainBlock("example.com")
addAction("example.com", DropAction())

addDelay({"0.0.0.0", "example.com"}, 200)
addAction(makeRule("0.0.0.0"), DelayAction(200))

addAction(makeRule("0.0.0.0"), NoRecurseAction())
addNoRecurseRule("example.com")

addQPSLimit(makeRule("0.0.0.0"), 5)
addAction(MaxQPSIPRule(5), NoRecurseAction())
addAction("com.", QPSPoolAction(10000, "gtld-cluster"))

addAction(NotRule(QClassRule(1)), DropAction()) --Drop Queries that are not the internet class
addAction(OrRule{OpcodeRule(5), NotRule(QClassRule(1))}, DropAction()) --Drop Queries that are not the internet class or use the update command
addAction("example.com", RCodeAction(3)) --nxdomain for example.com
addAction(RegexRule("[0-9]{4,}\\.com$"), DropAction())

--addPoolRule("0.0.0.0", "abuse")
addAction({"0.0.0.0"}, PoolAction("abuse"))

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


## unbound

```sh
unbound-control get_option cache-min-ttl
unbound-control set_option cache-min-ttl: 60 # change option on the fly
unbound-control stats_noreset
unbound-control ratelimit_list
unbound-control ip_ratelimit_list
unbound-control dump_cache > unbound_cache
unbound-control reload
unbound-control load_cache < unbound_cache

unbound-host -v -f /usr/local/etc/unbound/root.key -t A example.com # useful for running a query through unbound
unbound-host -v -f /usr/local/etc/unbound/root.key -d -d -t A example.com # useful for debugging
drill -S example.com # chase signature(s)
```

## iptables

https://www.cyberciti.biz/tips/linux-iptables-examples.html

```sh
iptables -A INPUT -s 0.0.0.0 -j DROP -p udp
iptables -L -n -v
iptables -L --line-numbers
iptables -D INPUT 2
```


# Test DNS performance/load

https://github.com/cobblau/dnsperf

https://github.com/jedisct1/dnsblast

# DNS-over-(D)TLS

https://tools.ietf.org/html/rfc7858

https://datatracker.ietf.org/doc/draft-ietf-dprive-dtls-and-tls-profiles/

https://dnsprivacy.org/wiki/display/DP/DNS+Privacy+Implementation+Status

## Client:

https://dnsprivacy.org/wiki/display/DP/DNS+Privacy+Daemon+-+Stubby

https://getdnsapi.net/blog/dns-privacy-daemon-stubby/

https://getdnsapi.net/documentation/readme/

### Stubby

#### Stubby on MacOS

```sh
brew install stubby
```

Example stubby.yml

```yml
dns_transport_list: [GETDNS_TRANSPORT_TLS]
tls_authentication: GETDNS_AUTHENTICATION_REQUIRED
limit_outstanding_queries: 16
# EDNS0 option for keepalive idle timeout in ms as specified in
# https://tools.ietf.org/html/rfc7828 This keeps idle TLS connections open
idle_timeout: 60000 # 60 sec, 1 min
# Specify the timeout on getting a response to an individual request
timeout: 12000 # 12 sec (default 5s)
# Control the maximum number of connection failures that will be permitted
# before Stubby backs-off from using an individual upstream (default 2)
#tls_connection_retries: 5
listen_addresses:
  - 127.0.0.1@44
#  - 0::1@44
upstream_recursive_servers:
  - address_data: 45.76.113.31
    tls_auth_name: "dns.seby.io"
    tls_pubkey_pinset:
      - digest: "sha256"
        value: l2ZfXm/PituWJpi8lZwYqh9JREvmt6pmkYDcBUO9fK8=
  - address_data: 9.9.9.9
     tls_auth_name: "dns.quad9.net"
     tls_pubkey_pinset:
       - digest: "sha256"
         value: MujBQ+U0p2eZLTnQ2KGEqs+fPLYV/1DnpZDjBDPwUqQ=
```

Show all options and their current value, checks config file for syntax errors

```sh
stubby -i
```

## Linux TCP Fast Open


/etc/sysctl.conf

```
net.ipv4.tcp_fastopen = 3
```

```sh
# temp
echo "3" > /proc/sys/net/ipv4/tcp_fastopen
sudo sysctl -w net.ipv4.tcp_fastopen=3

# permanent
echo "net.ipv4.tcp_fastopen=3" > /etc/sysctl.d/30-tcp_fastopen.conf
sysctl --system
sysctl -p
reboot
cat /proc/sys/net/ipv4/tcp_fastopen

# monitor
grep '^TcpExt:' /proc/net/netstat | cut -d ' ' -f 87-92  | column -t
ip tcp_metrics show 127.0.0.1
ip tcp_metrics
```

## FreeBSD TCP Fast Open

/etc/sysctl.conf

```
net.inet.tcp.fastopen.enabled=1
```

See implementation file for more sysctl options: [sys/netinet/tcp_fastopen.c](https://svnweb.freebsd.org/base/head/sys/netinet/tcp_fastopen.c?view=markup)


### [Compile the kernel](https://www.freebsd.org/doc/en/books/handbook/kernelconfig-building.html) with MYKERNEL file

Use something like `pkg install subversion && svn co https://svn.FreeBSD.org/base/releng/$(freebsd-version | awk -F '-' '{print $1}')/usr/src` to get the source.

/usr/src/sys/amd64/conf/MYKERNEL

```sh
include GENERIC
ident MYKERNEL

# TFO TCP Fast Open TCP_FASTOPEN (enable with `sysctl -w net.inet.tcp.fastopen.enabled=1`)
options         TCP_RFC7413
```

**Note**

Don't forget to edit the `/etc/freebsd-update.conf` file to prevent a routine `freebsd-update fetch install` overwriting our custom kernel with the Generic kernel.

/etc/freebsd-update.conf
```
Components src world
```
