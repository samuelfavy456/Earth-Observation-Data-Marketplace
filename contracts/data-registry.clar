;; Earth Observation Data Registry Contract
;; Manages satellite imagery and environmental data registration

;; Constants
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-DATA-NOT-FOUND (err u101))
(define-constant ERR-INVALID-INPUT (err u102))
(define-constant ERR-DATA-ALREADY-EXISTS (err u103))
(define-constant ERR-INSUFFICIENT-PAYMENT (err u104))

;; Data Variables
(define-data-var next-data-id uint u1)
(define-data-var registry-fee uint u1000000) ;; 1 STX in microSTX

;; Data Maps
(define-map data-entries
  { data-id: uint }
  {
    provider: principal,
    data-type: (string-ascii 50),
    location: (string-ascii 100),
    timestamp: uint,
    resolution: uint,
    file-hash: (string-ascii 64),
    metadata-uri: (string-ascii 200),
    price-per-license: uint,
    quality-score: uint,
    is-active: bool,
    emergency-priority: bool
  }
)

(define-map provider-data
  { provider: principal }
  { data-count: uint, total-revenue: uint, reputation-score: uint }
)

(define-map data-access-log
  { data-id: uint, accessor: principal }
  { access-timestamp: uint, access-type: (string-ascii 20) }
)

;; Read-only functions
(define-read-only (get-data-entry (data-id uint))
  (map-get? data-entries { data-id: data-id })
)

(define-read-only (get-provider-stats (provider principal))
  (map-get? provider-data { provider: provider })
)

(define-read-only (get-next-data-id)
  (var-get next-data-id)
)

(define-read-only (get-registry-fee)
  (var-get registry-fee)
)

(define-read-only (get-data-by-location (location (string-ascii 100)))
  (ok "Location-based search not implemented in this version")
)

;; Public functions
(define-public (register-data
  (data-type (string-ascii 50))
  (location (string-ascii 100))
  (resolution uint)
  (file-hash (string-ascii 64))
  (metadata-uri (string-ascii 200))
  (price-per-license uint)
  (emergency-priority bool))
  (let
    (
      (data-id (var-get next-data-id))
      (current-provider-stats (default-to
        { data-count: u0, total-revenue: u0, reputation-score: u50 }
        (map-get? provider-data { provider: tx-sender })
      ))
    )
    ;; Validate inputs
    (asserts! (> (len data-type) u0) ERR-INVALID-INPUT)
    (asserts! (> (len location) u0) ERR-INVALID-INPUT)
    (asserts! (> resolution u0) ERR-INVALID-INPUT)
    (asserts! (> (len file-hash) u0) ERR-INVALID-INPUT)
    (asserts! (> price-per-license u0) ERR-INVALID-INPUT)

    ;; Check payment for registration fee
    (try! (stx-transfer? (var-get registry-fee) tx-sender CONTRACT-OWNER))

    ;; Register the data entry
    (map-set data-entries
      { data-id: data-id }
      {
        provider: tx-sender,
        data-type: data-type,
        location: location,
        timestamp: block-height,
        resolution: resolution,
        file-hash: file-hash,
        metadata-uri: metadata-uri,
        price-per-license: price-per-license,
        quality-score: u0, ;; Will be set by quality assessment
        is-active: true,
        emergency-priority: emergency-priority
      }
    )

    ;; Update provider statistics
    (map-set provider-data
      { provider: tx-sender }
      {
        data-count: (+ (get data-count current-provider-stats) u1),
        total-revenue: (get total-revenue current-provider-stats),
        reputation-score: (get reputation-score current-provider-stats)
      }
    )

    ;; Increment next data ID
    (var-set next-data-id (+ data-id u1))

    (ok data-id)
  )
)

(define-public (update-data-status (data-id uint) (is-active bool))
  (let
    (
      (data-entry (unwrap! (map-get? data-entries { data-id: data-id }) ERR-DATA-NOT-FOUND))
    )
    ;; Only data provider can update status
    (asserts! (is-eq tx-sender (get provider data-entry)) ERR-NOT-AUTHORIZED)

    ;; Update the data entry
    (map-set data-entries
      { data-id: data-id }
      (merge data-entry { is-active: is-active })
    )

    (ok true)
  )
)

(define-public (log-data-access (data-id uint) (access-type (string-ascii 20)))
  (let
    (
      (data-entry (unwrap! (map-get? data-entries { data-id: data-id }) ERR-DATA-NOT-FOUND))
    )
    ;; Ensure data is active
    (asserts! (get is-active data-entry) ERR-DATA-NOT-FOUND)

    ;; Log the access
    (map-set data-access-log
      { data-id: data-id, accessor: tx-sender }
      { access-timestamp: block-height, access-type: access-type }
    )

    (ok true)
  )
)

;; Admin functions
(define-public (set-registry-fee (new-fee uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (var-set registry-fee new-fee)
    (ok true)
  )
)

(define-public (update-quality-score (data-id uint) (quality-score uint))
  (let
    (
      (data-entry (unwrap! (map-get? data-entries { data-id: data-id }) ERR-DATA-NOT-FOUND))
    )
    ;; Only contract owner can update quality scores (will be called by quality assessment contract)
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (asserts! (<= quality-score u100) ERR-INVALID-INPUT)

    ;; Update the data entry
    (map-set data-entries
      { data-id: data-id }
      (merge data-entry { quality-score: quality-score })
    )

    (ok true)
  )
)
