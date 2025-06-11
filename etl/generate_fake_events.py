from faker import Faker
import random
import uuid
from datetime import datetime, timedelta

fake = Faker()
start_date = datetime.now() - timedelta(days=60)

events = []

for day_offset in range(60):
    current_day = start_date + timedelta(days=day_offset)
    for _ in range(random.randint(200, 500)):
        event_time = fake.date_time_between_dates(
            datetime_start=current_day,
            datetime_end=current_day + timedelta(hours=23, minutes=59)
        )
        user_id = f"user_{random.randint(1, 100)}"
        provider_id = f"provider_{random.randint(1, 5)}"
        amount = round(random.uniform(5.0, 500.0), 2)
        currency = random.choice(["USD", "EUR", "GBP"])

        auth_event = {
            "event_id": str(uuid.uuid4()),
            "event_type": "authorization",
            "timestamp": event_time.isoformat(),
            "user_id": user_id,
            "provider_id": provider_id,
            "amount": amount,
            "currency": currency
        }
        events.append(auth_event)

        if random.random() > 0.05:  # 95% авторизаций завершаются успешно
            settlement_time = event_time + timedelta(minutes=random.randint(1, 90))
            settle_event = auth_event.copy()
            settle_event["event_id"] = str(uuid.uuid4())
            settle_event["event_type"] = "settlement"
            settle_event["timestamp"] = settlement_time.isoformat()
            events.append(settle_event)

import json
with open("generated_events.json", "w") as f:
    json.dump(events, f, indent=2, default=str)
