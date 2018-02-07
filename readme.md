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

<!-- Generate new keys (optional - this is done automatically) -->

```sh

```

# Test

## Test with [vagrant](https://www.vagrantup.com/) (recommended)

```bash
brew cask install vagrant virtualbox
vagrant up
```

## Linting & Formatting

```bash
pip install yamllint 
pip install ansible-lint # may overwrite /usr/local/bin/ansible
gem install travis --no-rdoc --no-ri

ansible-playbook playbook.yml -i hosts --syntax-check
travis lint .travis.yml
yamllint -- **/*.yml *.yml # or yamllint $(find . -name '*.yml')
ansible-lint --exclude=required-roles --exclude="$HOME/.ansible/roles" playbook.yml
```

Or just run the lint script: `./lint`
