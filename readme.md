# Open DNS Resolver with DNSCrypt

## Usage

```sh
ansible-galaxy install -r requirements.yml
ansible-playbook site.yml -i hosts --diff
```

### tests
```sh
ansible-playbook site.yml -i hosts --syntax-check
ansible-playbook site.yml -i hosts --check --diff
```
