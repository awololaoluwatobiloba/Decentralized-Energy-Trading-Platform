;; Energy Trade Contract

(define-data-var trade-counter uint u0)

(define-map energy-trades uint {
  listing-id: uint,
  buyer: principal,
  energy-amount: uint,
  total-price: uint,
  status: (string-ascii 20)
})

(define-public (create-trade (listing-id uint) (energy-amount uint))
  (let
    ((listing (unwrap! (map-get? energy-listings listing-id) (err u404)))
     (total-price (* energy-amount (get price-per-kwh listing)))
     (new-id (+ (var-get trade-counter) u1)))
    (asserts! (get active listing) (err u403))
    (asserts! (<= energy-amount (get energy-amount listing)) (err u401))
    (map-set energy-trades new-id {
      listing-id: listing-id,
      buyer: tx-sender,
      energy-amount: energy-amount,
      total-price: total-price,
      status: "pending"
    })
    (var-set trade-counter new-id)
    (ok new-id)
  )
)

(define-public (confirm-trade (trade-id uint))
  (let
    ((trade (unwrap! (map-get? energy-trades trade-id) (err u404)))
     (listing (unwrap! (map-get? energy-listings (get listing-id trade)) (err u404))))
    (asserts! (is-eq tx-sender (get seller listing)) (err u403))
    (asserts! (is-eq (get status trade) "pending") (err u401))
    (try! (stx-transfer? (get total-price trade) (get buyer trade) (get seller listing)))
    (map-set energy-trades trade-id
      (merge trade { status: "completed" }))
    (map-set energy-listings (get listing-id trade)
      (merge listing {
        energy-amount: (- (get energy-amount listing) (get energy-amount trade))
      }))
    (ok true)
  )
)

(define-read-only (get-trade (trade-id uint))
  (map-get? energy-trades trade-id)
)

(define-read-only (get-trade-count)
  (var-get trade-counter)
)

