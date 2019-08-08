# Payment smart contract

The contract is used while buying BCERTs for fiat transactions. It validates Payment Token

## Fields

| Field | Type | Key words | Description |
|---|---|---|---|
| `balance` | `uint` | `public` | Current balance of the account |
| `usedTokens` | `mapping(string => bool)` | `private` | Tokens, that were used previously |

## Constants

| Constant | Type | Value | Description |
|---|---|---|---|
| `_tokenValidatedCode` | `uint` | `10007` | Code for `TokenValidated` event |
| `_transferSuccessCode` | `uint` | `10008` | Code for `TransferSuccess` event |
| `_transferDeclineCode` | `uint` | `10009` | Code for `TransferDecline` event |
| `_balanceReplenishedCode` | `uint` | `10010` | Code for `BalanceReplenished` event |

## Events

| Event | Accepted values | Description |
|---|---|---|
| `TokenValidated` | `uint code` - event code, `string token` - validated token, `bool isValid` - is token valid | Emits when token validated |
| `TransferSuccess` | `uint code` - event code, `address to` - address for transfering, `uint amount` - amount of BCERTs to transfer | Emits when transfer was successful |
| `TransferDecline` | `uint code` - event code, `address to` - address for transfering, `uint amount` - amount of BCERTs to transfer | Emits to log declined transfer |
| `BalanceReplenished` | `uint code` - event code, `uint oldBalance` - old value of balance, `uint newBalance` - new value of balance | Emits when balance was replenished |

## Methods

| Method | Returned value | Argument | Key words | Description |
|---|---|---|---|---|
| `validate` | `bool` | `string token` - token for validation | `external` | Validates token (check if was used before) |
| `replenish` | -//- | -//- | `external payable` | Replenished contract balance |
| `transfer` | -//- | `string token` - validated token, `address payable to` - address for transfering, `uint amount` - amount of BCERTs to transfer | `external` | Transfers BCERTs to account |
| `decline` | -//- | `address payable to` - address for transfering, `uint amount` - amount of BCERTs to transfer | `external` | Logs that transfer was declined |
