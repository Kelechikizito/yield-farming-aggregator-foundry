import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { TrendingUp, TrendingDown } from "lucide-react";
import { useProtocolRates } from "@/hooks/useProtocolRates";

export default function YieldTable() {
  const { rates, loading, error, refresh } = useProtocolRates();

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
              {rates.map((row, index) => {
                const isPositive = Math.random() > 0.5;
                const randomChange = (Math.random() * 2).toFixed(1); // mock 24h change
                const isHighest = index === 0;

                return (
                  <tr
                    key={index}
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
                          {randomChange}%
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
              })}
            </tbody>
          </table>
        </div>
      </CardContent>
    </Card>
  );
}
