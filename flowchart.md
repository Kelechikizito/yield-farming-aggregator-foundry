# Yield Farming Aggregator Logic Flowchart

## Main Application Flow

```
START
  ↓
[User Opens App] ✅
  ↓
[Load Dashboard] ✅ → [Fetch Protocol Data] ✅
  ↓                      ↓
[Display Yields] ✅    [Get Current APY/TVL from:] ✅
  ↓                 • Compound Protocol ✅
[User Decision]     • Aave Protocol  ✅
  ↓                 • Uniswap Pools ✅
BRANCH A: View Only • Other DeFi Protocols
BRANCH B: Connect Wallet    ↓
                   [Process & Sort Data]
                          ↓
                   [Display Best Yields]
```

## Wallet Connection Flow ✅

```
[User Clicks "Connect Wallet"]
  ↓
[Check Available Wallets]
  ↓
BRANCH: MetaMask? → [Connect MetaMask]
BRANCH: WalletConnect? → [Connect WalletConnect]
BRANCH: Other? → [Connect Other Wallet]
  ↓
[Wallet Connected?] 
  ↓               ↓
 YES             NO
  ↓               ↓
[Get Wallet Balance] [Show Error Message]
  ↓               ↓
[Show User Portfolio] [Return to Dashboard]
```

## Yield Comparison Logic

```
[Start Yield Comparison]
  ↓
FOR EACH PROTOCOL:
  ↓
[Fetch Current APY]
  ↓
[Check Protocol Safety Score]
  ↓
[Calculate Risk-Adjusted Returns]
  ↓
[Factor in Gas Costs]
  ↓
[Store Protocol Data]
  ↓
[Next Protocol?] → YES (loop back)
  ↓ NO
[Sort All Protocols by:]
• Net APY (after gas)
• Risk Level
• Liquidity Available
  ↓
[Display Ranked Results]
```

## Investment Decision Flow

```
[User Selects Protocol]
  ↓
[Enter Investment Amount]
  ↓
[Validate Input] → [Amount > Wallet Balance?] → YES → [Show Error]
  ↓ NO                                         ↓
[Calculate Estimated Returns]                   [Return to Input]
  ↓
[Show Transaction Preview:]
• Amount to Invest
• Expected APY
• Gas Costs
• Net Expected Returns
  ↓
[User Confirms?] → NO → [Cancel Transaction]
  ↓ YES
[Execute Investment]
```

## Auto-Compound Logic

```
[Auto-Compound Timer Triggered]
  ↓
FOR EACH USER POSITION:
  ↓
[Check Accrued Rewards]
  ↓
[Rewards > Minimum Threshold?] → NO → [Skip This Position]
  ↓ YES
[Calculate Gas Cost for Compound]
  ↓
[Rewards > Gas Cost + Profit Margin?] → NO → [Skip This Position]
  ↓ YES
[Execute Compound Transaction:]
• Claim Rewards
• Reinvest Rewards
• Update Position Data
  ↓
[Transaction Successful?] → NO → [Log Error & Retry Later]
  ↓ YES
[Update User Balance]
  ↓
[Continue to Next Position]
```

## Strategy Switching Logic

```
[Strategy Monitor Timer Triggered]
  ↓
FOR EACH USER POSITION:
  ↓
[Get Current Protocol APY]
  ↓
[Scan All Other Protocols]
  ↓
[Find Best Alternative APY]
  ↓
[Calculate Switch Benefits:]
• New APY - Current APY
• Gas Costs for Exit/Entry
• Time to Break Even
  ↓
[Net Benefit > Threshold?] → NO → [Keep Current Position]
  ↓ YES
[Check User Switch Preferences]
  ↓
[Auto-Switch Enabled?] → NO → [Send Notification Only]
  ↓ YES
[Execute Strategy Switch:]
• Withdraw from Current Protocol
• Claim Any Rewards
• Deposit to New Protocol
  ↓
[Update User Position Data]
```

## Error Handling Flow

```
[Error Detected]
  ↓
[What Type of Error?]
  ↓
BRANCH: Network Error → [Retry Connection] → [Max Retries?] → [Show User Error]
BRANCH: Transaction Failed → [Check Gas/Balance] → [Show Specific Error]
BRANCH: Protocol Error → [Switch to Backup Data Source] → [Log Issue]
BRANCH: User Error → [Show Helpful Message] → [Return to Previous Step]
```

## Data Update Cycle

```
[Application Running]
  ↓
[Background Timer Every 30 seconds:]
  ↓
[Update Protocol APYs]
  ↓
[Update Token Prices]
  ↓
[Update Gas Prices]
  ↓
[Check User Positions]
  ↓
[Trigger Strategy Analysis]
  ↓
[Update UI if Changes Detected]
  ↓
[Continue Cycle]
```

## Risk Management Flow

```
[Before Any Transaction]
  ↓
[Check Protocol Health:]
• TVL Changes
• Recent Exploits
• Community Sentiment
  ↓
[Risk Level Acceptable?] → NO → [Block Transaction & Warn User]
  ↓ YES
[Check User Limits:]
• Max Investment per Protocol
• Total Portfolio Exposure
• Diversification Rules
  ↓
[Within Limits?] → NO → [Suggest Alternative Action]
  ↓ YES
[Proceed with Transaction]
```

## Emergency Procedures

```
[Emergency Detected]
  ↓
[What Emergency Type?]
  ↓
BRANCH: Protocol Exploit → [Auto-withdraw All Funds] → [Move to Safe Assets]
BRANCH: Market Crash → [Check Stop-Loss Triggers] → [Execute if Needed]
BRANCH: Smart Contract Bug → [Pause All Operations] → [Alert Users]
BRANCH: Network Congestion → [Delay Non-Critical Operations] → [Queue for Later]
```

## User Interface Logic

```
[Dashboard Load]
  ↓
[Show Loading Spinner]
  ↓
[Data Loaded?] → NO → [Show Skeleton/Loading State]
  ↓ YES
[Display Components:]
• Yield Comparison Table
• User Portfolio (if connected)
• Market Overview
• Recent Transactions
  ↓
[User Interaction?] → [Route to Appropriate Flow]
  ↓
[Update UI Reactively]
```

## Key Decision Points Summary

1. **Protocol Selection**: APY vs Risk vs Liquidity
2. **Auto-Compound Timing**: Rewards vs Gas Costs
3. **Strategy Switching**: Benefit vs Switching Costs
4. **Risk Management**: Safety vs Returns
5. **User Experience**: Speed vs Accuracy vs Cost

## Data Flow Summary

```
External APIs → Data Processing → Strategy Engine → User Interface
     ↑                                    ↓
User Actions ← Transaction Execution ← Decision Logic
```

This flowchart represents the complete logical structure of your yield farming aggregator, showing how data flows, decisions are made, and actions are executed throughout the system.