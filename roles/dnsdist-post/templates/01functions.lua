{{ ansible_managed | comment('plain', prefix='--[[', postfix='--]]') }}

--utility function
function file_exists(name)
  local f=io.open(name,"r")
  if f==nil then return false else f:close() return true end
end


--[[ Attempt at auto renewing certificate
  --main issue is that DNSCrypt clients need to have the old cert avaliable for 1 hour to migrate to the new cert
  --second issue that the dnsdist needs to be restarted for the addDNSCryptBind command

  local time=0
  local cert_id=0

  function create_cert()
    warnlog("New Certificate is being generated!")
    warnlog("New Certificate ID is " .. cert_id)
    validTo=os.time()+(365*86400) -- Certificate is valid for 1 year
    generateDNSCryptCertificate("/etc/dnsdist/providerPrivate.key", "/etc/dnsdist/resolver.cert", "/etc/dnsdist/resolver.key", cert_id, os.time(), validTo)
    local f=io.open("/etc/dnsdist/expire", "w")
    if not f then print('Can\'t create file: /etc/dnsdist/expire'); return 'File Error'; end
    f.write(validTo)
    f.close()
    cert_id=cert_id+1
  end

  function check_cert()
    warnlog("Checking cert!")
    local f=io.open("/etc/dnsdist/expire", "r")
    if f~=nil
    then
      local f=io.open("/etc/dnsdist/expire", "r")
      local expire=f.read()
      f.close()
      warnlog("Cert expires at " .. expire .. " time now is " .. os.time())
      if expire < os.time()+(10800) -- 3 hours before cert expires
      then
        create_cert()
      else
        warnlog("Cert is still valid!")
      end
    else
      create_cert()
    end
  end

  function renew() --add renew() to maintenance function
    time=time+1
    if time > 3600 -- 3600=1h, 365*86400=1 year, 3600=every 22 hours
    then
      time=0
      check_cert()
    end
  end
--]]
