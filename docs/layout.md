?# Website Layout & Structure Documentation

**Location:** `Website/layout.md`  
**Purpose:** Defines the UI layout structure and Next.js routing architecture for the Numou ERP Marketing Website.

---

## 1. Directory & Routing Structure (Next.js App Router)

The website will follow a Route Group pattern to separate the public marketing pages from the authenticated dashboard.

```text
src/
└── app/
    ├── (marketing)/           # Public-facing website pages
    │   ├── layout.tsx         # Global Navbar & Footer shell
    │   ├── page.tsx           # Homepage (Hero, Features, Pricing)
    │   ├── pricing/page.tsx   # Detailed pricing breakdown
    │   └── agency/page.tsx    # White-label partner program details
    ├── (dashboard)/           # Authenticated ERP application
    │   ├── layout.tsx         # Sidebar & Header shell for authenticated users
    │   └── page.tsx           # Main dashboard overview
    ├── layout.tsx             # Root layout (Fonts, ThemeProvider, i18n)
    └── globals.css            # Tailwind directives
```

---

## 2. Global UI Layout (`(marketing)/layout.tsx`)

The marketing website will share a consistent shell across all pages:

### **A. Navigation Bar (Header)**
* **State:** Sticky at the top, transparent with blur effect (`backdrop-blur`).
* **Left:** Numou ERP Logo (Emerald Green).
* **Center:** Links to `Features`, `Pricing`, `Agency Partner`.
* **Right:** 
  * Language Toggle (`EN` / `عربي`)
  * `Login` (Ghost button)
  * `Get Started` (Solid Emerald CTA button)

### **B. Main Content Area**
* Dynamically renders page content (`children`).
* Supports fluid width and responsive padding for mobile/tablet/desktop.

### **C. Footer**
* **Grid Layout (4 Columns):**
  1. **Brand:** Logo + Tagline ("Empowering Smart Business Growth.")
  2. **Product:** Features, Pricing, ZATCA Sandbox.
  3. **Partners:** Agency Program, API Documentation.
  4. **Legal:** Privacy Policy, Terms of Service.
* **Bottom Bar:** Copyright © 2026 Numou Technologies Limited.

---

## 3. Homepage Layout (`(marketing)/page.tsx`)

Based on the `wireframestructure.md`, the homepage is stacked in the following vertical layout:

1. **Hero Section:** High-impact H1 heading, Sub-headline, Dual CTAs (End-user vs Agency).
2. **Trust Bar:** Logos/Badges for ZATCA, KSA Data Residency (AWS Riyadh), Vision 2030, Mada.
3. **Problem vs Solution Matrix:** A 2-column comparative table showing "Old Manual Process" vs "Numou Automated Engine".
4. **Dual-Track Features:** Feature cards for Service Businesses (ZATCA, WhatsApp) and Agencies (White-label, API).
5. **Pricing Preview:** Toggle between End-User and Agency packages.
6. **FAQ:** Security and KSA Regulation questions.
7. **Sticky Footer CTA:** Final call to action for booking a demo or contacting sales.

---

## 4. Design Tokens & Theming (Tailwind)

The layout will utilize the following custom colors integrated into `tailwind.config.js`:

* **Primary (Emerald):** `#064E3B` (Trust, Growth, Saudi Identity)
* **Secondary (Gold):** `#D4AF37` (Premium, Enterprise)
* **Backgrounds (Ink/Slate):** `#0F172A` (Dark mode backgrounds)
* **Typography:**
  * **English:** `Plus Jakarta Sans`
  * **Arabic:** `IBM Plex Sans Arabic`

