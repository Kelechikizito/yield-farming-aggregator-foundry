## Frontend Architecture & Component Structure

Based on your flowchart, here's a comprehensive guide to building the frontend for your yield farming aggregator:

## Core Application Structure

### **App Architecture:**
```
src/
├── components/           # Reusable UI components
├── pages/               # Main application pages
├── hooks/               # Custom React hooks
├── services/            # API calls and blockchain interactions
├── utils/               # Helper functions
├── store/               # State management
├── types/               # TypeScript definitions
└── assets/              # Images, icons, etc.
```

## Essential Pages/Views

### **1. Dashboard (Main Landing Page)**
**Purpose:** Overview of all available yields and user portfolio
**Components needed:**
- Header with wallet connection
- Yield comparison table
- Market overview cards
- User portfolio summary (if connected)

### **2. Protocol Details Page**
**Purpose:** Deep dive into specific protocols
**Components needed:**
- Protocol information card
- Historical APY charts
- Risk metrics
- Investment interface

### **3. Portfolio Page**
**Purpose:** User's current positions and performance
**Components needed:**
- Position cards
- Performance charts
- Transaction history
- Auto-compound settings

### **4. Analytics Page**
**Purpose:** Market insights and trends
**Components needed:**
- Yield trend charts
- Protocol comparison graphs
- Market statistics

## Core Components Breakdown

### **Layout Components**

**1. AppLayout.tsx**
```tsx
// Main application shell
- Header (wallet connection, navigation)
- Sidebar (optional, for desktop)
- Main content area
- Footer
- Notification system
```

**2. Header.tsx**
```tsx
// Top navigation and wallet
- Logo/brand
- Navigation menu
- Wallet connection button
- User profile dropdown (when connected)
- Network selector
```

### **Dashboard Components**

**3. YieldTable.tsx**
```tsx
// Main yields comparison table
- Sortable columns (Protocol, APY, TVL, Risk)
- Search/filter functionality
- Protocol logos and names
- Investment quick actions
- Loading states
```

**4. MarketOverview.tsx**
```tsx
// Market statistics cards
- Total TVL across all protocols
- Average APY
- Best performing protocol
- Market trend indicators
```

**5. PortfolioSummary.tsx**
```tsx
// User's portfolio at a glance
- Total invested amount
- Current value
- Total earned
- Active positions count
```

### **Investment Components**

**6. InvestmentModal.tsx**
```tsx
// Investment flow interface
- Amount input
- Protocol selection
- Transaction preview
- Gas estimation
- Confirm/cancel buttons
- Progress indicators
```

**7. ProtocolCard.tsx**
```tsx
// Individual protocol display
- Protocol logo and name
- Current APY
- TVL and safety score
- Quick invest button
- Risk indicators
```

### **Portfolio Management Components**

**8. PositionCard.tsx**
```tsx
// Individual position display
- Amount invested
- Current value
- Earned rewards
- APY performance
- Manage actions (withdraw, compound)
```

**9. AutoCompoundSettings.tsx**
```tsx
// Auto-compound configuration
- Enable/disable toggle
- Minimum threshold settings
- Gas limit preferences
- Frequency selection
```

### **Wallet & Transaction Components**

**10. WalletConnector.tsx**
```tsx
// Wallet connection interface
- Available wallet options (MetaMask, WalletConnect)
- Connection status
- Account display
- Disconnect option
```

**11. TransactionStatus.tsx**
```tsx
// Transaction progress tracking
- Pending state
- Success/failure states
- Transaction hash links
- Retry mechanisms
```

### **Data Visualization Components**

**12. APYChart.tsx**
```tsx
// Historical APY trends
- Line chart for APY over time
- Multiple protocol comparison
- Time range selectors
- Interactive tooltips
```

**13. PortfolioChart.tsx**
```tsx
// Portfolio performance visualization
- Portfolio value over time
- Asset allocation pie chart
- Profit/loss tracking
```

## Frontend Development Strategy

### **Phase 1: Core Foundation (Weeks 1-2)**

**Start with essential infrastructure:**

1. **Setup & Configuration**
   - Create React app with TypeScript
   - Configure routing (React Router)
   - Setup state management (Redux Toolkit or Zustand)
   - Install Web3 libraries (ethers.js, wagmi)

