VAULT_FILES = group_vars/all/vault.yml group_vars/webservers/vault.yml

install:
	ansible-galaxy install -r requirements.yml --force
syntax:
	ansible-playbook setup_servers.yml --syntax-check
	ansible-playbook setup_vpn.yml --syntax-check
	ansible-playbook setup_redmine.yml --syntax-check
	ansible-playbook setup_gateway.yml --syntax-check
	ansible-playbook setup_datadog.yml --syntax-check
lint:
	ansible-lint --exclude .ansible
check: syntax lint
initial-setup:
	ansible-playbook setup_servers.yml -e "ansible_user=root"
setup-vpn:
	ansible-playbook setup_vpn.yml -e "ansible_user=root"
setup-redmine:
	ansible-playbook setup_redmine.yml
setup-gateway:
	ansible-playbook setup_gateway.yml
setup-datadog:
	ansible-playbook setup_datadog.yml
setup: initial-setup setup-vpn setup-gateway setup-redmine setup-datadog

vault-encrypt:
	ansible-vault encrypt $(VAULT_FILES)
vault-decrypt:
	ansible-vault decrypt $(VAULT_FILES)
ensure-vault-encrypted:
	@for file in $(VAULT_FILES); do \
		grep -q "\$$ANSIBLE_VAULT" $$file \
			&& echo "Vault file $$file is encrypted. All good!" \
			|| (echo "ERROR: $$file is NOT encrypted! Please run 'make vault-encrypt' before committing." && exit 1); \
	done
commit-check: check ensure-vault-encrypted
