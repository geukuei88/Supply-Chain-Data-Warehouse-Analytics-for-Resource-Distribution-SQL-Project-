import pandas as pd

# Load the file
df = pd.read_csv('D:/Datasets/superstore.csv', encoding='cp1252')
print("File loaded successfully")

# Create a dictionary to handle potential column name variations
column_mapping = {
    'Ship Mode': 'Ship Mode', 
}

# Define your column lists with exact names
customer_cols = ['Customer ID', 'Customer Name', 'Segment', 'Country', 
                 'City', 'State', 'Postal Code', 'Region']

product_cols = ['Product ID', 'Category', 'Sub-Category', 'Product Name']

order_cols = ['Order ID', 'Order Date', 'Ship Date', 'Ship Mode', 
              'Customer ID', 'Product ID', 'Sales', 'Quantity', 'Discount', 'Profit']

# Verify all columns exist
print("\nChecking columns...")
all_cols = customer_cols + product_cols + order_cols
missing_cols = [col for col in all_cols if col not in df.columns]

if missing_cols:
    print("Error: The following columns are missing from the file:")
    for col in missing_cols:
        print(f"   - '{col}'")
    print(f"\nAvailable columns in file: {df.columns.tolist()}")
else:
    print("All required columns found!")
    
    # Create the three files
    print("\nCreating files...")
    
    # Customer details
    df[customer_cols].drop_duplicates(subset=['Customer ID']).to_csv(
        'customer_details.csv', index=False, encoding='utf-8'
    )
    print("customer_details.csv created")
    
    # Product details
    df[product_cols].drop_duplicates(subset=['Product ID']).to_csv(
        'product_details.csv', index=False, encoding='utf-8'
    )
    print("product_details.csv created")
    
    # Order details
    df[order_cols].sort_values('Order ID').to_csv(
        'order_details.csv', index=False, encoding='utf-8'
    )
    print("order_details.csv created")
    
    # Summary
    print(f"\n Summary:")
    print(f"   - Customers: {df['Customer ID'].nunique():,}")
    print(f"   - Products: {df['Product ID'].nunique():,}")
    print(f"   - Orders: {len(df):,}")
