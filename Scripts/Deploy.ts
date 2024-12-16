import { ethers } from "hardhat";
import * as dotenv from "dotenv";

dotenv.config();

async function main() {
  const [deployer, governor, minter] = await ethers.getSigners();

  console.log("Deploying contracts with the account:", deployer.address);
  console.log("Governor address:", governor.address);
  console.log("Minter address:", minter.address);

  const balance = await deployer.getBalance();
  console.log("Account balance:", balance.toString());

  const FASToken = await ethers.getContractFactory("FractionalAllowanceStablecoin");
  const token = await FASToken.deploy(
    "FractionalAllowanceStablecoin", // name
    "FAST", // symbol
    ethers.utils.parseUnits("1000000", 18), // initialSupply
    deployer.address, // deployerAddress
    governor.address, // governanceAddress
    minter.address, // minterAddress
    100 // initialFractionInBps
  );

  console.log("Token address:", token.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });