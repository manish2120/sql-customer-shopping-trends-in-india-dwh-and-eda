import os
import pandas as pd

# Calculate absolute paths relative to script location
script_dir = os.path.dirname(os.path.abspath(__file__))
project_root = os.path.abspath(os.path.join(script_dir, '..', '..'))

input_csv = os.path.join(project_root, 'datasets', 'customer_shopping_behavior.csv')
output_csv = os.path.join(project_root, 'datasets', 'customer_shopping_behavior_renamed_columns.csv')

# Read the CSV file
df = pd.read_csv(input_csv)

# Convert the column names to lowercase and replace spaces with underscore
df.columns = df.columns.str.lower().str.replace(' ', '_')

# Rename the columns to standardized names
df.rename(columns = {
    'online/offline': 'online_offline',
    'purchase_amount_(₹)': 'purchase_amount_inr', 
    'discount_(%)': 'discount_percent', 
    'festival/sale': 'festival_sale', 
    'shipping_charge_(₹)': 'shipping_charge_inr', 
    'delivery_time_(days)': 'delivery_time_in_days'
}, inplace = True)

# Save the DataFrame to a new CSV file
df.to_csv(output_csv, index = False)
print(f"[+] Column renaming complete. Saved to: {output_csv}")