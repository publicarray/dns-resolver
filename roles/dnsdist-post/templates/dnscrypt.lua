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
generateDNSCryptCertificate("/etc/dnsdist/providerPrivate.key", "/etc/dnsdist/resolver.cert.0", "/etc/dnsdist/resolver.key.0", 0, os.time() - 60 , os.time() + 86340)

--Open ports / Listening for clients
-- addDNSCryptBind("{{ansible_default_ipv4.address}}:54", "{{dnscrypt_provider_name}}", "/etc/dnsdist/resolver.cert.0", "/etc/dnsdist/resolver.key.0")
addDNSCryptBind("{{ansible_default_ipv4.address}}:443", "{{dnscrypt_provider_name}}", "/etc/dnsdist/resolver.cert.0", "/etc/dnsdist/resolver.key.0")
-- addDNSCryptBind("{{ansible_default_ipv4.address}}:1053", "{{dnscrypt_provider_name}}", "/etc/dnsdist/resolver.cert.0", "/etc/dnsdist/resolver.key.0")
-- addDNSCryptBind("{{ansible_default_ipv4.address}}:1194", "{{dnscrypt_provider_name}}", "/etc/dnsdist/resolver.cert.0", "/etc/dnsdist/resolver.key.0")
addDNSCryptBind("{{ansible_default_ipv4.address}}:5353", "{{dnscrypt_provider_name}}", "/etc/dnsdist/resolver.cert.0", "/etc/dnsdist/resolver.key.0")
addDNSCryptBind("{{ansible_default_ipv4.address}}:8080", "{{dnscrypt_provider_name}}", "/etc/dnsdist/resolver.cert.0", "/etc/dnsdist/resolver.key.0")
-- addDNSCryptBind("{{ansible_default_ipv4.address}}:27015", "{{dnscrypt_provider_name}}", "/etc/dnsdist/resolver.cert.0", "/etc/dnsdist/resolver.key.0")

local last = os.time()
serial = 0
function autoRenewCert() -- called approx. every second in maintenance function

  -- (60*60*23) - 300 = 82500 (23 hours)  - 1 hour for clients to update cirt + clock diff of 5 min
  -- 60*60*24 - 60 = 86340 (24 hours) -- cert expires in 24 - clock diff of 1 min
  local now = os.time()
  if ((now - last) > 82500) then
    serial = serial + 1

    getDNSCryptBind(0):generateAndLoadInMemoryCertificate("/etc/dnsdist/providerPrivate.key", serial, now - 60, now + 86340)
    getDNSCryptBind(1):generateAndLoadInMemoryCertificate("/etc/dnsdist/providerPrivate.key", serial, now - 60, now + 86340)
    getDNSCryptBind(2):generateAndLoadInMemoryCertificate("/etc/dnsdist/providerPrivate.key", serial, now - 60, now + 86340)
    -- getDNSCryptBind(3):generateAndLoadInMemoryCertificate("/etc/dnsdist/providerPrivate.key", serial, now - 60, now + 86340)
    -- getDNSCryptBind(4):generateAndLoadInMemoryCertificate("/etc/dnsdist/providerPrivate.key", serial, now - 60, now + 86340)
    -- getDNSCryptBind(5):generateAndLoadInMemoryCertificate("/etc/dnsdist/providerPrivate.key", serial, now - 60, now + 86340)
    -- getDNSCryptBind(6):generateAndLoadInMemoryCertificate("/etc/dnsdist/providerPrivate.key", serial, now - 60, now + 86340)
    last = now
  end
end
