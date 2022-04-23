// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Moonbirds.sol";
import "../src/Crow.sol";

contract CrowTest is Test {
    /// variables
    uint256 moonbirdId = 2968;
    address moonbirdOwner = 0x8bab29A0dad122B770F095f1E130ded4ceC30a52;
    address moonbirdContract = 0x23581767a106ae21c074b2276D25e5C3e136a68b;
    Moonbirds moonbird = Moonbirds(moonbirdContract);
    address user2 = address(0x2);
    Crow crow;

    function setUp() public {
        // setup crow as moonbird owner
        vm.prank(moonbirdOwner);
        crow = new Crow(moonbirdContract);
    }

    function testCheckMoonbird() public {
        (bool nesting, uint256 current, uint256 total) = moonbird.nestingPeriod(moonbirdId);
        assertTrue(nesting);
        assertTrue(current > 0);
        assertTrue(total > 0);
    }

    function testTransferMoonbird() public {
        vm.startPrank(moonbirdOwner);
        vm.expectRevert("Moonbirds: nesting");
        moonbird.safeTransferFrom(moonbirdOwner, user2, moonbirdId);
        moonbird.safeTransferWhileNesting(moonbirdOwner, user2, moonbirdId);

        //should keep nesting
        (bool nesting, uint256 current, uint256 total) = moonbird.nestingPeriod(moonbirdId);
        assertTrue(nesting);
        assertTrue(current > 0);
        assertTrue(total > 0);
        assertEq(moonbird.balanceOf(user2), 1);
        assertEq(moonbird.balanceOf(moonbirdOwner), 0);
    }

    function testRecoverBird() public {
        vm.startPrank(moonbirdOwner);
        moonbird.safeTransferWhileNesting(moonbirdOwner, address(crow), moonbirdId);
        crow.recoverBird(moonbirdId);

        //should keep nesting
        (bool nesting, uint256 current, uint256 total) = moonbird.nestingPeriod(moonbirdId);
        assertTrue(nesting);
        assertTrue(current > 0);
        assertTrue(total > 0);
        assertEq(moonbird.balanceOf(moonbirdOwner), 1);
    }

    function testPlaceOffer() public {
        hoax(user2, 100 ether);
        crow.placeOffer{value : 50 ether}(50 ether, moonbirdId);

        assertEq(crow.userToOffer(user2, moonbirdId), 50 ether);
        assertEq(user2.balance, 50 ether);
        assertEq(address(crow).balance, 50 ether);
    }

    function testCancelOffer() public {
        hoax(user2, 100 ether);
        crow.placeOffer{value : 50 ether}(50 ether, moonbirdId);

        vm.prank(user2);
        crow.cancelOffer(moonbirdId);

        assertEq(crow.userToOffer(user2, moonbirdId), 0 ether);
        assertEq(user2.balance, 100 ether);
    }


    function testAcceptOffer() public {
        uint256 startingBalance = moonbirdOwner.balance;
        vm.prank(moonbirdOwner);
        moonbird.safeTransferWhileNesting(moonbirdOwner, address(crow), moonbirdId);

        hoax(user2, 100 ether);
        crow.placeOffer{value : 50 ether}(50 ether, moonbirdId);

        vm.prank(moonbirdOwner);
        crow.acceptOffer(moonbirdId, user2);

        assertEq(crow.userToOffer(user2, moonbirdId), 0 ether);
        assertEq(user2.balance, 50 ether);
        assertEq(moonbirdOwner.balance, 50 ether + startingBalance);
        assertEq(moonbird.balanceOf(moonbirdOwner), 0);
        assertEq(moonbird.balanceOf(user2), 1);
    }
}