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

Install cert (expires in one year)

```sh
# $ service dnsdist stop
$ dnsdist --client

# > generateDNSCryptProviderKeys("/etc/dnsdist/providerPublic.key", "/etc/dnsdist/providerPrivate.key")
# > generateDNSCryptCertificate("/etc/dnsdist/providerPrivate.key", "/etc/dnsdist/resolver.cert", "/etc/dnsdist/resolver.key", 0, os.time(), os.time()+(365*86400))
> printDNSCryptProviderFingerprint("/etc/dnsdist/providerPublic.key")
> quit
# > shutdown()

# $ service dnsdist start

```

## Renew cert

```sh 
$ service dnsdist stop
$ dnsdist

> generateDNSCryptCertificate("/etc/dnsdist/providerPrivate.key", "/etc/dnsdist/resolver.cert", "/etc/dnsdist/resolver.key", 0, os.time(), os.time()+(365*86400))
> shutdown()

$ service dnsdist start

```
