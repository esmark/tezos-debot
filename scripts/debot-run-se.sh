#!/usr/bin/env bash

set -o errexit

appName=${app:-Tezos}
src=${src:-./debots}
appArtifact=build/${appName}
user=${user:-mykeys}
tezos="tz1aWXP237BLwNHJcCD4b3DutCevhqq2T1Z9"

npx everdev network default se
npx everdev signer default "${user}"

network=$(npx everdev network list | grep Default | cut -d' ' -f1)
signer=$(npx everdev signer list | grep Default | cut -d' ' -f1)

addressContract() {
  npx everdev contract info --signer "${2:-$signer}" "${1}" | grep Address | cut -d' ' -f4
}
accountType() {
  npx tonos-cli --json account "${1}" | jq -r .[].acc_type
}
addressWallet() {
  addressContract "$(artifactContract "${2:-SurfMultisigWallet}")" "${1:-$signer}"
}
artifactContract() {
  walletName="${1:-SurfMultisigWallet}" # SafeMultisigWallet | SetcodeMultisigWallet
  slug="$(echo "${walletName::-6}" | tr '[:upper:]' '[:lower:]')/${walletName}"
  rev="5adb4c394fcc22b790ede9a3c18e74f1db8034c8"
  path="tonlabs/ton-labs-contracts/${rev}/solidity"
  prefix="${HOME}/.everdev/contract"
  if [ ! -f "${prefix}/${walletName}.abi.json" ]; then
    wget --quiet --directory-prefix="${prefix}" "https://raw.githubusercontent.com/${path}/${slug}.abi.json"
  fi
  if [ ! -f "${prefix}/${walletName}.tvc" ]; then
    wget --quiet --directory-prefix="${prefix}" "https://raw.githubusercontent.com/${path}/${slug}.tvc"
  fi
  printf '%s/%s' "${prefix}" "${walletName}"
}
createWallet() {
  walletName="${1}"
  owner="${2}"
  value="${3:-100055894001}"
  artifact="$(artifactContract "${walletName}")"
  if [ -e "$(npx everdev signer list | grep "${owner}")" ]; then
      npx everdev signer generate --mnemonic "${owner}"
  fi
  keyPublic="0x$(npx everdev signer info "${owner}" | jq -r .keys.public)"
  input="owners:[$keyPublic],reqConfirms:1"
  npx everdev contract deploy --signer "${owner}" --value "${value}" \
    --input "${input}" "${artifact}" >> build.log 2>&1
  addressWallet "${owner}"
}

rm -fr -- *.log
echo "network: ${network} signer: ${signer} user: ${user}"
if [ "${network}" == "se" ] && ! npx everdev se info | grep --quiet running; then
  npx everdev se reset
fi

configUrl="$(npx everdev network list | grep Default | cut -d' ' -f4 | cut -d',' -f1)"
npx tonos-cli config --url "${configUrl}" > /dev/null 2>&1

if [ "$(accountType "$(addressWallet "${user}")")" != "Active" ]; then
  printf "Create wallet for %s... " "${user}"
  printf '%s' "$(createWallet SurfMultisigWallet "${user}")"
  echo " ✓"
fi

npx everdev signer info "${user}" | jq -r .keys > secret.json
npx tonos-cli config \
  --keys secret.json \
  --pubkey "0x$(npx everdev signer info "${user}" | jq -r .keys.public)" \
  --wallet "$(addressWallet "${user}")" > /dev/null 2>&1

printf "Compile contract... "
npx everdev sol compile --code --output-dir build "${src}/${appName}.sol"
echo "✓"

appAddr="$(addressContract "${appArtifact}")"
if [ "$(accountType "$appAddr")" != "Active" ]; then
  printf "Deploy DeBot... "
  npx everdev contract deploy --value 1000000000 "${appArtifact}" &>>build.log
  echo "✓"
  mkdir -p network
  echo "${appAddr}" > "network/${network}-debot.addr"
# TODO else upgrade
fi

printf "Deploy ABI... "
appABI=$(< "${appArtifact}.abi.json" jq --compact-output | xxd -ps -c 20000)
npx everdev contract run --address "${appAddr}" "${appArtifact}" setABI --input "dabi:$appABI" &>>build.log
echo "✓"

printf "Deploy Icon... "
ICON_BYTES=$(base64 -w 0 "${src}/icon.png")
ICON=$(echo -n "data:image/png;base64,$ICON_BYTES" | xxd -ps -c 20000)
npx everdev contract run --address "${appAddr}" "${appArtifact}" setIcon --input "icon:$ICON" &>>build.log
echo "✓"

printf "Deploy Default Tezos address ${tezos} ... "
npx everdev contract run --address "${appAddr}" "${appArtifact}" setDefaultTezosAddress --input "value:$tezos" &>>build.log
echo "✓"

echo "DeBot ${appAddr}"
echo "npx tonos-cli debot --debug fetch ${appAddr}"
npx tonos-cli debot fetch "${appAddr}"