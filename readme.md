# Open DNS Resolver with DNSCrypt

## Usage

```sh
$ ansible-galaxy install -r requirements.yml
$ ansible-playbook playbook.yml -i hosts --diff
```

### Checks
```sh
$ ansible-playbook playbook.yml -i hosts --syntax-check
$ ansible-playbook playbook.yml -i hosts --check --diff
```

## Post install

Generate new keys (optional - this is done automatically)

```sh
$ service dnsdist stop
$ dnsdist

> generateDNSCryptProviderKeys("/etc/dnsdist/providerPublic.key", "/etc/dnsdist/providerPrivate.key")
> generateDNSCryptCertificate("/etc/dnsdist/providerPrivate.key", "/etc/dnsdist/resolver.cert.0", "/etc/dnsdist/resolver.key.0", 0, os.time(), os.time()+(365*86400))
> shutdown()

$ service dnsdist start
```

Get DNScrypt provider fingerprint

```sh
$ dnsdist --client

> printDNSCryptProviderFingerprint("/etc/dnsdist/providerPublic.key")
> quit
```

# Test

## with [molecule](https://molecule.readthedocs.io/)

### [first time setup](https://molecule.readthedocs.io/en/master/usage.html)

```sh
pip install molecule # or brew install molecule
# molecule init --driver <yourdriver>
# brew install docker # or brew cask install vagrant virtualbox
```

```sh
molecule test
```

## with docker

```sh
docker build -f docker/Dockerfile-ubuntu16.04 -t dns-ubuntu16.04 .
```
