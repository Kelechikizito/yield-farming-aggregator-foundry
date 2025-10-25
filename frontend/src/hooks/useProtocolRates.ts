// hooks/useProtocolRates.ts
import { useState, useEffect, useCallback } from "react";

interface ProtocolRate {
  protocol: string;
  token: string;
  apy: number;
  tvl: number;
  risk?: string;
  apyChange24h?: number | null;
  timestamp: number;
}

interface UseProtocolRatesReturn {
  rates: ProtocolRate[];
  loading: boolean;
  error: string | null;
  refresh: () => Promise<void>;
  lastUpdated: number | null;
}

export function useProtocolRates(autoRefresh = true): UseProtocolRatesReturn {
  const [rates, setRates] = useState<ProtocolRate[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [lastUpdated, setLastUpdated] = useState<number | null>(null);

  // ==================== FETCH FROM DEFI LLAMA ====================
  const fetchFromDefiLlama = async (): Promise<ProtocolRate[]> => {
    const response = await fetch("https://yields.llama.fi/pools");
    const { data } = await response.json();

    const targetProtocols = ["aave-v3", "compound-v3", "uniswap-v3"];

    // ✅ Filter to only single-asset pools (exclude LP pairs)
    const filtered = data
      .filter(
        (pool: any) =>
          targetProtocols.includes(pool.project) &&
          pool.chain === "Ethereum" &&
          pool.apy > 0 &&
          pool.exposure === "single" && // Only single-asset pools
          !pool.symbol?.includes("/") // Exclude LP pairs like "ETH/USDC"
      )
      .slice(0, 30);

    // ✅ Normalize and map fields
    return filtered.map((pool: any) => ({
      protocol: pool.project,
      token: pool.symbol || "N/A",
      apy: pool.apy,
      tvl: pool.tvlUsd,
      apyChange24h: pool.apyPct1D ?? null,
      risk: "Low",
      timestamp: Date.now(),
    }));
  };

  // ==================== MAIN FETCH FUNCTION ====================
  const fetchRates = useCallback(async () => {
    setLoading(true);
    setError(null);

    try {
      const llamaRates = await fetchFromDefiLlama();
      setRates(llamaRates.sort((a, b) => b.apy - a.apy));
      setLastUpdated(Date.now());
    } catch (err) {
      console.error("Error fetching rates:", err);
      setError(err instanceof Error ? err.message : "Failed to fetch rates");

      // ✅ Fallback mock data
      setRates([
        {
          protocol: "compound-v3",
          token: "USDC",
          apy: 5.8,
          tvl: 2450000000,
          risk: "Low",
          timestamp: Date.now(),
        },
        {
          protocol: "aave-v3",
          token: "DAI",
          apy: 6.3,
          tvl: 5800000000,
          risk: "Low",
          timestamp: Date.now(),
        },
        {
          protocol: "aave-v3",
          token: "ETH",
          apy: 3.1,
          tvl: 890000000,
          risk: "Low",
          timestamp: Date.now(),
        },
      ]);
    } finally {
      setLoading(false);
    }
  }, []);

  // ==================== INITIAL FETCH ====================
  useEffect(() => {
    fetchRates();
  }, [fetchRates]);

  // ==================== AUTO REFRESH EVERY 5 MIN ====================
  useEffect(() => {
    if (!autoRefresh) return;
    const interval = setInterval(fetchRates, 5 * 60 * 1000);
    return () => clearInterval(interval);
  }, [autoRefresh, fetchRates]);

  return {
    rates,
    loading,
    error,
    refresh: fetchRates,
    lastUpdated,
  };
}

// import { useProtocolRates } from "@/hooks/useProtocolRates";

// function YieldTable() {
//   const { rates, loading, error, refresh } = useProtocolRates();

//   if (loading) return <div>Loading...</div>;
//   if (error) return <div>Error: {error}</div>;

//   return (
//     <div>
//       <button onClick={refresh}>Refresh</button>
//       <table>
//         {rates.map((rate) => (
//           <tr key={`${rate.protocol}-${rate.token}`}>
//             <td>{rate.protocol}</td>
//             <td>{rate.token}</td>
//             <td>{rate.apy.toFixed(2)}%</td>
//             <td>${(rate.tvl / 1e6).toFixed(2)}M</td>
//           </tr>
//         ))}
//       </table>
//     </div>
//   );
// }
