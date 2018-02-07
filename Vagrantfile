Vagrant.configure("2") do |config|

  # https://wiki.ubuntu.com/Releases
  # https://app.vagrantup.com/ubuntu/
  # config.vm.define "ubuntu18.04", autostart: false do |node| # development #LTS
  #   node.vm.box = "ubuntu/bionic64"
  # end

  config.vm.define "ubuntu17.10", primary: true do |node|
    node.vm.box = "ubuntu/artful64"
    # on 1st run permissions are not properly read, a re-run of the playbook will fix this.
    # fatal: [ubuntu17.10]: FAILED! => {"changed": false, "msg":
    # "Unable to start service nsd: Job for nsd.service failed because the control process exited with error code.
    # \nSee \"systemctl  status nsd.service\" and \"journalctl  -xe\" for details.\n"}
    # Solution: re-run the ansible playbook
  end

  config.vm.define "ubuntu16.04" do |node| #LTS
    node.vm.box = "ubuntu/xenial64"
  end

  config.vm.define "ubuntu14.04", autostart: false do |node| #LTS
    node.vm.box = "ubuntu/trusty64"
    #  Cannot fetch index base URL https://pypi.python.org/simple/\nCould not find any downloads that satisfy the requirement pip
    #  No solution as of yet
  end

  # https://www.debian.org/releases/
  # https://wiki.debian.org/DebianReleases
  # https://app.vagrantup.com/debian/
  # config.vm.define "debian10", autostart: false do |node| # development
  #   node.vm.box = "debian/buster64"
  # end

  config.vm.define "debian9" do |node|
    node.vm.box = "debian/stretch64"
     # Unable to reload service nsd: nsd.service is not active, cannot reload
     # fixes itself after a second ansible palybook run
     # Solution: re-run the ansible playbook
  end

  config.vm.define "debian8", autostart: false do |node|
    node.vm.box = "debian/jessie64"
    # Make unbound fails,  plugin needed to handle lto object
    # Solution: upgrade compiler (gcc)
  end

  # https://wiki.centos.org/Download
  # https://app.vagrantup.com/centos/
  config.vm.define "centos7" do |node|
    node.vm.box = "centos/7"
  end

  # https://www.freebsd.org/releases/
  # https://app.vagrantup.com/freebsd/
  config.vm.define "freebsd11.1" do |node|
    node.vm.box = "freebsd/FreeBSD-11.1-RELEASE"
    node.ssh.shell = "sh"
    node.vm.base_mac = "080027D14C66"
    node.vm.synced_folder ".", "/vagrant", disabled: true
    # This box takes a long time to boot for the first time
    # due to a script that updates, sets up FreeBSD and reboots the machine
  end

  config.vm.define "freebsd10.4", autostart: false do |node|
    node.vm.box = "freebsd/FreeBSD-10.4-RELEASE"
    node.ssh.shell = "sh"
    node.vm.base_mac = "080027D14C66"
    node.vm.synced_folder ".", "/vagrant", disabled: true
    # This box takes a long time to boot for the first time
    # due to a script that updates, sets up FreeBSD and reboots the machine
  end

  # https://www.openbsd.org/plus.html
  # https://app.vagrantup.com/generic/
  config.vm.define "openbsd6" do |node|
    node.vm.box = "generic/openbsd6"
    node.ssh.shell = "sh"
    # TASK [publicarray.unbound : Generate an OpenSSL private key with the default values (4096 bits, RSA)] ***
    # fatal: [openbsd6]: FAILED! => {"changed": false, "msg": "The directory /usr/local/etc/unbound does not exist or the file is not a directory", "name": "/usr/local/etc/unbound"}
  end

  config.vm.provision :shell, inline: <<-SHELL
    if command -v python>/dev/null 2>&1; then
      exit 0
    elif command -v yum >/dev/null 2>&1; then
      yum check-update
      yum install python
    elif command -v apt-get >/dev/null 2>&1; then
      ## ubuntu17.04 (no longer supported):
      ## sed -i -e 's/archive.ubuntu.com\|security.ubuntu.com/old-releases.ubuntu.com/g' /etc/apt/sources.list
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
