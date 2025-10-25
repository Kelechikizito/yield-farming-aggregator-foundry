import Hero from "@/components/Hero";
import SummaryCards from "@/components/SummaryCards";
import SearchBar from "@/components/SearchBar";
import YieldTable from "@/components/YieldTable";
import Footer from "@/components/Footer";
import { useProtocolRates } from "@/hooks/useProtocolRates";

export default function Dashboard() {
  const { rates, loading, error, refresh, lastUpdated } =
    useProtocolRates(true);
  return (
    <main className="container mx-auto px-4 py-8">
      <Hero lastUpdated={lastUpdated} />
      <SummaryCards />
      {/* <SearchBar /> */}
      <YieldTable />
      <Footer />
    </main>
  );
}
