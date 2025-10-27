// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract Projeto_2 {
    address public immutable i_admin;

    struct Proposal {
        string name;
        uint256 voteCount;
    }

    Proposal[] public proposals;

    // winners da rodada encerrada
    string[] internal winners;

    // em vez de bool, versionamos por rodada
    uint256 public roundId;
    mapping(address => uint256) public votedRound;

    enum Phase {
        Setup,
        Voting,
        Ended,
        Tie
    }
    Phase public currentPhase;

    // ==== Events ====
    event Opening(uint256 indexed roundId);
    event Closure(
        uint256 indexed roundId,
        uint256 highestVoteCount,
        uint256 winnersCount
    );
    event Voted(
        address indexed voter,
        uint256 indexed proposalIndex,
        uint256 indexed roundId
    );
    event RestartingVotingPhase(uint256 indexed newRoundId);

    // ==== Errors ====
    error AlreadyVoted();
    error PhaseError(Phase expected, Phase actual);
    error IndexOutOfBounds();
    error OnlyAdminCanCallThisFunction();
    error EmptyProposalList();

    // ==== Modifiers ====
    modifier onlyAdmin() {
        if (msg.sender != i_admin) revert OnlyAdminCanCallThisFunction();
        _;
    }

    modifier inPhase(Phase p) {
        if (p != currentPhase) revert PhaseError(p, currentPhase);
        _;
    }

    // ==== Lifecycle ====
    constructor(string[] memory proposalNames) {
        if (proposalNames.length == 0) revert EmptyProposalList();
        i_admin = msg.sender;
        _initProposals(proposalNames);
        currentPhase = Phase.Setup;
        roundId = 1;
    }

    function startVotingPhase() external onlyAdmin inPhase(Phase.Setup) {
        currentPhase = Phase.Voting;
        emit Opening(roundId);
    }

    function endVotingPhase() external onlyAdmin inPhase(Phase.Voting) {
        // calcula winners e atualiza fase
        (uint256 highest, uint256 count) = _highestVoteCountAndTally();
        winners = _namesWithVotes(highest, count);

        // define fase
        if (winners.length > 1) {
            currentPhase = Phase.Tie;
        } else {
            currentPhase = Phase.Ended;
        }
        emit Closure(roundId, highest, winners.length);
    }

    // Reinicia votação: incrementa round, permite novos votos, preserva propostas ou opcionalmente substitui
    function voteContinue(
        string[] memory newProposalNames
    )
        external
        onlyAdmin // pode continuar após Ended ou Tie
    {
        if (currentPhase == Phase.Ended || currentPhase == Phase.Setup || currentPhase == Phase.Voting) revert PhaseError(Phase.Tie, Phase.Ended);

        // Se vierem novos nomes, substitui a lista; senão, reaproveita
        if (newProposalNames.length > 0) {
            _initProposals(newProposalNames);
        } else {
            // reset de contagem mantendo nomes
            uint256 len = proposals.length;
            for (uint256 i = 0; i < len; ) {
                proposals[i].voteCount = 0;
                unchecked {
                    ++i;
                }
            }
        }

        // limpa winners anteriores
        delete winners;

        // próxima rodada
        unchecked {
            ++roundId;
        }
        currentPhase = Phase.Voting;
        emit RestartingVotingPhase(roundId);
    }

    // ==== Voting ====
    function vote(uint256 proposalIndex) external inPhase(Phase.Voting) {
        _checkProposalIndex(proposalIndex);
        if (votedRound[msg.sender] == roundId) revert AlreadyVoted();

        votedRound[msg.sender] = roundId;
        proposals[proposalIndex].voteCount += 1;
        emit Voted(msg.sender, proposalIndex, roundId);
    }

    // ==== Views ====
    /// Retorna os nomes dos vencedores (1 ou mais) após o término.
    function winner() external view returns (string[] memory) {
        require(
            currentPhase == Phase.Ended || currentPhase == Phase.Tie,
            "Winners available only after end"
        );
        return winners;
    }

    /// Retorna todas as propostas com seus votos.
    function getProposals() external view returns (Proposal[] memory list) {
        uint256 len = proposals.length;
        list = new Proposal[](len);
        for (uint256 i = 0; i < len; ) {
            list[i] = proposals[i];
            unchecked {
                ++i;
            }
        }
    }

    // ==== Internals (view helpers) ====
    function _highestVoteCountAndTally()
        private
        view
        returns (uint256 highest, uint256 countWithHighest)
    {
        uint256 len = proposals.length;
        for (uint256 i = 0; i < len; ) {
            uint256 v = proposals[i].voteCount;
            if (v > highest) {
                highest = v;
                countWithHighest = 1;
            } else if (v == highest) {
                // conta empates no mesmo maior
                countWithHighest += 1;
            }
            unchecked {
                ++i;
            }
        }
    }

    function _namesWithVotes(
        uint256 target,
        uint256 count
    ) private view returns (string[] memory names) {
        names = new string[](count);
        uint256 idx;
        uint256 len = proposals.length;
        for (uint256 i = 0; i < len; ) {
            if (proposals[i].voteCount == target) {
                names[idx++] = proposals[i].name;
                if (idx == count) break; // pequena otimização
            }
            unchecked {
                ++i;
            }
        }
    }

    // ==== Internals (mutating) ====
    function _initProposals(string[] memory names) private {
        delete proposals;
        uint256 len = names.length;
        if (len == 0) revert EmptyProposalList();
        for (uint256 i = 0; i < len; ) {
            proposals.push(Proposal({name: names[i], voteCount: 0}));
            unchecked {
                ++i;
            }
        }
    }

    // ==== Checks ====
    function _checkProposalIndex(uint256 proposalIndex) private view {
        if (proposalIndex >= proposals.length) revert IndexOutOfBounds();
    }
}
