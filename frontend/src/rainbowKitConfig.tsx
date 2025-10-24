"use client";

import { getDefaultConfig } from "@rainbow-me/rainbowkit"; //
import {
  arbitrum,
  base,
  mainnet,
  optimism,
  anvil,
  zksync,
  sepolia,
} from "wagmi/chains"; // this will include all the allowed chains for our application

// This is the configuration for RainbowKit, a popular wallet connection library for Ethereum-based applications.
// We are using the getDefaultConfig function to create a default configuration for our app named "Yield-Farming-Aggregator".
// The configuration includes the app name, WalletConnect project ID, supported chains, and server-side rendering (SSR) setting.

export default getDefaultConfig({
  appName: "Yield-Farming-Aggregator",
  projectId: process.env.NEXT_PUBLIC_WALLETCONNECT_PROJECT_ID!,
  chains: [mainnet, optimism, arbitrum, base, zksync, sepolia, anvil],
  ssr: true, // Since this is a static site; client-side rendering, this is disabled
});
