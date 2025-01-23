;; Energy Certificate NFT Contract

(define-non-fungible-token energy-certificate uint)

(define-data-var token-id-counter uint u0)

(define-map token-metadata uint {
  owner: principal,
  energy-amount: uint,
  production-date: uint,
  source: (string-ascii 50)
})

(define-public (mint-certificate (energy-amount uint) (source (string-ascii 50)))
  (let
    ((new-id (+ (var-get token-id-counter) u1)))
    (try! (nft-mint? energy-certificate new-id tx-sender))
    (map-set token-metadata new-id {
      owner: tx-sender,
      energy-amount: energy-amount,
      production-date: block-height,
      source: source
    })
    (var-set token-id-counter new-id)
    (ok new-id)
  )
)

(define-public (transfer (token-id uint) (sender principal) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender sender) (err u403))
    (try! (nft-transfer? energy-certificate token-id sender recipient))
    (ok (map-set token-metadata token-id
      (merge (unwrap! (map-get? token-metadata token-id) (err u404))
        { owner: recipient })))
  )
)

(define-read-only (get-token-metadata (token-id uint))
  (map-get? token-metadata token-id)
)

(define-read-only (get-last-token-id)
  (var-get token-id-counter)
)

