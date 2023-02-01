pragma solidity 0.6.7;
pragma experimental ABIEncoderV2;

import "./GebMath.sol";

abstract contract BalancerPoolLike {
    enum Variable { PAIR_PRICE, BPT_PRICE, INVARIANT }

    // variable - One of { PAIR_PRICE, BPT_PRICE, INVARIANT }
    // secs - The duration of the query in seconds
    // ago - The time in seconds from since end of that duration.
    struct OracleAverageQuery {
        Variable variable;
        uint256 secs;
        uint256 ago;
    }
    function getTimeWeightedAverage(OracleAverageQuery[] calldata queries) external virtual view returns (uint256[] memory results);
    function getLatest(Variable variable) external virtual view returns (uint256);
}



contract BalancerRelayer is GebMath {
    // --- Variables ---
    // Multiplier for the balancer price feed in order to scaled it to 18 decimals.
    uint8   public constant multiplier = 0;

    bytes32 public constant symbol = "ethusd";

    // Balancer
    BalancerPoolLike public immutable balancerPool;

    BalancerPoolLike.Variable public immutable poolVariable;

    constructor(
      address balancerPool_,
      BalancerPoolLike.Variable poolVariable_
    ) public {
        require(balancerPool_ != address(0), "BalancerRelayer/null-balancer-address");

        balancerPool                   = BalancerPoolLike(balancerPool_);
        poolVariable                   = poolVariable_;
    }
    // --- Main Getters ---
    /**
    * @notice Fetch the latest medianResult or revert if is response is null
    **/
    function read() external view returns (uint256) {
        uint256 medianPrice = multiply(balancerPool.getLatest(poolVariable), 10 ** uint(multiplier));

        require(medianPrice > 0, "BalancerRelayer/invalid-price-feed");
        return medianPrice;
    }
    /**
    * @notice Fetch the latest medianResult and whether it is valid or not
    **/
    function getResultWithValidity() external view returns (uint256, bool) {
        uint256 medianPrice = multiply(balancerPool.getLatest(poolVariable), 10 ** uint(multiplier));

        return (medianPrice, medianPrice > 0);
    }

    // --- Median Updates ---
    /*
    * @notice Remnant from other Balancer medians
    */
    function updateResult(address feeReceiver) external {}
}
