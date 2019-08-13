# Payment smart contract

The contract is used while buying BCERTs for fiat transactions. It validates Payment Token

## Fields

| Field | Type | Key words | Description |
|---|---|---|---|
| `owner` | `address` | `public` | Owner of the contract |
| `balance` | `uint` | `public` | Current balance of the account |
| `_usedTokens` | `mapping(string => bool)` | `private` | Tokens, that were used previously |
| `_version` | `uint` | `private` | Counter of emitted events |
| `_transfer` | `mapping(string => Transfer)` | `private` | Stores information of all successful transfers |
| `_admins` | `mapping(address => bool)` | `private` | Stores admins, who can transfer money from account |

## Modifiers

| Modifier | Accepted values | Description |
|---|---|---|
| `onlyOwner` | -//- | only owner access modifier |
| `onlyAdmin` | -//- | only admin access modifier |

## Event codes

| Code | Value |
|---|---|
| `_contractCreatedCode` | `30001` |
| `_tokenValidatedCode` | `30002` |
| `_transferSuccessCode` | `30003` |
| `_balanceReplenishedCode` | `30004` |
| `_adminAdded` | `30005` |
| `_adminRemoved` | `30006` |

## Events

| Event | Accepted values | Description |
|---|---|---|
| `ContractCreated` | `uint code` - event code, `uint version` - version | Emits when contract created |
| `TokenValidated` | `uint code` - event code, `uint version` - version, `string token` - validated token, `bool isValid` - is token valid | Emits when token validated |
| `TransferSuccess` | `uint code` - event code, `uint version` - version, `string token` - validated token, `address to` - address for transfering, `uint amount` - amount of BCERTs to transfer | Emits when transfer was successful |
| `BalanceReplenished` | `uint code` - event code, `uint version` - version, `uint oldBalance` - old value of balance, `uint amount` - transferred amount, `uint newBalance` - new value of balance | Emits when balance was replenished |
| `AdminAdded` | `uint code` - event code, `uint version` - version, `address newAdmin` - new admin | Emits when new admin added |
| `AdminRemoved` | `uint code` - event code, `uint version` - version, `address oldAdmin` - old admin | Emits when admin removed |

## Methods

| Method | Returned value | Argument | Key words | Description |
|---|---|---|---|---|
| `validate` | `bool` | `string token` - token for validation | `external` | Validates token (check if was used before) |
| -//- | -//- | -//- | `external payable` | Fallback function to replenish contract balance |
| `transfer` | -//- | `string token` - validated token, `address payable to` - address for transfering, `uint amount` - amount of BCERTs to transfer | `external` | Transfers BCERTs to account |
| `transfer` | -//- | `string token` - validated token, `address payable to` - address for transfering, `uint amount` - amount of BCERTs to transfer, `string extension` - additional data | `public` | Transfers BCERTs to account, fills extension field |
| `addAdmin` | -//- | `address newAdmin` - new admin | `public` | Adds admin to contract. Admin can transfer money from account |
| `removeAdmin` | -//- | `address oldAdmin` - old admin | `public` | Removes admin from contract |
