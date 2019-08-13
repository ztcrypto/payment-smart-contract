pragma solidity >=0.4.22 <0.6.0;

/// @title Payment smart contract
/// @notice Used while buying BCERTs for fiat transactions. Validates Payment Token
contract Payment {

    /// @notice stores information about transfer
    struct Transfer {
        /// @notice unique transfer token
        string token;
        /// @notice who receives
        address receiver;
        /// @notice amount of money in transfer
        uint amount;
        /// @notice admin which calls transfer
        address admin;
        /// @notice space for more data
        string extension;
    }

    /// @notice stores all successful transfers
    mapping(string => Transfer) private _transfers;

    /// @notice contract owner
    address public owner;

    /// @notice contract balance
    uint public balance;

    /// @notice stores used tokens
    mapping(string => bool) private _usedTokens;

    /// @notice stores admins
    mapping(address => bool) private _admins;

    /// @notice counts number of event
    uint private _version = 0;

    /// @notice event codes
    uint constant _contractCreatedCode = 30001;
    uint constant _tokenValidatedCode = 30002;
    uint constant _transferSuccessCode = 30003;
    uint constant _balanceReplenishedCode = 30004;
    uint constant _adminAdded = 30005;
    uint constant _adminRemoved = 30006;

    /// @notice events
    event ContractCreated(uint code, uint version);
    event TokenValidated(uint code, uint version, string token, bool isValid);
    event TransferSuccess(uint code, uint version, string token, address to, uint amount);
    event BalanceReplenished(uint code, uint version, uint oldBalance, uint amount, uint newBalance);
    event AdminAdded(uint code, uint version, address newAdmin);
    event AdminRemoved(uint code, uint version, address oldAdmin);

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

    /// @notice checks, if the token was used before
    /// @param token string, which is used for validation
    /// @return if token is valid
    /// @dev emits event when token was checked
    function validate(string calldata token) external returns(bool) {
        bool isValid = !_usedTokens[token];
        emit TokenValidated(_tokenValidatedCode, _version++, token, isValid);
        return isValid;
    }

    /// @notice fallback function, replenishes contract balance
    /// @dev emits event with new value of balance
    function () external payable {
        if (msg.value > 0) {
            uint oldBalance = balance;
            balance += msg.value;
            emit BalanceReplenished(_balanceReplenishedCode, _version++, oldBalance, msg.value, balance);
        }
    }

    /// @notice transfers BCERTs to some account, invalidates token, logs successful transfer
    /// @param token previously used token for invalidation
    /// @param to address to transfer BCERTs
    /// @param amount amount of BCERTS
    /// @param extension additional data
    /// @dev emits event when transfer succeed
    function transfer(string memory token, address payable to, uint amount, string memory extension) public onlyAdmin() {
        require(amount <= balance, "Insufficient funds");

        to.transfer(amount);
        balance -= amount;
        _usedTokens[token] = true;

        Transfer memory newTransfer;
        newTransfer.token = token;
        newTransfer.receiver = to;
        newTransfer.amount = amount;
        newTransfer.admin = msg.sender;
        newTransfer.extension = extension;
        _transfers[token] = newTransfer;

        emit TransferSuccess(_transferSuccessCode, _version++, token, to, amount);
    }

    /// @notice transfers BCERTs to some account, invalidates token, logs successful transfer
    /// @param token previously used token for invalidation
    /// @param to address to transfer BCERTs
    /// @param amount amount of BCERTS
    /// @dev emits event when transfer succeed
    function transfer(string calldata token, address payable to, uint amount) external onlyAdmin() {
        transfer(token, to, amount, "");
    }

    /// @notice adds admin to contract
    /// @param newAdmin address of new admin
    function addAdmin(address newAdmin) public onlyAdmin() {
        _admins[newAdmin] = true;
        emit AdminAdded(_adminAdded, _version++, newAdmin);
    }

    /// @notice removes admin from contract
    /// @param oldAdmin address of removed admin
    function removeAdmin(address oldAdmin) public onlyAdmin() {
        delete _admins[oldAdmin];
        emit AdminRemoved(_adminRemoved, _version++, oldAdmin);
    }
}