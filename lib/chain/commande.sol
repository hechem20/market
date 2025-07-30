// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract OrderManager {
    struct Order {
        string productName;
        uint price;
        string clientName;
        string clientAddressText;
        address clientWallet;
    }

    Order[] public orders;

    event OrderAdded(string productName, uint price, string clientName, string clientAddressText, address indexed clientWallet);

    function addOrder(
        string memory _productName,
        uint _price,
        string memory _clientName,
        string memory _clientAddressText
    ) public {
        Order memory newOrder = Order({
            productName: _productName,
            price: _price,
            clientName: _clientName,
            clientAddressText: _clientAddressText,
            clientWallet: msg.sender
        });

        orders.push(newOrder);
        emit OrderAdded(_productName, _price, _clientName, _clientAddressText, msg.sender);
    }

    function getAllOrders() public view returns (Order[] memory) {
        return orders;
    }

    function getOrderCount() public view returns (uint) {
        return orders.length;
    }
}
