pragma solidity >=0.4.22 <0.6.0;

import "truffle/Assert.sol";
import "../contracts/Payment.sol";

contract TestPayment {
    uint public initialBalance = 10000 wei;

    function testValidateWithNewToken() public {
        Payment pc = new Payment();
        string memory token = "asd";

        Assert.isTrue(pc.validate(token), "Should be valid");
    }

    function testReplenish() public {
        Payment pc = new Payment();

        uint contractBalance = address(pc).balance;
        uint amount = 200 wei;
        (bool result,) = address(pc).call.value(amount).gas(200000)("");
        Assert.isTrue(result, "Can't provide test transaction");

        Assert.equal(pc.balance(), contractBalance + amount, "Public balance should be increased by amount");
        Assert.equal(address(pc).balance, pc.balance(),
                     "Global variable 'balance' should have same value as public balance");
    }

    function testTransfer() public {
        Payment pc = new Payment();

        uint amount = 100 wei;
        (bool result,) = address(pc).call.value(amount).gas(200000)("");
        Assert.isTrue(result, "Can't provide test transaction");

        string memory token = "aaaaaaaaaaaa";
        address payable to = address(0x0001123);
        uint receiverBalance = address(to).balance;

        uint contractBalance = pc.balance();
        Assert.isTrue(pc.validate(token), "Should be valid");
        pc.transfer(token, to, amount);
        Assert.isFalse(pc.validate(token), "Should be invalid");

        Assert.equal(address(to).balance, receiverBalance + amount,
                     "Receiver didn't get transferred amount of ether");

        Assert.equal(pc.balance(), contractBalance - amount, "Public balance should be (old balance - transferred amount)");
        Assert.equal(address(pc).balance, pc.balance(),
                     "Global 'balance' should have same value as public balance");
    }
}