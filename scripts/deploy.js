const { ethers, run, network } = require("hardhat");

async function main() {
  const NFT = await ethers.getContractFactory("NFT");
  console.log("Deploying contract...");

  const nft = await NFT.deploy(
    "Non Fungible Token",
    "NFT",
    "baseuri",
    "hiddenuri"
  );
  await nft.deployed();
  console.log(`Deployed contract to: ${nft.address}`);
}

// main
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
