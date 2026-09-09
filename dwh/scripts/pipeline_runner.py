"""
===============================================================================
Master Data Pipeline Orchestrator & Data Quality Runner
===============================================================================
Script Purpose:
    Orchestrates the end-to-end Data Warehouse ETL pipeline:
    1. CSV Standardization
    2. SQL Server Ingestion & Transformations (Bronze -> Silver -> Gold)
    3. Automated Data Quality Checks (PrimaryKey, Null & Integrity checks)
    4. Audit Metadata Reporting (Queries audit.etl_log)

Usage:
    python dwh/scripts/pipeline_runner.py
===============================================================================
"""

import os
import sys
import schedule
import time
import datetime
import subprocess

# Import pandas and pyodbc
try:
    import pandas as pd
    
except ImportError:
    print("[-] pandas is required. Install via: pip install pandas")
    sys.exit(1)

try:
    import pyodbc

except ImportError:
    print("[-] pyodbc is required for SQL Server connection. Install via: pip install pyodbc")
    pyodbc = None

# Configuration
DB_CONFIG = {
    "server": r"localhost\SQLEXPRESS", # Update with SQL Server instance name, e.g., 'localhost\SQLEXPRESS' or '.'
    "database": "IndianCustomerShoppingTrendsDW",
    "trusted_connection": "yes",
    "driver": "{ODBC Driver 17 for SQL Server}" # Adjust driver if using Driver 18
}

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
PROJECT_ROOT = os.path.abspath(os.path.join(SCRIPT_DIR, "..", ".."))
RENAME_COLUMNS_SCRIPT = os.path.abspath(os.path.join(SCRIPT_DIR, "rename_columns.py"))

# Reusable Headers and Steps Formatting
def print_header(title):
    print("\n" + "=" * 80)
    print(f"  {title}")
    print("=" * 80)

def print_step(step_num, title):
    print(f"\n>>> Step {step_num} - {title}")
    print("-" * 60)

# Database Connection
def get_db_connection():
    "Establishes connection to MS SQL Server."
    if pyodbc is None:
        raise Exception("pyodbc library not installed.")
    
    conn_str = (
        f"DRIVER={DB_CONFIG['driver']};"
        f"SERVER={DB_CONFIG['server']};"
        f"DATABASE={DB_CONFIG['database']};"
        f"Trusted_Connection={DB_CONFIG['trusted_connection']};"
    )

    # Connect the database and auto commit the statements
    return pyodbc.connect(conn_str, autocommit=True)

# Create connection to the database
def create_connection():
    """Creates a connection to the database."""
    try:
        conn = get_db_connection()
        cursor = conn.cursor()

        return conn, cursor
    except Exception as e:
        print(f"[-] Database connection error: {e}")
        return None, None

# Close the database connection
def close_connection(conn, cursor):
    """Closes the database connection."""
    try:
        cursor.close()
        conn.close()
    except Exception as e:
        print(f"[-] Database connection error: {e}")

# STEP 1: Pre-processing Source CSV Files (Python Pandas)
def csv_preprocessing():
    """Step 1: Standardize raw CSV column names."""
    print_step(1, "Pre-processing Source CSV Files (Python Pandas)")
    raw_csv = os.path.join(PROJECT_ROOT, "datasets", "customer_shopping_behavior.csv")
    renamed_csv = os.path.join(PROJECT_ROOT, "datasets", "customer_shopping_behavior_renamed_columns.csv")

    if not os.path.exists(RENAME_COLUMNS_SCRIPT):
        print(f"[-] Rename columns script not found at: {RENAME_COLUMNS_SCRIPT}")
        return False

    print(f"[*] Executing Script: {RENAME_COLUMNS_SCRIPT}")
    
    # runs the external script
    result = subprocess.run([sys.executable, RENAME_COLUMNS_SCRIPT], capture_output=True, text=True)

    # checks if the script ran successfully
    if result.returncode == 0: 
        print("[+] CSV Pre-processing completed successfully.")
        print(result.stdout)
        return True
    else:
        print("[-] CSV Pre-processing failed.")
        print(result.stderr)
        return False

# STEP 2
def execute_sql_pipeline():
    """Step 2: Trigger SQL Stored Procedures for Bronze & Silver layers."""
    print_step(2, "Triggering Database Stored Procedures (Bronze -> Silver)")
    
    try:
        conn, cursor = create_connection()

        print("[*] Executing Procedure: bronze.load_bronze...")
        cursor.execute("EXEC bronze.load_bronze;") # sends the SQL query/precedure to SQL Server to execute.
        print("[+] Bronze Layer load executed successfully.")

        print("[*] Executing Procedure: silver.load_silver...")
        cursor.execute("EXEC silver.load_silver;")
        print("[+] Silver Layer load executed successfully.")

        close_connection(conn, cursor)
        return True
    except Exception as e:
        print(f"[-] SQL Pipeline Execution Error: {e}")
        return False

