VAULT_FILES = group_vars/all/vault.yml group_vars/webservers/vault.yml

install:
	ansible-galaxy install -r requirements.yml --force
syntax:
	ansible-playbook playbook.yml --syntax-check
	ansible-playbook setup_servers.yml --syntax-check
	ansible-playbook setup_vpn.yml --syntax-check
	ansible-playbook setup_gateway.yml --syntax-check
lint:
	ansible-lint --exclude .ansible
check: syntax lint
deploy:
	ansible-playbook playbook.yml
initial-setup:
	ansible-playbook setup_servers.yml -e "ansible_user=root"
setup-vpn:
	ansible-playbook setup_vpn.yml -e "ansible_user=root"
setup-gateway:
	ansible-playbook setup_gateway.yml
setup: initial-setup setup-vpn setup-gateway deploy

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
