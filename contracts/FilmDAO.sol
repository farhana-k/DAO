
// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0;

import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/utils/Strings.sol';


contract FilmDAO is Ownable {

  using Strings for uint256;

  enum ProposalState {
      Review,
      Cancelled,
      Voting,
      Defeated,
      Succeeded,
      Accepted,
      Rejected
  }


  enum VoteType {
      Against,
      For,
      Abstain
  }


  struct Project {
      uint256 stakedAmount;
      uint256 stakersCount;
      uint256 proposalThresholdAmt;
      uint256 votingThresholdAmt;
      uint256 minStakingAmt;
      uint256[] ProjectProposals;
  }

  mapping(address => uint256) internal OrgAdmins;
  mapping(uint256 => uint256) public ForWeight;
  mapping(uint256 => uint256) public AgainstWeight;
  mapping(uint256 => address[]) public ForVoters;
  mapping(uint256 => address[]) public AgainstVoters;
  mapping(uint256 => address[]) public AbstainVoters;
  mapping(uint256 => mapping(address => bool)) public ProposalVoters;
  mapping(uint256 => mapping(address => uint256)) public StakedAmounts;
  mapping(uint256 => Project) public Projects;
  mapping(uint256 => ProposalState) public ProposalStates;


  uint256 public ProposalsCount;
  uint256 public ProjectsCount;


  constructor() {
    OrgAdmins[_msgSender()] = 1;
  }

 
  function OrgAdmin_Check(address _add) public view returns (bool) {
    return OrgAdmins[_add] > 0 ? true : false;
  }

  function OrgAdmin_Add(address _orgAdmin) public onlyOwner {
     OrgAdmins[_orgAdmin] = 1;
  }

  function OrgAdmin_Remove(address _orgAdmin) public onlyOwner {
     OrgAdmins[_orgAdmin] = 0;
  }


  function Project_Add(uint256 _proposalThresholdAmt, uint256 _votingThresholdAmt, uint256 _minStakingAmt) public returns(uint256) {
    require(OrgAdmin_Check(msg.sender) == true, 'Only admins can create projects.');
    unchecked {
      ProjectsCount++;
      Projects[ProjectsCount].stakedAmount = 0;
      Projects[ProjectsCount].proposalThresholdAmt = _proposalThresholdAmt;
      Projects[ProjectsCount].votingThresholdAmt = _votingThresholdAmt;
      Projects[ProjectsCount].minStakingAmt = _minStakingAmt;
    }
    return ProjectsCount;
  }

  function Project_GetVotingThrashold(uint256 _projectID) public view returns (uint256) {
    return Projects[_projectID].votingThresholdAmt;
  }

  function Project_GetProposalThrashold(uint256 _projectID) public view returns (uint256) {
    return Projects[_projectID].proposalThresholdAmt;
  }

  function Project_SetVotingThrashold(uint256 _projectID, uint256 _votingThresholdAmt) public {
    require(OrgAdmin_Check(msg.sender) == true, 'Only admins can set values.');
    Projects[_projectID].votingThresholdAmt = _votingThresholdAmt;
  }

  function Project_SetProposalThrashold(uint256 _projectID, uint256 _proposalThresholdAmt) public {
    require(OrgAdmin_Check(msg.sender) == true, 'Only admins can set values.');
    Projects[_projectID].proposalThresholdAmt = _proposalThresholdAmt;
  }

  function Project_GetStakedInfo(uint256 _projectID) public view returns (uint256 StakersCount, uint256 StakedAmount) {
    return (Projects[_projectID].stakersCount, Projects[_projectID].stakedAmount);
  }

  function Project_GetAllProposals(uint256 _projectID) public view returns (uint256[] memory) {
    return Projects[_projectID].ProjectProposals;
  }


  function Project_StakeMoney(uint256 _amount, uint256 _projectID) public  {
    require(_amount > 0, 'Invalid Amount.');
    require((_projectID <= ProjectsCount) && (_projectID > 0), 'Invalid Project ID' );
    require(StakedAmounts[_projectID][msg.sender] + _amount >= Projects[ProjectsCount].minStakingAmt, 'Low staking amount');

    unchecked {
      Projects[_projectID].stakedAmount += _amount;
      if (StakedAmounts[_projectID][msg.sender] == 0) {
        Projects[_projectID].stakersCount += 1;
      }     
      StakedAmounts[_projectID][msg.sender] += _amount;
    }
  }


  function Proposal_Add(uint256 _projectID) public returns(uint256) {
    require((_projectID <= ProjectsCount) && (_projectID > 0), 'Invalid Project ID' );
    require(StakedAmounts[_projectID][msg.sender] >= Projects[_projectID].proposalThresholdAmt, 'Low staked amount');

  
    ProposalsCount++;
    Projects[_projectID].ProjectProposals.push(ProposalsCount);
    ProposalStates[ProposalsCount] = ProposalState.Review;
      return ProposalsCount;
  }

  function Proposal_GetVoterCounts(uint256 _proposalID) public view returns(uint256 ForVotes, uint256 AgainstVotes, uint256 AbstainVotes)  {    
    return (ForVoters[_proposalID].length, AgainstVoters[_proposalID].length, AbstainVoters[_proposalID].length);
  }

  function Proposal_GetVotingWeights(uint256 _proposalID) public view returns(uint256 VoteForWeight, uint256 VoteAgainstWeight)  {    
    return (ForWeight[_proposalID], AgainstWeight[_proposalID]);
  }

  function Proposal_GetForVoters(uint256 _proposalID) public view returns(address[] memory)  {    
    return ForVoters[_proposalID];
  }

  function Proposal_GetAgainstVoters(uint256 _proposalID) public view returns(address[] memory)  {    
    return AgainstVoters[_proposalID];
  }
  
  function Proposal_GetAbstainVoters(uint256 _proposalID) public view returns(address[] memory)  {    
    return AbstainVoters[_proposalID];
  }


  function Proposal_GetState(uint256 _proposalID) public view returns (ProposalState) {
    return ProposalStates[_proposalID];
  }

  function Proposal_SetState(uint256 _proposalID, ProposalState _state) public  {
    require(OrgAdmin_Check(msg.sender) == true, 'Only admins can change state.');
    require((_proposalID <= ProposalsCount) && (_proposalID > 0), 'Invalid Proposal ID' );
    ProposalStates[_proposalID] = _state;
  }


  function Proposal_SetState_CloseVoting(uint256 _projectID, uint256 _proposalID) public returns(uint256 VoteForWeight, uint256 VoteAgainstWeight) {
    require(OrgAdmin_Check(msg.sender) == true, 'Only admins can change state.');
    require((_projectID <= ProjectsCount) && (_projectID > 0), 'Invalid Project ID' );
    require((_proposalID <= ProposalsCount) && (_proposalID > 0), 'Invalid Proposal ID' );
    uint256 nForWeight;
    uint256 nAgainstWeight;

    nAgainstWeight = AgainstWeight[_proposalID];
    nForWeight = ForWeight[_proposalID];

    if (nForWeight >= nAgainstWeight) {
      ProposalStates[_proposalID] = ProposalState.Succeeded;
    } else {
      ProposalStates[_proposalID] = ProposalState.Defeated;
    }
    return (nForWeight, nAgainstWeight);
  }

  function Proposal_EvaluateVotes(uint256 _projectID, uint256 _proposalID) public returns (uint256 VoteForWeight, uint256 VoteAgainstWeight) {
    require(OrgAdmin_Check(msg.sender) == true, 'Only admins can change state.');
    require((_projectID <= ProjectsCount) && (_projectID > 0), 'Invalid Project ID' );
    require((_proposalID <= ProposalsCount) && (_proposalID > 0), 'Invalid Proposal ID' );

    uint256 nCount;
    uint256 nTotStakedAmt;
    uint256 nForWeight;
    uint256 nAgainstWeight;
    nTotStakedAmt = Projects[_projectID].stakedAmount;
    require(nTotStakedAmt > 0, 'No Amount Staked' );

    for (nCount = 0; nCount < ForVoters[_proposalID].length; nCount++) 
    {
      nForWeight += StakedAmounts[_projectID][msg.sender];
    }

    for (nCount = 0; nCount < AgainstVoters[_proposalID].length; nCount++) 
    {
      nAgainstWeight += StakedAmounts[_projectID][msg.sender];
    }

    ForWeight[_proposalID] = nForWeight;
    AgainstWeight[_proposalID] = nAgainstWeight;
    return(nForWeight, nAgainstWeight);
  }



   function Proposal_CastVote(uint8 _voteType, uint256 _projectID, uint256 _proposalID) public  {
      require((_projectID <= ProjectsCount) && (_projectID > 0), 'Invalid Project ID' );
      require((_proposalID <= ProposalsCount) && (_proposalID > 0), 'Invalid Proposal ID' );
      require(ProposalVoters[_proposalID][msg.sender] == false, 'Already Voted');
      require(StakedAmounts[_projectID][msg.sender] >= Projects[_projectID].votingThresholdAmt, 'Low staked amount');
      require(ProposalStates[_proposalID] == ProposalState.Voting, 'Proposal not open for Voting');

      uint256 nTotStakedAmt;
      nTotStakedAmt = Projects[_projectID].stakedAmount;
      require(nTotStakedAmt > 0, 'No Amount Staked' );
      
      ProposalVoters[_proposalID][msg.sender] = true;

      if (_voteType == uint8(VoteType.Against)) {
        AgainstVoters[_proposalID].push(msg.sender);
        AgainstWeight[_proposalID] += StakedAmounts[_projectID][msg.sender];

      } else if (_voteType == uint8(VoteType.For)) {
        ForVoters[_proposalID].push(msg.sender);
        ForWeight[_proposalID] += StakedAmounts[_projectID][msg.sender];
      } else if (_voteType == uint8(VoteType.Abstain)) {
        AbstainVoters[_proposalID].push(msg.sender);
      } else {
          revert("invalid value for VoteType");
      }

    }

//  function Project_UnStakeMoney(uint256 _amount, uint256 _projectID) public  {

    // to be updated

  //}
 
  fallback() external  {
  }

  
}
