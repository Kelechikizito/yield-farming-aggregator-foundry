import Image from "next/image";
import Header from "@/components/Header";
import Hero from "@/components/Hero";
import SummaryCards from "@/components/SummaryCards";
import SearchBar from "@/components/SearchBar";
import YieldTable from "@/components/YieldTable";
import Footer from "@/components/Footer";


export default function Home() {
  return (
    <div className="min-h-screen bg-background">
      <Header />
      <main className="container mx-auto px-4 py-8">
        <Hero />
        <SummaryCards />
        <SearchBar />
        <YieldTable />
        <Footer />
      </main>
    </div>
  );
}
