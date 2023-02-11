import Web3 from "web3";
import FilmDAO from "./FilmDAO.json"
  const ethereum = window.ethereum;

  const web3 = new Web3(ethereum);

  // const ContractAddress = FilmDAO.networks["5777"].address;
  const ContractAddress = '0x32E196677dc2F48118c6820dB26076af905D5a4c';
  const ContractAbi = FilmDAO.abi;

  const myContract = new web3.eth.Contract(
    ContractAbi,
    ContractAddress
  );

  export default myContract;