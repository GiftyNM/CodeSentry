;; CodeSentry - Smart Contract Monitoring and Validation Platform
;; A decentralized monitoring and validation system for Clarity smart contracts

;; Constants
(define-constant SYSTEM_OPERATOR tx-sender)
(define-constant ERR_UNAUTHORIZED (err u300))
(define-constant ERR_NOT_FOUND (err u301))
(define-constant ERR_VALIDATOR_REGISTERED (err u302))
(define-constant ERR_INVALID_VALIDATOR (err u303))

;; Data Variables
(define-data-var validation-counter uint u0)
(define-data-var validation-cost uint u2000000) ;; 2 STX in microSTX

;; Data Maps
(define-map contract-validations
    { validation-id: uint }
    {
        validated-contract: principal,
        validation-expert: principal,
        validation-block: uint,
        risk-assessment: uint,
        issues-detected: uint,
        validation-proof-hash: (string-ascii 64),
        is-quality-checked: bool
    }
)

(define-map certified-validators
    { validator-principal: principal }
    {
        experience-points: uint,
        validation-total: uint,
        approved-validations: uint,
        validator-enabled: bool
    }
)

(define-map contract-validation-records
    { validated-contract: principal }
    {
        current-validation-id: uint,
        validation-count: uint,
        highest-quality-score: uint
    }
)

;; Authorization map for quality checkers
(define-map quality-checkers principal bool)

;; Public Functions

;; Register a new contract validator
(define-public (register-contract-validator)
    (let ((caller tx-sender))
        (asserts! (is-none (map-get? certified-validators { validator-principal: caller })) ERR_VALIDATOR_REGISTERED)
        (map-set certified-validators 
            { validator-principal: caller }
            {
                experience-points: u0,
                validation-total: u0,
                approved-validations: u0,
                validator-enabled: true
            }
        )
        (ok true)
    )
)

;; Submit a contract validation assessment
(define-public (submit-validation-assessment (validated-contract principal) (risk-assessment uint) (issues-detected uint) (validation-proof-hash (string-ascii 64)))
    (let (
        (caller tx-sender)
        (next-validation-id (+ (var-get validation-counter) u1))
        (validator-info (unwrap! (map-get? certified-validators { validator-principal: caller }) ERR_INVALID_VALIDATOR))
    )
        ;; Ensure validator is registered and enabled
        (asserts! (get validator-enabled validator-info) ERR_INVALID_VALIDATOR)
        
        ;; Pay validation cost
        (try! (stx-transfer? (var-get validation-cost) caller SYSTEM_OPERATOR))
        
        ;; Create validation record
        (map-set contract-validations
            { validation-id: next-validation-id }
            {
                validated-contract: validated-contract,
                validation-expert: caller,
                validation-block: stacks-block-height,
                risk-assessment: risk-assessment,
                issues-detected: issues-detected,
                validation-proof-hash: validation-proof-hash,
                is-quality-checked: false
            }
        )
        
        ;; Update validator statistics
        (map-set certified-validators
            { validator-principal: caller }
            (merge validator-info { validation-total: (+ (get validation-total validator-info) u1) })
        )
        
        ;; Update contract validation tracking
        (let ((record-info (default-to 
                { current-validation-id: u0, validation-count: u0, highest-quality-score: u100 }
                (map-get? contract-validation-records { validated-contract: validated-contract })
            )))
            (map-set contract-validation-records
                { validated-contract: validated-contract }
                {
                    current-validation-id: next-validation-id,
                    validation-count: (+ (get validation-count record-info) u1),
                    highest-quality-score: (if (< risk-assessment (get highest-quality-score record-info)) 
                                   risk-assessment 
                                   (get highest-quality-score record-info))
                }
            )
        )
        
        ;; Update validation counter
        (var-set validation-counter next-validation-id)
        
        (ok next-validation-id)
    )
)

;; Quality check of validation assessment (only quality checkers can approve others' work)
(define-public (quality-check-validation (validation-id uint))
    (let (
        (caller tx-sender)
        (validation-info (unwrap! (map-get? contract-validations { validation-id: validation-id }) ERR_NOT_FOUND))
        (original-validator (get validation-expert validation-info))
    )
        ;; Ensure caller is quality checker and not checking their own work
        (asserts! (default-to false (map-get? quality-checkers caller)) ERR_UNAUTHORIZED)
        (asserts! (not (is-eq caller original-validator)) ERR_UNAUTHORIZED)
        
        ;; Mark validation as quality checked
        (map-set contract-validations
            { validation-id: validation-id }
            (merge validation-info { is-quality-checked: true })
        )
        
        ;; Update original validator's experience
        (let ((validator-info (unwrap! (map-get? certified-validators { validator-principal: original-validator }) ERR_NOT_FOUND)))
            (map-set certified-validators
                { validator-principal: original-validator }
                (merge validator-info { 
                    approved-validations: (+ (get approved-validations validator-info) u1),
                    experience-points: (+ (get experience-points validator-info) u20)
                })
            )
        )
        
        (ok true)
    )
)

;; Admin function to authorize quality checkers
(define-public (authorize-quality-checker (checker principal))
    (begin
        (asserts! (is-eq tx-sender SYSTEM_OPERATOR) ERR_UNAUTHORIZED)
        (map-set quality-checkers checker true)
        (ok true)
    )
)

;; Admin function to modify validation cost
(define-public (modify-validation-cost (new-cost uint))
    (begin
        (asserts! (is-eq tx-sender SYSTEM_OPERATOR) ERR_UNAUTHORIZED)
        (var-set validation-cost new-cost)
        (ok true)
    )
)

;; Read-only Functions

;; Get validation details
(define-read-only (get-validation-details (validation-id uint))
    (map-get? contract-validations { validation-id: validation-id })
)

;; Get validator details
(define-read-only (get-validator-profile (validator-principal principal))
    (map-get? certified-validators { validator-principal: validator-principal })
)

;; Get contract validation summary
(define-read-only (get-contract-validation-summary (validated-contract principal))
    (map-get? contract-validation-records { validated-contract: validated-contract })
)

;; Get most recent validation for a contract
(define-read-only (get-current-contract-validation (validated-contract principal))
    (let ((record-info (map-get? contract-validation-records { validated-contract: validated-contract })))
        (match record-info
            summary (map-get? contract-validations { validation-id: (get current-validation-id summary) })
            none
        )
    )
)

;; Get current validation counter
(define-read-only (get-total-validation-count)
    (var-get validation-counter)
)

;; Get validation cost
(define-read-only (get-current-validation-cost)
    (var-get validation-cost)
)

;; Check if checker is authorized
(define-read-only (is-authorized-quality-checker (checker principal))
    (default-to false (map-get? quality-checkers checker))
)