// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VendorProductStore {
    address public owner;

    struct Product {
        uint id;
        string name;
        uint price; // en wei
        uint benefit;
        string qrCodeHash;
        address payable seller;
        bool exists;
    }

    uint public nextId = 1;
    mapping(uint => Product) public products;
    uint public totalBenefit;
    mapping(address => uint) public sellerProfits;

    event ProductAdded(uint indexed id, string name, uint price, uint benefit, address seller);
    event ProductUpdated(uint indexed id, string name, uint price, uint benefit);
    event ProductDeleted(uint indexed id);
    event ProductPurchased(uint indexed id, address buyer, address seller, uint price);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    modifier onlySeller(uint id) {
        require(products[id].seller == msg.sender, "Not the seller of this product");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function addProduct(string memory name, uint price, uint benefit, string memory qrCodeHash) external {
        products[nextId] = Product({
            id: nextId,
            name: name,
            price: price,
            benefit: benefit,
            qrCodeHash: qrCodeHash,
            seller: payable(msg.sender),
            exists: true
        });
        totalBenefit += benefit;
        emit ProductAdded(nextId, name, price, benefit, msg.sender);
        nextId++;
    }

    function updateProduct(uint id, string memory name, uint price, uint benefit) external onlySeller(id) {
        require(products[id].exists, "Product not found");
        totalBenefit = totalBenefit - products[id].benefit + benefit;
        products[id].name = name;
        products[id].price = price;
        products[id].benefit = benefit;
        emit ProductUpdated(id, name, price, benefit);
    }

    function deleteProduct(uint id) external onlySeller(id) {
        require(products[id].exists, "Product not found");
        totalBenefit -= products[id].benefit;
        delete products[id];
        emit ProductDeleted(id);
    }

    function buyProduct(uint id) external payable {
        Product memory product = products[id];
        require(product.exists, "Product not found");
        require(msg.value >= product.price, "Not enough USDT (msg.value)");

        product.seller.transfer(product.price);
        sellerProfits[product.seller] += product.price;

        emit ProductPurchased(id, msg.sender, product.seller, product.price);
    }

    function getProduct(uint id) external view returns (Product memory) {
        return products[id];
    }

    function getAllProducts() external view returns (Product[] memory) {
        uint count = 0;
        for (uint i = 1; i < nextId; i++) {
            if (products[i].exists) {
                count++;
            }
        }

        Product[] memory all = new Product[](count);
        uint j = 0;
        for (uint i = 1; i < nextId; i++) {
            if (products[i].exists) {
                all[j] = products[i];
                j++;
            }
        }
        return all;
    }

    function getSellerProfit(address seller) external view returns (uint) {
        return sellerProfits[seller];
    }

    function getTotalBenefit() external view returns (uint) {
        return totalBenefit;
    }
}
