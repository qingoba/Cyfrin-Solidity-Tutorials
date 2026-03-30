## Foundry Simple Storage

Foundry Setup

Foundry is a relatively new but rapidly growing smart contract development framework known for its efficiency and modularity. Foundry manages your dependencies, compiles your project, runs tests, deploys, and lets you interact with the chain from the command-line and via Solidity scripts.

[Foundry Book](https://book.getfoundry.sh/) is the most comprehensive resource that has the answers to all your questions. It will be handy along the way.

Install foundry via `curl -L https://foundry.paradigm.xyz | bash`, and simply type `foundryup` and `Enter` to install and update Foundry to the latest version. This will install four components: forge, cast, anvil, and chisel. To confirm the successful installation, run `forge --version`.

Use [Solidity by Nomic Foundation (Hardhat)](https://marketplace.visualstudio.com/items?itemName=NomicFoundation.hardhat-solidity) and **Even Better TOML** extensions in VSCode.

+ Use `forge` to build project
+ Use `anvil` to setup a local testnet
+ Use `forge fmt` to format code
+ Use `forge test` to run the unit test
+ Use `forge install` to install dependencies
+ Use `forge coverage` to check code coverage

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

  For it (it 指的是脚本合约) to be considered a Foundry script and to be able to access the extended functionality Foundry is bringing to the table, we need to import `Script` from `"forge-std/Script.sol"` and make `DeploySimpleStorage` inherit `Script`.

  Every script needs a main function, which, according to the best practice linked above is called `run`. Whenever you run `forge script` this is the function that gets called

  To run a script, type `forge script script/DeploySimpleStorage.s.sol`, if the RPC URL is not specified, Foundry automatically launches an Anvil instance, runs your script (in our case deployed the contract) and then terminates the Anvil instance.

+ `vm` is a keyword and also a cheat code in Foundry;

  `vm.startBroadcast` indicates the starting point for the list of transactions that get to be sent to the `RPC URL`;

  `vm.stopBroadcast` indicates the ending point of the list of transactions that get to be sent to the `RPC URL`;

+ `cast` is a very versatile tool provided by Foundry.

  Use `cast --to-base 0x714e1 dec` to convert hex numbers to normal numbers 

+ Every time you change the state of the blockchain you do it using a transaction.

  The EVM and ZKsync ecosystems support multiple transaction types to accommodate various Ethereum Improvement Proposals (EIPs). Initially, Ethereum had only one transaction type (`0x0` legacy), but as the ecosystem evolved, multiple types were introduced through various EIPs. Subsequent types include type 1, which introduces an *access list* of addresses and keys, and type 2, also known as [EIP 1559](https://eips.ethereum.org/EIPS/eip-1559) transactions.

  `0x2` type is the current default type for the EVM.

  ***

+ 要将合约部署到测试网, 而不是在本地, 仍然是回答上面两个问题, RPC URL 以及谁来签名交易.

  我们使用 Alchemy 提供的 RPC, 即 Node as a Service, 然后使用一个含有 Sepolia ETH 的账户来签名.

  部署到测试网后, 可以在 Etherscan 里手动 verify 合约, 从而能够直接在网页上与合约交互, example: https://sepolia.etherscan.io/address/0xce318061450fb3cc63808f44d0ee9a933a75c051#code

  Later, we'll learn how to verify programmatically using Foundry, which supports multiple explorers.

  Alchemy 功能极其强大, 作者称之为 Think of Alchemy as the AWS of Web3

***

Private Key Safety

+ **It's very bad to have private keys in bash history**

+ **I promise to never use my private key associated with real money in plain text.**

+ **You should never use a `.env` again.**

+ **If you are seeing your private key in plain text, you are doing something wrong.**

+ 当你把私钥等信息放在 `.env` 文件中时, 可以直接使用 `source .env` 把其加载到环境变量里, 然后直接在命令行里 `$PRIVATE_KEY` 使用, 开发的时候很方便. 但这种方式不适用于生产环境.

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

## Foundry ZKsync

在 ZKsync 网络中使用 Foundry 和我们在 EVM 中用的不一样, 其工具包被称为 foundryup-zksync, 并且安装这个工具包后, 相关的 forge 和 cast 命令都变成了 ZKsync 版本. 幸运的是, 再次使用 foundryup 即可将工具包切换回原版. 原版也被称为 Vanilla Foundry, 其中 Vanilla 是一个英语中常用的说法, 意思是原版的, 未经修改的. 

简言之, foundryup-zksync 和 foundryup 可以在两个环境之间来回切换, 很方便.

安装: https://foundry-book.zksync.io/introduction/installation/

编译 `forge build --zksync`

本地测试 `anvil-zksync`

搭建本地完整的网络环境, 使用 Docker + zksync-cli dev, 但据说目前 anvil-zksync 已经能覆盖大多数场景.

## Foundry Fund Me

Foundry Test

+ **`function setUp()` will invoke before run test, and each of our tests uses a fresh `setUp`**

+ Use `console.log` to log something you want

+ Use flag `-v` to decide how verbose the log output

  ```
  Verbosity levels:
      - 2: Print logs for all tests (-vv)
      - 3: Print execution traces for failing tests (-vvv)
      - 4: Print execution traces for all tests, and setup traces for failing tests
      - 5: Print execution and setup traces for all tests (-vvvvv)
  ```

+ 如果我们写一个单测检查 `assertEq(fundMe.i_owner(), msg.sender);`, 会得到 FAIL, 这是因为, FundMe 合约实际上是在 setUp 函数中被创建的, 实际的创建者是 FundMeTestContract, 而不是我们跑测试的这个人, 所以如果改成 `assertEq(fundMe.i_owner(), address(this));` 就可以通过了, 其中 `address(this)` 表示当前合约的地址 (因为要运行合约中的代码, 必然要先将合约部署, 部署完的合约必然有一个地址)

+ This course will cover 4 different types of tests:

  - **Unit tests**: Focus on isolating and testing individual smart contract functions or functionalities.
  - **Integration tests**: Verify how a smart contract interacts with other contracts or external systems.
  - **Forking tests**: Forking refers to creating a copy of a blockchain state at a specific point in time. This copy, called a fork, is then used to run tests in a simulated environment.
  - **Staging tests**: Execute tests against a deployed smart contract on a staging environment before mainnet deployment.

+ Use `forge test --mt testPriceFeedVersionIsAccurate` to run a specific test case

+ 在 FundMe 的代码中, 我们使用了硬编码的 PriceFeed 合约地址, 其是位于 Sepolia 上的, 如果我们编写

  ```solidity
  function testPriceFeedVersionIsAccurate() public {
      uint256 version = fundMe.getVersion();
      assertEq(version, 4);
  }
  ```

  该测试会失败, 因为 `forge test` 会在本地的 Anvil 网络上运行.

  为了解决这个问题, 我们可以使用 forking test, 即使用远端的网络来模拟运行, 使用方法很简单, 带上参数 `--fork-url` 即可, `forge test --fork-url $SEPOLIA_RPC_URL`

+ 随着合约越来越复杂, 使用部署脚本来部署合约是一个恰当的做法, 并且部署脚本还可以在单测里使用.

  如果我们更改单测的 setUp 函数如下:

  ```solidity
    function setUp() external {
        favNumber = 1314;
        greatCourse = true;
        deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
    }
  ```

  那么现在谁是合约的 owner 呢? 就是调用单测的人! 因为部署脚本中写了 `vm.startBroadcast`

  `vm.startBroadcast` is special, it uses the address that calls the test contract or the address / private key provided as the sender.

  所以当我们更改了 setUp 函数后, 验证合约 Owner 的用例也要随之做出修改.

+ 对于一个复杂的合约, 不能总是依赖 Fork Testing, 应该能够完全在本地测试.

  换句话说, 就像你在企业中的项目, 应该在本地单测完整的功能, 而不是依赖集成测试.

  为此, 我们常常需要 Mock 一些外部合约的行为, 来达成测试的目标.

  当有 Mock 的合约时, 我们需要先部署这些合约, 然后引用.
  
+ 除了需要 Mock 合约的行为, 我们还需要 Mock 更多的行为, 这时候我们会用一系列的 Cheatcode, 比如

  + `vm.expectRevert()`, the next line after this one should revert! If not test fails. 相当于其他高级语言中的 expect Exception, 即期待抛出异常, 用于检测 bad case

  + User management is a very important aspect you need to take care of when writing tests. Imagine you are writing a more complex contract, where you have different user roles, maybe the `owner` has some privileges, different from an `admin` who has different privileges from a `minter`, who, as you've guessed, has different privileges from the `end user`. How can we differentiate all of them in our testing? We need to make sure we can write tests about who can do what.

    我们可以使用 `vm.prank(address)`, 这个方法 sets `msg.sender` to the specified address for the next call. “The next call” includes static calls as well, but not calls to the cheat code address.

    如果某个代码块都要更改调用方, 可以使用 `vm.startPrank(address)` 和 `vm.stopPrank()` 包围这些代码块

  + `makeAddr(name)` 可以创造出来一个地址

  + `vm.deal(alice, 10 ether);` 可以给 Alice 发 10 个 ETH 

+ 在很多单测用例中, 我们都要先交互一下合约, 然后验证合约的状态, 交互的这一步, 如果被频繁使用, 可以考虑抽成 modifier, 让多个用例共享.

+ 当你想做一些快速且简短的验证时, 除了上 Remix 把你的合约想出来, 也可以使用 Chisel 工具.

   `Chisel` is one of the 4 components of Foundry alongside `forge`, `cast` and `anvil`

  Chisel 非常类似 Python 解释器, 是一个交互型的终端, 可以直接编写 Solidity 代码, 其会把你的代码包裹在一个合约的 run 函数里, 

Gas

+ 一笔交易消耗的 Gas Fee 通过 Gas Used x Gas Price 得出.

  其中 Gas Used 是执行交易所需的"计算量"单位，是一个纯数字，衡量的是计算复杂度

  其中 Gas Price 是你愿意为每单位 Gas 支付多少 ETH (通常以 Gwei 为单位，1 Gwei = 10⁻⁹ ETH)

+ 以太坊在 EIP-1559 (London 升级) 之后，gas price 由两部分组成：

  + Base Fee — 由协议根据上一个区块的拥堵程度自动调整。区块越满，base fee 越高；区块越空，base fee 越低。这部分 ETH 会被销毁（burn）。
  + Priority Fee (Tip) — 用户额外给矿工/验证者的小费，激励他们优先打包你的交易。

  实际 gas price = base fee + priority fee

+ 借助 https://etherscan.io/gastracker 可以看到 Gas Price 的市场价格

+ 在本地, 对单测执行 `forge snapshot --mt testWithdrawFromOwner` 会得到一个 `.gas-snapshot` 文件, 其中写明了每个测试用例所消耗的 Gas

+ 在执行单测时, Anvil 为了方便, 默认 Gas Price 设置为 0, 因此交易是不需要支付 Gas Fee 的.

  Simple, for testing purposes the Anvil gas price is defaulted to `0`

  所以对于这个单测:

  ```solidity
  function testWithdrawFromOwner() public {
      uint256 startingFundMeBalance = address(fundMe).balance;
      uint256 startingOwnerBalance = fundMe.owner().balance;
  
      vm.startPrank(fundMe.owner());
      fundMe.withdraw();
      vm.stopPrank();
  
      uint256 endingFundMeBalance = address(fundMe).balance;
      uint256 endingOwnerBalance = fundMe.owner().balance;
      assertEq(endingFundMeBalance, 0);
      assertEq(
          startingFundMeBalance + startingOwnerBalance,
          endingOwnerBalance
      );
  }
  ```

  是不够严谨的, 因为我们作为合约的调用方, 需要支付一些 Gas, 那么支付 Gas 后, endingOwnerBalance 就不能严格等于初始金额加上收到的金额, 还应该减掉 Gas Fee

  我们可以通过一些 cheatcode 来计算 withdraw 花费了多少 gas, 通过:

  + `vm.txGasPrice(GAS_PRICE);` 设置当前环境的 Gas Price, 以 gwei 为单位

  + Solidity 内置函数 `gasleft()`, 返回当前执行环境中还剩多少 Gas, 该数字不是 Wei 的数目, 是一个纯计算数字. 从流程上来说, 用户在发起交易时, 需要预先指定一个 **gas limit**, 即你愿意为这笔交易最多提供多少 gas, 这个数字是不带价格单位的.

  + `tx.gasprice` 内置变量, 在合约函数中引用 tx 时, 指代的是当前这笔正在进行的交易, 这里是获取这笔交易所指定的 gas price. 在 EIP-1559 之前, 用户愿意支付的 gas price 和 gas limit 一样一起直接指定; 到 EIP-1559 升级后, baseFee 通过协议算法算出来, 用户指定两个参数:

    ```
    {
      "to": "0x...",
      "gasLimit": 21000,
      "maxFeePerGas": 30000000000,        // 最多愿意付 30 Gwei/gas
      "maxPriorityFeePerGas": 2000000000  // 其中给验证者的小费 2 Gwei/gas
    }
    ```

    实际支付的 gas price = min(maxFeePerGas, baseFee + maxPriorityFeePerGas)

    在这个例子中, 获取到的是我们用 vm.txGasPrice 设置的值, 然后用两次 `gasleft()` 得到的结果做差, 就能得到调用 withdraw 消耗了多少 Gas.

Storage

+ 在 Solidity 中, 合约中的状态变量以每个 32 bytes 的 slot 存储, 按顺序排列. 但不包括 arrary 和 mapping, 因为后两者需要动态扩容.

+ 检查 EVM 如何存储变量有几种办法: 在单测中使用 `vm.load()`, 使用 forge inspect, 对已部署的合约使用 cast storage. 我们以 FundMe 合约为例, 该合约中的状态变量包括:

  ```solidity
  AggregatorV3Interface priceFeed;
  address immutable public owner;
  address[] public funders;
  mapping (address => uint256) public addressToAmountFunded;
  mapping (address => uint256) public addressToCountFunded;
  ```

  我们可以编写一个单测, 通过 vm.load 获取并打印 slot 的内容:

  ```solidity
  function testPrintStorageData() public {
      for (uint256 i = 0; i < 3; i++) {
          bytes32 value = vm.load(address(fundMe), bytes32(i));
          console.log("Value at location", i, ":");
          console.logBytes32(value);
      }
      console.log("PriceFeed address:", address(fundMe.getPriceFeed()));
  }
  
  // got output
  Logs:
    Value at location 0 :
    0x00000000000000000000000034a1d3fff3958843c43ad80f30b94c510645c316
    Value at location 1 :
    0x0000000000000000000000000000000000000000000000000000000000000000
    Value at location 2 :
    0x0000000000000000000000000000000000000000000000000000000000000000
    Value at location 3 :
    0x0000000000000000000000000000000000000000000000000000000000000000
    Value at location 4 :
    0x0000000000000000000000000000000000000000000000000000000000000000
    PriceFeed address:  0x34A1D3fff3958843C43aD80F30b94c510645C316
  ```

  其中 address 类型是 20 字节, 独占 slot 0; 接下来的 immutable 编译时就被写入字节码, 不占用运行时空间; 然后是一个数组, 数组使用一个 slot 存储其长度信息, 数组的元素存储在 `keccak256(slot)` 开始的位置, 其中 slot 表示其所在 slot 的编号, 具体来说, 我们可以使用下面的语句访问数组元素:

  ```solidity
  // funders 在 slot 1, 第 i 个元素在：
  bytes32 baseSlot = keccak256(abi.encode(uint256(1)));
  bytes32 value = vm.load(address(fundMe), bytes32(uint256(baseSlot) + i));
  ```

  接下来是两个 mapping 类型, mapping 占用一个 slot, 但该 slot 本身不存储任何, 实际的数据存储在 `keccak256(key, slot)` 的位置, 具体来说, 使用下面的语句访问 mapping 元素:

  ```solidity
  // mapping 在 slot 2, 关键字为 key 的元素位于:
  bytes32 slot = keccak256(abi.encode(key, uint256(2)));
  bytes32 value = vm.load(address(fundMe), slot);
  ```

  ***

  能直接使用如下命令整理出状态变量的存储: `forge inspect FundMe storageLayout`, 会直接输出一个表格, 里面包含很丰富的信息, 非常清晰.

  对于已经部署的合约, 可以使用 `cast storage contractAddress slotNum` 查看, 这个命令没指定网络, 估计是默认使用 Anvil 本地网络, 具体不做探究了, 用到的时候再查阅.

+ 我们之所以研究 Storage, 是因为读写 Storage 的 Gas 花费相当大, 从 EVM OP Code 列表中能够看到, https://www.evm.codes/?fork=osaka#54, SLOAD 最低花费的 Gas 是 100, 而 MLOAD 只有 3, 相差好几十倍的花费. 所以我们在编写代码时, 能少用 Storage 就少用.

  另外, 如果想看一个合约的 OP Code, 可以使用 `cast code contractAddress` 然后把十六进制复制到 https://etherscan.io/opcode-tool Etherscan 提供的工具中

+ 在我们之前的 withdraw 函数实现中, for 循环的长度我们通过 `funders.length` 来确定, 这是一个 Storage 读取, 每次迭代都要读取, 我们可以将其预先加载到 memory 中, 能够省一些 Gas. 可以通过我们之前介绍的 Gas 统计方法来做一个实验, 对比两者的 Gas 消耗, 此处略去了.

Integration Test

+ Integration tests are crucial for verifying how your smart contract interacts with other contracts, external APIs, or decentralized oracles that provide data feeds. These tests help ensure your contract can properly receive and process data, send transactions to other contracts, and function as intended within the wider ecosystem.

  和企业中的代码库应该有集成测试一样, 我们的合约也要有集成测试, 从外部的角度来测试合约的功能

  在进行集成测试之前, 首先我们需要有一个 Endpoint. 换句话说, 我们应该先找到已经部署好的这份合约, 然后对其进行集成测试. 幸运的是, Cyfrin 提供了一个工具包叫做 foundry-devops, 其中有工具帮助我们在某个指定的网络中找到最新的那个部署版本.

+ 值得注意的是, 如果 foundry.toml 中显式配置了 remappings, 会覆盖 Foundry 对 lib/ 目录的自动发现机制。所以虽然 lib/foundry-devops/ 目录存在, Solidity 编译器找不到 foundry-devops/src/DevOpsTools.sol 的路径映射. 所以要么就是都用 remapping, 要么就放在 lib 里自动发现.


Makefile:

+ Automates tasks related to building and deploying your smart contracts.

+ Integrates with Foundry commands like `forge build`, `forge test` and `forge script`.

+ Can manage dependencies between different smart contract files.

+ Streamlines the development workflow by reducing repetitive manual commands.

+ Allows you to automatically grab the `.env` contents.

+ 你之前几乎没用过 `Makefile`, 但它其实相当好用, 尤其是, 当你修改完代码需要执行一大串命令时, 把这些命令都集合到 make 的一个 target 里, 直接一个命令就搞定了! 比如说, 你想把 change 部署到 beta, 需要三步, 就可以整理到 make 里!

+ 可以编写一个 deploy-sepolia 目标, 来实现一键部署, 不用再搞一长串的命令

  ```makefile
  -include .env
  
  build:
  	forge build
  	
  deploy-sepolia:
  	forge script script/DeployFundMe.s.sol:DeployFundMe --rpc-url $(SEPOLIA_RPC_URL) --private-key $(SEPOLIA_PRIVATE_KEY) --broadcast --verify --etherscan-api-key $(ETHERSCAN_API_KEY) -vvvv
  ```

  
