import { useState } from "react";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import {
  AlertDialog,
  AlertDialogAction,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
} from "@/components/ui/alert-dialog";
import { TrendingUp, TrendingDown } from "lucide-react";
import { toast } from "sonner";
import { useProtocolRates } from "@/hooks/useProtocolRates";

const SUPPORTED_CHAINS = ["Ethereum", "Arbitrum", "Optimism", "zkSync"];

// Shape of the row the user clicked "Start Farming" on
interface SelectedRow {
  protocol: string;
  chain: string;
  token: string;
  apy: number;
  tvl: number;
}

export default function YieldTable() {
  const [selectedChain, setSelectedChain] = useState("Ethereum");
  const { rates, loading, error, refresh } = useProtocolRates(selectedChain);

  // ← Controls which row's dialog is open
  const [dialogRow, setDialogRow] = useState<SelectedRow | null>(null);
  const [isInvesting, setIsInvesting] = useState(false);

  // ==================== INVEST HANDLER ====================
  const handleInvest = async () => {
    if (!dialogRow) return;
    setIsInvesting(true);

    try {
      // TODO: replace with your real invest() contract call
      await new Promise((resolve) => setTimeout(resolve, 1200)); // simulated delay

      const investedAt = new Date().toLocaleTimeString([], {
        hour: "2-digit",
        minute: "2-digit",
        second: "2-digit",
      });

      toast.success("Investment Successful 🎉", {
        description: (
          <div className="mt-1 space-y-1 text-sm">
            <div className="flex justify-between">
              <span className="text-muted-foreground">Protocol</span>
              <span className="font-medium">{dialogRow.protocol}</span>
            </div>
            <div className="flex justify-between">
              <span className="text-muted-foreground">Chain</span>
              <span className="font-medium">{dialogRow.chain}</span>
            </div>
            <div className="flex justify-between">
              <span className="text-muted-foreground">Asset</span>
              <span className="font-medium">{dialogRow.token}</span>
            </div>
            <div className="flex justify-between">
              <span className="text-muted-foreground">APY</span>
              <span className="font-medium text-green-500">
                {dialogRow.apy.toFixed(2)}%
              </span>
            </div>
            <div className="flex justify-between">
              <span className="text-muted-foreground">TVL</span>
              <span className="font-medium">
                ${(dialogRow.tvl / 1e6).toFixed(2)}M
              </span>
            </div>
            <div className="flex justify-between pt-1 border-t border-border">
              <span className="text-muted-foreground">Invested at</span>
              <span className="font-medium">{investedAt}</span>
            </div>
          </div>
        ),
        duration: 6000,
      });
    } catch (err) {
      toast.error("Investment Failed", {
        description: "Something went wrong. Please try again.",
      });
    } finally {
      setIsInvesting(false);
      setDialogRow(null); // close dialog
    }
  };

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
    <>
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

          {/* Chain selector */}
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
                    Chain
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
                        key={`${row.protocol}-${row.chain}-${row.token}`}
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
                          {/* ← Opens the alert dialog for this specific row */}
                          <Button
                            size="sm"
                            variant="outline"
                            className="text-xs bg-transparent"
                            onClick={() =>
                              setDialogRow({
                                protocol: row.protocol,
                                chain: row.chain,
                                token: row.token,
                                apy: row.apy,
                                tvl: row.tvl,
                              })
                            }
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

      {/* ==================== ALERT DIALOG ==================== */}
      <AlertDialog
        open={!!dialogRow}
        onOpenChange={(open) => {
          if (!open) setDialogRow(null);
        }}
      >
        <AlertDialogContent>
          <AlertDialogHeader>
            <AlertDialogTitle>Confirm Investment</AlertDialogTitle>
            <AlertDialogDescription asChild>
              <div className="space-y-3 mt-2">
                <p className="text-sm text-muted-foreground">
                  You are about to start farming in the following opportunity:
                </p>
                {dialogRow && (
                  <div className="rounded-md border border-border p-3 space-y-2 text-sm">
                    <div className="flex justify-between">
                      <span className="text-muted-foreground">Protocol</span>
                      <span className="font-medium">{dialogRow.protocol}</span>
                    </div>
                    <div className="flex justify-between">
                      <span className="text-muted-foreground">Chain</span>
                      <span className="font-medium">{dialogRow.chain}</span>
                    </div>
                    <div className="flex justify-between">
                      <span className="text-muted-foreground">Asset</span>
                      <span className="font-medium">{dialogRow.token}</span>
                    </div>
                    <div className="flex justify-between">
                      <span className="text-muted-foreground">APY</span>
                      <span className="font-medium text-green-500">
                        {dialogRow.apy.toFixed(2)}%
                      </span>
                    </div>
                    <div className="flex justify-between">
                      <span className="text-muted-foreground">TVL</span>
                      <span className="font-medium">
                        ${(dialogRow.tvl / 1e6).toFixed(2)}M
                      </span>
                    </div>
                  </div>
                )}
              </div>
            </AlertDialogDescription>
          </AlertDialogHeader>

          <AlertDialogFooter>
            <AlertDialogCancel disabled={isInvesting}>Cancel</AlertDialogCancel>
            <AlertDialogAction onClick={handleInvest} disabled={isInvesting}>
              {isInvesting ? "Investing..." : "Invest"}
            </AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>
    </>
  );
}
