const { ethers, network } = require("hardhat");

async function main() {
  const NFT = await ethers.getContractFactory("NFT");
  console.log("Deploying contract...");

  const nft = await NFT.deploy(
    "https://gateway.pinata.cloud/ipfs/QmbQNaNQDu5WuhgHY2V6BqMosHABXs74Q9SoeKqSB8hF1T/",
    "https://gateway.pinata.cloud/ipfs/QmVafHJdNpzvbgX3G8Umkw7iNdNFjJHzg43UZib2jVgtmL"
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
