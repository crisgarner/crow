// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

interface Moonbirds {
    /**
     * @notice Returns the length of time, in seconds, that the Moonbird has nested.
     * @dev Nesting is tied to a specific Moonbird, not to the owner, so it doesn't reset upon sale.
     * @return nesting Whether the Moonbird is currently nesting. MAY be true with zero current nesting if in the same block as nesting began.
     * @return current Zero if not currently nesting, otherwise the length of time since the most recent nesting began.
     * @return total Total period of time for which the Moonbird has nested across its life, including the current period.
     */
    function nestingPeriod(uint256 tokenId) external view returns (bool nesting, uint256 current, uint256 total);

    /**
     * @notice Transfer a token between addresses while the Moonbird is minting, thus not resetting the nesting period.
     */
    function safeTransferWhileNesting(address from, address to, uint256 tokenId) external;

    /**
     * @dev See {IERC721-balanceOf}.
     */
    function balanceOf(address owner) external view returns (uint256);

    /**
     * @dev See {IERC721-approve}.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev See {IERC721-transferFrom}.
     */
    function transferFrom(address from, address to, uint256 tokenId) external;

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
}