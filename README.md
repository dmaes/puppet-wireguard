# Puppet Wireguard

## Generate keys:
```sh
wg genkey | tee privatekey | wg pubkey > publickey
```

## Example (hiera)
```yaml
wireguard::interfaces:
  wg0:
    private_key: YourPrivateKey
    listen_port: 51820
    address4: 192.168.20.1/24
    peers:
      SomePeer:
        public_key: SomePeerPublicKey
        endpoint: some.peer.com:51820
        allowed_ips: ['192.168.0.0/16']
        persistent_keepalive: 10
```

## Updating config: `setconf` vs `syncconf`
Summarised from the wg manpage:
`setconf` will set the configuration of specified interface to the contents of the specified config file.
`syncconf` will read the current configuration of the interface and only make changes that are explicitely different from the config file and the current config. Slower then `setconf`, but less disruptive to current peer sessions
