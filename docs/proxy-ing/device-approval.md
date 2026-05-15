# Device Approval

proxy.ing addresses are owned by the user, not by a single device. A Mac,
iPhone, or other client must be approved before it receives tunnel credentials.

## Username Rules

Usernames are normalized to lowercase and must match:

```text
^[a-z0-9](?:[a-z0-9-]{1,28}[a-z0-9])$
```

That means:

- 3 to 30 characters
- lowercase letters, numbers, and hyphens
- no leading or trailing hyphen

Reserved names include `www`, `api`, `admin`, `mail`, `ftp`, `proxy`, `sale`,
`releases`, `prod`, `pay`, and `checkout`. Router-level subdomains such as
`api`, `mail`, `admin`, `app`, and `releases` are also reserved.

## Passkey Ownership

The registry uses passkeys for address ownership.

| Field | Value |
| --- | --- |
| Relying party ID | `proxy.ing` |
| Relying party name | `Proxy` |
| Default expected origins | `https://proxy.ing`, `https://checkout.proxy.ing` |
| Associated domains | `applinks:proxy.ing`, `webcredentials:proxy.ing` |

The owner creates the passkey during address registration. Proxy and Proxy
Mobile can then ask the owner to prove control of the address before issuing a
recovery credential or approving another device.

## Registration Flow

1. The client asks for passkey registration options.
2. The owner creates a passkey for `username.proxy.ing`.
3. The registry verifies the passkey response and reserves the address.
4. The client starts Stripe Checkout.
5. The registry activates the address after checkout.
6. The owner issues and stores a recovery credential.
7. Approved devices can claim tunnel credentials.

The recovery credential is the fallback owner credential. Store it somewhere
safe after checkout.

## Device Challenge Flow

1. A new device creates a device challenge for the address.
2. The owner opens an approval link such as:

   ```text
   https://proxy.ing/approve-device?challenge_id=...
   ```

3. Proxy or Proxy Mobile shows the device label and verification code.
4. The owner approves the challenge using a passkey or recovery credential.
5. The new device claims the approved challenge.
6. The registry returns the tunnel credentials to that device.
7. The device starts `cloudflared` and routes proxy.ing traffic to Grand
   Central.

## Registry Routes

Proxy and Proxy Mobile use the registry under:

```text
https://api.theproxycompany.com/v1/proxy-ing
```

| Route | Purpose |
| --- | --- |
| `GET /health` | Registry health check |
| `GET /addresses/:username` | Address status |
| `POST /reservations` | Legacy reservation path; passkey registration is required |
| `POST /passkeys/registration/options` | Start passkey registration for an address |
| `POST /passkeys/registration/verify` | Finish passkey registration |
| `POST /passkeys/assertion/options` | Start passkey owner verification |
| `POST /stripe/checkout` | Create a Stripe Checkout session for a reserved address |
| `GET /stripe/redirect` | Return from Stripe and open Proxy |
| `POST /addresses/:username/activate` | Activate an address from the trusted payment path |
| `POST /devices/challenge` | Ask the owner to approve a device |
| `GET /devices/challenges/:id` | Check device challenge status |
| `POST /devices/approve` | Owner approval for a device challenge |
| `POST /devices/claim` | Approved device claims tunnel credentials |
| `POST /devices/authorize` | Owner-authenticated device authorization |
| `POST /recovery/issue` | Issue the fallback recovery credential |

The public router also calls
`https://api.theproxycompany.com/v1/usernames/validate?username=...` before it
serves the shared web client for a `username.proxy.ing` address.

## Related

- [Getting started](getting-started.md)
- [Routes](routes.md)
- [Client API](client-api.md)
