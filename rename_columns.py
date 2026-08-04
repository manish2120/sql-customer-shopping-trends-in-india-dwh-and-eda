import pandas as pd

# Read the CSV file
df = pd.read_csv('./datasets/customer_shopping_behavior.csv')

# Convert the column names to lowercase and replace spaces with underscore
df.columns = df.columns.str.lower().str.replace(' ', '_')

# Rename the columns to standardized names
df.rename(columns = {'online/offline': 'online_offline' ,'purchase_amount_(₹)': 'purchase_amount_inr', 'discount_(%)': 'discount_percent', 'festival/sale': 'festival_sale', 'shipping_charge_(₹)': 'shipping_charge_inr', 'delivery_time_(days)': 'delivery_time_in_days'}, inplace = True)

# Save the DataFrame to a new CSV file
df.to_csv('./datasets/customer_shopping_behavior_renamed_columns.csv', index = False)