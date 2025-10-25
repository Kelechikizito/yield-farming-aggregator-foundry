import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";

export default function SummaryCards() {
  return (
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
          <div className="text-2xl font-bold text-foreground">2</div>
          <p className="text-xs text-muted-foreground mt-1">Active protocols</p>
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
          <p className="text-xs text-muted-foreground mt-1">Compound</p>
        </CardContent>
      </Card>
    </div>
  );
}
