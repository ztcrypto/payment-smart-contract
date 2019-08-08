pragma solidity >=0.4.22 <0.6.0;

/// @title Payment smart contract
/// @notice Used while buying BCERTs for fiat transactions. Validates Payment Token
contract Payment {

    /// @notice contract balance
    uint public balance;

    /// @notice stores used tokens
    mapping(string => bool) private _usedTokens;

    /// @notice event codes
    uint constant _tokenValidatedCode = 10007;
    uint constant _transferSuccessCode = 10008;
    uint constant _transferDeclineCode = 10009;
    uint constant _balanceReplenishedCode = 10010;

    /// @notice events
    event TokenValidated(uint code, string token, bool isValid);
    event TransferSuccess(uint code, address to, uint amount);
    event TransferDecline(uint code, address to, uint amount);
    event BalanceReplenished(uint code, uint oldBalance, uint newBalance);

    /// @notice checks, if the token was used before
    /// @param token string, which is used for validation
    /// @return if token is valid
    /// @dev emits event when token was checked
    function validate(string calldata token) external returns(bool) {
        bool isValid = !_usedTokens[token];
        emit TokenValidated(_tokenValidatedCode, token, isValid);
        return isValid;
    }

    /// @notice replenishes contract balance
    /// @dev emits event with new value of balance
    function replenish() external payable {
        uint oldBalance = balance;
        balance += msg.value;
        emit BalanceReplenished(_balanceReplenishedCode, oldBalance, balance);
    }

    /// @notice transfers BCERTs to some account, invalidates token, logs successful transfer
    /// @param token previously used token for invalidation
    /// @param to address to transfer BCERTs
    /// @param amount amount of BCERTS
    /// @dev emits event when transfer succeed
    function transfer(string calldata token, address payable to, uint amount) external {
        require(amount <= balance, "Insufficient funds");

        address(to).transfer(amount);
        balance -= amount;
        _usedTokens[token] = true;
        emit TransferSuccess(_transferSuccessCode, to, amount);
    }

    /// @notice logs declined transfer
    /// @param to address to transfer BCERTs
    /// @param amount amount of BCERTS
    /// @dev emits event to log declining
    function declain(address payable to, uint amount) external {
        emit TransferDecline(_transferDeclineCode, to, amount);
    }
}