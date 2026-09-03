# sn0w user services

User units live here when their owning component is ready to expose one.

Provisioning links individual units into `~/.config/systemd/user/`; this directory is intentionally versioned so fresh clones always contain the service source tree.

Do not enable placeholder or unavailable services. Each Ansible role owns the lifecycle of the units for the component it installs.
