import random
import pandas as pd
from datetime import datetime, timedelta
import numpy as np

# Note: These are just example functions to generate data. Cheers to be expanded as needed.
def generate_region_enrichment():
    data = [
        ("E12000001", "North East", 31.32, 24068, 989),
        ("E12000002", "North West", 16.8, 37564, 841),
        ("E12000003", "Yorkshire and the Humber", 20.27, 32886, 1032),
        ("E12000004", "East Midlands", 39.19, 34939, 1446),
        ("E12000005", "West Midlands", 10.89, 25980, 1111),
        ("E12000006", "East of England", 31.03, 23515, 1271),
        ("E12000007", "London", 19.98, 37966, 805),
        ("E12000008", "South East", 31.11, 29161, 951),
        ("E12000009", "South West", 37.39, 26001, 756),
        ("W92000004", "Wales", 10.79, 33543, 1659),
        ("S92000003", "Scotland", 7.44, 34914, 751),
        ("N92000002", "Northern Ireland", 23.43, 34904, 1187),
    ]

    df = pd.DataFrame(
        data,
        columns=[
            "RegionCode",
            "RegionName",
            "ONS_DeprivationIndex",
            "MedianIncome",
            "MedianRent",
        ],
    )
    df.to_csv("region_enrichment.csv", index=False)


def generate_customers(n=300):
    personas = ["student", "grad", "family", "contractor"]
    regions = [
        "E12000007",
        "E12000001",
        "E12000002",
        "E12000003",
        "S92000003",
        "N92000002",
        "E12000008",
        "W92000004",
        "E12000009",
        "E12000004",
        "E12000006",
        "E12000005",
    ]
    cities = [
        "London",
        "Newcastle",
        "Manchester",
        "Leeds",
        "Edinburgh",
        "Belfast",
        "Reading",
        "Cardiff",
        "Brighton",
        "Bristol",
        "Nottingham",
        "Cambridge",
        "Birmingham",
    ]

    records = []
    for i in range(1, n + 1):
        age = random.randint(18, 70)
        income = random.randint(800, 7000)

        persona = random.choice(personas)
        risk = random.choice(["Low", "Medium", "High"])

        records.append(
            [
                i,
                f"Customer {i}",
                age,
                (
                    "18–24"
                    if age < 25
                    else "25–34" if age < 35 else "35–49" if age < 50 else "50+"
                ),
                income,
                "£0–1.5k" if income < 1500 else "£1.5–2.5k" if income < 2500 else "£2.5–4k" if income < 4000 else "£4–8k",
                random.choice(cities),
                random.choice(regions),
                persona,
                risk,
            ]
        )

    df = pd.DataFrame(
        records,
        columns=[
            "CustomerID",
            "FullName",
            "Age",
            "AgeBand",
            "IncomeMonthly",
            "IncomeBand",
            "City",
            "RegionCode",
            "Persona",
            "RiskSegment",
        ],
    )

    df.to_csv("customers.csv", index=False)


def generate_accounts(customers_df):
    records = []
    account_id = 1

    for _, row in customers_df.iterrows():
        records.append([
            account_id,
            row["CustomerID"],
            random.choice(["Current", "Savings"]),
            datetime.now().date() - timedelta(days=random.randint(30, 900)),
            1 if row["Persona"] == "student" else 0,
            random.choice([0, 1])
        ])
        account_id += 1

    df = pd.DataFrame(records, columns=[
        "AccountID", "CustomerID", "ProductType",
        "OpenDate", "IsStudent", "IsJoint"
    ])

    df.to_csv("accounts.csv", index=False)


def generate_transactions(month, year, accounts_df):
    records = []
    txn_id = 1

    for _, acc in accounts_df.iterrows():
        balance = random.randint(500, 3000)

        for _ in range(random.randint(10, 40)):
            amount = random.randint(-300, -5)

            if random.random() < 0.15:
                amount = random.randint(1000, 4000)  # salary

            balance += amount

            records.append([
                txn_id,
                acc["AccountID"],
                acc["CustomerID"],
                amount,
                "GBP",
                random.choice(["Tesco", "Amazon", "Acme Lettings", "Spotify"]),
                random.choice([5411, 5812, 6513, 4899]),
                random.choice(["Groceries", "Entertainment", "Housing", "Subscriptions"]),
                random.choice(["Online", "InStore"]),
                random.choice(["London", "Manchester"]),
                random.choice(["E12000007", "E12000002"]),
                1 if amount > 0 and random.random() < 0.05 else 0,
                datetime(year, month, random.randint(1, 28)),
                balance
            ])

            txn_id += 1

    df = pd.DataFrame(records, columns=[
        "TransactionID", "AccountID", "CustomerID", "Amount",
        "Currency", "MerchantName", "MCC", "Category",
        "Channel", "City", "RegionCode",
        "IsRefund", "TransactionDate", "BalanceAfter"
    ])

    filename = f"transactions_{year}{month:02d}.csv"
    df.to_csv(filename, index=False)

if __name__ == "__main__":
    generate_region_enrichment()
    generate_customers()

    customers = pd.read_csv("customers.csv")
    generate_accounts(customers)

    accounts = pd.read_csv("accounts.csv")

    for m in range(1, 7):
        generate_transactions(m, 2025, accounts)

