# CodeSentry 👁️‍🗨️

A decentralized smart contract monitoring and validation platform built on the Stacks blockchain using Clarity smart contracts.

## Overview

CodeSentry enables certified validators to register, conduct comprehensive assessments of Clarity smart contracts, and have their work quality-checked by authorized experts. The platform maintains a detailed database of contract validations, risk assessments, and validator credentials.

## Features

### 🔍 Contract Validation
- Submit detailed risk assessments for any Clarity smart contract
- Track risk scores and detected security issues
- Store validation proofs with cryptographic hash verification
- Maintain comprehensive validation history and timeline for each contract

### 👨‍💻 Validator Management
- Decentralized validator registration system
- Experience-based ranking and reputation tracking
- Quality check system for validation accuracy
- Active/inactive status management for validators

### ✅ Quality Assurance System
- Expert quality checkers validate assessment accuracy
- Experience point progression based on approved validations
- Self-checking prevention mechanisms
- Transparency and accountability features

### 📈 Analytics & Monitoring
- Contract-specific validation summaries
- Historical risk score tracking
- Validator performance metrics
- Platform-wide validation statistics

## Smart Contract Structure

### Data Storage
- **contract-validations**: Complete validation records with timestamps and risk scores
- **certified-validators**: Validator profiles with experience points and statistics  
- **contract-validation-records**: Per-contract validation history and quality scores
- **quality-checkers**: Authorized expert checker addresses

### Key Functions

#### Public Functions
- `register-contract-validator()` - Register as a new validator
- `submit-validation-assessment()` - Submit validation for a contract
- `quality-check-validation()` - Quality check an existing validation
- `authorize-quality-checker()` - Admin function to add quality checkers
- `modify-validation-cost()` - Admin function to update fees

#### Read-Only Functions
- `get-validation-details()` - Retrieve specific validation information
- `get-validator-profile()` - View validator statistics and reputation
- `get-contract-validation-summary()` - Contract's complete validation history
- `get-current-contract-validation()` - Most recent validation for a contract
- `get-total-validation-count()` - Platform validation statistics
- `get-current-validation-cost()` - Current fee for submitting validations

## Economic Model

- **Validation Cost**: 2 STX per validation submission (configurable by admin)
- **Revenue Distribution**: Fees go to platform maintenance and development
- **Incentive Structure**: Experience points increase through successful quality checks

## Getting Started

### Prerequisites
- Stacks wallet with STX for transaction fees and validation submissions
- Understanding of Clarity smart contract security principles

### For Validators
1. Call `register-contract-validator()` to join the platform
2. Conduct risk analysis of target contracts
3. Submit validations using `submit-validation-assessment()` with:
   - Target contract principal
   - Risk assessment score (0-100, lower is better)
   - Number of issues detected
   - IPFS hash of detailed validation proof

### For Quality Checkers
1. Must be authorized by platform admin
2. Review submitted validations for quality and accuracy
3. Cannot quality-check own validations (enforced by contract)

### For Contract Developers
1. Use read-only functions to check validation status of any contract
2. View historical risk assessments
3. Track improvement over time through multiple validations

## Security Features

- **Access Controls**: Admin-only functions for critical operations
- **Self-Check Prevention**: Validators cannot quality-check their own work
- **Economic Deterrents**: Validation costs prevent spam submissions
- **Transparency**: All validation data publicly accessible on-chain
- **Immutability**: Validation records cannot be modified after submission