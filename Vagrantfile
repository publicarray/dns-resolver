Vagrant.configure("2") do |config|
  config.vm.define "ubuntu17.04", autostart: false do |node|
    node.vm.box = "ubuntu/zesty64" # not supported -> Unable to start service nsd: Job for nsd.service failed because the control process exited with error code
  end

  config.vm.define "ubuntu16.04", autostart: false do |node| #LTS
    node.vm.box = "ubuntu/xenial64"
  end

  config.vm.define "ubuntu14.04", primary: true do |node| #LTS
    node.vm.box = "ubuntu/trusty64"
  end

  config.vm.define "debian9", autostart: false do |node| # Unable to reload service nsd: nsd.service is not active, cannot reload
    node.vm.box = "debian/stretch64"
  end

  config.vm.define "debian8", autostart: false do |node|
    node.vm.box = "debian/jessie64 "
  end

  config.vm.define "centos7", autostart: false do |node|
    node.vm.box = "centos/7"
  end

  config.vm.define "freebsd11.1", autostart: false do |node|
    node.vm.box = "freebsd/FreeBSD-11.1-RELEASE"
    node.ssh.shell = "sh"
    node.vm.base_mac = "080027D14C66"
    node.vm.synced_folder ".", "/vagrant", disabled: true
  end

  config.vm.define "freebsd10.4", autostart: false do |node|
    node.vm.box = "freebsd/FreeBSD-10.4-RELEASE"
    node.ssh.shell = "sh"
    node.vm.base_mac = "080027D14C66"
    node.vm.synced_folder ".", "/vagrant", disabled: true
  end

  config.vm.define "openbsd6", autostart: false do |node|
    node.vm.box = "generic/openbsd6"
    node.ssh.shell = "sh"
  end

  config.vm.provision :shell, inline: <<-SHELL
    if command -v python>/dev/null 2>&1; then
      exit 0
    elif command -v yum >/dev/null 2>&1; then
      yum check-update
      yum install python
    elif command -v apt-get >/dev/null 2>&1; then
      apt-get update -qq
      apt-get install -y python
    elif command -v pkg >/dev/null 2>&1; then
      pkg update
      pkg install -y python
    elif command -v pkg_add >/dev/null 2>&1; then
      pkg_add -Iz python-2.7
      ln -sf /usr/local/bin/python2.7 /usr/local/bin/python
      ln -sf /usr/local/bin/python2.7-2to3 /usr/local/bin/2to3
      ln -sf /usr/local/bin/python2.7-config /usr/local/bin/python-config
      ln -sf /usr/local/bin/pydoc2.7  /usr/local/bin/pydoc
    else
      echo "No compatable package manager found"
      exit 1
    fi
  SHELL

  # Use :ansible or :ansible_local
  config.vm.provision :ansible do |ansible|
    ansible.verbose = "v"
    ansible.playbook = "test.yml"
  end
end
