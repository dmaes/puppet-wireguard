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
