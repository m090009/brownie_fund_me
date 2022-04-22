// SPDX-License-Identifier: MIT

pragma solidity >=0.6.6 <0.9.0;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract FundMe {
    mapping(address => uint256) public addressToAmountFunded;
    address[] public funders;
    AggregatorV3Interface public priceFeed;
    address public owner;

    constructor(address _priceFeed) public {
        owner = msg.sender;
        priceFeed = AggregatorV3Interface(_priceFeed);
    }

    // Payable function value like stake or claim
    function fund() public payable {
        // msg.sender is the function call sender
        // msg.value is how much they sent in wei

        // Set funding threshold to 50
        uint256 minimumUSD = 50 * 10**18;
        require(
            getConversionRate(msg.value) >= minimumUSD,
            "You need to spend more ETH!"
        );
        addressToAmountFunded[msg.sender] += msg.value;
        funders.push(msg.sender);
        // ETH -> USD convestion rate
        // Chainlink
    }

    function getVersion() public view returns (uint256) {
        AggregatorV3Interface priceFeed = priceFeed;
        return priceFeed.version();
    }

    function getPrice() public view returns (uint256) {
        (, int256 answer, , , ) = priceFeed.latestRoundData();
        return uint256(answer * 10000000000); // in wei
    }

    // 1000000000
    function getConversionRate(uint256 ethAmount)
        public
        view
        returns (uint256)
    {
        uint256 ethPrice = getPrice();
        // Price of one Gwei
        uint256 ethAmountInUSD = (ethPrice * ethAmount) / 100000000;
        return ethAmountInUSD;
        //0.00003300177328970
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _; //Execute the code after the require
    }

    //Add the modifier to the definition of the method
    function withdraw() public payable onlyOwner {
        payable(msg.sender).transfer(address(this).balance);

        for (
            uint256 funderIndex = 0;
            funderIndex < funders.length;
            funderIndex++
        ) {
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }
        funders = new address[](0);
    }

    function getEntranceFee() public view returns (uint256) {
        // minimumUSD
        uint256 minimumUSD = 50 * 10**18;
        uint256 price = getPrice();
        uint256 precision = 1 * 10**8;
        return ((minimumUSD * precision) / price) + 1;
    }
}
