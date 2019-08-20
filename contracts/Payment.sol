pragma solidity >=0.4.22 <0.6.0;

/// @title Payment smart contract
/// @notice Used while buying BCERTs for fiat transactions. Validates PaymentID
contract Payment {

    /// @notice stores information about transfer
    struct Transfer {
        /// @notice unique transfer paymentID
        string paymentID;
        /// @notice who receives
        address receiver;
        /// @notice amount of money in transfer
        uint amount;
        /// @notice admin which calls transfer
        address admin;
        /// @notice space for more data
        string extension;
    }

    /// @notice contract owner
    address public owner;

    /// @notice stores all successful transfers
    mapping(string => Transfer) private _transfers;

    /// @notice stores payment IDs
    mapping(string => bool) private _paymentIDs;

    /// @notice stores admins
    mapping(address => bool) private _admins;

    /// @notice counts number of event
    uint private _version = 0;

    /// @notice event codes
    uint constant _contractCreatedCode = 30001;
    uint constant _invalidPaymentIDCode = 30002;
    uint constant _transferSuccessCode = 30003;
    uint constant _balanceReplenishedCode = 30004;
    uint constant _adminAddedCode = 30005;
    uint constant _adminRemovedCode = 30006;
    uint constant _insufficientFundsCode = 30007;

    /// @notice events
    event ContractCreated(uint code, uint version);
    event InvalidPaymentID(uint code, uint version, string paymentID);
    event TransferSuccess(uint code, uint version, string paymentID, address to, uint amount);
    event BalanceReplenished(uint code, uint version, uint amount, uint balance);
    event AdminAdded(uint code, uint version, address newAdmin);
    event AdminRemoved(uint code, uint version, address oldAdmin);
    event InsufficientFunds(uint code, uint version, uint amount, uint balance);

    /// @notice checks, whether the sender is owner
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    /// @notice checks, whether the sender is admin
    modifier onlyAdmin() {
        require(_admins[msg.sender], "Only admin can call this function");
        _;
    }

    /// @notice creates contract and adds owner to admins
    constructor() public {
        owner = msg.sender;
        _admins[msg.sender] = true;
        emit ContractCreated(_contractCreatedCode, _version++);
    }

    /// @notice fallback function, replenishes contract balance
    /// @dev emits event with new value of balance
    function () external payable {
        if (msg.value > 0) {
            emit BalanceReplenished(_balanceReplenishedCode, _version++, msg.value, address(this).balance);
        }
    }

    /// @notice transfers BCERTs to some account, invalidates paymentID, logs successful transfer
    /// @param paymentID previously used paymentID for invalidation
    /// @param to address to transfer BCERTs
    /// @param amount amount of BCERTS
    /// @param extension additional data
    /// @dev emits event when transfer succeed
    function transfer(string memory paymentID, address payable to, uint amount, string memory extension) public onlyAdmin() {
        uint balance = address(this).balance;
        if (amount > balance) {
            emit InsufficientFunds(_insufficientFundsCode, _version++, amount, balance);
            revert("Insufficient funds");
        }
        if (_paymentIDs[paymentID]) {
            emit InvalidPaymentID(_invalidPaymentIDCode, _version++, paymentID);
            revert("Payment ID was used before");
        }

        to.transfer(amount);
        _paymentIDs[paymentID] = true;

        Transfer memory newTransfer;
        newTransfer.paymentID = paymentID;
        newTransfer.receiver = to;
        newTransfer.amount = amount;
        newTransfer.admin = msg.sender;
        newTransfer.extension = extension;
        _transfers[paymentID] = newTransfer;

        emit TransferSuccess(_transferSuccessCode, _version++, paymentID, to, amount);
    }

    /// @notice transfers BCERTs to some account, invalidates paymentID, logs successful transfer
    /// @param paymentID previously used paymentID for invalidation
    /// @param to address to transfer BCERTs
    /// @param amount amount of BCERTS
    /// @dev emits event when transfer succeed
    function transfer(string calldata paymentID, address payable to, uint amount) external onlyAdmin() {
        transfer(paymentID, to, amount, "");
    }

    /// @notice adds admin to contract
    /// @param newAdmin address of new admin
    function addAdmin(address newAdmin) public onlyOwner() {
        _admins[newAdmin] = true;
        emit AdminAdded(_adminAddedCode, _version++, newAdmin);
    }

    /// @notice removes admin from contract
    /// @param oldAdmin address of removed admin
    function removeAdmin(address oldAdmin) public onlyOwner() {
        delete _admins[oldAdmin];
        emit AdminRemoved(_adminRemovedCode, _version++, oldAdmin);
    }
}