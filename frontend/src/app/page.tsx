"use client";


import Image from "next/image";
// import Header from "@/components/Header";
import Hero from "@/components/Hero";
import SummaryCards from "@/components/SummaryCards";
import SearchBar from "@/components/SearchBar";
import YieldTable from "@/components/YieldTable";
import Footer from "@/components/Footer";
import { useAccount } from "wagmi";


export default function Home() {
  const { isConnected } = useAccount();

  return (
    <div className="min-h-screen bg-background">
      {isConnected ? (
        
      <main className="container mx-auto px-4 py-8">
        <Hero />
        <SummaryCards />
        <SearchBar />
        <YieldTable />
        <Footer />
      </main>
      ) : (
        <div className="flex justify-center mt-10 text-xl font-bold text-foreground">Please connect a wallet ...</div>
      )}
    </div>
  );
}
