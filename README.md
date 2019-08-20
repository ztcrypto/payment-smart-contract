# Payment smart contract

The contract is used while buying BCERTs for fiat transactions. It validates PaymentID

## Fields

| Field | Type | Key words | Description |
|---|---|---|---|
| `owner` | `address` | `public` | Owner of the contract |
| `_transfers` | `mapping(string => Transfer)` | `private` | Stores information of all successful transfers |
| `_paymentIDs` | `mapping(string => bool)` | `private` | Payment IDs, that were used previously |
| `_admins` | `mapping(address => bool)` | `private` | Stores admins, who can transfer money from account |
| `_version` | `uint` | `private` | Counter of emitted events |

## Modifiers

| Modifier | Accepted values | Description |
|---|---|---|
| `onlyOwner` | -//- | only owner access modifier |
| `onlyAdmin` | -//- | only admin access modifier |

## Event codes

| Code | Value |
|---|---|
| `_contractCreatedCode` | `30001` |
| `_invalidPaymentIDCode` | `30002` |
| `_transferSuccessCode` | `30003` |
| `_balanceReplenishedCode` | `30004` |
| `_adminAddedCode` | `30005` |
| `_adminRemovedCode` | `30006` |
| `_insufficientFundsCode` | `30007` |

## Events

| Event | Accepted values | Description |
|---|---|---|
| `ContractCreated` | `uint code` - event code, `uint version` - version | Emits when contract created |
| `InvalidPaymentID` | `uint code` - event code, `uint version` - version, `string paymentID` - validated paymentID | Emits when given invalid paymentID for transfer |
| `TransferSuccess` | `uint code` - event code, `uint version` - version, `string paymentID` - validated paymentID, `address to` - address for transfering, `uint amount` - amount of BCERTs to transfer | Emits when transfer was successful |
| `BalanceReplenished` | `uint code` - event code, `uint version` - version, `uint amount` - transferred amount, `uint balance` - new value of balance | Emits when balance was replenished |
| `AdminAdded` | `uint code` - event code, `uint version` - version, `address newAdmin` - new admin | Emits when new admin added |
| `AdminRemoved` | `uint code` - event code, `uint version` - version, `address oldAdmin` - old admin | Emits when admin removed |
| `InsufficientFunds` | `uint code` - event code, `uint version` - version, `uint amount` - given amount of BCERTs, `uint balance` - current contract balance | Emits when BCERT amount for transfer is more than contract balance |

## Methods

| Method | Returned value | Argument | Key words | Description |
|---|---|---|---|---|
| `constructor` | -//- | `public` | Creates contract and adds owner to admins |
| -//- | -//- | -//- | `external payable` | Fallback function to replenish contract balance |
| `transfer` | -//- | `string paymentID` - validated payment ID, `address payable to` - address for transfering, `uint amount` - amount of BCERTs to transfer | `external` | Transfers BCERTs to account |
| `transfer` | -//- | `string paymentID` - validated paymentID, `address payable to` - address for transfering, `uint amount` - amount of BCERTs to transfer, `string extension` - additional data | `public` | Transfers BCERTs to account, fills extension field |
| `addAdmin` | -//- | `address newAdmin` - new admin | `public` | Adds admin to contract. Admin can transfer money from account |
| `removeAdmin` | -//- | `address oldAdmin` - old admin | `public` | Removes admin from contract |
