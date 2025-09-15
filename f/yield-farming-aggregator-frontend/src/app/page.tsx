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

export default function YieldHunterDashboard() {
  return (
    <div className="min-h-screen bg-background">
      {/* Header Separate the header into a components of its own */}
      <header className="border-b border-border bg-card">
        <div className="container mx-auto px-4 py-4">
          <div className="flex sm:flex-row flex-col items-center justify-between">
            <div className="flex">
              <div className="flex items-center space-x-2">
                <div className="w-8 h-8 bg-accent rounded-lg flex items-center justify-center">
                  <TrendingUp className="w-5 h-5 text-accent-foreground" />
                </div>
                <h1 className="text-xl font-bold text-foreground">
                  Yield Farming Aggregator
                </h1>
              </div>
              <nav className="hidden md:flex space-x-6">
                <a
                  href="#"
                  className="text-foreground hover:text-accent transition-colors"
                >
                  Dashboard
                </a>
                <a
                  href="#"
                  className="text-muted-foreground hover:text-accent transition-colors"
                >
                  Markets
                </a>
                <a
                  href="#"
                  className="text-muted-foreground hover:text-accent transition-colors"
                >
                  Portfolio
                </a>
                <a
                  href="#"
                  className="text-muted-foreground hover:text-accent transition-colors"
                >
                  Analytics
                </a>
              </nav>
            </div>
            <div className="flex">
              <Button variant="outline" size="sm">
                <RefreshCw className="w-4 h-4 mr-2" />
                Refresh
              </Button>
              <Button variant="outline" size="sm">
                <Settings className="w-4 h-4" />
              </Button>
              <Button className="bg-accent hover:bg-accent/90 text-accent-foreground">
                <Wallet className="w-4 h-4 mr-2" />
                Connect Wallet
              </Button>
            </div>
          </div>
        </div>
      </header>

      {/* Main Content */}
      <main className="container mx-auto px-4 py-8">
        {/* Hero Section */}
        <div className="mb-8">
          <h2 className="text-3xl font-bold text-foreground mb-2 text-balance">
            Discover the highest yields in DeFi
          </h2>
          <p className="text-muted-foreground text-lg text-pretty">
            Compare rates across 20+ protocols and maximize your crypto
            earnings.
          </p>
          <div className="flex items-center text-sm text-muted-foreground mt-4">
            <div className="w-2 h-2 bg-accent rounded-full mr-2 animate-pulse"></div>
            Data updated 2 minutes ago
          </div>
        </div>

        {/* Summary Cards */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
          <Card className="bg-card border-border">
            <CardHeader className="pb-3">
              <CardTitle className="text-sm font-medium text-muted-foreground">
                Highest APY Available
              </CardTitle>
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold text-accent">18.7%</div>
              <p className="text-xs text-muted-foreground mt-1">
                Uniswap V3 ETH/USDC
              </p>
            </CardContent>
          </Card>

          <Card className="bg-card border-border">
            <CardHeader className="pb-3">
              <CardTitle className="text-sm font-medium text-muted-foreground">
                Total Protocols Tracked
              </CardTitle>
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold text-foreground">24</div>
              <p className="text-xs text-muted-foreground mt-1">
                Active protocols
              </p>
            </CardContent>
          </Card>

          <Card className="bg-card border-border">
            <CardHeader className="pb-3">
              <CardTitle className="text-sm font-medium text-muted-foreground">
                Average Market APY
              </CardTitle>
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold text-foreground">11.2%</div>
              <p className="text-xs text-muted-foreground mt-1">
                Across all protocols
              </p>
            </CardContent>
          </Card>

          <Card className="bg-card border-border">
            <CardHeader className="pb-3">
              <CardTitle className="text-sm font-medium text-muted-foreground">
                Best Low-Risk Option
              </CardTitle>
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold text-accent">8.5%</div>
              <p className="text-xs text-muted-foreground mt-1">
                Compound USDC
              </p>
            </CardContent>
          </Card>
        </div>

        {/* Search and Filter Bar */}
        <div className="flex flex-col sm:flex-row gap-4 mb-6">
          <div className="relative flex-1">
            <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-muted-foreground w-4 h-4" />
            <input
              type="text"
              placeholder="Search protocols..."
              className="w-full pl-10 pr-4 py-2 bg-input border border-border rounded-lg text-foreground placeholder-muted-foreground focus:outline-none focus:ring-2 focus:ring-ring"
            />
          </div>
          <div className="flex gap-2">
            <select className="px-3 py-2 bg-input border border-border rounded-lg text-foreground focus:outline-none focus:ring-2 focus:ring-ring">
              <option>All Risk Levels</option>
              <option>Low Risk</option>
              <option>Medium Risk</option>
              <option>High Risk</option>
            </select>
            <select className="px-3 py-2 bg-input border border-border rounded-lg text-foreground focus:outline-none focus:ring-2 focus:ring-ring">
              <option>All Assets</option>
              <option>USDC</option>
              <option>ETH</option>
              <option>DAI</option>
            </select>
          </div>
        </div>

        {/* Yield Comparison Table */}
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

        {/* Footer */}
        <footer className="mt-16 pt-8 border-t border-border">
          <div className="flex flex-col md:flex-row justify-between items-center">
            <div className="flex space-x-6 mb-4 md:mb-0">
              <a
                href="#"
                className="text-muted-foreground hover:text-accent transition-colors"
              >
                About
              </a>
              <a
                href="#"
                className="text-muted-foreground hover:text-accent transition-colors"
              >
                FAQ
              </a>
              <a
                href="#"
                className="text-muted-foreground hover:text-accent transition-colors"
              >
                Terms
              </a>
              <a
                href="#"
                className="text-muted-foreground hover:text-accent transition-colors"
              >
                Privacy
              </a>
            </div>
            <p className="text-sm text-muted-foreground">
              Powered by DeFi protocols
            </p>
          </div>
        </footer>
      </main>
    </div>
  );
}
