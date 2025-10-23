// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24; // solidity version - informando a versão do solidity

// "^" allow the compiler to use the informed version or above - permite o compilador usar a versão informada ou superior

contract Projeto_2 {
    address public immutable i_admin;

    struct Proposal {
        string name;
        uint256 voteCount;
    }

    string[] private proposalsNamesCount;

    Proposal[] public proposals;

    mapping(address => bool) public hasVoted;

    enum Phase {
        Setup,
        Voting,
        Ended
    }

    Phase public currentPhase;

    event Opening();
    event Closure();
    event Voted(address indexed voter, uint256 indexed proposalIndex);

    error AlreadyVoted();
    error PhaseError();
    error IndexOutOfBounds();

    modifier onlyAdmin() {
        require(msg.sender == i_admin, "Only admin can call this function.");
        _;
    }

    modifier inPhase(Phase p) {
        if (p != currentPhase) revert PhaseError();
        _;
    }

    constructor(string[3] memory proposalNames) {
        i_admin = msg.sender;

        for (uint256 i = 0; i < proposalNames.length; i++) {
            proposals.push(Proposal({name: proposalNames[i], voteCount: 0}));
        }

        currentPhase = Phase.Setup;
    }
}