2. **Basic Layout**
   - AppLayout component
   - Header with basic navigation
   - Responsive design foundation

3. **Wallet Integration**
   - WalletConnector component
   - Basic wallet connection flow
   - Account display

### **Phase 2: Core Features (Weeks 3-4)**

**Build the main user journey:**

1. **Dashboard Page**
   - YieldTable component
   - Basic protocol data display
   - MarketOverview cards

2. **Investment Flow**
   - InvestmentModal component
   - Amount validation
   - Transaction submission

3. **Portfolio Basics**
   - PortfolioSummary component
   - Basic position tracking

### **Phase 3: Advanced Features (Weeks 5-6)**

**Add sophisticated functionality:**

1. **Auto-compound Interface**
   - Settings configuration
   - Status monitoring
   - History tracking

2. **Analytics & Charts**
   - APY trend visualization
   - Portfolio performance charts
   - Protocol comparison tools

3. **Strategy Management**
   - Strategy switching interface
   - Recommendation system
   - Risk assessment display

### **Phase 4: Polish & Optimization (Weeks 7-8)**

**Enhance user experience:**

1. **Error Handling**
   - Comprehensive error states
   - User-friendly error messages
   - Retry mechanisms

2. **Loading States**
   - Skeleton screens
   - Progress indicators
   - Optimistic updates

3. **Mobile Optimization**
   - Responsive components
   - Touch-friendly interactions
   - Mobile-specific flows

## Key Frontend Technologies

### **Core Stack:**
- **React 18** with TypeScript
- **Vite** for development/building
- **React Router** for navigation
- **Tailwind CSS** for styling

### **Web3 Integration:**
- **wagmi** - React hooks for Ethereum
- **viem** - TypeScript Ethereum library
- **RainbowKit** - Wallet connection UI

### **State Management:**
- **Zustand** (lightweight) or **Redux Toolkit**
- **React Query** for server state
- **Local storage** for user preferences

### **UI/Visualization:**
- **Recharts** for data visualization
- **Framer Motion** for animations
- **Radix UI** or **Headless UI** for primitives

## Critical Frontend Considerations

### **Performance:**
- Lazy load heavy components
- Virtualize large lists (yield tables)
- Optimize bundle size with code splitting
- Cache API responses

### **User Experience:**
- Clear loading states everywhere
- Intuitive error messages
- Consistent visual feedback
- Mobile-first responsive design

### **Security:**
- Validate all user inputs
- Sanitize displayed data
- Secure wallet interactions
- Environment variable management

### **Accessibility:**
- Keyboard navigation
- Screen reader support
- High contrast mode
- Focus management

## Data Flow Architecture

```
User Action → Component → Custom Hook → Service Layer → Blockchain/API
     ↑                                        ↓
User Interface ← State Update ← Response Processing ← Response
```

### **Custom Hooks You'll Need:**

```tsx
useWallet()          // Wallet connection and account data
useProtocols()       // Fetch protocol data and APYs
useUserPositions()   // User's current positions
useInvestment()      // Investment transaction logic
useAutoCompound()    // Auto-compound settings and status
useMarketData()      // Overall market statistics
```

## Getting Started Checklist

1. **Setup Development Environment**
   - Node.js and package manager
   - Code editor with TypeScript support
   - Git repository

2. **Initialize Project**
   ```bash
   npm create vite@latest yield-aggregator -- --template react-ts
   cd yield-aggregator
   npm install wagmi viem @rainbow-me/rainbowkit
   ```

3. **Core Dependencies**
   ```bash
   npm install react-router-dom zustand @tanstack/react-query
   npm install recharts framer-motion lucide-react
   npm install tailwindcss @tailwindcss/forms
   ```

4. **Development Tools**
   ```bash
   npm install -D @types/node eslint prettier
   ```

Start with the Dashboard page and YieldTable component - this gives users immediate value and helps you understand the data flow. Then build the wallet connection and investment modal. This approach ensures you have a working prototype quickly while building toward the full feature set.

Would you like me to provide detailed code examples for any specific components or elaborate on the state management strategy?