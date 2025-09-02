# BitLend - Institutional Bitcoin Lending Protocol

[![Clarity Version](https://img.shields.io/badge/Clarity-3.0-blue.svg)](https://docs.stacks.co/clarity)
[![Protocol Version](https://img.shields.io/badge/Protocol-v3.1.0-green.svg)](./contracts/bitlend.clar)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](./LICENSE)
[![Tests](https://img.shields.io/badge/Tests-Vitest-brightgreen.svg)](./tests)

## Overview

BitLend is an advanced Bitcoin collateralized lending platform designed for institutional investors and sophisticated traders seeking maximum capital efficiency. Built on the Stacks blockchain, BitLend transforms idle Bitcoin holdings into productive assets through a sophisticated lending protocol that offers dynamic interest rates, automated risk management, and enterprise-grade security features.

Institutions can deposit Bitcoin as collateral to access liquidity while maintaining long-term exposure to Bitcoin's price appreciation, enabling capital efficiency without sacrificing Bitcoin position integrity.

## 🚀 Key Features

### Core Functionality

- **Bitcoin-Collateralized Lending**: Secure Bitcoin deposits to unlock liquidity
- **Dynamic Interest Rates**: Market-responsive rates based on volatility and risk metrics
- **Multi-Asset Support**: BTC, STX, and USDC support with extensible architecture
- **Automated Risk Management**: Real-time health scoring and liquidation protection
- **Enterprise-Grade Security**: Comprehensive validation and emergency controls

### Advanced Features

- **Compound Interest Calculations**: Sophisticated interest accrual mechanisms
- **Volatility-Adjusted Collateral Ratios**: Risk-aware collateral requirements
- **Position Health Monitoring**: Continuous risk assessment and alerts
- **Liquidation Protection**: Optional protection mechanisms for qualified positions
- **Portfolio Management**: Multi-position tracking and analytics

### Institutional Features

- **Governance Controls**: Protocol parameter management and upgrades
- **Emergency Pause Mechanism**: Circuit breakers for market protection
- **Revenue Tracking**: Transparent protocol fee and revenue analytics
- **Oracle Integration**: Real-time price feeds with confidence scoring

## 📊 Protocol Specifications

### Risk Parameters

- **Minimum Collateral Ratio**: 175% (configurable)
- **Liquidation Threshold**: 130% (configurable)
- **Maximum User Positions**: 25 positions per account
- **Liquidation Penalty**: 5% of collateral value
- **Protocol Fee**: 2% (configurable, max 10%)

### Supported Assets

- **BTC**: Primary collateral asset with volatility-adjusted pricing
- **STX**: Secondary collateral with enhanced volatility monitoring
- **USDC**: Stable asset support for diversified strategies

### Technical Limits

- **Maximum Loan Term**: 36 months
- **Position Tracking**: Up to 25 concurrent positions per user
- **Price Oracle**: Real-time feeds with confidence scoring (90-95%)

## 🏗️ Architecture

### Smart Contract Structure

```
contracts/
├── bitlend.clar           # Main protocol contract
└── ...                   # Additional modules (future expansion)

Core Components:
├── Financial Calculations # Interest, collateral ratios, risk assessment
├── Position Management   # Creation, tracking, liquidation
├── User Accounts        # Portfolio management, health scoring
├── Price Oracles        # Multi-asset price feeds
├── Governance           # Parameter updates, emergency controls
└── Read-Only Functions  # Analytics and reporting
```

### Data Structures

#### Lending Positions

```clarity
{
  borrower: principal,
  collateral-amount: uint,
  loan-amount: uint,
  interest-rate: uint,
  created-block: uint,
  last-update: uint,
  status: (string-ascii 20),
  risk-level: (string-ascii 10),
  protection-enabled: bool
}
```

#### User Accounts

```clarity
{
  position-ids: (list 25 uint),
  total-collateral: uint,
  total-interest-paid: uint,
  health-score: uint
}
```

#### Price Feeds

```clarity
{
  price: uint,
  last-update: uint,
  volatility: uint,
  confidence: uint
}
```

## 🔧 Installation & Setup

### Prerequisites

- [Clarinet](https://docs.hiro.so/clarinet) v2.0+
- [Node.js](https://nodejs.org/) v18+
- [Git](https://git-scm.com/)

### Quick Start

1. **Clone the Repository**

   ```bash
   git clone https://github.com/chris-jonas/bitlend.git
   cd bitlend
   ```

2. **Install Dependencies**

   ```bash
   npm install
   ```

3. **Run Contract Checks**

   ```bash
   clarinet check
   ```

4. **Execute Tests**

   ```bash
   npm test
   ```

5. **Deploy to Devnet**

   ```bash
   clarinet deploy --devnet
   ```

## 📋 Usage Guide

### Protocol Initialization

```clarity
;; Initialize the protocol (contract owner only)
(contract-call? .bitlend initialize-protocol)
```

### Core Operations

#### 1. Deposit Collateral

```clarity
;; Deposit Bitcoin as collateral
(contract-call? .bitlend deposit-collateral u100000000) ;; 1 BTC in satoshis
```

#### 2. Create Lending Position

```clarity
;; Create a position with collateral, loan amount, and term
(contract-call? .bitlend create-position
  u100000000  ;; 1 BTC collateral
  u50000000   ;; 0.5 BTC loan
  u12         ;; 12-month term
)
```

#### 3. Repay Loan

```clarity
;; Repay loan with accrued interest
(contract-call? .bitlend repay-loan
  u1          ;; position-id
  u55000000   ;; repayment amount including interest
)
```

### Monitoring & Analytics

#### Position Details

```clarity
;; Get comprehensive position information
(contract-call? .bitlend get-position-details u1)
```

#### User Portfolio

```clarity
;; View complete user portfolio
(contract-call? .bitlend get-user-portfolio 'SP1ABC123...)
```

#### Protocol Metrics

```clarity
;; Access protocol-wide analytics
(contract-call? .bitlend get-protocol-metrics)
```

## 🔐 Security Features

### Risk Management

- **Real-time Health Scoring**: Continuous position monitoring
- **Automated Liquidation**: Protection against under-collateralization
- **Volatility Adjustments**: Dynamic risk parameter updates
- **Position Limits**: Maximum exposure controls per user

### Access Controls

- **Owner-Only Functions**: Critical parameter updates restricted
- **Position Authorization**: Borrower-only access to position management
- **Emergency Pause**: Market protection circuit breakers

### Validation

- **Input Sanitization**: Comprehensive parameter validation
- **State Consistency**: Atomic transaction processing
- **Error Handling**: Detailed error codes and messages

## 🧪 Testing

### Test Framework

The protocol uses Vitest with Clarinet SDK for comprehensive testing:

```bash
# Run all tests
npm test

# Run tests with coverage
npm run test:report

# Watch mode for development
npm run test:watch
```

### Test Categories

- **Unit Tests**: Individual function validation
- **Integration Tests**: Multi-function workflow testing
- **Edge Cases**: Boundary condition verification
- **Security Tests**: Attack vector validation

### Example Test Structure

```typescript
describe("BitLend Protocol", () => {
  it("should initialize protocol correctly", () => {
    // Test protocol initialization
  });
  
  it("should create lending positions", () => {
    // Test position creation workflow
  });
  
  it("should handle liquidations properly", () => {
    // Test liquidation mechanics
  });
});
```

## 🎛️ Governance

### Parameter Updates

Protocol owners can adjust key parameters:

- **Collateral Ratios**: Minimum and liquidation thresholds
- **Interest Rates**: Base rates and volatility adjustments
- **Protocol Fees**: Revenue sharing and treasury allocation
- **Risk Parameters**: Health scoring and liquidation mechanics

### Emergency Controls

- **Protocol Pause**: Halt all operations during emergencies
- **Position Protection**: Enable/disable liquidation protection
- **Oracle Updates**: Price feed management and validation

## 📈 Economics

### Interest Rate Model

```clarity
interest-rate = base-rate + (volatility / 5)
```

### Collateral Requirements

- **Standard Positions**: 175% minimum collateral ratio
- **Low-Risk Positions**: 250%+ collateral ratio (enhanced benefits)
- **Liquidation Threshold**: 130% (adjustable)

### Fee Structure

- **Protocol Fee**: 2% of interest payments
- **Liquidation Penalty**: 5% of collateral value
- **Treasury Allocation**: Transparent revenue tracking

## 🚀 Roadmap

### Phase 1: Core Protocol ✅

- [x] Basic lending mechanics
- [x] Risk management systems
- [x] Oracle integration
- [x] Governance framework

### Phase 2: Advanced Features 🚧

- [ ] Cross-collateral positions
- [ ] Yield farming integration
- [ ] Advanced order types
- [ ] Mobile SDKs

### Phase 3: Institutional Features 📋

- [ ] Institutional dashboards
- [ ] API integrations
- [ ] Custom risk models
- [ ] Multi-signature governance

### Phase 4: Ecosystem Expansion 🔮

- [ ] Additional asset support
- [ ] Layer 2 integration
- [ ] Cross-chain bridges
- [ ] Institutional partnerships

## 🤝 Contributing

We welcome contributions from the community! Please see our [Contributing Guidelines](./CONTRIBUTING.md) for details.

### Development Workflow

1. Fork the repository
2. Create a feature branch
3. Write tests for new functionality
4. Ensure all tests pass
5. Submit a pull request

### Code Standards

- Follow Clarity best practices
- Maintain comprehensive test coverage
- Document all public functions
- Use descriptive variable names

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](./LICENSE) file for details.

## Stacks Ecosystem

- [Stacks Documentation](https://docs.stacks.co/)
- [Clarity Language Reference](https://docs.stacks.co/clarity)
- [Clarinet Developer Tools](https://docs.hiro.so/clarinet)
