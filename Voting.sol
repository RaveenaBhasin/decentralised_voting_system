// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Voting Smart Contract
 * @dev A smart contract for creating polls and conducting voting.
 */
contract Voting {
    address public owner;

    /**
     * @dev Represents a poll with a unique identifier, title, candidates (options), voting period,
     * mapping to track whether an address has voted, votes count for each option, and a flag to indicate if the poll has ended.
     */
    struct Poll {
        uint256 id;
        string title;
        string[] candidates;
        uint256 votingStart;
        uint256 votingEnd;
        mapping(address => bool) hasVoted;
        mapping(uint256 => uint256) votesCount;
        bool ended;
    }

    mapping(uint256 => Poll) polls;
    uint256 public pollCounter;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    modifier onlyDuringVotingPeriod(uint256 pollId) {
        require(
            block.timestamp >= polls[pollId].votingStart &&
                block.timestamp <= polls[pollId].votingEnd,
            "Voting period is not active"
        );
        _;
    }

    modifier hasNotVoted(uint256 pollId) {
        require(
            !polls[pollId].hasVoted[msg.sender],
            "You have already voted in this poll"
        );
        _;
    }

    modifier pollNotEnded(uint256 pollId) {
        require(!polls[pollId].ended, "Voting for this poll has ended");
        _;
    }

    /**
     * @dev Emitted when a new poll is created.
     * @param pollId The unique identifier of the poll.
     * @param title The title of the poll.
     * @param candidates The array of poll options.
     * @param votingStart The timestamp when the voting period starts.
     * @param votingEnd The timestamp when the voting period ends.
     */
    event PollCreated(
        uint256 indexed pollId,
        string title,
        string[] candidates,
        uint256 votingStart,
        uint256 votingEnd
    );

    /**
     * @dev Emitted when a vote is cast in a poll.
     * @param pollId The unique identifier of the poll.
     * @param voter The address of the voter.
     * @param candidate The chosen option index.
     */
    event Voted(
        uint256 indexed pollId,
        address indexed voter,
        uint256 candidate
    );

    /**
     * @dev Emitted when the voting period for a poll ends, providing the winner and the number of votes received.
     * @param pollId The unique identifier of the poll.
     * @param winner The winning option in the poll.
     * @param winningCandidateVotes The number of votes received by the winning option.
     */
    event PollEnded(
        uint256 indexed pollId,
        string winner,
        uint256 winningCandidateVotes
    );

    constructor() {
        owner = msg.sender;
    }

    /**
     * @dev Creates a new poll with specified details.
     * @param _title The title of the poll.
     * @param _candidates The array of poll options.
     * @param _votingStart The timestamp when the voting period starts.
     * @param _votingEnd The timestamp when the voting period ends.
     */
    function createPoll(
        string memory _title,
        string[] memory _candidates,
        uint256 _votingStart,
        uint256 _votingEnd
    ) external onlyOwner {
        pollCounter++;
        Poll storage newPoll = polls[pollCounter];
        newPoll.id = pollCounter;
        newPoll.title = _title;
        newPoll.candidates = _candidates;
        newPoll.votingStart = _votingStart;
        newPoll.votingEnd = _votingEnd;
        newPoll.ended = false;
        emit PollCreated(
            pollCounter,
            _title,
            _candidates,
            _votingStart,
            _votingEnd
        );
    }

    /**
     * @dev Allows a voter to cast a vote for a specific option in a poll.
     * @param pollId The unique identifier of the poll.
     * @param candidateId The chosen option index.
     */
    function vote(uint256 pollId, uint256 candidateId) external
        onlyDuringVotingPeriod(pollId)
        hasNotVoted(pollId)
        pollNotEnded(pollId)
    {
        require(
            candidateId < polls[pollId].candidates.length,
            "Invalid option"
        );

        polls[pollId].hasVoted[msg.sender] = true;
        polls[pollId].votesCount[candidateId]++;

        emit Voted(pollId, msg.sender, candidateId);
    }

    /**
     * @dev Ends the voting period for a poll and determines the winner.
     * @param pollId The unique identifier of the poll.
     */
    function endPoll(uint256 pollId) external
        onlyOwner
        onlyDuringVotingPeriod(pollId)
        pollNotEnded(pollId)
    {
        polls[pollId].ended = true;

        uint256 winningCandidate = 0;
        uint256 winningVotes = 0;

        for (uint256 i = 0; i < polls[pollId].candidates.length; i++) {
            if (polls[pollId].votesCount[i] > winningVotes) {
                winningVotes = polls[pollId].votesCount[i];
                winningCandidate = i;
            }
        }

        emit PollEnded(
            pollId,
            polls[pollId].candidates[winningCandidate],
            winningVotes
        );
    }

    /**
     * @dev Retrieves the results of a poll after the voting period has ended.
     * @param pollId The unique identifier of the poll.
     * @return candidates The array of poll options.
     * @return votes The array of votes corresponding to each option.
     */
    function getPollResults(uint256 pollId) external view returns (string[] memory candidates, uint256[] memory votes){
        require(polls[pollId].ended, "Voting for this poll has not ended yet");

        candidates = polls[pollId].candidates;
        votes = new uint256[](candidates.length);

        for (uint256 i = 0; i < candidates.length; i++) {
            votes[i] = polls[pollId].votesCount[i];
        }

        return (candidates, votes);
    }

    /**
     * @dev Retrieves the winner and the number of votes received by the winning option in a poll.
     * @param pollId The unique identifier of the poll.
     * @return winner The winning option in the poll.
     * @return winningVotes The number of votes received by the winning option.
     */
    function getPollWinner(uint256 pollId) external view returns (string memory winner, uint256 winningVotes){
        require(polls[pollId].ended, "Voting for this poll has not ended yet");

        uint256 winningCandidate = 0;
        uint256 winningVotesCount = 0;

        for (uint256 i = 0; i < polls[pollId].candidates.length; i++) {
            if (polls[pollId].votesCount[i] > winningVotesCount) {
                winningVotesCount = polls[pollId].votesCount[i];
                winningCandidate = i;
            }
        }

        winner = polls[pollId].candidates[winningCandidate];
        return (winner, winningVotesCount);
    }

    /**
     * @dev Retrieves all poll IDs.
     * @return allPollIds An array containing all poll IDs.
     */
    function getAllPollIds() external view returns (uint256[] memory allPollIds){
        allPollIds = new uint256[](pollCounter);

        for (uint256 i = 1; i <= pollCounter; i++) {
            allPollIds[i - 1] = polls[i].id;
        }

        return allPollIds;
    }

    /**
     * @dev Retrieves the details of a specific poll.
     * @param pollId The unique identifier of the poll.
     * @return title The title of the poll.
     * @return candidates The array of poll options.
     * @return votingStart The timestamp when the voting period starts.
     * @return votingEnd The timestamp when the voting period ends.
     * @return ended A boolean indicating whether the poll has ended.
     */
    function getPollDetails(uint256 pollId) external view returns (string memory title, string[] memory candidates, uint256 votingStart, uint256 votingEnd, bool ended) {
        require(pollId <= pollCounter, "Invalid poll ID");

        Poll storage poll = polls[pollId];
        return (poll.title, poll.candidates, poll.votingStart, poll.votingEnd, poll.ended);
    }

}
