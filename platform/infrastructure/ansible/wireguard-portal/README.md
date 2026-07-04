# WireGuard Portal Ansible Install

This playbook installs WireGuard Portal on the small VPN VM created by Terraform.

It intentionally does not install monitoring, dashboards, exporters, or database integrations.

## Usage

```bash
cp inventory.example.ini inventory.ini
ansible-playbook -i inventory.ini playbook.yml
```

Set `ansible_host` to the Terraform output `vpn_vm_public_ip_addresses["wireguard"]`.

## Optional Caddy Reverse Proxy

Caddy is disabled by default because a real DNS name must point to the VM before automatic HTTPS can work.

```bash
ansible-playbook -i inventory.ini playbook.yml \
  -e caddy_enabled=true \
  -e caddy_domain=<vpn-domain>
```

Keep private domains and secrets out of committed inventory files.
