// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

contract Projeto_2 {
    address public immutable i_admin;

    struct Proposal {
        string name;
        uint256 voteCount;
    }

    Proposal[] public proposals;

    string[] private proposalsNames;

    mapping(address => bool) public hasVoted;

    enum Phase {
        Setup,
        Voting,
        Ended,
        Tie
    }

    Phase public currentPhase;

    event Opening();
    event Closure();
    event Voted(address indexed voter, uint256 indexed proposalIndex);
    event RestartingVotingPhase();

    error AlreadyVoted();
    error PhaseError();
    error IndexOutOfBounds();
    error OnlyAdminCanCallThisFunction();

    modifier onlyAdmin() {
        if (msg.sender != i_admin) revert OnlyAdminCanCallThisFunction();
        // require(msg.sender == i_admin, "Only admin can call this function.");
        // Using `if` and `revert` is more gas efficient than `require` with a string message.
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

    function startVotingPhase() external onlyAdmin inPhase(Phase.Setup) {
        currentPhase = Phase.Voting;
        emit Opening();
    }

    function endVotingPhase() external onlyAdmin inPhase(Phase.Voting) {
        currentPhase = Phase.Ended;
        emit Closure();
    }

    function vote(uint256 proposalIndex) external inPhase(Phase.Voting) {
        if (hasVoted[msg.sender]) revert AlreadyVoted();
        if (proposalIndex >= proposals.length) revert IndexOutOfBounds();

        hasVoted[msg.sender] = true;
        proposals[proposalIndex].voteCount += 1;

        emit Voted(msg.sender, proposalIndex);
    }

    // Returns the winner(s) after the voting phase. If multiple proposals
    // have the same highest vote count this returns all tied proposal names.
    // The function is `view` and does not modify contract state.
    function proposalWinner()
        external
        view
        inPhase(Phase.Ended)
        returns (string[] memory winnerNames_)
    {
        uint256 winningVoteCount = 0;

        // First pass: determine the highest vote count
        for (uint256 i = 0; i < proposals.length; i++) {
            if (proposals[i].voteCount > winningVoteCount) {
                winningVoteCount = proposals[i].voteCount;
            }
        }

        // Second pass: count how many proposals have that highest vote count
        uint256 tieCount = 0;
        for (uint256 i = 0; i < proposals.length; i++) {
            if (proposals[i].voteCount == winningVoteCount) {
                tieCount += 1;
            }
        }

        // Build result array with all winners (one or many)
        winnerNames_ = new string[](tieCount);
        uint256 idx = 0;
        for (uint256 i = 0; i < proposals.length; i++) {
            if (proposals[i].voteCount == winningVoteCount) {
                winnerNames_[idx] = proposals[i].name;
                idx += 1;
            }
        }
    }

    function voteContinue() external onlyAdmin inPhase(Phase.Ended) {
        currentPhase = Phase.Voting;
        emit RestartingVotingPhase();
    }
}
