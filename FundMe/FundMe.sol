// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import {PriceConverter} from "./PriceConverter.sol";

error NotOwner();

contract FundMe {

    using PriceConverter for uint256;

    mapping(address => uint256) public addressToAmountFunded;
    address[] public funders;

    // Could we make this constant? /* hint: No! We should make it immutable! */
    address public /* immutable */ i_owner;
    // 21,508 - immutable
    // 23,644 - non-immutable
    uint256 public constant MINIMUM_USD = 5e18; // 5 * 10 ** 18
    // 21,415 gas - constant
    // 23,515 gas - non-constant
    // 21,415 * 141000000000 = $9.058545
    // 23,515 * 141000000000 = $9.946845

    constructor() {
        i_owner = msg.sender;
    }

    function fund() public payable {
        require(msg.value.getConversionRate() >= MINIMUM_USD, "Not enough ETH!");
        // required(PriceConverter.getConversionRate(msg.value) >= MINUMUM_USD, "Not enough ETH!");
        addressToAmountFunded[msg.sender] += msg.value;
        funders.push(msg.sender);
    }

    function getVersion() public view returns(uint256) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        return priceFeed.version();
    }

    modifier onlyOwner {
        // require(msg.sender == i_owner, "Sender is not owner!");
        if (msg.sender != i_owner) {revert NotOwner();}
        _;
    }

    function withdraw() public onlyOwner {
        // for loop
        // [1, 2, 3, 4] = elements
        //  0, 1, 2, 3  = indexes
        // (starting index; ending index; step amount)
        for (uint256 funderIndex=0; funderIndex < funders.length; funderIndex++){
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }
        funders = new address[](0);
        // msg.sender = address
        // payable(msg.sender) = payable address
        
        // // transfer
        // payable(msg.sender).transfer(address(this).balance);

        // // send
        // bool sendSuccess = payable(msg.sender).send(address(this).balance);
        // require(sendSuccess, "Send failed");

        // // call
        (bool callSuccess, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Call failed");
    }

// //  Explainer from: https://solidity-by-example.org/fallback/
// //     Ether is sent to contract 
// //         is msg.data empty?
// //             /   \
// //            yes  no
// //            /     \
// //     receive()?  fallback()
// //       /     \
// //     yea     no
// //     /         \
// //   receive()   fallback()

    fallback() external payable{
        fund();
    }

    receive() external payable{
        fund();
    }

}