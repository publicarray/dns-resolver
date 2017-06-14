# Open DNS Resolver with DNSCrypt

## Usage

```sh
$ ansible-galaxy install -r requirements.yml
$ ansible-playbook site.yml -i hosts --diff
```

### Checks
```sh
$ ansible-playbook site.yml -i hosts --syntax-check
$ ansible-playbook site.yml -i hosts --check --diff
```


## TODO auto certificate rotations

## Post install

Generate new keys (optional - this is done automatically)

```sh
$ service dnsdist stop
$ dnsdist

> generateDNSCryptProviderKeys("/etc/dnsdist/providerPublic.key", "/etc/dnsdist/providerPrivate.key")
> generateDNSCryptCertificate("/etc/dnsdist/providerPrivate.key", "/etc/dnsdist/resolver.cert", "/etc/dnsdist/resolver.key", 0, os.time(), os.time()+(365*86400))
> shutdown()

$ service dnsdist start
```

Get DNScrypt provider fingerprint

```sh
$ dnsdist --client

> printDNSCryptProviderFingerprint("/etc/dnsdist/providerPublic.key")
> quit
```

## Renew cert (required to do this one a year)

```sh 
$ service dnsdist stop
$ dnsdist

> generateDNSCryptCertificate("/etc/dnsdist/providerPrivate.key", "/etc/dnsdist/resolver.cert", "/etc/dnsdist/resolver.key", 0, os.time(), os.time()+(365*86400))
> shutdown()

$ service dnsdist start

```
