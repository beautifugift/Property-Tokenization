;; Property Token Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-token-owner (err u101))
(define-constant err-token-not-found (err u102))

;; Define the non-fungible token
(define-non-fungible-token property-token uint)

;; Data Variables
(define-data-var last-token-id uint u0)

;; Data Maps
(define-map property-metadata uint 
  {
    address: (string-ascii 100),
    size: uint,
    value: uint,
    last-appraisal-date: uint
  }
)

;; SIP-009: Get the last token ID
(define-read-only (get-last-token-id)
  (ok (var-get last-token-id)))

;; SIP-009: Get the token URI
(define-read-only (get-token-uri (token-id uint))
  (ok none))

;; SIP-009: Get the owner of a token
(define-read-only (get-owner (token-id uint))
  (ok (nft-get-owner? property-token token-id)))

;; SIP-009: Transfer token
(define-public (transfer (token-id uint) (sender principal) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender sender) err-not-token-owner)
    (try! (nft-transfer? property-token token-id sender recipient))
    (ok true)
  )
)

;; Mint new property token
(define-public (mint-property-token (address (string-ascii 100)) (size uint) (value uint) (appraisal-date uint))
  (let
    (
      (token-id (+ (var-get last-token-id) u1))
    )
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (try! (nft-mint? property-token token-id tx-sender))
    (map-set property-metadata token-id
      {
        address: address,
        size: size,
        value: value,
        last-appraisal-date: appraisal-date
      }
    )
    (var-set last-token-id token-id)
    (ok token-id)
  )
)

;; Get property metadata
(define-read-only (get-property-metadata (token-id uint))
  (map-get? property-metadata token-id)
)

;; Update property metadata
(define-public (update-property-metadata (token-id uint) (new-value uint) (new-appraisal-date uint))
  (let
    (
      (owner (unwrap! (nft-get-owner? property-token token-id) err-token-not-found))
      (current-metadata (unwrap! (map-get? property-metadata token-id) err-token-not-found))
    )
    (asserts! (is-eq tx-sender owner) err-not-token-owner)
    (map-set property-metadata token-id
      (merge current-metadata
        {
          value: new-value,
          last-appraisal-date: new-appraisal-date
        }
      )
    )
    (ok true)
  )
)