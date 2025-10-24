import Hero from "@/components/Hero";
import SummaryCards from "@/components/SummaryCards";
import SearchBar from "@/components/SearchBar";
import YieldTable from "@/components/YieldTable";
import Footer from "@/components/Footer";

export default function Dashboard() {
  return (
    <main className="container mx-auto px-4 py-8">
      <Hero />
      <SummaryCards />
      <SearchBar />
      <YieldTable />
      <Footer />
    </main>
  );
}
