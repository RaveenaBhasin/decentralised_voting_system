# Voting Smart Contract

## Overview
The Voting Smart Contract allows users to create polls, vote on options within the polls, and determine the winner based on the votes received during a specified voting period.

## Contract Structure

### Owner
- The contract has an `owner` address who has the privilege to create polls and end the voting period.

### Poll Structure
- Each poll is represented by a unique identifier, a title, an array of candidates (options), a voting start timestamp, a voting end timestamp, a mapping to track whether an address has voted, votes count for each option, and a flag to indicate if the poll has ended.

### Events
1. `PollCreated`: Emitted when a new poll is created.
    - Parameters:
        - `pollId`: The unique identifier of the poll.
        - `title`: The title of the poll.
        - `candidates`: The array of poll options.
        - `votingStart`: The timestamp when the voting period starts.
        - `votingEnd`: The timestamp when the voting period ends.

2. `Voted`: Emitted when a vote is cast in a poll.
    - Parameters:
        - `pollId`: The unique identifier of the poll.
        - `voter`: The address of the voter.
        - `candidate`: The chosen option index.

3. `PollEnded`: Emitted when the voting period for a poll ends.
    - Parameters:
        - `pollId`: The unique identifier of the poll.
        - `winner`: The winning option in the poll.
        - `winningCandidateVotes`: The number of votes received by the winning option.

### Functions

1. `createPoll`
   - **Access:** Only the owner
   - **Description:** Creates a new poll with specified details.

2. `vote`
   - **Access:** Any user
   - **Description:** Allows a voter to cast a vote for a specific option in a poll.

3. `endPoll`
   - **Access:** Only the owner
   - **Description:** Ends the voting period for a poll and determines the winner.

4. `getPollResults`
   - **Access:** Any user
   - **Description:** Retrieves the results of a poll after the voting period has ended.

5. `getPollWinner`
   - **Access:** Any user
   - **Description:** Retrieves the winner and the number of votes received by the winning option in a poll.

6. `getAllPollIds`
   - **Access:** Any user
   - **Description:** Retrieves all poll IDs.

7. `getPollDetails`
   - **Access:** Any user
   - **Description:** Retrieves the details of a specific poll.

## Etherscan Link  
#### https://sepolia.etherscan.io/address/0x824cd0a64dabc437e8f5497d8da4e14002be14c9

## Sample Testing for Voting Smart Contract

### Execution:

1. Deploy the contract using Remix.
2. Call `createPoll` function with the provided arguments.

- **Account:** Deployer's Account
- **Arguments:**
  - `_title:` "Poll 1"
  - `_candidates:` ["A", "B", "C"]
  - `_votingStart:` "1706912120"
  - `_votingEnd:` "1707084920"

### View Poll IDs

Call `getAllPollIds` to view the poll IDs present.

- **Account:** Any Account 

###  Vote in the Poll

Run the `vote` function multiple times from different voter accounts with the provided arguments.

- **Account:** Any Voter Account
- **Arguments:**
  - `pollId:` "1"
  - `candidateId:` "1"

### End Poll

Call `endPoll` function with the provided arguments.

- **Account:** Deployer's Account
- **Arguments:**
  - `pollId:` "1"

### View Poll Results

Call `getPollResults` to view the candidates in the poll along with votes allocated to them.

- **Arguments:**
  - `pollId:` "1"

### View Poll Winner

Call `getPollWinner` to view the winner candidate along with their votes.

- **Arguments:**
  - `pollId:` "1"
 
