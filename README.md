# Property-Tokenization
# Property Token Smart Contract

A Clarity smart contract implementation for tokenizing real estate properties with fractional ownership capabilities. This contract enables property owners to create unique tokens representing real estate assets and distribute fractional ownership through fungible tokens.

## Features

### Non-Fungible Token (NFT)
- Unique token representation for each property
- Built-in NFT trait implementation
- Token URI support for metadata storage
- Automated token ID management

### Property Details Storage
- Comprehensive property metadata storage including:
  - Property address (UTF-8 string, max 100 chars)
  - Property size (uint)
  - Property type (UTF-8 string, max 20 chars)
  - Total value (uint)
  - Total shares (uint)
  - Location (UTF-8 string, max 50 chars)
  - Token URI (optional UTF-8 string, max 256 chars)

### Fractional Ownership
- Fungible token implementation for share distribution
- Share transfer functionality
- Share balance tracking per property and owner

## Contract Functions

### Administrative Functions

#### `mint-property`
Creates a new property token with associated metadata.

```clarity
(mint-property 
    (address (string-utf8 100))
    (size uint)
    (property-type (string-utf8 20))
    (total-value uint)
    (total-shares uint)
    (location (string-utf8 50))
    (token-uri (optional (string-utf8 256))))
```

Returns: `(response uint uint)` - New token ID or error

### NFT Trait Functions

#### `get-last-token-id`
```clarity
(get-last-token-id) => (response uint uint)
```
Returns the ID of the last minted token.

#### `get-token-uri`
```clarity
(get-token-uri (token-id uint)) => (response (optional (string-utf8 256)) uint)
```
Returns the URI for the specified token's metadata.

#### `get-owner`
```clarity
(get-owner (token-id uint)) => (response (optional principal) uint)
```
Returns the owner of the specified token.

#### `transfer`
```clarity
(transfer (token-id uint) (sender principal) (recipient principal)) => (response bool uint)
```
Transfers ownership of the specified token.

### Share Management Functions

#### `transfer-shares`
```clarity
(transfer-shares 
    (property-id uint)
    (amount uint)
    (recipient principal))
```
Transfers fractional ownership shares between accounts.

#### `get-shares`
```clarity
(get-shares (property-id uint) (owner principal))
```
Returns the number of shares owned by a specific address for a property.

### Read-Only Functions

#### `get-property-details`
```clarity
(get-property-details (property-id uint))
```
Returns all stored metadata for a specific property.

## Error Codes

- `u100`: Owner-only operation
- `u101`: Not token owner
- `u102`: Token already exists
- `u103`: Token not found
- `u404`: Token URI not found

## Usage Example

1. **Mint a new property token:**
```clarity
(contract-call? .property-token mint-property
    "123 Blockchain Street"    ;; address
    u2500                     ;; size (sq ft)
    "residential"             ;; property-type
    u500000                   ;; total-value
    u1000                     ;; total-shares
    "New York"                ;; location
    (some "ipfs://...")       ;; token-uri
)
```

2. **Transfer shares:**
```clarity
(contract-call? .property-token transfer-shares
    u1          ;; property-id
    u100        ;; amount
    'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM  ;; recipient
)
```

## Security Considerations

1. Only the contract owner can mint new property tokens
2. Share transfers require sufficient balance
3. Property transfers require ownership verification
4. All monetary values are handled in microunits to prevent rounding errors

## Development and Testing

To deploy and test this contract:

1. Install the Clarity CLI
2. Deploy the contract to the Stacks blockchain
3. Run test cases for all main functions
4. Verify property details and share distribution

## Future Enhancements

Potential improvements to consider:

1. Multi-signature support for property transfers
2. Dividend distribution mechanism
3. Property valuation updates
4. Integration with real estate legal frameworks
5. Enhanced metadata standards
6. Secondary market support

## License
