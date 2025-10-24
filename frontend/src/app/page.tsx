"use client";

import Image from "next/image";
// import Header from "@/components/Header";
import Dashboard from "@/components/Dashboard";
import { useAccount } from "wagmi";

export default function Home() {
  const { isConnected } = useAccount();

  return (
    <div className="min-h-screen bg-background">
      {isConnected ? (
        <Dashboard />
      ) : (
        <div className="flex justify-center mt-10 text-xl font-bold text-foreground">
          Please connect a wallet ...
        </div>
      )}
    </div>
  );
}
