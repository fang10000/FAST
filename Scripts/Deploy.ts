import { publicClient, walletClient, deployer, governorAddress, minterAddress } from './Config';
import { parseUnits, formatEther } from 'viem';
import { abi, bytecode } from '../artifacts/contracts/FASToken.sol/FractionalAllowanceStablecoin.json';

async function main() {
  const deployerAddress = deployer.address;

  console.log("Deployer address:", deployerAddress);
  console.log("Governor address:", governorAddress);
  console.log("Minter address:", minterAddress);

  try {
    const balance = await publicClient.getBalance({ address: deployerAddress });
    console.log("Account balance:", formatEther(balance));
  } catch (error) {
    console.error("Error fetching balance:", error);
    return;
  }

  const initialSupply = 1000000;
  const initialFractionInBps = 100;

  console.log("Deploying contract with the following parameters:");
  console.log("ABI:", JSON.stringify(abi, null, 2));
  console.log("Bytecode:", bytecode);
  console.log("Constructor arguments:", [
    "FractionalAllowanceStablecoin", // name
    "FAST", // symbol
    initialSupply, // initialSupply
    deployerAddress, // adminAddress
    governorAddress, // governanceAddress
    minterAddress, // minterAddress
    initialFractionInBps // initialFractionInBps
  ]);

  try {
    const tx = await walletClient.deployContract({
      abi,
      bytecode: bytecode as `0x${string}`, // Ensure the bytecode is prefixed with 0x
      args: [
        "FractionalAllowanceStablecoin", // name
        "FAST", // symbol
        initialSupply, // initialSupply
        deployerAddress, // adminAddress
        governorAddress, // governanceAddress
        minterAddress, // minterAddress
        initialFractionInBps // initialFractionInBps
      ],
    });

    const receipt = await publicClient.waitForTransactionReceipt({ hash: tx });
    console.log(`Contract deployed at ${receipt.contractAddress}`);
  } catch (error) {
    console.error("Error deploying contract:", error);
  }
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error("Error in main function:", error);
    process.exit(1);
  });

