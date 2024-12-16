;; Define the dividend pool
(define-data-var dividend-pool uint u0)

;; Define a map to store ownership shares
(define-map ownership-shares principal uint)

;; Define a list to keep track of all shareholders
(define-data-var shareholders (list 200 principal) (list))

;; Function to update the dividend pool
(define-public (update-dividend-pool (amount uint))
  (begin
    (var-set dividend-pool (+ (var-get dividend-pool) amount))
    (ok true)))

;; Function to calculate total shares
(define-private (calculate-total-shares)
  (fold + (map get-value (var-get shareholders)) u0))

;; Helper function to get share value from principal
(define-private (get-value (owner principal))
  (default-to u0 (map-get? ownership-shares owner)))

(define-public (set-ownership-share (owner principal) (shares uint))
  (let ((current-shares (default-to u0 (map-get? ownership-shares owner))))
    (if (is-eq current-shares shares)
      (ok false)  ;; No change needed
      (begin
        (map-set ownership-shares owner shares)
        (if (is-none (index-of (var-get shareholders) owner))
          (if (< (len (var-get shareholders)) u200)
            (match (as-max-len? (append (var-get shareholders) owner) u200)
              updated-list (begin
                (var-set shareholders updated-list)
                (ok true))
              (err u1))  ;; Error appending to list
            (err u2))  ;; List is full
          (ok true))))))
;; Function to distribute dividends
(define-public (distribute-dividends)
  (let ((current-pool (var-get dividend-pool))
        (total-shares (calculate-total-shares))
        (sender-shares (default-to u0 (map-get? ownership-shares tx-sender))))
    (if (and (> total-shares u0) (> sender-shares u0))
      (let ((dividend-amount (/ (* sender-shares current-pool) total-shares)))
        (begin
          (map-set ownership-shares tx-sender (- sender-shares dividend-amount))
          (var-set dividend-pool (- current-pool dividend-amount))
          (ok dividend-amount)))
      (err u0))))

;; Function to get the current dividend pool amount
(define-read-only (get-dividend-pool)
  (ok (var-get dividend-pool)))

;; Function to get an owner's current share
(define-read-only (get-ownership-share (owner principal))
  (ok (default-to u0 (map-get? ownership-shares owner))))

;; Function to get all shareholders
(define-read-only (get-shareholders)
  (ok (var-get shareholders)))