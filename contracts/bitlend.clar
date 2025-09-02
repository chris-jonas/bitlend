;; BitLend - Institutional Bitcoin Lending Protocol
;;
;; Summary:
;; Advanced Bitcoin collateralized lending platform designed for institutional 
;; investors and sophisticated traders seeking maximum capital efficiency.
;;
;; Description:
;; BitLend transforms idle Bitcoin holdings into productive assets through
;; a sophisticated lending protocol built on Stacks. The platform offers 
;; dynamic interest rates, automated risk management, and enterprise-grade 
;; security features. Institutions can deposit Bitcoin as collateral to access
;; liquidity while maintaining long-term exposure to Bitcoin's price appreciation.
;;

;; SYSTEM CONSTANTS & GOVERNANCE
(define-constant CONTRACT_OWNER tx-sender)
(define-constant PROTOCOL_VERSION u310)

;; ERROR DEFINITIONS
(define-constant ERR_UNAUTHORIZED (err u1000))
(define-constant ERR_INSUFFICIENT_COLLATERAL (err u1001))
(define-constant ERR_BELOW_THRESHOLD (err u1002))
(define-constant ERR_INVALID_AMOUNT (err u1003))
(define-constant ERR_ALREADY_ACTIVE (err u1004))
(define-constant ERR_NOT_INITIALIZED (err u1005))
(define-constant ERR_LIQUIDATION_INVALID (err u1006))
(define-constant ERR_POSITION_NOT_FOUND (err u1007))
(define-constant ERR_POSITION_INACTIVE (err u1008))
(define-constant ERR_INVALID_ID (err u1009))
(define-constant ERR_ORACLE_FAILURE (err u1010))
(define-constant ERR_UNSUPPORTED_ASSET (err u1011))
(define-constant ERR_MARKET_PROTECTION (err u1012))

;; PROTOCOL CONFIGURATION
(define-constant SUPPORTED_ASSETS (list "BTC" "STX" "USDC"))
(define-constant MAX_USER_POSITIONS u25)
(define-constant BLOCKS_PER_DAY u144)
(define-constant LIQUIDATION_PENALTY u5) ;; 5%
(define-constant TREASURY_FEE u2) ;; 2%

;; PROTOCOL STATE
(define-data-var protocol-active bool false)
(define-data-var min-collateral-ratio uint u175) ;; 175%
(define-data-var liquidation-ratio uint u130) ;; 130%
(define-data-var protocol-fee uint u2) ;; 2%
(define-data-var total-btc-reserves uint u0)
(define-data-var total-positions uint u0)
(define-data-var protocol-revenue uint u0)
(define-data-var emergency-pause bool false)

;; DATA STRUCTURES

;; Lending position tracking
(define-map lending-positions
  { position-id: uint }
  {
    borrower: principal,
    collateral-amount: uint,
    loan-amount: uint,
    interest-rate: uint,
    created-block: uint,
    last-update: uint,
    status: (string-ascii 20),
    risk-level: (string-ascii 10),
    protection-enabled: bool,
  }
)

;; User account management
(define-map user-accounts
  { user: principal }
  {
    position-ids: (list 25 uint),
    total-collateral: uint,
    total-interest-paid: uint,
    health-score: uint,
  }
)

;; Price oracle data
(define-map price-feeds
  { asset: (string-ascii 4) }
  {
    price: uint,
    last-update: uint,
    volatility: uint,
    confidence: uint,
  }
)