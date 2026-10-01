# Provisioning

sn0w is reconstructed from this repository rather than from an opaque machine image.

## Contract

A fresh supported Fedora installation should converge toward the same workstation by running:

```bash
git clone https://github.com/PizzukaTorph/sn0w-dotfile.git
cd sn0w-dotfile
./bootstrap.sh vm
```

On the MacBook running Fedora Asahi Minimal:

```bash
./bootstrap.sh asahi
```

`bootstrap.sh` only ensures Ansible exists and delegates to the playbook. Ansible owns package/service/config convergence. Dotfiles remain ordinary version-controlled files. Long-running shell components are owned by systemd user services.

## Profiles

### vm

Development/test profile for a generic Fedora VM. Hardware-specific values may be mocked by sn0w components.

### asahi

Physical MacBook profile. Fedora Asahi owns kernel, firmware and Apple Silicon hardware enablement; sn0w must not replace that stack.

## Idempotency

The desired workflow is intentionally destructive-test friendly:

1. create fresh Fedora VM;
2. clone this repository;
3. run bootstrap;
4. log into Hyprland;
5. verify sn0w;
6. destroy VM and repeat.

Provisioning bugs are fixed here, not manually on the machine.
