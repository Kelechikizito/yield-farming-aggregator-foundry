export default function Hero() {
    return (
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
    )
}