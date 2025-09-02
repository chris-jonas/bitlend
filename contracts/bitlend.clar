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

;; FINANCIAL CALCULATIONS

;; Calculate collateral ratio with volatility adjustment
(define-private (calc-collateral-ratio
    (collateral uint)
    (loan uint)
    (price uint)
    (volatility uint)
  )
  (let (
      (adjusted-value (* (* collateral price) (- u100 volatility)))
      (ratio (/ (* adjusted-value u100) loan))
    )
    (/ ratio u100)
  )
)

;; Calculate compound interest
(define-private (calc-compound-interest
    (principal uint)
    (rate uint)
    (blocks uint)
  )
  (let (
      (daily-rate (/ rate u365))
      (periods (/ blocks BLOCKS_PER_DAY))
      (compound-factor (+ u100 daily-rate))
      (final-amount (* principal (pow compound-factor periods)))
    )
    (- final-amount principal)
  )
)

;; Risk assessment algorithm
(define-private (assess-risk
    (ratio uint)
    (age uint)
    (volatility uint)
  )
  (let (
      (ratio-score (if (>= ratio u200)
        u30
        u10
      ))
      (age-score (if (>= age u4320)
        u20
        u5
      ))
      (volatility-penalty (if (>= volatility u20)
        u5
        u0
      ))
      (total (- (+ ratio-score age-score) volatility-penalty))
    )
    (if (> total u50)
      u50
      total
    )
  )
)

;; Liquidation evaluation
(define-private (check-liquidation (position-id uint))
  (match (map-get? lending-positions { position-id: position-id })
    position-data (let (
        (btc-price (unwrap! (get price (map-get? price-feeds { asset: "BTC" }))
          ERR_ORACLE_FAILURE
        ))
        (volatility (unwrap! (get volatility (map-get? price-feeds { asset: "BTC" }))
          ERR_ORACLE_FAILURE
        ))
        (current-ratio (calc-collateral-ratio (get collateral-amount position-data)
          (get loan-amount position-data) btc-price volatility
        ))
      )
      (if (and
          (<= current-ratio (var-get liquidation-ratio))
          (is-eq (get status position-data) "active")
          (not (get protection-enabled position-data))
        )
        (execute-liquidation position-id)
        (ok "healthy")
      )
    )
    ERR_POSITION_NOT_FOUND
  )
)

;; Execute liquidation
(define-private (execute-liquidation (position-id uint))
  (match (map-get? lending-positions { position-id: position-id })
    position-data (let (
        (borrower (get borrower position-data))
        (collateral (get collateral-amount position-data))
        (penalty (* collateral LIQUIDATION_PENALTY))
        (remaining (- collateral penalty))
      )
      (begin
        (map-set lending-positions { position-id: position-id }
          (merge position-data { status: "liquidated" })
        )
        (var-set protocol-revenue (+ (var-get protocol-revenue) penalty))
        (ok "liquidated")
      )
    )
    ERR_POSITION_NOT_FOUND
  )
)

;; VALIDATION FUNCTIONS
(define-private (valid-position-id (id uint))
  (and (> id u0) (<= id (var-get total-positions)))
)

(define-private (valid-asset (asset (string-ascii 4)))
  (is-some (index-of SUPPORTED_ASSETS asset))
)

(define-private (valid-price (price uint))
  (and (> price u0) (<= price u5000000000000))
)

;; PROTOCOL MANAGEMENT

;; Initialize protocol
(define-public (initialize-protocol)
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
    (asserts! (not (var-get protocol-active)) ERR_ALREADY_ACTIVE)

    ;; Set initial price feeds
    (map-set price-feeds { asset: "BTC" } {
      price: u4500000000,
      last-update: stacks-block-height,
      volatility: u15,
      confidence: u95,
    })

    (map-set price-feeds { asset: "STX" } {
      price: u200000,
      last-update: stacks-block-height,
      volatility: u25,
      confidence: u90,
    })

    (var-set protocol-active true)
    (ok "initialized")
  )
)

;; Emergency controls
(define-public (toggle-emergency-pause)
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
    (var-set emergency-pause (not (var-get emergency-pause)))
    (ok (var-get emergency-pause))
  )
)

;; CORE LENDING OPERATIONS

;; Deposit Bitcoin collateral
(define-public (deposit-collateral (amount uint))
  (begin
    (asserts! (var-get protocol-active) ERR_NOT_INITIALIZED)
    (asserts! (not (var-get emergency-pause)) ERR_MARKET_PROTECTION)
    (asserts! (> amount u0) ERR_INVALID_AMOUNT)

    (var-set total-btc-reserves (+ (var-get total-btc-reserves) amount))

    (match (map-get? user-accounts { user: tx-sender })
      existing (map-set user-accounts { user: tx-sender }
        (merge existing { total-collateral: (+ (get total-collateral existing) amount) })
      )
      (map-set user-accounts { user: tx-sender } {
        position-ids: (list),
        total-collateral: amount,
        total-interest-paid: u0,
        health-score: u100,
      })
    )

    (ok amount)
  )
)

;; Create lending position
(define-public (create-position
    (collateral uint)
    (loan-amount uint)
    (term-months uint)
  )
  (let (
      (btc-price (unwrap! (get price (map-get? price-feeds { asset: "BTC" }))
        ERR_ORACLE_FAILURE
      ))
      (volatility (unwrap! (get volatility (map-get? price-feeds { asset: "BTC" }))
        ERR_ORACLE_FAILURE
      ))
      (collateral-value (* collateral btc-price))
      (min-collateral (* loan-amount (var-get min-collateral-ratio)))
      (new-id (+ (var-get total-positions) u1))
      (interest-rate (+ u4 (/ volatility u5)))
    )
    (begin
      (asserts! (var-get protocol-active) ERR_NOT_INITIALIZED)
      (asserts! (>= collateral-value min-collateral) ERR_INSUFFICIENT_COLLATERAL)
      (asserts! (<= term-months u36) ERR_INVALID_AMOUNT)