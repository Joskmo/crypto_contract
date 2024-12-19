// SPDX-License-Identifier: GPL-3.0


pragma solidity >=0.8.2 <0.9.0;

contract EstateAgency {
    struct Estate{
        address owner;
        string info;
        uint area;
        bool is_banned;
        bool on_sale;
    }

    struct Sale {
        uint EstateID;
        address owner;
        address newOwner;
        uint price;
        address[] buyers;
        uint[] bids;
    }

    Estate[] public estates;
    Sale[] public sales;

    address admin;

    modifier isAdmin() {
        require(msg.sender == admin, "Admin only");
        _;
    }

    modifier isOwner(uint estateID) {
        require(estateID < estates.length, "Invalid estateID");
        require(msg.sender == estates[estateID].owner, "Owner only");
        _;
    }

    constructor() {
        admin = msg.sender;
    }

    // Administration functions
    function createEstate(address owner, string memory info, uint area) public isAdmin {
        require(owner != address(0), "Invalid address");
        require(area > 0, "Area must be positive");

        estates.push(Estate(owner, info, area, false, false));
    }

    function banEstate(uint estateID) public isAdmin {
        require(!estates[estateID].is_banned, "Already banned");
        estates[estateID].is_banned = true;
    } 

    function unbanEstate(uint estateID) public isAdmin {
        require(estates[estateID].is_banned, "Already unbanned");
        estates[estateID].is_banned = false;
    }

    // Sell functions
    function createSale(uint estateID, uint price) public isOwner(estateID) {
        require(price > 10**9 wei, "Price is too low");
        require(!estates[estateID].is_banned, "Estate is banned");
        require(!estates[estateID].on_sale, "Already on sale");

        address[] memory buyers;
        uint[] memory bids;

        sales.push(Sale(estateID, estates[estateID].owner, address(0), price, buyers, bids));
        estates[estateID].on_sale = true;
    }

    // Buyes functions
    function makeBid(uint saleID) public payable {
        require(saleID < sales.length, "Wrong saleID");
        require(msg.value >= sales[saleID].price, "Price is too low");
        require(msg.sender != sales[saleID].owner, "SelfSelling");
        require(sales[saleID].newOwner == address(0), "Sale is closed");
        
    }
}

// storage - для хранилища контрактов
// memory - для локальной памяти