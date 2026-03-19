## Foundry Simple Storage

Foundry Setup

Foundry is a relatively new but rapidly growing smart contract development framework known for its efficiency and modularity. Foundry manages your dependencies, compiles your project, runs tests, deploys, and lets you interact with the chain from the command-line and via Solidity scripts.

[Foundry Book](https://book.getfoundry.sh/) is the most comprehensive resource that has the answers to all your questions. It will be handy along the way.

Install foundry via `curl -L https://foundry.paradigm.xyz | bash`, and simply type `foundryup` and `Enter` to install and update Foundry to the latest version. This will install four components: forge, cast, anvil, and chisel. To confirm the successful installation, run `forge --version`.

Use [Solidity by Nomic Foundation (Hardhat)](https://marketplace.visualstudio.com/items?itemName=NomicFoundation.hardhat-solidity) and **Even Better TOML** extensions in VSCode.

+ Use `forge` to build project
+ Use `anvil` to setup a local testnet
+ Use `forge fmt` to format code

***

Project Setup

The way you [create a new Foundry project](https://book.getfoundry.sh/projects/creating-a-new-project) is by running the `forge init` command. This will create a new Foundry project in your current working directory. If you want Foundry to create the new project in a new folder type `forge init nameOfNewFolder`. Keep in mind that by default `forge init` expects an empty folder. If your folder is not empty you must run `forge init --force .`

`lib` is the folder where all your dependencies are installed, here you'll find things like:

- `forge-std` (the forge library used for testing and scripting)
- `openzeppelin-contracts` is the most battle-tested library of smart contracts
- and many more, depending on what you need/install

`foundry.toml` - gives configuration parameters for Foundry

Type in `forge build` or `forge compile` to compile the smart contracts in your project. Once the compiling is finished, you'll see some new folders in the Explorer tab on the left side. One of them is a folder called `out`. Here you'll be able to find the [ABI](https://docs.soliditylang.org/en/latest/abi-spec.html) of the smart contract together with the [Bytecode](https://www.geeksforgeeks.org/introduction-to-bytecode-and-opcode-in-solidity/) and a lot of useful information.

***

Delolyment

We should answer two questions before we deploy the smart contract:

+ Where do we deploy?
+ Who's paying the gas fee (signing the transaction)?

First we start a Ethereum Network in Ganache, then run `forge create SimpleStorage --rpc-url http://127.0.0.1:7545 --interactive --broadcast`, 注意如果不加上 `--broadcast` 交易无法上到区块里, 然后从 Ganache 里取一个私钥来签名就行了.

当然也可以用 Anvil 来创建网络, 效果是一样的 `forge create SimpleStorage --rpc-url http://127.0.0.1:8545 --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 --broadcast`

+ 除了直接使用命令行, 我们也可以使用脚本来部署合约. In Foundry we keep our scripts in the `script` folder. Using `.s.sol` as a suffix is a naming convention for Foundry scripts, in future lessons, when we'll write Foundry tests, these will bear the suffix of `.t.sol`.

  For it (it 指的是脚本合约) to be considered a Foundry script and to be able to access the extended functionality Foundry is bringing to the table we need to import `Script` from `"forge-std/Script.sol"` and make `DeploySimpleStorage` inherit `Script`.

  Every script needs a main function, which, according to the best practice linked above is called `run`. Whenever you run `forge script` this is the function that gets called

  To run a script, type `forge script script/DeploySimpleStorage.s.sol`, if the RPC URL is not specified, Foundry automatically launches an Anvil instance, runs your script (in our case deployed the contract) and then terminates the Anvil instance.

+ `vm` is a keyword and also a cheat code in Foundry;

  `vm.startBroadcast` indicates the starting point for the list of transactions that get to be sent to the `RPC URL`;

  `vm.stopBroadcast` indicates the ending point of the list of transactions that get to be sent to the `RPC URL`;

+ `cast` is a very versatile tool provided by Foundry.

  Use `cast --to-base 0x714e1 dec` to convert hex numbers to normal numbers 

+ Every time you change the state of the blockchain you do it using a transaction.

  ***

+ 要将合约部署到测试网, 而不是在本地, 仍然是回答上面两个问题, RPC URL 以及谁来签名交易.

  我们使用 Alchemy 提供的 RPC, 即 Node as a Service, 然后使用一个含有 Sepolia ETH 的账户来签名.

  部署到测试网后, 可以在 Etherscan 里手动 verify 合约, 从而能够直接在网页上与合约交互, example: https://sepolia.etherscan.io/address/0xce318061450fb3cc63808f44d0ee9a933a75c051#code

  Later, we'll learn how to verify programmatically using Foundry, which supports multiple explorers.

***

Private Key Safety

+ **It's very bad to have private keys in bash history**

+ **I promise to never use my private key associated with real money in plain text.**

+ **You should never use a `.env` again.**

+ **If you are seeing your private key in plain text, you are doing something wrong.**

+ 当你把私钥等信息放在 `.env` 文件中时, 可以直接使用 `source .env` 把其加载到环境变量里, 然后直接在命令行里 `$PRIVATE_KEY` 使用, 开发的时候很方便. 但这种方式也不适用于生产环境.

+ 对于生产环境, 不能把你的私钥以明文的形式存储在磁盘里, 更不能放在 bash history 里.

  我们可以用两种方式来避免:

  + 使用 -- interactive 参数, 需要时直接输入私钥, 不留在磁盘里

  + 使用 Foundry keystore 工具, 输入私钥后, 其还要求输入一个密码, 使用该密码对私钥加密, 并存储密文.

    下次使用时, 交互式直接输入密码, 即可解密密文, 密文存在磁盘里, 私钥动态解析出来.

    相当于原来是输入私钥, 现在是输入密码.

    ```bash
    # create keystore
    cast wallet import mykey --interactive
    
    # use keystore
    forge script script/Deploy.s.sol --keystore ~/.foundry/keystores/mykey --broadcast
    forge script script/Deploy.s.sol --account mykey --broadcast
    ```

***

Interact with contract by CLI

+ Foundry has a built-in tool known as `Cast`. `Cast` comes loaded with numerous commands to interact with. Learn more about them by typing `cast --help`. One such useful command is `send` which is designed to sign and publish a transaction. To view help about `send`, type `cast send --help`.

  To use `send` we need a signature and some arguments.

  `cast send 0x5Fb.. "store(uint256)" 1337 --rpc-url $RPC_URL --private-key $PRIVATE_KEY`
  
+ `cast` conveniently provides a way to read information stored on the blockchain.  It works similarly to `send`, where you have to provide a signature and some arguments. The difference is you are only peering into the storage, not modifying it.

  `