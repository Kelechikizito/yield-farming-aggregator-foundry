import {
  Search,
} from "lucide-react";

export default function SearchBar() {
    return (
        <div className="flex flex-col sm:flex-row gap-4 mb-6">
          <div className="relative flex-1">
            <Search className="absolute top-3 left-3 text-muted-foreground w-4 h-4" />
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
    )
}