# tezos-debot for Ever Surf

## Develop environment require

- `POSIX`: bash, grep, etc
- `node`: v.16, https://nodejs.org/en/download/package-manager/
- `nvm`: v.8, https://github.com/nvm-sh/nvm
- `everdev`: v.1, npm i everdev
- `tonos-cli`: everdev tonos-cli install

## Settings

- tonos-cli.cong.json - set network configuration
- update scripts/debot-run(-se).sh: 
user=${user:-mykeys}
tezos="tz1aWXP237BLwNHJcCD4b3DutCevhqq2T1Z9"

## How to compile and deploy

- Start in SE (local) network: bash scripts/debot-run-se.sh
- Start in dev network: bash scripts/debot-run.sh

## Set default Tezos address
```shell
npx everdev contract run --address <address> <api_file> setDefaultTezosAddress --input "value:<tz_addr>"
```

## How to fetch debot 
### in terminal

- npx tonos-cli debot fetch <address>

### in Ever Surf

1. Open Your Ever Surf wallet, https://web.ever.surf/debots.
2. Find debot by address and select (be careful to check the network, https://web.ever.surf/settings/advanced-settings-network).
3. Select menu items of debot.