import './App.css';
import { useState } from 'react';
import { ethers } from 'ethers'
import Greeter from './artifacts/contracts/Greeter.sol/Greeter.json'

// Update with the contract address logged out to the CLI when it was deployed 
const greeterAddress = "0x5FbDB2315678afecb367f032d93F642f64180aa3";

function App() {
  // store greeting in local state
  const [greeting, setGreetingValue] = useState()

  // request access to the user's MetaMask account
  async function requestAccount() {
    await window.ethereum.request({ method: 'eth_requestAccounts' });// request access to the user's MetaMask account

  }

  // call the smart contract, read the current greeting value
  async function fetchGreeting() {
    if (typeof window.ethereum !== 'undefined') {//checking if metamask is available.
      const provider = new ethers.providers.Web3Provider(window.ethereum)//creating a new provider using ethers.
      const contract = new ethers.Contract(greeterAddress, Greeter.abi, provider)//creating an instance of the contract and passing adddress, abi, and provider.
      try {
        const data = await contract.greet()//calling greet() in our contract using our instance.
        console.log('data: ', data)
      } catch (err) {
        console.log("Error: ", err)
      }
    }    
  }

  // call the smart contract, send an update
  async function setGreeting() {
    if (!greeting) return //checking if user has typed in something, and we're not passing an empty string.
    if (typeof window.ethereum !== 'undefined') {
      await requestAccount()//wait for user to allow their account to be used.
      const provider = new ethers.providers.Web3Provider(window.ethereum);
      const signer = provider.getSigner()//to update the blockchain we nedd to create a transaction, so we need to sign it using a signer.
      const contract = new ethers.Contract(greeterAddress, Greeter.abi, signer)//passing signer.
      const transaction = await contract.setGreeting(greeting)//calling the contract's setGreeting function and passing 'greeting' as an argument.
      await transaction.wait()// waiting for transaction to be confirmed on the blockchain.
      fetchGreeting()// logging the new value.
    }
  }

  return (
    <div className="App">
      <header className="App-header">
        <button onClick={fetchGreeting}>Fetch Greeting</button>
        <button onClick={setGreeting}>Set Greeting</button>
        <input onChange={e => setGreetingValue(e.target.value)} placeholder="Set greeting" />{/*The input field has a onChange channeler. When the user is typing the onChange channeler is going to fire, and call the setGreetingValue, which is going to update the local greeting value with the event.target.value, which is whatever written to the UI*/}
      </header>
    </div>
  );
}

export default App;
