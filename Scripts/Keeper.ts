import { createWalletClient, custom, http, parseEther } from 'viem';
import { sepolia } from 'viem/chains';
import { mnemonicToAccount } from 'viem/accounts';
import { readFileSync } from 'fs';
import * as dotenv from 'dotenv';

dotenv.config();

// ENV variables needed:
// SEPOLIA_RPC_URL: the RPC endpoint for sepolia
// MINTER_PRIVATE_KEY: private key of the minter role account
// CONTRACT_ADDRESS: the deployed contract address of FractionalAllowanceStablecoin

const SEPOLIA_RPC_URL = process.env.SEPOLIA_RPC_URL as string;
const MINTER_PRIVATE_KEY = process.env.MINTER_PRIVATE_KEY as string;
const CONTRACT_ADDRESS = process.env.CONTRACT_ADDRESS as string;

if (!SEPOLIA_RPC_URL || !MINTER_PRIVATE_KEY || !CONTRACT_ADDRESS) {
  console.error("Please set SEPOLIA_RPC_URL, MINTER_PRIVATE_KEY, and CONTRACT_ADDRESS in .env");
  process.exit(1);
}

// ABI of the FractionalAllowanceStablecoin, includes at least the applyDrip function
// Ensure you have the ABI. If you have your ABI as a JSON file, read it in:
const abi = [
  {
    "inputs": [],
    "name": "applyDrip",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  // ... You can include other ABI entries if needed
];

// Create a wallet client using viem
const walletClient = createWalletClient({
  account: {
    type: 'privateKey',
    privateKey: MINTER_PRIVATE_KEY,
  },
  chain: sepolia,
  transport: http(SEPOLIA_RPC_URL),
});

async function callApplyDrip() {
  try {
    console.log("Calling applyDrip() on the contract...");

    const hash = await walletClient.writeContract({
        address: CONTRACT_ADDRESS as `0x${string}`,
        abi,
        functionName: 'applyDrip',
        account: null
    });

    console.log("Transaction sent. Hash:", hash);

    const publicClient = createPublicClient({
      chain: sepolia,
      transport: http(SEPOLIA_RPC_URL),
    });
    const receipt = await publicClient.waitForTransactionReceipt({ hash });
    console.log("Transaction mined in block:", receipt.blockNumber);
  } catch (error: any) {
    console.error("Error calling applyDrip():", error);
  }
}

// Call applyDrip() immediately on start (optional)
callApplyDrip();

// Set interval to call applyDrip() every 90 seconds (90 * 1000 ms)
setInterval(() => {
  callApplyDrip();
}, 90 * 1000);