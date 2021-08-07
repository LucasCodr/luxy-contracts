//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "hardhat/console.sol";

abstract contract RoyaltiesV1Luxy is Initializable {
    struct Royalties {
        address payable account;
        uint96 value;
    }

    event RoyaltiesSet(uint256 tokenId, Royalties[] royalties);
    event RoyaltieAccountUpdate(
        uint256 tokenId,
        uint256 index,
        address previousAccount,
        address newAccount
    );
    mapping(uint256 => Royalties[]) internal royalties;

    function __RoyaltiesV1Luxy_init_unchained() internal initializer {}

    function __RoyaltiesV1Luxy_init() public initializer {
        __RoyaltiesV1Luxy_init_unchained();
    }

    function getRoyalties(uint256 id)
        external
        view
        returns (Royalties[] memory)
    {
        return royalties[id];
    }

    function _setRoyalties(uint256 _id, Royalties[] memory _royalties)
        internal
    {
        require(royalties[_id].length == 0, "Royalties already set");
        for (uint256 i = 0; i < _royalties.length; i++) {
            require(
                _royalties[i].account != address(0x0),
                "Recipient should be present"
            );
            require(
                _royalties[i].value != 0,
                "Royalty value should be positive"
            );
            royalties[_id].push(_royalties[i]);
        }
        emit RoyaltiesSet(_id, _royalties);
    }

    function _updateAccount(
        uint256 _id,
        address _from,
        address _to
    ) internal {
        uint256 length = royalties[_id].length;
        address previousAccount = address(0x0);
        uint256 index = 0;
        for (uint256 i = 0; i < length; i++) {
            if (royalties[_id][i].account == _from) {
                previousAccount = royalties[_id][i].account;
                index = i;
                royalties[_id][i].account = payable(address(uint160(_to)));
            }
        }
        require(
            previousAccount != address(0x0),
            "Account not found, are you using the correct wallet?"
        );
        emit RoyaltieAccountUpdate(
            _id,
            index,
            previousAccount,
            royalties[_id][index].account
        );
    }
}
