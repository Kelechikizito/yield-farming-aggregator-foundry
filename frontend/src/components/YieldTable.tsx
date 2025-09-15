import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import {
  Search,
  Settings,
  RefreshCw,
  Wallet,
  TrendingUp,
  TrendingDown,
} from "lucide-react";


export default function YieldTable() {
    return (
        <Card className="bg-card border-border">
          <CardHeader>
            <CardTitle className="text-xl font-bold text-foreground">
              Yield Opportunities
            </CardTitle>
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
                  {[
                    {
                      protocol: "Compound",
                      asset: "USDC",
                      apy: "8.5%",
                      tvl: "$2.1B",
                      risk: "Low",
                      change: "+0.3%",
                      isPositive: true,
                    },
                    {
                      protocol: "Aave",
                      asset: "ETH",
                      apy: "12.2%",
                      tvl: "$8.7B",
                      risk: "Medium",
                      change: "-0.8%",
                      isPositive: false,
                    },
                    {
                      protocol: "Uniswap V3",
                      asset: "ETH/USDC",
                      apy: "18.7%",
                      tvl: "$1.4B",
                      risk: "High",
                      change: "+2.1%",
                      isPositive: true,
                      isHighest: true,
                    },
                    {
                      protocol: "Curve",
                      asset: "3Pool",
                      apy: "6.8%",
                      tvl: "$3.2B",
                      risk: "Low",
                      change: "+0.1%",
                      isPositive: true,
                    },
                    {
                      protocol: "Yearn",
                      asset: "yUSDC",
                      apy: "11.4%",
                      tvl: "$890M",
                      risk: "Medium",
                      change: "+1.2%",
                      isPositive: true,
                    },
                    {
                      protocol: "SushiSwap",
                      asset: "ETH/DAI",
                      apy: "15.3%",
                      tvl: "$650M",
                      risk: "High",
                      change: "-1.5%",
                      isPositive: false,
                    },
                  ].map((row, index) => (
                    <tr
                      key={index}
                      className={`border-b border-border hover:bg-muted/50 transition-colors ${
                        row.isHighest ? "bg-accent/10" : ""
                      }`}
                    >
                      <td className="p-4">
                        <div className="flex items-center space-x-3">
                          <div className="w-8 h-8 bg-muted rounded-full flex items-center justify-center">
                            <span className="text-xs font-medium text-muted-foreground">
                              {row.protocol.charAt(0)}
                            </span>
                          </div>
                          <span className="font-medium text-foreground">
                            {row.protocol}
                          </span>
                        </div>
                      </td>
                      <td className="p-4">
                        <span className="font-mono text-sm text-foreground">
                          {row.asset}
                        </span>
                      </td>
                      <td className="p-4">
                        <span
                          className={`font-mono text-sm font-bold ${
                            row.isHighest ? "text-accent" : "text-foreground"
                          }`}
                        >
                          {row.apy}
                        </span>
                      </td>
                      <td className="p-4">
                        <span className="font-mono text-sm text-foreground">
                          {row.tvl}
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
                          {row.isPositive ? (
                            <TrendingUp className="w-3 h-3 text-accent" />
                          ) : (
                            <TrendingDown className="w-3 h-3 text-destructive" />
                          )}
                          <span
                            className={`font-mono text-sm ${
                              row.isPositive
                                ? "text-accent"
                                : "text-destructive"
                            }`}
                          >
                            {row.change}
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
                  ))}
                </tbody>
              </table>
            </div>
          </CardContent>
        </Card>
    )
}