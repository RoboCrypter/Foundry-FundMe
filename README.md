# Foundry Fund Me

Deployed [FundMe](https://sepolia.etherscan.io/address/0x5d5baa64b2434946e33041bfb918afa248b60ad3) contract on Sepolia : 0x5d5baA64B2434946E33041Bfb918AFA248b60ad3

# Getting Started

## Requirements

- [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
  - You'll know you did it right if you can run `git --version` and you see a response like `git version x.x.x`
- [foundry](https://getfoundry.sh/)
  - You'll know you did it right if you can run `forge --version` and you see a response like `forge 0.2.0 (816e00b 2023-03-16T00:05:26.396218Z)`


## Quickstart

```
git clone https://github.com/RoboCrypter/Foundry-FundMe.git

cd Foundry-FundMe

forge compile
```


# Usage

## Deploy

```
forge script script/FundMe.s.sol
```

## Testing

1. Unit
2. Integration
3. Forked


```
forge test
```

### To run only specific test function

```
forge test --match-test testFunctionName

or

forge test --mt testFunctionName
```

### To run test on a fork testnet

```
forge test --fork-url $SEPOLIA_RPC_URL
```

### Test Coverage

```
forge coverage
```

## Local zkSync 

The instructions here will allow you to work with this repo on zkSync.

### (Additional) Requirements 

In addition to the requirements above, you'll need:
- [foundry-zksync](https://github.com/matter-labs/foundry-zksync)
  - You'll know you did it right if you can run `forge --version` and you see a response like `forge 0.0.2 (816e00b 2023-03-16T00:05:26.396218Z)`. 
- [npx & npm](https://docs.npmjs.com/cli/v10/commands/npm-install)
  - You'll know you did it right if you can run `npm --version` and you see a response like `7.24.0` and `npx --version` and you see a response like `8.1.0`.
- [docker](https://docs.docker.com/engine/install/)
  - You'll know you did it right if you can run `docker --version` and you see a response like `Docker version 20.10.7, build f0df350`.
  - Then, you'll want the daemon running, you'll know it's running if you can run `docker --info` and in the output you'll see something like the following to know it's running:
```bash
Client:
 Context:    default
 Debug Mode: false
```

### Setup local zkSync node 

Run the following:

```bash
npx zksync-cli dev config
```

And select: `In memory node` and do not select any additional modules.

Then run:
```bash
npx zksync-cli dev start
```

And you'll get an output like:
```
In memory node started v0.1.0-alpha.22:
 - zkSync Node (L2):
  - Chain ID: 260
  - RPC URL: http://127.0.0.1:8011
  - Rich accounts: https://era.zksync.io/docs/tools/testing/era-test-node.html#use-pre-configured-rich-wallets
```

### Deploy to local zkSync node

```bash
forge create src/FundMe.sol:FundMe --rpc-url http://127.0.0.1:8011 --private-key $(DEFAULT_ZKSYNC_LOCAL_KEY) --constructor-args $(shell forge create test/mock/MockV3Aggregator.sol:MockV3Aggregator --rpc-url http://127.0.0.1:8011 --private-key $(DEFAULT_ZKSYNC_LOCAL_KEY) --constructor-args 8 200000000000 --legacy --zksync | grep "Deployed to:" | awk '{print $$3}') --legacy --zksync
```

This will deploy a mock price feed and a fund me contract to the zkSync node.

# Deployment to a testnet or mainnet

### 1. Setup environment variables

You'll want to set your `SEPOLIA_RPC_URL` and `PRIVATE_KEY` as environment variables. You can add them to a `.env` file, similar to what you see in `.env.example`.


- `PRIVATE_KEY`: The private key of your account, like from [Metamask](https://metamask.io/)

- **NOTE:** FOR DEVELOPMENT, PLEASE USE A KEY THAT DOESN'T HAVE ANY REAL FUNDS ASSOCIATED WITH IT.

  - You can learn how to export it [here](https://metamask.zendesk.com/hc/en-us/articles/360015289632-How-to-Export-an-Account-Private-Key)
  
- `SEPOLIA_RPC_URL`: This is url of the sepolia testnet node you're working with. You can get setup with one for free from [Alchemy](https://alchemy.com/?a=673c802981)

- Optionally, add your `ETHERSCAN_API_KEY` if you want to verify your contract on [Etherscan](https://etherscan.io/)


### 2. Get testnet ETH

Head over to [faucets.chain.link](https://faucets.chain.link/) and get some testnet ETH. You should see the ETH show up in your metamask.


### 3. Deploy and Verify

```
forge script script/FundMe.s.sol --rpc-url $SEPOLIA_RPC_URL --private-key $PRIVATE_KEY --verify --etherscan-api-key $ETHERSCAN_API_KEY --broadcast
```

## Scripts

After deploying to a testnet or local net, you can run the scripts. 

Using cast, deployed on a testnet example:

### Fund

```
cast send <FUNDME_CONTRACT_ADDRESS> "fund()" --value 0.1ether --private-key <PRIVATE_KEY>
```

### Withdraw

```
cast send <FUNDME_CONTRACT_ADDRESS> "withdraw()"  --private-key <PRIVATE_KEY>
```

or

Via scripts, deployed on a testnet example:

```
forge script script/Interactions.s.sol:FundMe_Fund --rpc-url $SEPOLIA_RPC_URL  --private-key $PRIVATE_KEY  --broadcast

forge script script/Interactions.s.sol:FundMe_Withdraw --rpc-url $SEPOLIA_RPC_URL  --private-key $PRIVATE_KEY  --broadcast
```



## Estimate gas

You can estimate how much gas things cost by running:

```
forge snapshot
```

And you'll see an output file called `.gas-snapshot` in your directory.


# Formatting


To run code formatting:
```
forge fmt
```


# Thank you!

If you appreciated this, feel free to follow me or donate!

ETH/Arbitrum/Optimism/Polygon/etc Address: 0x047821Dc2b13F680FeD9B006F0868bE43AcF4fe6

[![RoboCrypter Twitter](https://img.shields.io/badge/Twitter-1DA1F2?style=for-the-badge&logo=twitter&logoColor=white)](https://twitter.com/RoboCrypter)
[![RoboCrypter Linkedin](https://img.shields.io/badge/LinkedIn-0077B5?style=for-the-badge&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/0xSiddique/)
[![RoboCrypter Medium](https://img.shields.io/badge/Medium-000000?style=for-the-badge&logo=medium&logoColor=white)](https://medium.com/@RoboCrypter/)
