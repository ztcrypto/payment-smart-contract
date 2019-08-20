pragma solidity >=0.4.22 <0.6.0;

import "truffle/Assert.sol";
import "../contracts/Payment.sol";
import "./ThrowProxy.sol";

contract TestPayment {
    uint public initialBalance = 10000 wei;

    function testReplenish() public {
        Payment pc = new Payment();

        uint contractBalance = address(pc).balance;
        uint amount = 200 wei;
        (bool result,) = address(pc).call.value(amount).gas(200000)("");
        Assert.isTrue(result, "Can't provide transfer");
        Assert.equal(address(pc).balance, contractBalance + amount, "Contract balance should be increased by amount");
    }

    function testTransfer() public {
        Payment pc = new Payment();

        uint initAmount = 1000;
        (bool result,) = address(pc).call.value(initAmount).gas(200000)("");
        Assert.isTrue(result, "Can't provide transfer");

        uint amount = 100 wei;
        string memory paymentID = "paymentID";
        address payable to = address(0x1111);
        uint receiverBalance = address(to).balance;
        uint contractBalance = address(pc).balance;

        pc.transfer(paymentID, to, amount);
        Assert.equal(address(to).balance, receiverBalance + amount,
                     "Receiver didn't get transferred amount");
        Assert.equal(address(pc).balance, contractBalance - amount,
                     "Contract balance should be decreased by transferred amount)");

        ThrowProxy admin = new ThrowProxy(address(pc));

        address payable pAdmin = address(uint160(address(admin)));

        string memory newPaymentID = "another one";

        // test for non-admin transfer
        Payment(pAdmin).transfer(newPaymentID, to, amount);
        result = admin.execute.gas(200000)();
        Assert.isFalse(result, "Should throw because admin wasn't added");

        pc.addAdmin(address(admin));

        // test for admin transfer
        receiverBalance = address(to).balance;
        Payment(pAdmin).transfer(newPaymentID, to, amount);
        result = admin.execute.gas(200000)();
        Assert.isTrue(result, "Shouldn't throw because new admin was added");
        Assert.equal(address(to).balance, receiverBalance + amount,
                     "Receiver didn't get transferred amount");

        // test for invalid payment ID
        Payment(pAdmin).transfer(newPaymentID, to, amount);
        result = admin.execute.gas(200000)();
        Assert.isFalse(result, "Should throw because of invalid payment ID");

        // test for insufficient funds
        Payment(pAdmin).transfer(newPaymentID, to, 1000000000);
        result = admin.execute.gas(200000)();
        Assert.isFalse(result, "Should throw because of insufficient funds");

        pc.removeAdmin(address(admin));

        // test for invalid payment ID
        string memory otherPaymentID = "and another one";
        Payment(pAdmin).transfer(otherPaymentID, to, amount);
        result = admin.execute.gas(200000)();
        Assert.isFalse(result, "Should throw because admin was removed");
    }
}