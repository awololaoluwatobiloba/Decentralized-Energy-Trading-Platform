;; Smart Meter Integration Contract

(define-constant CONTRACT_OWNER tx-sender)

(define-map authorized-meters principal bool)

(define-map energy-data uint {
  user: principal,
  meter-id: principal,
  timestamp: uint,
  energy-produced: uint,
  energy-consumed: uint
})

(define-data-var data-counter uint u0)

(define-public (authorize-meter (meter principal))
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) (err u403))
    (ok (map-set authorized-meters meter true))
  )
)

(define-public (revoke-meter (meter principal))
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) (err u403))
    (ok (map-set authorized-meters meter false))
  )
)

(define-public (log-energy-data (user principal) (energy-produced uint) (energy-consumed uint))
  (let
    ((new-id (+ (var-get data-counter) u1)))
    (asserts! (default-to false (map-get? authorized-meters tx-sender)) (err u403))
    (map-set energy-data new-id {
      user: user,
      meter-id: tx-sender,
      timestamp: block-height,
      energy-produced: energy-produced,
      energy-consumed: energy-consumed
    })
    (var-set data-counter new-id)
    (ok new-id)
  )
)

(define-read-only (get-energy-data (data-id uint))
  (map-get? energy-data data-id)
)

(define-read-only (get-data-count)
  (var-get data-counter)
)

