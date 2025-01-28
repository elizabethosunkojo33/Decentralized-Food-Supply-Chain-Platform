;; Product Registration and Origin Contract

(define-non-fungible-token product uint)

(define-map product-info
  { product-id: uint }
  {
    name: (string-ascii 100),
    origin: (string-ascii 100),
    producer: principal,
    production-date: uint,
    batch-number: (string-ascii 50)
  }
)

(define-data-var product-id-nonce uint u0)

(define-constant AUTHORIZED_REGISTRARS
  (list
    'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM
    'ST2CY5V39NHDPWSXMW9QDT3HC3GD6Q6XX4CFRK9AG
  )
)

(define-read-only (is-authorized-registrar (address principal))
  (is-some (index-of AUTHORIZED_REGISTRARS address))
)

(define-public (register-product
  (name (string-ascii 100))
  (origin (string-ascii 100))
  (producer principal)
  (batch-number (string-ascii 50))
)
  (let
    ((new-product-id (+ (var-get product-id-nonce) u1)))
    (asserts! (is-authorized-registrar tx-sender) (err u403))
    (try! (nft-mint? product new-product-id producer))
    (map-set product-info
      { product-id: new-product-id }
      {
        name: name,
        origin: origin,
        producer: producer,
        production-date: block-height,
        batch-number: batch-number
      }
    )
    (var-set product-id-nonce new-product-id)
    (ok new-product-id)
  )
)

(define-read-only (get-product-info (product-id uint))
  (map-get? product-info { product-id: product-id })
)

(define-public (transfer-product (product-id uint) (recipient principal))
  (nft-transfer? product product-id tx-sender recipient)
)

