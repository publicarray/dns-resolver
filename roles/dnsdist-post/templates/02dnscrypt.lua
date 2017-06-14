{{ ansible_managed | comment('plain', prefix='--[[', postfix='--]]') }}

--DNSCrypt / DNSCurve
--Generate Keys only once
if file_exists("/etc/dnsdist/providerPrivate.key") == false
then
  generateDNSCryptProviderKeys("/etc/dnsdist/providerPublic.key", "/etc/dnsdist/providerPrivate.key")
end

--Generate Cert (Expires in 1 Year!)
if file_exists("/etc/dnsdist/resolver.cert") == false
then
  generateDNSCryptCertificate("/etc/dnsdist/providerPrivate.key", "/etc/dnsdist/resolver.cert", "/etc/dnsdist/resolver.key", 0, os.time(), os.time()+(365*86400))
end

--Open ports / Listening for clients
addDNSCryptBind("{{ansible_default_ipv4.address}}:54", "{{dnscrypt_provider_name}}", "/etc/dnsdist/resolver.cert", "/etc/dnsdist/resolver.key")
addDNSCryptBind("{{ansible_default_ipv4.address}}:443", "{{dnscrypt_provider_name}}", "/etc/dnsdist/resolver.cert", "/etc/dnsdist/resolver.key")
addDNSCryptBind("{{ansible_default_ipv4.address}}:1053", "{{dnscrypt_provider_name}}", "/etc/dnsdist/resolver.cert", "/etc/dnsdist/resolver.key")
addDNSCryptBind("{{ansible_default_ipv4.address}}:1194", "{{dnscrypt_provider_name}}", "/etc/dnsdist/resolver.cert", "/etc/dnsdist/resolver.key")
addDNSCryptBind("{{ansible_default_ipv4.address}}:5353", "{{dnscrypt_provider_name}}", "/etc/dnsdist/resolver.cert", "/etc/dnsdist/resolver.key")
addDNSCryptBind("{{ansible_default_ipv4.address}}:8080", "{{dnscrypt_provider_name}}", "/etc/dnsdist/resolver.cert", "/etc/dnsdist/resolver.key")
addDNSCryptBind("{{ansible_default_ipv4.address}}:27015", "{{dnscrypt_provider_name}}", "/etc/dnsdist/resolver.cert", "/etc/dnsdist/resolver.key")
