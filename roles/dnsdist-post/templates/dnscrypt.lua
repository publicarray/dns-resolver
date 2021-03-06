{{ ansible_managed | comment('plain', prefix='--[[', postfix='--]]') }}

--utility function
function file_exists(name)
  local f=io.open(name,"r")
  if f==nil then return false else f:close() return true end
end

--DNSCrypt / DNSCurve
--Generate Keys only once
if file_exists("/etc/dnsdist/providerPrivate.key") == false
then
  generateDNSCryptProviderKeys("/etc/dnsdist/providerPublic.key", "/etc/dnsdist/providerPrivate.key")
end

--Generate init Cert (Expires in 24 hours!)
last = os.time()
generateDNSCryptCertificate("/etc/dnsdist/providerPrivate.key", "/etc/dnsdist/resolver.cert.0", "/etc/dnsdist/resolver.key.0", last, last - 60 , last + 86340)
{#
{%- if ansible_default_ipv4.address is defined %}
{%- set ip = ansible_default_ipv4.address %}
{%- else %}
{%- set ip = '0.0.0.0' %}
{%- endif %}
#}

{%- set ip = '0.0.0.0' %}

{%- if ansible_default_ipv6.address is defined %}
{%- set ip6 = ansible_default_ipv6.address %}
{%- else %}
{%- set ip6 = '::0' %}
{%- endif %}
--Open ports / Listening for clients
-- addDNSCryptBind("{{ip}}:54", "{{dnscrypt_provider_name}}", "/etc/dnsdist/resolver.cert.0", "/etc/dnsdist/resolver.key.0")
addDNSCryptBind("{{ip}}:443", "{{dnscrypt_provider_name}}", "/etc/dnsdist/resolver.cert.0", "/etc/dnsdist/resolver.key.0")
addDNSCryptBind("[{{ip6}}]:443", "{{dnscrypt_provider_name}}", "/etc/dnsdist/resolver.cert.0", "/etc/dnsdist/resolver.key.0")
-- addDNSCryptBind("{{ip}}:1053", "{{dnscrypt_provider_name}}", "/etc/dnsdist/resolver.cert.0", "/etc/dnsdist/resolver.key.0")
-- addDNSCryptBind("{{ip}}:1194", "{{dnscrypt_provider_name}}", "/etc/dnsdist/resolver.cert.0", "/etc/dnsdist/resolver.key.0")
addDNSCryptBind("{{ip}}:5353", "{{dnscrypt_provider_name}}", "/etc/dnsdist/resolver.cert.0", "/etc/dnsdist/resolver.key.0")
addDNSCryptBind("[{{ip6}}]:5353", "{{dnscrypt_provider_name}}", "/etc/dnsdist/resolver.cert.0", "/etc/dnsdist/resolver.key.0")
addDNSCryptBind("{{ip}}:8080", "{{dnscrypt_provider_name}}", "/etc/dnsdist/resolver.cert.0", "/etc/dnsdist/resolver.key.0")
addDNSCryptBind("[{{ip6}}]:8080", "{{dnscrypt_provider_name}}", "/etc/dnsdist/resolver.cert.0", "/etc/dnsdist/resolver.key.0")
-- addDNSCryptBind("{{ip}}:27015", "{{dnscrypt_provider_name}}", "/etc/dnsdist/resolver.cert.0", "/etc/dnsdist/resolver.key.0")

function autoRenewCert() -- called approx. every second in maintenance function

  -- (60*60*23) - 300 = 82500 (23 hours)  - 1 hour for clients to update cert + clock diff of 5 min
  -- 60*60*24 - 60 = 86340 (24 hours) -- cert expires in 24 - clock diff of 1 min
  local now = os.time()
  local diff = now - last
  if (diff > 82500) then

    getDNSCryptBind(0):generateAndLoadInMemoryCertificate("/etc/dnsdist/providerPrivate.key", now, now - 60, now + 86340)
    getDNSCryptBind(1):generateAndLoadInMemoryCertificate("/etc/dnsdist/providerPrivate.key", now, now - 60, now + 86340)
    getDNSCryptBind(2):generateAndLoadInMemoryCertificate("/etc/dnsdist/providerPrivate.key", now, now - 60, now + 86340)
    getDNSCryptBind(3):generateAndLoadInMemoryCertificate("/etc/dnsdist/providerPrivate.key", now, now - 60, now + 86340)
    getDNSCryptBind(4):generateAndLoadInMemoryCertificate("/etc/dnsdist/providerPrivate.key", now, now - 60, now + 86340)
    getDNSCryptBind(5):generateAndLoadInMemoryCertificate("/etc/dnsdist/providerPrivate.key", now, now - 60, now + 86340)
    -- getDNSCryptBind(6):generateAndLoadInMemoryCertificate("/etc/dnsdist/providerPrivate.key", now, now - 60, now + 86340)
    -- getDNSCryptBind(7):generateAndLoadInMemoryCertificate("/etc/dnsdist/providerPrivate.key", now, now - 60, now + 86340)
    last = now
  end
end
