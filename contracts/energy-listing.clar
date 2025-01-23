(define-trait energy-listing-trait
  (
    (get-energy-listing (uint) (response (optional {
      seller: principal,
      energy-amount: uint,
      price-per-kwh: uint,
      expiration: uint,
      active: bool
    }) uint))
    (update-listing (uint uint uint uint) (response bool uint))
  )
)

;; Energy Listing Contract

(define-data-var listing-counter uint u0)

(define-map energy-listings uint {
  seller: principal,
  energy-amount: uint,
  price-per-kwh: uint,
  expiration: uint,
  active: bool
})

(define-read-only (get-energy-listing (id uint))
  (map-get? energy-listings id)
)

(define-public (create-listing (energy-amount uint) (price-per-kwh uint) (expiration uint))
  (let
    ((new-id (+ (var-get listing-counter) u1)))
    (map-set energy-listings new-id {
      seller: tx-sender,
      energy-amount: energy-amount,
      price-per-kwh: price-per-kwh,
      expiration: expiration,
      active: true
    })
    (var-set listing-counter new-id)
    (ok new-id)
  )
)

(define-public (update-listing (listing-id uint) (energy-amount uint) (price-per-kwh uint) (expiration uint))
  (let
    ((listing (unwrap! (map-get? energy-listings listing-id) (err u404))))
    (asserts! (is-eq tx-sender (get seller listing)) (err u403))
    (ok (map-set energy-listings listing-id
      (merge listing {
        energy-amount: energy-amount,
        price-per-kwh: price-per-kwh,
        expiration: expiration
      })))
  )
)

(define-public (cancel-listing (listing-id uint))
  (let
    ((listing (unwrap! (map-get? energy-listings listing-id) (err u404))))
    (asserts! (is-eq tx-sender (get seller listing)) (err u403))
    (ok (map-set energy-listings listing-id
      (merge listing { active: false })))
  )
)

(define-read-only (get-listing (listing-id uint))
  (map-get? energy-listings listing-id)
)

(define-read-only (get-listing-count)
  (var-get listing-counter)
)

(impl-trait .energy-listing.energy-listing-trait)
