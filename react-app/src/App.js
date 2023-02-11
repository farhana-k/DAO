import {
  Button,
  Tabs,
  Tab,
  Row,
  Col,
  Card,
} from "react-bootstrap";

import "bootstrap/dist/css/bootstrap.min.css";
import { useState, useEffect } from "react";
import './App.css';
import myContract from './contract.js';
import State from './components/state.js'

function App() {

  useEffect(()=>{
    enableMetaMask();
  },[])

  const ethereum = window.ethereum;

  const [state, getstate] = useState({data:""})

    const getInitialState = () => {
      const value = "Review";
      return value;
    };

    const getInitialState1 = () => {
      const value = "0";
      return value;
    };

    const changeState = () => {  
      getstate({data: data}); 
  }; 

  const [value, setValue] = useState(getInitialState);
  const [value1, setValue1] = useState(getInitialState1);

  const handleChange = (e) => {
    setValue(e.target.value);
  };

  const handleChange1 = (e) => {
    setValue1(e.target.value);
  };
  
  
  // var Web3 = require('web3')
  // const web3 = new Web3('http://localhost:8545');

  const enableMetaMask = async () => {
    await ethereum.request({ method: "eth_requestAccounts" });
  };


  const Project_Add = async () => {
    enableMetaMask();

    let proposalThreshold = document.getElementById('proposalThreshold').value;
    let votingThreshold = document.getElementById('votingThreshold').value;
    let minStakeAmt = document.getElementById('minStakeAmt').value;
    const addProject = await myContract.methods.Project_Add(
      proposalThreshold,
      votingThreshold,
      minStakeAmt
    )
    .send({from:ethereum.selectedAddress})
  };

  

  const Project_StakeMoney = async () => {
    enableMetaMask();
    let id = document.getElementById('projectId').value;
    let amt = document.getElementById('amt').value;
    const stakeProject = await myContract.methods.Project_StakeMoney(
      id,
      amt
    )
    .send({from:ethereum.selectedAddress})
  };

  const Proposal_Add = async () => {
    enableMetaMask();

    let id = document.getElementById('projectid').value;
    const addProject = await myContract.methods.Proposal_Add(
      id
    )
    .send({from:ethereum.selectedAddress})
  };

  const vote_Add = async () => {
    enableMetaMask();
    let votetype = value1;
    let projId = document.getElementById('projId').value;
    let propId = document.getElementById('propId').value;
    const addProject = await myContract.methods.Proposal_CastVote(
      votetype,projId,propId
    )
    .send({from:ethereum.selectedAddress})
  };

  
  const closeVote = async () => {
    enableMetaMask();
    let projeId = document.getElementById('projeId').value;
    let proposId = document.getElementById('proposId').value;
    const closevote = await myContract.methods.Proposal_SetState_CloseVoting(
      projeId,proposId
    )
    .send({from:ethereum.selectedAddress})
  };


  const setState = async () => {
    enableMetaMask();
    let id = document.getElementById('proposId').value;
    const state = value;
    const addProject = await myContract.methods.Proposal_SetState(
      id, state
    )
    .send({from:ethereum.selectedAddress})
  };

  const get_State = async () => {
    let id = document.getElementById('proposaId').value;
    let res = [];
    const r = await myContract.methods.Proposal_GetState(id).call()
    res.push(r);
    return res;
  }

  let data = [];
  const p = Promise.resolve(get_State());
  p.then(value => {
      for (let i = 0; i < value[0].length ; i++){
          data.push((value[0][i].returnValues))
      }
  })


  return (
    <div style={{ maxWidth: "99.20%" }}>
      <br />
      <Tabs
        defaultActiveKey="adminTab"
        id="uncontrolled-tab-example"
        className="mb-3"
        style={{ paddingLeft: "10px" }}
      >
        <Tab
          eventKey="adminTab"
          title="Admin"
          style={{ paddingLeft: "10px" }}
        >
            <br></br>
            <Row>
              <Col>
                <Card style={{ width: "30rem" }}>
                  <Card.Header
                  ><Card.Title>
                  <b>Add a project</b>
                </Card.Title></Card.Header>
                  <Card.Body>
                    <Card.Text>
                    {/* Project Name */}
                    <br></br>
                      <input id="proposalThreshold" placeholder="Proposal Threshold"></input>
                      <br></br>
                      <br></br>
                      <input id="votingThreshold" placeholder="Voting Threshold"></input>
                      <br></br>
                      <br></br>
                      <input id="minStakeAmt" placeholder="Minimum stake amount"></input>
                    </Card.Text>
                    <Button
                      variant="success"
                      onClick={() => Project_Add()}
                    >
                      Submit
                    </Button>
                  </Card.Body>
                </Card>
              </Col>

              <Col>
                <Card style={{ width: "30rem" }}>
                  <Card.Header
                  ><Card.Title>
                  <b>Get Proposal State</b>
                </Card.Title></Card.Header>
                  <Card.Body>
                    <Card.Text>
                    {/* Project Name */}
                    <br></br>
                      <input id="proposaId" placeholder="Proposal ID"></input>
                      <br></br>
                      <br></br>
                    <State data = {state.data} ></State>
                    </Card.Text>
                    <Button
                      variant="success"
                      onClick={() => changeState()}
                    >
                      Submit
                    </Button>
                  </Card.Body>
                </Card>
              </Col>
              
              </Row>
              <br></br>
              <Row>

              <Col>
                <Card style={{ width: "30rem" }}>
                  <Card.Header
                  ><Card.Title>
                  <b>Set Proposal State</b>
                </Card.Title></Card.Header>
                  <Card.Body>
                    <Card.Text>
                    {/* Project Name */}
                    <br></br>
                      <input id="propoId" placeholder="Proposal ID"></input>
                      <br></br>
                      <br></br>
                      <select value={value} onChange={handleChange} >
                        <option value="0">Review</option>
                        <option value="1">Cancelled</option>
                        <option value="2">Voting</option>
                        <option value="3">Defeated </option>
                        <option value="4">Succeeded</option>
                        <option value="5">Accepted</option>
                        <option value="6">Rejected</option>
                      </select>
                      
                    </Card.Text>
                    <Button
                      variant="success"
                      onClick={() => setState()}
                    >
                      Submit
                    </Button>
                  </Card.Body>
                </Card>
              </Col>
              <Col>
                <Card style={{ width: "30rem" }}>
                  <Card.Header
                  ><Card.Title>
                  <b>Close Voting for proposal</b>
                </Card.Title></Card.Header>
                  <Card.Body>
                    <Card.Text>
                    {/* Project Name */}
                    <br></br>
                      <input id="projeId" placeholder="Project ID"></input>
                      <br></br>
                      <br></br>
                      <input id="proposId" placeholder="Proposal ID"></input>
                      <br></br>
                    </Card.Text>
                    <Button
                      variant="danger"
                      onClick={() => closeVote()}
                    >
                      Submit
                    </Button>
                  </Card.Body>
                </Card>
              </Col>

              </Row>
              </Tab>


              <Tab
          eventKey="proposal"
          title="User"
          style={{ paddingLeft: "10px" }}
        >
            <br></br>
            <Row>
            <Col>
                <Card style={{ width: "30rem" }}>
                  <Card.Header
                  ><Card.Title>
                  <b>Stake Money for a project</b>
                </Card.Title></Card.Header>
                  <Card.Body>
                    <Card.Text>
                    {/* Project Name */}
                    <br></br>
                      <input id="projectId" placeholder="Project ID"></input>
                      <br></br>
                      <br></br>
                      <input id="amt" placeholder="Amount"></input>
                    </Card.Text>
                    <Button
                      variant="success"
                      onClick={() => Project_StakeMoney()}
                    >
                      Submit
                    </Button>
                  </Card.Body>
                </Card>
              </Col>

            <Col>
                <Card style={{ width: "30rem" }}>
                  <Card.Header
                  ><Card.Title>
                  <b>Add Proposal</b>
                </Card.Title></Card.Header>
                  <Card.Body>
                    <Card.Text>
                    {/* Project Name */}
                    <br></br>
                      <input id="projectid" placeholder="Project ID"></input>
                      <br></br>
                      <br></br>
                    </Card.Text>
                    <Button
                      variant="success"
                      onClick={() => Proposal_Add()}
                    >
                      Submit
                    </Button>
                  </Card.Body>
                </Card>
              </Col>
              </Row>
              <br></br>
              <br></br>

            <Row>
            <Col>
                <Card style={{ width: "30rem" }}>
                  <Card.Header
                  ><Card.Title>
                  <b>Cast Vote</b>
                </Card.Title></Card.Header>
                  <Card.Body>
                    <Card.Text>
                      Vote Type <tab></tab>
                    {/* <br></br> */}
                      <select value={value1} onChange={handleChange1} >
                        <option value="0">Against</option>
                        <option value="1">For</option>
                        <option value="2">Abstain</option>
                      </select>
                      <br></br>
                      <br></br>
                      <input id="projId" placeholder="Project ID"></input>
                      <br></br>
                      <br></br>
                      <input id="propId" placeholder="Proposal ID"></input>
                    </Card.Text>
                    <Button
                      variant="success"
                      onClick={() => vote_Add()}
                    >
                      Submit
                    </Button>
                  </Card.Body>
                </Card>
              </Col>
              </Row>

              </Tab>
              </Tabs>
              </div>
  );
}

export default App;
