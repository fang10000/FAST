import { createWalletClient, custom, http } from 'viem';
import { sepolia } from 'viem/chains';
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
const abi = [
    {
        "inputs": [],
        "name": "applyDrip",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
    },
];

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
        // If you want to wait for confirmation, you can integrate a publicClient and waitForTransactionReceipt.

        // After the transaction is sent, schedule the next call with a random delay.
        scheduleNextCall();
    } catch (error: any) {
        console.error("Error calling applyDrip():", error);

        // Even if there's an error, try again later:
        scheduleNextCall();
    }
}

function getRandomDelay(): number {
    // Generate a random number between 60 and 180 seconds
    const min = 60;
    const max = 180;
    const randomSeconds = Math.floor(Math.random() * (max - min + 1)) + min;
    console.log(`Next call in ${randomSeconds} seconds.`);
    return randomSeconds * 1000; // convert to milliseconds
}

function scheduleNextCall() {
    const delay = getRandomDelay();
    setTimeout(() => {
        callApplyDrip();
    }, delay);
}

// Initial call
callApplyDrip();