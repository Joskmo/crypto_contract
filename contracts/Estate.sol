// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

contract EstateAgency {
    struct Estate{
        address owner;
        string info;
        uint area;
        bool is_banned;
        bool on_sale;
        bool on_gift;
    }

    struct Sale {
        uint EstateID;
        address owner;
        address newOwner;
        uint price;
        address[] buyers;
        uint[] bids;
    }

    struct Gift {
        uint estateID;
        address owner;
        address recipient;
        bool is_active;
    }

    Estate[] public estates;
    Sale[] public sales;
    Gift[] public gifts;

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

        estates.push(Estate(owner, info, area, false, false, false));
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

    // Buyers functions
    function makeBid(uint saleID) public payable {
        require(saleID < sales.length, "Wrong saleID");
        require(msg.value >= sales[saleID].price, "Price is too low");
        require(msg.sender != sales[saleID].owner, "SelfSelling");
        require(sales[saleID].newOwner == address(0), "Sale is closed");
        
    }

    // Gift functions
    function createGift(uint estateID, address recipient) public isOwner(estateID) {
        require(!estates[estateID].is_banned, "Estate is banned");
        require(!estates[estateID].on_sale, "Estate is on sale");
        require(!estates[estateID].on_gift, "Estate is already in gift process");
        require(recipient != address(0), "Invalid recipient");

        gifts.push(Gift(estateID, msg.sender, recipient, true));
        estates[estateID].on_gift = true;
    }

    function acceptGift(uint giftID) public {
        require(giftID < gifts.length, "Invalid giftID");
        Gift storage gift = gifts[giftID];

        require(gift.is_active, "Gift is not active");
        require(gift.recipient == msg.sender, "Not the recipient");

        estates[gift.estateID].owner = msg.sender;
        estates[gift.estateID].on_gift = false;
        gift.is_active = false;
    }

    function declineGift(uint giftID) public {
        require(giftID < gifts.length, "Invalid giftID");
        Gift storage gift = gifts[giftID];

        require(gift.is_active, "Gift is not active");
        require(gift.recipient == msg.sender, "Not the recipient");

        estates[gift.estateID].on_gift = false;
        gift.is_active = false;
    }

    function cancelGift(uint giftID) public {
        require(giftID < gifts.length, "Invalid giftID");
        Gift storage gift = gifts[giftID];

        require(gift.is_active, "Gift is not active");
        require(gift.owner == msg.sender, "Not the owner");

        estates[gift.estateID].on_gift = false;
        gift.is_active = false;
    }
}
