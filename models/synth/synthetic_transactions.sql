{{ config(materialized='table') }}

WITH
  {{ synth_column_primary_key(name="event_id") }}
  {{ synth_column_values(
      name="event_type",
      values=["authorization", "settlement"],
      probabilities=[0.7, 0.3]
  ) }}
  {{ synth_column_date(
      name="event_time",
      min="2024-03-01",
      max="2024-06-01"
  ) }}
  {{ synth_column_integer(name="user_id_int", min=1, max=1000) }}
  {{ synth_column_integer(name="provider_id_int", min=1, max=50) }}
  {{ synth_column_distribution(
      name="amount",
      distribution=synth_distribution_continuous_uniform(min=5, max=500)
  ) }}
  {{ synth_column_value(name="currency", value="USD") }}

  {{ synth_column_expression(
      name="user_id",
      expression="('user_' || user_id_int)::text"
  ) }}
  {{ synth_column_expression(
      name="provider_id",
      expression="('provider_' || provider_id_int)::text"
  ) }}

  {{ synth_table(rows=10000) }}

SELECT
  event_id,
  event_type,
  event_time AS timestamp,
  user_id,
  provider_id,
  amount,
  currency
FROM synth_table
