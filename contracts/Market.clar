;; Define the non-fungible token
(define-non-fungible-token property-token uint)

;; Define a map to store sell orders (only define this once)
(define-map sell-orders
  { token-id: uint }
  { seller: principal, price: uint }
)

;; Function to create a sell order
(define-public (create-sell-order (token-id uint) (price uint))
  (let
    (
      (owner (unwrap! (nft-get-owner? property-token token-id) (err u1)))
    )
    ;; Check if the sender is the owner of the token
    (asserts! (is-eq tx-sender owner) (err u2))
    ;; Add the sell order to the map
    (map-set sell-orders { token-id: token-id } { seller: tx-sender, price: price })
    (ok true)
  )
)

;; Function to buy a token from a sell order
(define-public (buy-token (token-id uint))
  (let
    (
      (order (unwrap! (map-get? sell-orders { token-id: token-id }) (err u3)))
      (seller (get seller order))
      (price (get price order))
    )
    ;; Check if the buyer has enough balance
    (asserts! (>= (stx-get-balance tx-sender) price) (err u4))
    ;; Transfer STX from buyer to seller
    (try! (stx-transfer? price tx-sender seller))
    ;; Transfer the NFT from seller to buyer
    (try! (nft-transfer? property-token token-id seller tx-sender))
    ;; Remove the sell order
    (map-delete sell-orders { token-id: token-id })
    (ok true)
  )
)

;; Function to cancel a sell order
(define-public (cancel-sell-order (token-id uint))
  (let
    (
      (order (unwrap! (map-get? sell-orders { token-id: token-id }) (err u5)))
      (seller (get seller order))
    )
    ;; Check if the sender is the seller
    (asserts! (is-eq tx-sender seller) (err u6))
    ;; Remove the sell order
    (map-delete sell-orders { token-id: token-id })
    (ok true)
  )
)