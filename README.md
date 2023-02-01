# Tellor Medians

This is a suite of contracts that can pull data from Balancer price feeds. There are contracts that can build a TWAP from a specific price feed as well as contracts that simply read the current result from a feed.

Contracts that require state updates can be connected to a separate contract that pays out rewards for updates in the form of GEB system coins.

Balancer docs: https://dev.balancer.fi/resources/pool-interfacing/oracle-pools