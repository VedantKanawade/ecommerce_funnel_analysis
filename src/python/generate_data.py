from faker import Faker
import pandas as pd
import random

fake = Faker()

# ---- Generate Users ----
num_users = 7500  # 1000 users
users = []

for i in range(1, num_users + 1):
    users.append({
        "user_id": i,
        "name": fake.name(),
        "email": fake.email(),
        "created_at": fake.date_between(start_date='-1y', end_date='today')
    })

users_df = pd.DataFrame(users)
users_df.to_csv("users.csv", index=False)

print("Users data generated!")

# ---- Generate Sessions ----
sessions = []
session_id = 1

for user in users:
    num_sessions = random.randint(5, 20)  # Each user has 5-20 sessions
    for _ in range(num_sessions):
        start = fake.date_time_between(start_date=user['created_at'], end_date='now')
        end = start + pd.Timedelta(minutes=random.randint(5, 60))
        sessions.append({
            "session_id": session_id,
            "user_id": user['user_id'],
            "session_start": start,
            "session_end": end
        })
        session_id += 1

sessions_df = pd.DataFrame(sessions)
sessions_df.to_csv("sessions.csv", index=False)

print("Sessions data generated!")

# ---- Generate Events ----
events = []
event_id = 1
event_types = ["view", "add_to_cart", "checkout"]

# Read sessions if not already in memory
sessions_df = pd.read_csv("sessions.csv")
# Convert session_start and session_end to datetime
sessions_df['session_start'] = pd.to_datetime(sessions_df['session_start'])
sessions_df['session_end'] = pd.to_datetime(sessions_df['session_end'])
sessions = sessions_df.to_dict(orient='records')

for session in sessions:
    num_events = random.randint(1, 10)  # Each session has 1-10 events
    for _ in range(num_events):
        events.append({
            "event_id": event_id,
            "session_id": session['session_id'],
            "event_type": random.choices(
                event_types, weights=[0.6, 0.3, 0.1], k=1
            )[0],  # Most events are views, fewer add-to-cart/checkouts
            "product_id": random.randint(100, 200),  # Example product IDs
            "event_time": fake.date_time_between(
                start_date=session['session_start'], 
                end_date=session['session_end']
            )
        })
        event_id += 1

events_df = pd.DataFrame(events)
events_df.to_csv("events.csv", index=False)

print("Events data generated!")

# ---- Generate Orders ----
orders = []
order_id = 1

for user in users:
    num_orders = random.randint(0, 10)  # Some users don't order, some order multiple times
    for _ in range(num_orders):
        order_date = fake.date_between(start_date=user['created_at'], end_date='today')
        orders.append({
            "order_id": order_id,
            "user_id": user['user_id'],
            "order_amount": round(random.uniform(20.0, 500.0), 2),  # realistic order amounts
            "order_date": order_date
        })
        order_id += 1

orders_df = pd.DataFrame(orders)
orders_df.to_csv("orders.csv", index=False)

print("Orders data generated!")
# ---- Generate Payments ----
payments = []
payment_id = 1
payment_methods = ["Credit Card", "PayPal", "Debit Card", "Gift Card"]

# Read orders if not already in memory
orders_df = pd.read_csv("orders.csv")
orders_df['order_date'] = pd.to_datetime(orders_df['order_date'])
orders = orders_df.to_dict(orient='records')

for order in orders:
    payments.append({
        "payment_id": payment_id,
        "order_id": order['order_id'],
        "payment_amount": order['order_amount'],  # full payment
        "payment_date": order['order_date'],
        "payment_method": random.choice(payment_methods)
    })
    payment_id += 1

payments_df = pd.DataFrame(payments)
payments_df.to_csv("payments.csv", index=False)

print("Payments data generated!")
