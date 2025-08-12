const web3 = new Web3(window.ethereum);
let contract;
const contractAddress = '0xdd85ed2ba4eFDFdaBb496BeD8445499DE07E875a'; // Replace with your deployed contract address
let userAccount;

// Load the ABI
fetch('./abi/SkillSharing.json')
    .then(response => response.json())
    .then(abi => {
        contract = new web3.eth.Contract(abi, contractAddress);
        console.log("Contract initialized:", contract);
    });

// Connect MetaMask on page load
window.addEventListener("load", async () => {
    try {
        await window.ethereum.request({ method: 'eth_requestAccounts' });
        const accounts = await web3.eth.getAccounts();
        userAccount = accounts[0];
        console.log("Connected account:", userAccount);
    } catch (error) {
        console.error("MetaMask connection error:", error);
    }
});


document.getElementById("listSkillForm").addEventListener("submit", async (e) => {
    e.preventDefault();
    const description = document.getElementById("description").value;
    const price = web3.utils.toWei(document.getElementById("price").value, "ether");
    const expirationTime = Math.floor(new Date(document.getElementById("expirationTime").value).getTime() / 1000);
    const maxBuyers = document.getElementById("maxBuyers").value;

    try {
        await contract.methods.listSkill(description, price, expirationTime, maxBuyers)
            .send({ from: userAccount });
        alert("Skill listed successfully!");
    } catch (error) {
        console.error("Error listing skill:", error);
    }
});


document.getElementById("purchaseSkillForm").addEventListener("submit", async (e) => {
    e.preventDefault();
    const skillId = document.getElementById("skillId").value;

    try {
        const skill = await contract.methods.skills(skillId).call();
        const price = skill.price;

        await contract.methods.purchaseSkill(skillId)
            .send({ from: userAccount, value: price });
        alert("Skill purchased successfully!");
    } catch (error) {
        console.error("Error purchasing skill:", error);
    }
});


document.getElementById("rateSkillForm").addEventListener("submit", async (e) => {
    e.preventDefault();
    const skillId = document.getElementById("rateSkillId").value;
    const rating = document.getElementById("rating").value;

    try {
        await contract.methods.rateSkill(skillId, rating)
            .send({ from: userAccount });
        alert("Skill rated successfully!");
    } catch (error) {
        console.error("Error rating skill:", error);
    }
});



document.getElementById("withdrawEarningsButton").addEventListener("click", async () => {
    try {
        await contract.methods.withdrawFunds().send({ from: userAccount });
        alert("Funds withdrawn successfully!");
    } catch (error) {
        console.error("Error withdrawing funds:", error);
    }
});


async function getSkillDetails(skillId) {
    try {
        const skill = await contract.methods.getSkillDetails(skillId).call();
        console.log("Skill details:", skill);
        return skill;
    } catch (error) {
        console.error("Error fetching skill details:", error);
    }
}


async function getSkillRating(skillId) {
    try {
        const rating = await contract.methods.getSkillRating(skillId).call();
        console.log(`Average rating for skill ${skillId}:`, rating);
        return rating;
    } catch (error) {
        console.error("Error fetching skill rating:", error);
    }
}


async function deactivateSkill(skillId) {
    try {
        await contract.methods.deactivateSkill(skillId).send({ from: userAccount });
        alert("Skill deactivated successfully!");
    } catch (error) {
        console.error("Error deactivating skill:", error);
    }
}


// Initialize Web3
if (typeof window.ethereum !== 'undefined') {
    const web3 = new Web3(window.ethereum);
    console.log('MetaMask detected');
  } else {
    console.error('MetaMask is not installed!');
  }
  
  // Request account access
  async function connectMetaMask() {
    try {
      await ethereum.request({ method: 'eth_requestAccounts' });
      console.log('MetaMask connected!');
    } catch (error) {
      console.error('User denied account access:', error);
    }
  }
  
  connectMetaMask();
  


