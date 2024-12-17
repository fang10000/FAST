import { config as dotenvConfig } from "dotenv";
import { resolve } from "path";
import { createPublicClient, http, createWalletClient } from "viem";
import { hardhat } from "viem/chains";
import { privateKeyToAccount } from "viem/accounts";

// Load environment variables from .env file
dotenvConfig({ path: resolve(__dirname, "../.env") });

// Retrieve environment variables
export const providerApiKey = process.env.ALCHEMY_API_KEY || "";
export const ALCHEMY_URL = process.env.ALCHEMY_URL || "";
export const deployerPrivateKey = process.env.DEPLOYER_PRIVATE_KEY || "";
export const governorAddress = process.env.GOVERNOR_ADDRESS || "";
export const minterAddress = process.env.MINTER_ADDRESS || "";

// Validate Environment Variables
if (!providerApiKey) {
  throw new Error("Missing ALCHEMY_API_KEY in .env file");
}

if (!ALCHEMY_URL) {
  throw new Error("Missing ALCHEMY_URL in .env file");
}

if (!deployerPrivateKey) {
  throw new Error("Missing PRIVATE_KEY in .env file");
}

if (!governorAddress) {
  throw new Error("Missing GOVERNOR_ADDRESS in .env file");
}

if (!minterAddress) {
  throw new Error("Missing MINTER_ADDRESS in .env file");
}

// Ensure ALCHEMY_URL ends with a slash
const formattedAlchemyUrl = ALCHEMY_URL.endsWith("/")
  ? ALCHEMY_URL
  : `${ALCHEMY_URL}/`;

const privateKey = deployerPrivateKey.startsWith("0x")
  ? deployerPrivateKey
  : `0x${deployerPrivateKey}`;

// Create deployer account
export const deployer = privateKeyToAccount(privateKey as `0x${string}`);

// Create shared client instances
export const publicClient = createPublicClient({
  chain: hardhat,
  transport: http('http://127.0.0.1:8545'), // Connect to Hardhat local testnet
});

export const walletClient = createWalletClient({
  chain: hardhat,
  transport: http('http://127.0.0.1:8545'), // Connect to Hardhat local testnet
  account: privateKey as `0x${string}`,
});
