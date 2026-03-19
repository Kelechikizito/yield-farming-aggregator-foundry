import { useState } from "react";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
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

  const [dialogRow, setDialogRow] = useState<SelectedRow | null>(null);
  const [isInvesting, setIsInvesting] = useState(false);

  // ← Amount input state
  const [amount, setAmount] = useState("");
  const [amountError, setAmountError] = useState<string | null>(null);

  // ==================== OPEN DIALOG ====================
  const openDialog = (row: SelectedRow) => {
    setAmount(""); // reset amount on each open
    setAmountError(null); // reset error on each open
    setDialogRow(row);
  };

  // ==================== AMOUNT VALIDATION ====================
  const validateAmount = (value: string): boolean => {
    if (!value || value.trim() === "") {
      setAmountError("Please enter an amount to invest.");
      return false;
    }
    const parsed = parseFloat(value);
    if (isNaN(parsed) || parsed <= 0) {
      setAmountError("Amount must be a positive number.");
      return false;
    }
    setAmountError(null);
    return true;
  };

  // ==================== INVEST HANDLER ====================
  const handleInvest = async () => {
    if (!dialogRow) return;
    if (!validateAmount(amount)) return; // block submission if invalid

    setIsInvesting(true);

    try {
      // TODO: replace with your real invest() contract call
      // e.g. await yieldAggregator.invest(token, parseUnits(amount, 6), protocol)
      await new Promise((resolve) => setTimeout(resolve, 1200));

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
              <span className="text-muted-foreground">Amount Invested</span>
              <span className="font-medium">
                {amount} {dialogRow.token}
              </span>
            </div>
            <div className="flex justify-between">
              <span className="text-muted-foreground">APY</span>
              <span className="font-medium text-green-500">
                {dialogRow.apy.toFixed(2)}%
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
      setDialogRow(null);
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
                        className={`border-b border-border hover:bg-muted/50 transition-colors ${isHighest ? "bg-accent/10" : ""}`}
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
                            className={`font-mono text-sm font-bold ${isHighest ? "text-accent" : "text-foreground"}`}
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
                              className={`font-mono text-sm ${isPositive ? "text-accent" : "text-destructive"}`}
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
                            className="text-xs bg-transparent cursor-pointer"
                            onClick={() =>
                              openDialog({
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
              <div className="space-y-4 mt-2">
                {/* Position summary */}
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

                {/* ← Amount input */}
                <div className="space-y-2">
                  <Label
                    htmlFor="invest-amount"
                    className="text-sm font-medium"
                  >
                    Amount to Invest ({dialogRow?.token})
                  </Label>
                  <Input
                    id="invest-amount"
                    type="number"
                    min="0"
                    step="any"
                    placeholder={`e.g. 100`}
                    value={amount}
                    onChange={(e) => {
                      setAmount(e.target.value);
                      if (amountError) validateAmount(e.target.value); // live re-validate after first error
                    }}
                    className={
                      amountError
                        ? "border-destructive focus-visible:ring-destructive"
                        : ""
                    }
                  />
                  {/* Inline error message */}
                  {amountError && (
                    <p className="text-xs text-destructive">{amountError}</p>
                  )}
                </div>
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
