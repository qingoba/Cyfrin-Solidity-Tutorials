## Simple Storage

Use *semicolon* at the end of each line to signify that a statement is complete.

Variables are just placeholders for **values**.

Commonly used data types in Solidity:

+ `bool`: true or false

+ `uint`: unsigned whole number (positive)

  > we can specify the number of bits used for `uint` and ` int`. For example, `uint256` specifies that the variable has 256 bits (`uint` is a shorthand for `uint256`)

+ `int`: signed whole number (positive and negative)

+ `address`: 20 bytes value. An example of an address can be found within your MetaMask account.

+ `bytes`: low-level raw byte data (actually a sequence)

  > The value types `bytes1`, `bytes2`, `bytes3`, …, `bytes32` hold a sequence of bytes from one to up to 32. And `bytes` hold dynamic size.
  >
  > **Strings** are internally represented as *dynamic byte arrays* (`bytes` type) and designed specifically for working with text. For this reason, a string can easily be converted into bytes.

+ Use brackets to specify an array, like `uint256[] alist = [1, 2, 3]`

  `[]` indicates a dynamic array, and `[x]` indicates a static array

+ Use keyword `struct` to combine any data types into a new customized data type

+ Declare a mapping: ` mapping (address => uint256) addressToBalance;`

  Access a non-exsit key in mapping will return zero (default value)

Every variable in Solidity comes with a *default value*. Uninitialized uint256 for example, defaults to `0` (zero) and an uninitialized boolean defaults to `false`.

***

Deploy Contracts

The process of sending a transaction is the **same** for deploying a contract and for sending Ethers. The only difference is that the machine-readable code of the deployed contract is placed inside the *data* field of the deployment transaction.

From the accounts section, it becomes visible that ETH is being consumed every time a transaction is submitted. When the state of the blockchain is modified (e.g. deploying a contract, sending ETH, ...), is done by sending a transaction that consumes **gas**. Executing the `store` function is more expensive than just transferring ETH between accounts, with the rising gas expenses primarily associated (though not exclusively) with the code length.

The default visibility of the variable in contract is **internal**, preventing external contracts and users from viewing it.

