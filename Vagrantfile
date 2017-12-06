Vagrant.configure("2") do |config|
  config.vm.define "ubuntu17.04", autostart: false do |node|
    node.vm.box = "ubuntu/zesty64"
  end

  config.vm.define "ubuntu16.04", autostart: false do |node|
    node.vm.box = "ubuntu/xenial64"
  end

  config.vm.define "ubuntu14.04", primary: true do |node| #LTS
    node.vm.box = "ubuntu/trusty64"
  end

  config.vm.define "debian9", autostart: false do |node|
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
  end

  config.vm.define "freebsd10.4", autostart: false do |node|
    node.vm.box = "freebsd/FreeBSD-10.4-RELEASE"
  end

  config.vm.provision :shell, inline: <<-SHELL
    if command -v yum >/dev/null 2>&1; then
      yum check-update
      yum install python
    elif command -v apt-get >/dev/null 2>&1; then
      apt-get update -qq
      apt-get install -y python
    elif command -v pkg >/dev/null 2>&1; then
      pkg update
      pkg install -y python
    fi
  SHELL

  # Use :ansible or :ansible_local
  config.vm.provision :ansible do |ansible|
    ansible.verbose = "v"
    ansible.playbook = "test.yml"
  end
end