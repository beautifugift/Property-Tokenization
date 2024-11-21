;; Define constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-token-owner (err u101))

;; Define the non-fungible token
(define-non-fungible-token property-token uint)

;; Data var to keep track of the last token ID
(define-data-var last-token-id uint u0)

;; Data map to keep track of token owners
(define-map token-owners uint principal)

;; Mint new property token
(define-public (mint-property-token (address (string-ascii 100)) (size uint) (value uint) (appraisal-date uint))
  (let
    (
      (token-id (+ (var-get last-token-id) u1))
    )
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (try! (nft-mint? property-token token-id tx-sender))
    (map-set token-owners token-id tx-sender)
    (var-set last-token-id token-id)
    (ok token-id)
  )
)

;; Transfer property token
(define-public (transfer-token (token-id uint) (recipient principal))
  (let
    (
      (current-owner (map-get? token-owners token-id))
    )
    (asserts! (is-some current-owner) err-not-token-owner)
    (asserts! (is-eq tx-sender (unwrap-panic current-owner)) err-not-token-owner)
    (try! (nft-transfer? property-token token-id tx-sender recipient))
    (map-set token-owners token-id recipient)
    (ok true)
  )
)

;; Get the owner of a property token
(define-read-only (get-owner (token-id uint))
  (map-get? token-owners token-id)
)