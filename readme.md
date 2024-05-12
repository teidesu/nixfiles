# nixos 

ok hi this is my nixos config. it is pretty much a mess and the code sucks but welp

## impure dependencies
note to self on what needs to be installed on the host manually:

### common
- `/etc/ssh/agenix-key` (darwin: `~/.ssh/agenix-key`) - private key for secret decryption
- `./secrets/unsafe.key` - private key for unsafe secret decryption

> "unsafe" secrets are only secret to the "outside" world (i.e. the git repo), but are decrypted at build-time
> and are available globally to the system. this is useful for things like server ips, since i don't want to
> expose them to everyone, but they are not really secret in the sense that they are not sensitive data.

### koi:
- ~~`/etc/iso/win11.iso` - iso containing windows 11 installer (e.g. this: [magnet](magnet:?xt=urn:btih:56197d53136ffcecbae5225f0ac761121eacdac6&dn=Win11_22H2_English_x64v1.iso&tr=udp%3a%2f%2ftracker.torrent.eu.org%3a451%2fannounce&tr=udp%3a%2f%2ftracker.tiny-vps.com%3a6969%2fannounce&tr=udp%3a%2f%2fopen.stealth.si%3a80%2fannounce))~~ currently unused
- `/etc/vms/haos.img` - qcow2 image for haos vm (can be downloaded from the official website, the KVM/Proxmox image).
- `/etc/secureboot/keys` - secure boot keys, generated with `sudo nix-shell -p sbctl --run "sbctl create-keys"`
- to enroll fde onto tpm: `sudo systemd-cryptenroll /dev/nvme0n1p2 --tpm2-device=auto --tpm2-pcrs=0+2+7`

nginx may not start the first time, its fine, just run `sudo systemctl restart nginx` and it should work.
its likely due to docker containers not resolving yet. todo fix this

### teidesu-osx
`cp /var/run/current-system/Library/Fonts/* /Library/Fonts` - copy nix-managed fonts to system fonts (waiting for [this PR](https://github.com/LnL7/nix-darwin/pull/754))

### setting up

macos:
```bash
curl -L https://nixos.org/nix/install | sh
git clone https://github.com/teidesu/nixos ~/nixos
cd ~/nixos
./switch
```

## cat in a readme 🐈

![cat](https://cataas.com/cat)
