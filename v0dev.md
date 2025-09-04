# V0.dev Prompt: DeFi Yield Comparison Dashboard

## Project Description
Create a modern, responsive dashboard that displays and compares cryptocurrency yield farming rates across different DeFi protocols. This is the foundation for a yield farming aggregator application.

## Core Features Required

### 1. Main Dashboard Layout
- Clean, modern design with a financial/crypto theme
- Dark mode preferred with blue/green accent colors
- Responsive design that works on desktop and mobile
- Header with app name "YieldHunter" or similar
- Navigation placeholder for future features

### 2. Yield Comparison Table
Create a data table displaying:

**Columns:**
- Protocol Name (with logo/icon)
- Asset Type (USDC, ETH, DAI, etc.)
- Current APY (Annual Percentage Yield)
- TVL (Total Value Locked) in millions
- Risk Level (Low/Medium/High with color indicators)
- 24h Change (percentage change with up/down arrows)

**Sample Data to Display:**
```
Compound - USDC - 8.5% APY - $2.1B TVL - Low Risk - +0.3%
Aave - ETH - 12.2% APY - $8.7B TVL - Medium Risk - -0.8%
Uniswap V3 - ETH/USDC - 18.7% APY - $1.4B TVL - High Risk - +2.1%
Curve - 3Pool - 6.8% APY - $3.2B TVL - Low Risk - +0.1%
Yearn - yUSDC - 11.4% APY - $890M TVL - Medium Risk - +1.2%
SushiSwap - ETH/DAI - 15.3% APY - $650M TVL - High Risk - -1.5%
```

### 3. Key Features
- **Sortable columns** (click headers to sort by APY, TVL, etc.)
- **Search/filter functionality** to find specific protocols
- **"Best Yield" highlight** - visually emphasize the highest APY option
- **Risk indicators** with colored badges (green=low, yellow=medium, red=high)
- **Trending arrows** for 24h changes (green up, red down)

### 4. Summary Cards
At the top, show 4 summary cards:
- **Highest APY Available** (show best rate with protocol name)
- **Total Protocols Tracked** (show number like "24 Protocols")
- **Average Market APY** (calculated average)
- **Best Low-Risk Option** (highest APY among low-risk protocols)

### 5. Visual Enhancements
- **Protocol logos/icons** (use placeholder icons or simple colored circles)
- **Interactive hover effects** on table rows
- **Loading states** with skeleton placeholders
- **Responsive design** that stacks nicely on mobile
- **Charts/graphs** (optional): Simple bar chart showing APY comparison

### 6. Call-to-Action Elements
- **"Connect Wallet" button** (placeholder, not functional yet)
- **"Start Farming" buttons** next to each protocol (placeholders)
- **"Learn More" links** for each protocol

### 7. Additional UI Elements
- **Last updated timestamp** ("Data updated 2 minutes ago")
- **Refresh button** to simulate data updates
- **Settings gear icon** for future configuration
- **Help/FAQ tooltip icons** next to technical terms

## Design Guidelines

### Color Scheme
- Primary: Dark blue/navy (#1a202c)
- Secondary: Bright green for positive numbers (#48bb78)
- Accent: Blue for interactive elements (#4299e1)
- Warning: Orange/yellow for medium risk (#ed8936)
- Danger: Red for high risk and negative numbers (#f56565)

### Typography
- Use a clean, modern font like Inter or similar
- Clear hierarchy with different font weights
- Monospace font for numbers (APY, TVL, percentages)

### Layout
- Full-width container with proper padding
- Card-based design for different sections
- Proper spacing between elements
- Mobile-first responsive approach

## Technical Requirements
- Built with React and modern CSS (Tailwind preferred)
- Interactive table with sort functionality
- Simulated data (hardcoded is fine for now)
- Smooth animations and transitions
- Clean, semantic HTML structure
- Accessible design with proper ARIA labels

## Nice-to-Have Features
- **Filter dropdown** for risk level, asset type
- **APY range slider** to filter by yield percentage
- **Favorites system** to bookmark preferred protocols
- **Notifications badge** for significant rate changes
- **Mini charts** showing 7-day APY history for each protocol
- **Export data** button (CSV download simulation)

## User Experience Goals
- Users should immediately understand which protocol offers the best returns
- Information should be scannable and easy to compare
- The interface should feel professional and trustworthy
- Loading and interaction states should be smooth and responsive

## Sample Header Text
"Discover the highest yields in DeFi. Compare rates across 20+ protocols and maximize your crypto earnings."

## Footer Elements
- Links: About, FAQ, Terms, Privacy
- Social media placeholders
- "Powered by DeFi protocols" disclaimer

Create a polished, production-ready dashboard that looks like it belongs in the modern DeFi ecosystem. Focus on clean design, clear information hierarchy, and intuitive user experience.