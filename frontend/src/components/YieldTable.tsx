import { useState } from "react";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { TrendingUp, TrendingDown } from "lucide-react";
import { useProtocolRates } from "@/hooks/useProtocolRates";

const SUPPORTED_CHAINS = ["Ethereum", "Arbitrum", "Optimism", "zkSync"];

export default function YieldTable() {
  const [selectedChain, setSelectedChain] = useState("Ethereum"); // ← chain state
  const { rates, loading, error, refresh } = useProtocolRates(selectedChain); // ← pass chain

  if (loading)
    return (
      <div className="text-muted-foreground text-center py-8">Loading...</div>
    );
  if (error)
    return (
      <div className="text-destructive text-center py-8">
        Error: {error}
        <Button onClick={refresh} className="ml-3" variant="outline" size="sm">
          Retry
        </Button>
      </div>
    );

  return (
    <Card className="bg-card border-border">
      <CardHeader>
        <div className="flex items-center justify-between">
          <CardTitle className="text-xl font-bold text-foreground">
            Yield Opportunities
          </CardTitle>
          <Button
            onClick={refresh}
            variant="outline"
            size="sm"
            className="flex items-center space-x-2"
          >
            <TrendingUp className="w-4 h-4" />
            <span>Refresh</span>
          </Button>
        </div>

        {/* ← Chain selector */}
        <div className="flex flex-col sm:flex-row items-center gap-4 mt-3">
          {SUPPORTED_CHAINS.map((chain) => (
            <Button
              key={chain}
              size="sm"
              variant={selectedChain === chain ? "default" : "outline"}
              onClick={() => setSelectedChain(chain)}
              className="text-xs"
            >
              {chain}
            </Button>
          ))}
        </div>
      </CardHeader>

      <CardContent className="p-0">
        <div className="overflow-x-auto">
          <table className="w-full">
            <thead>
              <tr className="border-b border-border">
                <th className="text-left p-4 text-sm font-medium text-muted-foreground">
                  Protocol
                </th>
                <th className="text-left p-4 text-sm font-medium text-muted-foreground">
                  Chain {/* ← added */}
                </th>
                <th className="text-left p-4 text-sm font-medium text-muted-foreground">
                  Asset
                </th>
                <th className="text-left p-4 text-sm font-medium text-muted-foreground">
                  APY
                </th>
                <th className="text-left p-4 text-sm font-medium text-muted-foreground">
                  TVL
                </th>
                <th className="text-left p-4 text-sm font-medium text-muted-foreground">
                  Risk
                </th>
                <th className="text-left p-4 text-sm font-medium text-muted-foreground">
                  24h Change
                </th>
                <th className="text-left p-4 text-sm font-medium text-muted-foreground">
                  Action
                </th>
              </tr>
            </thead>

            <tbody>
              {rates.length === 0 ? (
                <tr>
                  <td
                    colSpan={8}
                    className="text-center p-8 text-muted-foreground"
                  >
                    No yield opportunities found on {selectedChain}
                  </td>
                </tr>
              ) : (
                rates.map((row, index) => {
                  const apyChange = row.apyChange24h;
                  const isPositive =
                    apyChange != null ? apyChange >= 0 : Math.random() > 0.5;
                  const displayChange =
                    apyChange != null
                      ? Math.abs(apyChange).toFixed(1)
                      : (Math.random() * 2).toFixed(1);
                  const isHighest = index === 0;

                  return (
                    <tr
                      key={`${row.protocol}-${row.chain}-${row.token}`} // ← better key
                      className={`border-b border-border hover:bg-muted/50 transition-colors ${
                        isHighest ? "bg-accent/10" : ""
                      }`}
                    >
                      <td className="p-4">
                        <div className="flex items-center space-x-3">
                          <div className="w-8 h-8 bg-muted rounded-full flex items-center justify-center">
                            <span className="text-xs font-medium text-muted-foreground">
                              {row.protocol.charAt(0).toUpperCase()}
                            </span>
                          </div>
                          <span className="font-medium text-foreground">
                            {row.protocol}
                          </span>
                        </div>
                      </td>

                      {/* ← Chain column */}
                      <td className="p-4">
                        <span className="text-sm text-muted-foreground">
                          {row.chain}
                        </span>
                      </td>

                      <td className="p-4">
                        <span className="font-mono text-sm text-foreground">
                          {row.token}
                        </span>
                      </td>

                      <td className="p-4">
                        <span
                          className={`font-mono text-sm font-bold ${
                            isHighest ? "text-accent" : "text-foreground"
                          }`}
                        >
                          {row.apy.toFixed(2)}%
                        </span>
                      </td>

                      <td className="p-4">
                        <span className="font-mono text-sm text-foreground">
                          ${Number(row.tvl / 1e6).toFixed(2)}M
                        </span>
                      </td>

                      <td className="p-4">
                        <Badge
                          variant={
                            row.risk === "Low"
                              ? "secondary"
                              : row.risk === "Medium"
                                ? "outline"
                                : "destructive"
                          }
                        >
                          {row.risk}
                        </Badge>
                      </td>

                      <td className="p-4">
                        <div className="flex items-center space-x-1">
                          {isPositive ? (
                            <TrendingUp className="w-3 h-3 text-accent" />
                          ) : (
                            <TrendingDown className="w-3 h-3 text-destructive" />
                          )}
                          <span
                            className={`font-mono text-sm ${
                              isPositive ? "text-accent" : "text-destructive"
                            }`}
                          >
                            {isPositive ? "+" : "-"}
                            {displayChange}%
                          </span>
                        </div>
                      </td>

                      <td className="p-4">
                        <Button
                          size="sm"
                          variant="outline"
                          className="text-xs bg-transparent"
                        >
                          Start Farming
                        </Button>
                      </td>
                    </tr>
                  );
                })
              )}
            </tbody>
          </table>
        </div>
      </CardContent>
    </Card>
  );
}
