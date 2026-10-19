
Part 1: VAT / Mushak compliance prompts

1) Generate a comprehensive VAT (Mushak) compliance checklist for a POS / Billing system in Bangladesh that supports:

1. VAT registration and basics
    Act as a Bangladesh VAT consultant. My business is [type, e.g., garment exporter / retail shop / IT service provider] with annual turnover of about BDT [amount]. Explain in simple English (with Bangla terms in brackets):
        1. Whether I need VAT registration (BIN), turnover tax, or neither
        2. Which VAT rate or rebate regime applies to me
        3. The step-by-step process to register on the NBR online VAT portal
        4. The documents I need
        Flag anything that may have changed under the latest Finance Act or SRO so I can verify it.

2) Generate a step-by-step implementation plan for integrating **Mushak 6.3 and 6.4** auto-generation into an existing POS/Billing backend. Assume: 

- Database schema: sales records exist with fields: transaction_id, date_time, customer_name, customer_bin, item_description, quantity, unit_price, total_price, vat_amount.  
- Output format: JSON with fields: mushak63_record, mushak64_invoice. 
- Integration point: a new endpoint or middleware that reads daily sales and produces these reports.  
- Error handling: what to log if data is incomplete or formatting fails.

2. Mushak forms guide

List the main Mushak forms under the VAT & SD Rules 2016 that a [business type] must maintain: purchase book, sales book, tax invoice (Mushak-6.3), challan, credit/debit notes, price declaration, and monthly return (Mushak-9.1). For each form, give: purpose, when to issue it, mandatory fields, who keeps copies, and common mistakes. Present it as a table. Mark any form numbers you are not fully sure of so I can check them.

3. Monthly return preparation

I will give you my monthly purchase and sales data. Help me prepare for the Mushak-9.1 return: calculate output VAT, eligible input tax credit (rebate), any carry-forward, and net payable. Show your calculation step by step, list the items that may be ineligible for rebate, and tell me the filing deadline and the treasury challan process. Data: [paste table]

4. Invoice design
Design a compliant VAT invoice (Mushak-6.3 format) layout for [business type]. List all mandatory fields (BIN, challan number, date/time, buyer details, HS code, quantity, value, SD, VAT, total) and give me a template I can hand to my developer.

5. Audit and notice response
I received a [VAT audit notice / show-cause / demand notice] from [VAT Commissionerate]. Summarize the likely issue, list the documents to prepare, draft a polite and formal reply in English and Bangla, and outline appeal options (Commissioner Appeals, Tribunal) with timelines. Advise me to confirm with a licensed VAT practitioner.
Part 2: VAT software implementation prompts

6. Requirements gathering (BRD)

Act as a business analyst. Write a Business Requirements Document for a VAT management module for a Bangladesh company in [industry]. Cover: BIN and item/HS code master data, purchase and sales entry, auto-generated Mushak forms (6.1, 6.2, 6.3, 6.4, 9.1), rebate calculation, SD/VAT/AIT/VDS handling, credit and debit notes, treasury challan tracking, and reports. Include user roles and an approval workflow.

7. Vendor and software selection
Create a scorecard to evaluate VAT software options for Bangladesh (NBR-compliant ERP modules, local vendors, in-house build). Criteria: Mushak form accuracy, EFD/SDC support, NBR portal integration or API, Bangla/English support, VDS handling, audit trail, support SLA, cost, and data security. Output a weighted table and a list of questions to ask vendors in demos.
8. Implementation plan
Create a 12-week implementation plan for a VAT software rollout at [company, size, current system]. Include phases (discovery, configuration, data migration, UAT, parallel run, go-live, hypercare), owners, deliverables, risks, and a RACI chart. Add a parallel-run month where VAT is filed manually and in software, with a reconciliation checklist.

9. Data migration and testing
Generate SQL scripts to migrate [specify tables or types of data] from a legacy system to a new VAT-enabled database schema. Include rules for mapping old tax codes to new VAT classifications, scripts for cleansing invalid or missing BINs, and procedures to validate data integrity before parallel-running with manual Mushak filing. Create sample test cases for edge scenarios such as credit notes, multi-rate items, and missing supplier BINs.
