## ansible

Get facts: `ansible all -m setup -i hosts -u root`

## dnsdist

http://www.networksorcery.com/enp/protocol/dns.htm
http://dnsdist.org/README/

### stats

```lua
showVersion()
showServers()
dumpStats()
getPool(""):getCache():printStats()
showResponseLatency()
topQueries(20)
topClients(5)
topBandwidth(10)
-- https://www.iana.org/assignments/dns-parameters/dns-parameters.xhtml
topResponses(20, 3) -- NXDOMAIN = 3
topResponses(20, 2) -- SERVFAIL = 2
grepq("0.0.0.0", 25)
```

### actions/rules

```lua
showRules()

addAction(makeRule("0.0.0.0"), TCAction())
addAction(makeRule("0.0.0.0"), DropAction())
addAction(makeRule("0.0.0.0"), TeeAction("8.8.8.8")) -- send queries to 8.8.8.8 and cache response
addDomainSpoof("example.com", "127.0.0.1")
addDomainBlock("google.com")

addDelay({"0.0.0.0", "example.com"}, 200)
addAction(makeRule("0.0.0.0"), DelayAction(200))

addAction(makeRule("0.0.0.0"), NoRecurseAction())
addNoRecurseRule("example.com")

addQPSLimit(makeRule("0.0.0.0"), 5)
addAction(MaxQPSIPRule(5), NoRecurseAction())

addAction(NotRule(QClassRule(1)), DropAction()) --Drop Queries that are not the internet class
addAction(OrRule{OpcodeRule(5), NotRule(QClassRule(1))}, DropAction()) --Drop Queries that are not the internet class or update command
addAction("10.in-addr.arpa.", RCodeAction(3)) --nxdomain for private ips 10.0.0.0/8

rmRule(2)
```

## iptables

https://www.cyberciti.biz/tips/linux-iptables-examples.html

```sh
iptables -A INPUT -s 0.0.0.0 -j DROP -p udp
iptables -L -n -v
iptables -L --line-numbers
iptables -D INPUT 2
```