# STEP 3: DATA QUALITY CHECKS
def data_quality_assertions():
    """Step 3: Run Automated Data Quality Checks."""
    print_step(3, "Running Data Quality & Reliability Assertions")
    
    try:
        conn, cursor = create_connection()

        # Quality Check 1: Null Transaction IDs in Silver
        cursor.execute("SELECT COUNT(*) FROM silver.csti_customer_shopping_behavior WHERE transaction_id IS NULL;")

        # fetchone() returns tuple
        null_tx_count = cursor.fetchone()[0]
        if null_tx_count > 0:
            raise Exception(f"QUALITY FAILURE: Found {null_tx_count} NULL transaction_ids in Silver layer!")
        print("  [+] Pass: Zero NULL transaction_ids in Silver Layer.")

        # Quality Check 2: Duplicate Transaction IDs in Silver
        cursor.execute("""
            SELECT transaction_id, COUNT(*) 
            FROM silver.csti_customer_shopping_behavior 
            GROUP BY transaction_id 
            HAVING COUNT(*) > 1;
        """)

        dups = cursor.fetchall()
        if len(dups) > 0:
            raise Exception(f"QUALITY FAILURE: Found {len(dups)} duplicate transaction_ids in Silver layer!")
        print("  [+] Pass: Primary Key Uniqueness verified for transaction_id.")

        # Quality Check 3: Row Count Match between Bronze & Silver
        cursor.execute("SELECT COUNT(*) FROM bronze.csti_customer_shopping_behavior;")
        bronze_count = cursor.fetchone()[0]
        cursor.execute("SELECT COUNT(*) FROM silver.csti_customer_shopping_behavior;")
        silver_count = cursor.fetchone()[0]

        print(f"  [i] Bronze Row Count: {bronze_count} | Silver Row Count: {silver_count}")
        if bronze_count != silver_count:
            print("  [!] WARNING: Row count mismatch between Bronze and Silver layer!")
        else:
            print("  [+] Pass: Row counts match perfectly across Bronze and Silver.")

        close_connection(conn, cursor)
        return True
    except Exception as e:
        print(f"[-] Data Quality Verification Failed: {e}")
        return False

# STEP 4 AUDIT SUMMARY
def audit_summary_report():
    """Step 4: Fetch and display recent ETL audit logs."""
    print_step(4, "ETL Audit & Metadata Execution Summary")
    
    try:
        conn, cursor = create_connection()
        
        cursor.execute("""
            SELECT TOP 10 log_id, process_name, schema_name, processed_records, status, duration_seconds, created_at 
            FROM audit.etl_log 
            ORDER BY log_id DESC;
        """)
        rows = cursor.fetchall()
        
        if not rows:
            print("[!] No audit logs found in audit.etl_log.")
            return

        print(f"{'LogID':<8} | {'Process':<15} | {'Schema':<10} | {'Records':<10} | {'Status':<10} | {'Duration(s)':<12}")
        print("-" * 78)
        for r in rows:
            print(f"{r[0]:<8} | {r[1]:<15} | {r[2]:<10} | {str(r[3]):<10} | {r[4]:<10} | {str(r[5]):<12}")

        close_connection(conn, cursor)
        return True
    except Exception as e:
        print(f"[-] Unable to fetch audit summary: {e}")

# STEP 5: Main Orchestration Function - Only executes when this script is run directly
def main():
    start_time = time.time()
    print_header("STARTING DATA PIPELINE ORCHESTRATION RUNNER")

    # STEP 1: Pre-process CSV
    if not csv_preprocessing():
        print("[-] Pipeline aborted at Step 1.")
        return

    # STEP 2: Run SQL Stored Procedures
    if not execute_sql_pipeline():
        print("[-] Pipeline aborted at Step 2.")
        return

    # STEP 3: Run Data Quality Checks
    if not data_quality_assertions():
        print("[-] Pipeline aborted at Step 3 (Quality Checks Failed).")
        return

    # STEP 4: Audit Log Summary
    audit_summary_report()

    total_duration = round(time.time() - start_time, 2)
    print_header(f"PIPELINE COMPLETED SUCCESSFULLY IN {total_duration} SECONDS")

if __name__ == "__main__":
    print("[*] Starting Data Pipeline Scheduler...")
    # Run once immediately on launch
    main()

    # Schedule pipeline execution
    schedule.every(24).hours.do(main)

    print("\n[*] Scheduler active. Checking for pending jobs every 24 hours... (Press Ctrl+C to stop)")
    while True:
        # Checks the scheduled job time
        schedule.run_pending()
        time.sleep(1) # delay a scheduled job check for one second

