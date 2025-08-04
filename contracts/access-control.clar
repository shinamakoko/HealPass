;; HealPass Access Control Contract
;; Clarity v2

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Constants
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define-constant ERR-NOT-OWNER u100)
(define-constant ERR-NOT-AUTHORIZED u101)
(define-constant ERR-ALREADY-GRANTED u102)
(define-constant ERR-NOT-GRANTED u103)
(define-constant ERR-INVALID-ADDRESS u104)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Data Storage
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define-map access-permissions
  { patient: principal, provider: principal }
  { granted: bool, timestamp: uint }
)

(define-map patient-records
  principal
  (list 100 (tuple (uri (string-ascii 256)) (timestamp uint)))
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Private Helpers
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define-private (is-valid-principal (p principal))
  (not (is-eq p 'SP000000000000000000002Q6VF78))
)

(define-private (require-owner (owner principal))
  (asserts! (is-eq tx-sender owner) (err ERR-NOT-OWNER))
)

(define-private (current-timestamp)
  (unwrap-panic (block-height))
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Public Functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define-public (grant-access (provider principal))
  (begin
    (asserts! (is-valid-principal provider) (err ERR-INVALID-ADDRESS))
    (let ((key { patient: tx-sender, provider: provider }))
      (match (map-get access-permissions key)
        permission
          (asserts! (not (get granted permission)) (err ERR-ALREADY-GRANTED))
        none
          (map-set access-permissions key
            { granted: true, timestamp: (current-timestamp) })
      )
    )
    (ok true)
  )
)

(define-public (revoke-access (provider principal))
  (let ((key { patient: tx-sender, provider: provider }))
    (match (map-get access-permissions key)
      permission
        (begin
          (asserts! (get granted permission) (err ERR-NOT-GRANTED))
          (map-set access-permissions key
            { granted: false, timestamp: (current-timestamp) })
          (ok true)
        )
      none
        (err ERR-NOT-GRANTED)
    )
  )
)

(define-public (can-access (patient principal) (provider principal))
  (match (map-get access-permissions { patient: patient, provider: provider })
    entry
      (ok (get granted entry))
    none
      (ok false)
  )
)

(define-public (upload-record (uri (string-ascii 256)))
  (begin
    (asserts! (is-valid-principal tx-sender) (err ERR-INVALID-ADDRESS))
    (let ((existing (default-to (list) (map-get? patient-records tx-sender))))
      (map-set patient-records tx-sender
        (append existing (list
          { uri: uri, timestamp: (current-timestamp) })))
    )
    (ok true)
  )
)

(define-read-only (get-records (patient principal))
  (ok (default-to (list) (map-get? patient-records patient)))
)

(define-read-only (get-access-log (patient principal) (provider principal))
  (match (map-get access-permissions { patient: patient, provider: provider })
    entry (ok entry)
    none (err ERR-NOT-GRANTED)
  )
)
