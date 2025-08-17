# Earth Observation Data Marketplace

A comprehensive blockchain-based platform for trading satellite imagery and environmental data, built on the Stacks blockchain using Clarity smart contracts.

## Overview

The Earth Observation Data Marketplace provides a secure, transparent platform for:

- **Data Providers**: Satellite operators, research institutions, and environmental agencies can register and monetize their earth observation data
- **Data Consumers**: Researchers, businesses, and government agencies can discover, license, and access high-quality environmental data
- **Emergency Responders**: Priority access to critical data during disasters and emergencies

## System Architecture

The marketplace consists of five interconnected smart contracts:

### 1. Data Registry Contract (`data-registry.clar`)
- **Purpose**: Central registry for all earth observation data
- **Key Features**:
    - Data registration with metadata (location, timestamp, resolution, quality)
    - Provider reputation tracking
    - Access logging and audit trails
    - Emergency priority flagging for disaster response

### 2. Licensing Management Contract (`licensing.clar`)
- **Purpose**: Manages data licensing agreements and permissions
- **Key Features**:
    - Commercial and research license types
    - Time-based and usage-based licensing
    - Automatic license validation and expiration
    - Revenue distribution to data providers

### 3. Marketplace Trading Contract (`marketplace.clar`)
- **Purpose**: Handles transactions and payments
- **Key Features**:
    - Secure STX-based payments
    - Escrow services for large transactions
    - Bulk licensing discounts
    - Transparent pricing mechanisms

### 4. Quality Assessment Contract (`quality-assessment.clar`)
- **Purpose**: Evaluates and scores data quality
- **Key Features**:
    - Automated quality metrics (resolution, timeliness, accuracy)
    - Peer review system for data validation
    - Quality-based pricing adjustments
    - Compliance verification for standards

### 5. Emergency Response Contract (`emergency-response.clar`)
- **Purpose**: Coordinates data access during emergencies
- **Key Features**:
    - Priority access protocols for emergency responders
    - Automated disaster detection triggers
    - Free access provisions for humanitarian use
    - Real-time coordination with response agencies

## Data Types Supported

- **Satellite Imagery**: Optical, radar, hyperspectral
- **Climate Data**: Temperature, precipitation, atmospheric conditions
- **Environmental Monitoring**: Air quality, water quality, deforestation
- **Disaster Response**: Flood mapping, fire detection, damage assessment
- **Agricultural Data**: Crop monitoring, soil analysis, yield prediction

## Getting Started

### Prerequisites
- Clarinet CLI installed
- Node.js 18+ for testing
- Stacks wallet for transactions

### Installation
\`\`\`bash
# Clone the repository
git clone <repository-url>
cd earth-observation-marketplace

# Install dependencies
npm install

# Check contract syntax
npm run clarinet:check

# Run tests
npm test
\`\`\`

### Contract Deployment
\`\`\`bash
# Deploy to testnet
clarinet deploy --testnet

# Deploy to mainnet (production)
clarinet deploy --mainnet
\`\`\`

## Usage Examples

### Registering Data
```clarity
;; Register satellite imagery data
(contract-call? .data-registry register-data
  "optical-satellite"
  "40.7128,-74.0060"  ;; NYC coordinates
  u10                  ;; 10m resolution
  "abc123hash..."      ;; File hash
  "https://metadata.example.com/data1"
  u5000000            ;; 5 STX per license
  false               ;; Not emergency priority
)