Appending the `public` keyword next to a variable will automatically change its visibility and it will generate a **getter function** (a function that gets the variable's value when called).

In Solidity, functions and variables can have one of these four **visibility** specifiers:

- **`public`**: accessible from both inside the contract and from external contracts
- **`private`**: accessible only within the *current contract*. It does not hide a value but only restricts its access.
- **`external`**: used only for *functions*. Visible **only** from *outside* the contract.
- **`internal`**: accessible by the current contract and any contracts *derived* from it.

Pure and View keywords:

+ The terms `view` and `pure` are used when a function reads values from the blockchain without altering its state. Such functions will not initiate transactions but rather make calls, represented as blue buttons in the Remix interface. A `pure` function will prohibit any reading from the state or storage.
+ While calling `view` or `pure` functions doesn’t typically require gas, they do require it when called by another function that modifies the state or storage through a transaction (e.g. calling the function `retrieve` inside the function `storage`). This cost is called **execution cost** and it will add up to the transaction cost.

***

Data Locations

+ Solidity can store data in six different locations: Calldata, Memory, Storage, Stack, Code, Logs
+ `calldata` and `memory` are temporary storage locations for variables during function execution. `calldata` is read-only, used for function inputs that can't be modified. In contrast, `memory` allows for read-write access, letting variables be changed within the function. To modify `calldata` variables, they must first be loaded into `memory`.
+ Most variable types default to a non-storage location automatically (like memory, the stack, etc). However, for strings, you must specify either memory, calldata, or storage due to the way arrays are handled in memory.
+ Calldata variables are read-only and cheaper than memory. They are mostly used for input parameters.
+ Variables stored in `storage` are persistent on the blockchain, retaining their values between function calls and transactions.
+  a `string` is recognized as an **array of bytes**. On the other hand, primitive types, like `uint256` have built-in mechanisms that dictate how and where they are stored, accessed and manipulated.

After contract deployment:

+ View and pure functions will not send transactions

## Storage Factory

Use `new` keyword to deploy a new contract instance.

Import

+ The `import` keyword enables a contract to utilize code from other files without needing to include the entire codebase directly within the contract. Here are two of the main advantages that the `import` keyword provides. **Named imports** allows you to selectively import only the specific contracts you intend to use: `import { SimpleStorage } from "./SimpleStorage.sol";`
+ All the solidity contracts should be compiled together using the *same compiler version*. It's important to ensure **consistency** between compiler versions across files since each one will have its own `pragma` statement.

Contract ABI

+ You can see contranct ABI after compilation, in the Remix compilation tab, click **'Compilation Details'** to see ABI, METADATA, BYTECODE and everything.
+ Every time you have to interact with another contract, you need:
  1. the contract **address**
  2. the contract **ABI (Application Binary Interface)**: a standardized way for interacting with the binary version of a smart contract deployed on the blockchain. It specifies the functions, their parameters, and the structure of the data that can be used to interact with the contract. It's generated by the compiler.
+ If you do not have the full ABI available, a function selector will suffice (see later in the course).
+ In Solidity, it's possible to **type cast** an *address* to a type *contract*

Inheritance:

+ virtual functions from parents' contract can be overridden by child contract, use keyword `virtual` after the visibility keyword, example `function store(uint256 favNumber) public virtual `
+ Use keyword `is` to inherit from parent contract, will auto obtain **all methods** from parent. Example: `contract AddFiveStorage is SimpleStorage {}`
+ Use keyword `override` to override a virtual function, example: `function store(uint256 number) public override {}`

## Fund Me

We want `FundMe` to perform the following tasks:

1. **Allow users to send funds into the contract:** users should be able to deposit funds into the 'FundMe' contract
2. **Enable withdrawal of funds by the contract owner:** the account that owns `FundMe` should have the ability to withdraw all deposited funds
3. **Set a minimum funding value in USD:** there should be a minimum amount that can be deposited into the contract

value and payable

+ When a transaction it's sent to the blockchain, a **value** field is always included in the *transaction data*. This field indicates the **amount** of the native cryptocurrency being transferred in that particular transaction.
+ For the function `fund` to be able to receive Ethereum, it must be declared **`payable`**. In the Remix UI, this keyword will turn the function red, signifying that it can accept cryptocurrency.
+ In Solidity, the **value** of a transaction is accessible through the [`msg.value`](https://docs.soliditylang.org/en/develop/units-and-global-variables.html#special-variables-and-functions) **property**. This property is part of the *global object* `msg`. It represents the amount of **Wei** transferred in the current transaction, where *Wei* is the smallest unit of Ether (ETH).
+ 1 Ether = 1e9 Gwei = 1e18 Wei
+ Gas costs are usually expressed in Gwei

Transaction Revert

+ Use `require` statement to add checker. If the specified requirement is not met, the transaction will revert. And the `require` statement can include a custom error message, as the second function argument.
+ The gas used in the transaction will not be refunded if the transaction fails due to a revert statement. The gas has already been **consumed** because the code was executed by the computers, even though the transaction was ultimately reverted.
+ If a transaction reverts, is defined as failed

Transaction Fields

+ During a **value** transfer, a transaction will contain the following fields:
  - **Nonce**: transaction counter for the account
  - **Gas price (wei)**: maximum price that the sender is willing to pay *per unit of gas*
  - **Gas Limit**: maximum amount of gas the sender is willing to use for the transaction. A common value could be around 21000.
  - **To**: *recipient's address*
  - **Value (Wei)**: amount of cryptocurrency to be transferred to the recipient
  - **Data**: 🫙 *empty*
  - **v,r,s**: components of the transaction signature. They prove that the transaction is authorised by the sender.
+ During a **contract interaction transaction**, it will instead be populated with:
  - **Data**: 📦 *the content to send to the **To** address*, e.g. a function and its parameters.

Oracles - How if we want to set the threshold to 5 USD instead of 1 Ether?

+ We can use oracles to get external data

+ Why blockchain need oracles?

  This blockchain limitation exists because of its **deterministic nature**, ensuring that all nodes univocally reach a consensus. Attempting to introduce external data into the blockchain, will disrupt this consensus, resulting in what is referred to as a *smart contract connectivity issue* or *the Oracle problem*.

  区块链是一个封闭系统，它不具备主动获取外部信息的能力. 区块链的核心特性是**确定性（deterministic）**：给定相同的输入，所有节点必须产生完全相同的输出。这是共识机制的基础。

  假设一个智能合约直接调用外部 API 获取 ETH 价格：

  \- 节点 A 在时刻 T1 查询，得到 $1800

  \- 节点 B 在时刻 T2 查询，得到 $1801

  \- 节点 C 查询时 API 超时，没有返回值

  三个节点得到了不同的结果 → 无法达成共识

+ For smart contracts to effectively replace traditional agreements (传统合同), they must have the capability to interact with **real-world data**.

  Relying on a centralized Oracle for data transmission is inadequate as it reintroduces potential failure points. Centralizing data sources can undermine the trust assumptions essential for the blockchain functionality. Therefore, centralized nodes are not enough for external data or computation needs. *Chainlink* addresses these centralization challenges by offering a decentralized Oracle Network.

How Chainlink Works

+ Chainlink is a *modular and decentralized Oracle Network* that enables the integration of data and external computation into a smart contract. When a smart contract combines on-chain and off-chain data, can be defined as **hybrid** and it can create highly feature-rich applications.

+ Chainlink offers ready-made features that can be added to a smart contract. And we'll address some of them:

  - **Data Feeds**

  - **Verifiable Random Number**

  - **Automation (previously known as "Keepers")**

  - **Functions**

+ *Chainlink Data Feeds* are responsible for powering over $50 billion in the DeFi world. This network of Chainlink nodes aggregates data from various **exchanges** and **data providers**, with each node independently verifying the asset price.

  They aggregate this data and deliver it to a reference contract, the **price feed contract**, in a single transaction. Each contract will store the pricing details of a specific cryptocurrency

+ Chainlink VRF. The Chainlink VRF (Verifiable Random Function) provides a solution for generating **provably random numbers**, ensuring true fairness in applications such as NFT randomization, lotteries, and gaming. These numbers are determined off-chain, and they are immune to manipulation.

+ Chainlink Automation (previously known as "Keepers"). Another great feature is Chainlink's system of *Keepers*. These **nodes** listen for specific events and, upon being triggered, automatically execute the intended actions within the calling contract.

  区块链上的合约是被动的——没有人发起交易调用它，它就永远不会运行。但很多场景需要"到了某个条件就自动执行"，例如借贷的清算, 这就是 Automation 和 Functions 要解决的。Chainlink Automation 是一个去中心化的合约自动执行服务。Chainlink 节点帮你监控链上条件，条件满足时自动调用你的合约函数。

+ Chainlink Function. Finally, *Chainlink Functions* allow **API calls** to be made within a decentralized environment. This feature is ideal for creating innovative applications and is recommended for advanced users with a thorough understanding of Chainlink ecosystem.

  Chainlink Functions 允许智能合约执行自定义的链下计算，并把结果返回链上。你可以用 JavaScript 写任意逻辑，由 Chainlink 节点在链下执行。

+ 关于对 Chainlink 的理解: Chainlink **不是**一个独立的区块链。它没有自己的链、不出块、不维护自己的账本。Chainlink 是一个**去中心化的预言机中间件网络**，它运行在现有区块链之上。你可以把它理解为一个"服务层"——它的节点在链下运行，但最终把数据交付到以太坊（或其他链）的智能合约上。

  ```
  你的智能合约（以太坊上）
      │
      │ 调用 view 函数（不消耗 Gas）
      ▼
  Chainlink 喂价合约（也部署在以太坊上）
      ▲
      │ 定期写入最新价格（消耗 Gas，由 Chainlink 节点支付）
      │
  Chainlink 预言机节点网络（链下运行）
      ▲
      │ 获取数据
      │
  各大交易所 / 数据提供商（链下
  ```

  **OCR（Off-Chain Reporting）协议的写入流程**

  参与某个喂价任务的节点（比如 21 个）会通过 OCR 协议协作：

  1. **所有节点**各自从多个数据源获取价格
  2. **所有节点**在链下通过 P2P 网络交换各自的观测值
  3. **所有节点**在链下对聚合结果（中位数）达成共识
  4. **所有节点**对这个结果进行加密签名
  5. **其中一个节点**被轮换选为"发送者（transmitter）"，把聚合结果 + 所有签名打包成一笔交易提交到链上

  ***

  对于开发者来说, 使用 Chainlink 的数据非常简单，本质上就是**读取一个已经部署在以太坊上的 Chainlink 合约**, 例如喂价合约 (Price Feed Contract)。

Solidity Interface

+ 前面我们曾经说过, 要与一个合约交互, 我们必须知道合约的地址以及合约的 ABI, 那么 what is ABI exactly?

  **ABI（Application Binary Interface）本质是一个 JSON 格式的描述文件**，告诉外界：这个合约有哪些函数、每个函数接受什么参数、返回什么类型。以太坊上的合约在链上是编译后的字节码（bytecode），人类和其他合约无法直接理解。ABI 就是"说明书"，告诉调用方怎么把函数调用编码成字节码能理解的格式。

+ 但实际上我们好像没有用过 ABI, 而是直接 import 就调用合约函数了, 应该是编译器帮你做好了.

  获取 ABI 有两种方式, 一种是导入完整合约代码, 类似 SimpleStorage, 另一种就是导入 Interface.

+ To utilize the Price Feed Contract, we need its address and its ABI. The address is available in the Chainlink documentation under the [Price Feed Contract Addresses](https://docs.chain.link/data-feeds/price-feeds/addresses). For our purposes, we'll use ETH/USD price feed.

  To obtain the ABI, you can import, compile, and deploy the PriceFeed contract itself. In the previous section, we imported the `SimpleStorage` contract into the `StorageFactory` contract, deployed it, and only then we were able to use its functions.

  An alternative method involves the use of an **Interface**, which defines methods signature without their implementation logic. If compiled, the Price Feed Interface, it would return the ABI of the Price Feed contract itself, which was previously deployed on the blockchain. We don't need to know anything about the function implementations, only knowing the `AggregatorV3Interface` methods will suffice. The Price Feed interface, called `Aggregator V3 Interface`, can be found in Chainlink's GitHub repository

Imports from GitHub or NPM (Node Package Manager)

+ Smart Contracts *hosted on GitHub* can be imported directly into your project. 

  For example, `import { AggregatorV3Interface } from @chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";`

+ The `@chainlink/contracts` package, available on NPM, follows **Semantic Versioning (SemVer)**, which allows you to download and use specific versions in your contracts (e.g., `npm install @chainlink/contracts@1.2.3`) while being directly *synchronized* with Chainlink's GitHub repository. The rest of the import path specifies the exact file that Remix should use.

+ `AggregatorV3Interface priceFeed = AggregatorV3Interface(0x1b44F35..);`

  `AggregatorV3Interface(0x1b44F35..)` 这是一个类型转换语句, 而不是合约实例化, 也不是调用构造函数.

  非常值得注意的是, 这里的地址是 Sepolia 测试网上 ETH/USD 的喂价合约, 将其部署到其他网络是没用的, 函数调用会被 revert, 但 revert 错误信息并不会显示是由于合约不存在!

  喂价合约列表: https://docs.chain.link/data-feeds/price-feeds/addresses, 对于 BTC/ETH 喂价合约, 返回的是用 ETH 衡量的 BTC 价格.

Decimals

+ 如果我们调用 AggregatorV3Interface.decimals() 会返回 8, 说明喂价合约返回的价格数据有 8 个小数位, 即实际的价格要除以 $10^8$

  > 为什么会这样? Solidity 不支持浮点数。所以链上没办法直接表示 \$1800.50 这样的价格。解决方式是用整数 + decimals 来表示小数, decimals 意味着整数中包含多少位小数, 用整数除以 $10^{decimals}$ 即可得到真正的价格.

+ `msg.value` is a `uint256` value with 18 decimal places.

  Price Feed's `answer` is an `int256` value with 8 decimal places (USD-based pairs use 8 decimal places, while ETH-based pairs use 18 decimal places).

  This means the `price` returned from our `latestRoundData` function isn't directly compatible with `msg.value`. To match the decimal places, we multiply `price` by $1e10$: `price * 1e10`

+ In Solidity, only integer values are used, as the language does not support floating-point numbers. So always multiply before dividing to maintain precision and avoid truncation errors. 

The `msg.sender` global variable refers to the address that **initiates the transaction**.

Library

+ When a functionality can be *commonly used*, we can create a **library** to efficiently manage repeated parts of codes.

+ Solidity libraries are similar to contracts but do not allow the declaration of any **state variables** and **cannot receive ETH**.

+ We can start by creating a new file called `PriceConverter.sol`, and replace the `contract` keyword with `library` to declare a library: `library PriceConverter {}`

+ To access the Library, just use import keyword. And we can use `use` keyword to make the library method acts as native type method, for example:

  ```solidity
  import {PriceConverter} from "./PriceConverter.sol";
  using PriceConverter for uint256;
  require(msg.value.getConversionRate() >= minimumUsd, "didn't send enough ETH");
  // msg.value will be passed as first argument of getConversionRate
  ```

+ 如果我们将 Library 的方法设置为 public, 发现一样是可以编译的, 那为什么还要求 Library method 必须为 internal 呢? 实际上, 库代码在编译时被**内联**到调用合约中，成为调用合约字节码的一部分。不需要单独部署库合约。调用时就像调用自己的函数一样，用的是普通的 JUMP 指令，Gas 开销小。

  如果使用了 public / external 函数, 那么库必须单独部署为一个独立合约，调用合约通过 DELEGATECALL 来调用它。一般来说, 库函数尽量用 internal，除非你有明确的理由需要共享一个已部署的库实例

Safemath

+ `SafeMath.sol` was a staple in Solidity contracts before version 0.8. After this version, its usage has significantly dropped.

  ```solidity
  // Example implementation of Safemath
  function add(uint a, uint b) public pure returns (uint) {
      uint c = a + b;
      require(c >= a, "SafeMath: addition overflow");
      return c;
  }
  ```

+ With the introduction of Solidity version 0.8, automatic checks for overflows and underflows were implemented, making `SafeMath` redundant for these checks.

+ For scenarios where mathematical operations are known not to exceed a variable's limit, Solidity introduced the `unchecked` construct to make code more *gas-efficient*. Wrapping the addition operation with `unchecked` will *ignore the overflow and underflow checks*: if the `bigNumber` exceeds the limit, it will wrap its value to zero.

  It's important to use unchecked blocks with caution as they reintroduce the possibility of overflows and underflows.

You can use statement `funders = new address[]()` to reset an array, where the `new` keyword is used.

Sending ETH from a Contract

+ 对于编译器来说, 只有 address payable 能够接受 ETH, 因此在发送 ETH 之前, 需要将接受者地址转换为 payable, 然后在其上调用方法.

+ There're three different methods of sending ETH from one account to another: `transfer`, `send`, and `call`

  ```solidity
  // transfer, gas limit 2300
  // the current contract sends the Ether amount to the msg.sender
  payable(msg.sender).transfer(amount); 
  
  // send, gas limit 2300, and will return false if revert
  bool success = payable(msg.sender).send(address(this).balance);
  require(success, "Send failed");
  
  // call, recommended
  (bool success, ) = payable(msg.sender).call{value: address(this).balance}("");
  require(success, "Call failed");
  ```

+ The `call` function is flexible and powerful. It can be used to call any function without requiring its ABI. It does not have a gas limit, and like `send`, it returns a boolean value instead of reverting like `transfer`. 在上面的例子中, value 指定发送多少 ETH，`("")` 表示不调用目标地址上的任何函数（纯转账）

Contract Constructor

+ constructor is a native method like `constructor() {}`
+ The constructor function is automatically called during contract deployment, within the same transaction that deploys the contract.
+ We can use the constructor to set the contract's owner immediately when deployment. Then use this owner in `withdraw` function to make sure only admin can do withdraw operation. `require(msg.sender == owner, "must be owner");`

Function Modifier

+ If we build a contract with multiple *administrative functions*, that should only be executed by the contract owner, we might repeatedly check the caller identity: `require(msg.sender == owner, "Sender is not owner");`

+ Modifiers in Solidity allow embedding **custom lines of code** within any function to modify its behaviour.

  ```solidity
  modifier onlyOwner {
      require(msg.sender == owner, "Sender is not owner");
      _;
  }
  ```

  The underscore `_` placed in the body is a placeholder for the modified function's code. When the function with the modifier is called, the code before `_` runs first, and if it succeeds, the function's code executes next.

+ To use modifier in function, just like `function withdraw(uint amount) public onlyOwner {}`

Constants and Immutable

+ To reduce gas usage, we can use the keywords `constant` and `immutable`. These keywords ensure the variable values remain unchanged.

+ For values known at **compile time**, use the `constant` keyword. It prevents the variable from occupying a storage slot, making it cheaper and faster to read. Using the `constant` keyword can save approximately 19,000 gas, which is close to the cost of sending ETH between two accounts.

  Naming conventions for `constant` are all caps with underscores in place of spaces (e.g., `MINIMUM_USD`).

+ `immutable` can be used for variables set at deployment time that will not change. The naming convention for `immutable` variables is to add the prefix `i_` to the variable name (e.g., `i_owner`).

Custom Errors:

+ Introduced in **Solidity 0.8.4**, custom errors can be used in `revert` statements. These errors should be declared at the top of the code and used in `if` statements. The cheaper error code is then called in place of the previous error message string, reducing gas costs.

+ Example:

  ```solidity
  error NotOwner();
  
  function withdrawCustomError() public {
      if (msg.sender != owner) {
          revert NotOwner();
      }
      clear();
  }
  ```

Receive and Fallback

+ In Solidity, if Ether is sent to a contract without a `receive` or `fallback` function, the transaction will be **rejected**, and the Ether will not be transferred.

  ```
  ETH 发送到合约
      │
      ├── msg.data 为空？
      │       │
      │       ├── 是 → receive() 存在？
      │       │       ├── 是 → 调用 receive()
      │       │       └── 否 → 调用 fallback()
      │       │
      │       └── 否（msg.data 不为空）→ 调用 fallback()
      │
      └── 两个都不存在 → revert
  ```

+ `receive` and `fallback` are *special functions* triggered when users send Ether directly to the contract or call non-existent functions. These functions do not return anything and must be declared `external`

  为了测试 receive 和 fallback, 可以直接用钱包向合约地址发起转账.

  `receive` 和 `fallback` 很像 constructor 是 native 函数, 声明时不需要加 function 前缀.

一些经验谈:

+ Here are the exact 6 steps to solve any problem you may face. 非常对, 其实工作中就应该这样!

  1. Tinker
  2. Ask Your AI
  3. Read Docs
  4. Web Search
  5. Ask in a Forum
  6. Ask on the Support Forum or GitHub
  7. Iterate

+ When encountering an error, limit your troubleshooting time to 15-20 minutes. If you can't resolve it after 15-20 minutes, copy the error message and use your resources to ask for help.

  **While AI tools like ChatGPT can be very helpful, it's important not to rely on them entirely. It's crucial to learn the material yourself first**

  或许最好的方式就是作者所说的, 遇到问题自己先 troubleshooting 一段时间, 实在没办法了, 再考虑使用 AI, 否则我们会失去思考的方式.

Next, we'll move on to the **Foundry** course. Foundry is a smart contract framework that will enhance our smart contract development skills, allowing us to create safer tests, deploy contracts programmatically, and more.