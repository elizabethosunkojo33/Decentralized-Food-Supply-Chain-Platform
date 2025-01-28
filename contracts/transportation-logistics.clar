;; Transportation and Logistics Contract

(define-map transport-info
  { transport-id: uint }
  {
    product-id: uint,
    origin: (string-ascii 100),
    destination: (string-ascii 100),
    carrier: principal,
    start-date: uint,
    end-date: uint,
    status: (string-ascii 20)
  }
)

(define-data-var transport-id-nonce uint u0)

(define-constant AUTHORIZED_CARRIERS
  (list
    'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM
    'ST2CY5V39NHDPWSXMW9QDT3HC3GD6Q6XX4CFRK9AG
  )
)

(define-read-only (is-authorized-carrier (address principal))
  (is-some (index-of AUTHORIZED_CARRIERS address))
)

(define-public (create-transport
  (product-id uint)
  (origin (string-ascii 100))
  (destination (string-ascii 100))
)
  (let
    ((new-transport-id (+ (var-get transport-id-nonce) u1)))
    (asserts! (is-authorized-carrier tx-sender) (err u403))
    (map-set transport-info
      { transport-id: new-transport-id }
      {
        product-id: product-id,
        origin: origin,
        destination: destination,
        carrier: tx-sender,
        start-date: block-height,
        end-date: u0,
        status: "in-transit"
      }
    )
    (var-set transport-id-nonce new-transport-id)
    (ok new-transport-id)
  )
)

(define-public (update-transport-status (transport-id uint) (new-status (string-ascii 20)))
  (let
    ((transport (unwrap! (map-get? transport-info { transport-id: transport-id }) (err u404))))
    (asserts! (is-eq (get carrier transport) tx-sender) (err u403))
    (ok (map-set transport-info
      { transport-id: transport-id }
      (merge transport { status: new-status, end-date: (if (is-eq new-status "delivered") block-height (get end-date transport)) })
    ))
  )
)

(define-read-only (get-transport-info (transport-id uint))
  (map-get? transport-info { transport-id: transport-id })
)

