// hooks/useProtocolRates.ts
import { useState, useEffect, useCallback } from "react";

interface ProtocolRate {
  protocol: string;
  token: string;
  apy: number;
  tvl: number;
  risk?: string;
  timestamp: number;
}

interface UseProtocolRatesReturn {
  rates: ProtocolRate[];
  loading: boolean;
  error: string | null;
  refresh: () => Promise<void>;
}

export function useProtocolRates(autoRefresh = true): UseProtocolRatesReturn {
  const [rates, setRates] = useState<ProtocolRate[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  // ==================== FETCH FROM DEFI LLAMA ====================
  const fetchFromDefiLlama = async (): Promise<ProtocolRate[]> => {
    const response = await fetch("https://yields.llama.fi/pools");
    const data = await response.json();

    return data.data
      .filter(
        (pool: any) =>
          ["Compound", "Aave", "Uniswap V3"].includes(pool.project) &&
          pool.apy > 0
      )
      .slice(0, 20) // Limit to top 20 pools
      .map((pool: any) => ({
        protocol: pool.project,
        token: pool.symbol,
        apy: pool.apy,
        tvl: pool.tvlUsd || 0,
        risk: pool.exposure === "single" ? "Low" : "Medium",
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
    } catch (err) {
      console.error("Error fetching rates:", err);
      setError(err instanceof Error ? err.message : "Failed to fetch rates");

      // Fallback mock data (optional)
      setRates([
        {
          protocol: "Compound",
          token: "USDC",
          apy: 12.5,
          tvl: 2450000000,
          risk: "Low",
          timestamp: Date.now(),
        },
        {
          protocol: "Aave",
          token: "USDT",
          apy: 8.2,
          tvl: 5800000000,
          risk: "Low",
          timestamp: Date.now(),
        },
        {
          protocol: "Uniswap V3",
          token: "ETH/USDC",
          apy: 15.8,
          tvl: 890000000,
          risk: "Medium",
          timestamp: Date.now(),
        },
      ]);
    } finally {
      setLoading(false);
    }
  }, []);

  // Initial fetch
  useEffect(() => {
    fetchRates();
  }, [fetchRates]);

  // Auto-refresh every 30 seconds
  useEffect(() => {
    if (!autoRefresh) return;

    const interval = setInterval(fetchRates, 30000);
    return () => clearInterval(interval);
  }, [autoRefresh, fetchRates]);

  return {
    rates,
    loading,
    error,
    refresh: fetchRates,
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
