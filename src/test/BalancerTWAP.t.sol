pragma solidity 0.6.7;
pragma experimental ABIEncoderV2;

import "ds-test/test.sol";

import "../BalancerTWAP.sol";

abstract contract Hevm {
    function warp(uint256) virtual public;
}

contract BalancerPoolMock is BalancerPoolLike {
    uint result;

    function updateResult(uint next) external {
        result = next;
    }
    function getTimeWeightedAverage(OracleAverageQuery[] calldata /* queries */) external override view returns (uint256[] memory) {
        uint[] memory results = new uint[](1);
        results[0] = result;
        return results;
    }
    function getLatest(Variable /* variable */) external override view returns (uint256) {
        return result;
    }
}

contract BalancerTWAPTest is DSTest {
    BalancerPoolMock pool;
    BalancerTWAP relayer;

    function setUp() public {
        pool = new BalancerPoolMock();
        pool.updateResult(5 ether);
        relayer = new BalancerTWAP(address(pool), BalancerPoolLike.Variable.PAIR_PRICE, 1 hours, 30);
    }

    function test_constructor() public {
        assertEq(address(relayer.balancerPool()), address(pool));
    }
    function test_read() public {
        assertEq(relayer.read(), 5 ether);
    }
    function testFail_read_null() public {
        pool.updateResult(0);
        relayer.read();
    }
    function test_getResultWithValidity() public {
        (uint price, bool ok) = relayer.getResultWithValidity();
        assertEq(price, 5 ether);
        assertTrue(ok);
    }
    function test_getResultWithValidity_null_price() public {
        pool.updateResult(0);
        (uint price, bool ok) = relayer.getResultWithValidity();
        assertEq(price, 0);
        assertTrue(!ok);
    }
    function test_updateResult() public {
        relayer.updateResult(address(0x1));
    }
}
