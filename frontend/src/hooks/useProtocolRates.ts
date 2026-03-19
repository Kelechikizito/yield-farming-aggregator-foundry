// hooks/useProtocolRates.ts
import { useState, useEffect, useCallback } from "react";

interface ProtocolRate {
  protocol: string;
  chain: string; // ← added
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

// ← chain parameter added, defaults to "Ethereum"
export function useProtocolRates(
  chain = "Ethereum",
  autoRefresh = true,
): UseProtocolRatesReturn {
  const [rates, setRates] = useState<ProtocolRate[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [lastUpdated, setLastUpdated] = useState<number | null>(null);

  // ==================== FETCH FROM DEFI LLAMA ====================
  const fetchFromDefiLlama = async (): Promise<ProtocolRate[]> => {
    const response = await fetch("https://yields.llama.fi/pools");
    const { data } = await response.json();

    const targetProtocols = ["aave-v3", "compound-v3"];

    // ✅ Filter to only single-asset pools (exclude LP pairs)
    const filtered = data
      .filter(
        (pool: any) =>
          targetProtocols.includes(pool.project) &&
          pool.chain === chain && // ← dynamic now, no longer hardcoded
          pool.apy > 0 &&
          pool.exposure === "single" && // Only single-asset pools
          !pool.symbol?.includes("/"), // Exclude LP pairs like "ETH/USDC"
      )
      // ✅ Deduplicate: for same protocol+token, keep highest TVL
      .reduce((acc: any[], pool: any) => {
        const key = `${pool.project}-${pool.symbol}`;
        const existing = acc.find((p) => `${p.project}-${p.symbol}` === key);
        if (!existing || pool.tvlUsd > existing.tvlUsd) {
          return [
            ...acc.filter((p) => `${p.project}-${p.symbol}` !== key),
            pool,
          ];
        }
        return acc;
      }, [])
      .slice(0, 30);

    // ✅ Normalize and map fields
    return filtered.map((pool: any) => ({
      protocol: pool.project,
      chain: pool.chain, // ← added
      token: pool.symbol || "N/A",
      apy: pool.apy,
      tvl: pool.tvlUsd,
      apyChange24h: pool.apyPct1D ?? null,
      risk: "Low",
      timestamp: Date.now(),
    }));
  };

  // ==================== MAIN FETCH FUNCTION ====================
  // ← chain added to dependency array so refetch fires when chain changes
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
          chain: chain,
          token: "USDC",
          apy: 5.8,
          tvl: 2450000000,
          risk: "Low",
          timestamp: Date.now(),
        },
        {
          protocol: "aave-v3",
          chain: chain,
          token: "DAI",
          apy: 6.3,
          tvl: 5800000000,
          risk: "Low",
          timestamp: Date.now(),
        },
        {
          protocol: "aave-v3",
          chain: chain,
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
  }, [chain]); // ← chain in dependency array

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

// ==================== USAGE EXAMPLE ====================
// import { useProtocolRates } from "@/hooks/useProtocolRates";
//
// const SUPPORTED_CHAINS = ["Ethereum", "Arbitrum", "Optimism", "zkSync"];
//
// function YieldTable() {
//   const [selectedChain, setSelectedChain] = useState("Ethereum");
//   const { rates, loading, error, refresh } = useProtocolRates(selectedChain);
//
//   if (loading) return <div>Loading...</div>;
//   if (error) return <div>Error: {error}</div>;
//
//   return (
//     <div>
//       {/* Chain selector buttons */}
//       <div>
//         {SUPPORTED_CHAINS.map((chain) => (
//           <button
//             key={chain}
//             onClick={() => setSelectedChain(chain)}
//             style={{ fontWeight: selectedChain === chain ? "bold" : "normal" }}
//           >
//             {chain}
//           </button>
//         ))}
//         <button onClick={refresh}>Refresh</button>
//       </div>
//
//       <table>
//         <thead>
//           <tr>
//             <th>Protocol</th>
//             <th>Chain</th>
//             <th>Token</th>
//             <th>APY</th>
//             <th>TVL</th>
//             <th>24h Change</th>
//             <th>Action</th>
//           </tr>
//         </thead>
//         <tbody>
//           {rates.map((rate) => (
//             <tr key={`${rate.protocol}-${rate.chain}-${rate.token}`}>
//               <td>{rate.protocol}</td>
//               <td>{rate.chain}</td>
//               <td>{rate.token}</td>
//               <td>{rate.apy.toFixed(2)}%</td>
//               <td>${(rate.tvl / 1e6).toFixed(2)}M</td>
//               <td>{rate.apyChange24h != null ? `${rate.apyChange24h.toFixed(1)}%` : "—"}</td>
//               <td><button>Start Farming</button></td>
//             </tr>
//           ))}
//         </tbody>
//       </table>
//     </div>
//   );
// }
